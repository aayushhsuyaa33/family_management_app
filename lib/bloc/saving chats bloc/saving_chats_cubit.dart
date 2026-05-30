import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:family_management_app/app/api/api_routes.dart';
import 'package:family_management_app/service/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

part 'saving_chats_state.dart';

class SavingChatsCubit extends Cubit<SavingChatsState> {
  SavingChatsCubit() : super(SavingChatsState(status: ChatStatus.initial));
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final ScrollController scrollController = ScrollController();

  bool _cancelReply = false;

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _cancelReply = false;

    final updatedMessages = List<Map<String, dynamic>>.from(state.messages!)
      ..add({"role": "user", "content": text});

    emit(state.copyWith(messages: updatedMessages, status: ChatStatus.sending));
    _scrollToBottom();

    final reply = await _getChatGptReply(text);

    // Add empty AI message first
    updatedMessages.add({"role": "ai", "content": ""});
    emit(
      state.copyWith(
        messages: List.from(updatedMessages),

        isTyping: true,
        status: ChatStatus.typing,
      ),
    );

    _cancelReply = false; // reset cancel flag

    // Typing animation
    for (int i = 0; i < reply.length; i++) {
      if (_cancelReply) {
        updatedMessages[updatedMessages.length - 1]["content"] =
            '${updatedMessages.last["content"] ?? ""}\n...[stopped]';
        emit(
          state.copyWith(messages: List.from(updatedMessages), isTyping: false),
        );
        break;
      }

      await Future.delayed(const Duration(milliseconds: 5)); // typing speed

      // Append next character
      final newContent = (updatedMessages.last["content"] ?? "") + reply[i];
      updatedMessages[updatedMessages.length - 1] = {
        "role": "ai",
        "content": newContent,
      };

      emit(
        state.copyWith(messages: List.from(updatedMessages), isTyping: true),
      );
      // _scrollToBottom();
    }

    // Finish typing
    emit(
      state.copyWith(
        messages: List.from(updatedMessages),
        isTyping: false,
        status: ChatStatus.success,
      ),
    );

    _scrollToBottom();
    await _saveMessagesToFirestore(text, reply);
  }

  Future<String> _getChatGptReply(String message) async {
    try {
      final url = Uri.parse(ApiRoutes.baseUrl + ApiRoutes.chatUrl);
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return (data['reply'] ?? "AI did not respond.").toString().trim();
      } else {
        return "Error: ${res.statusCode}";
      }
    } catch (e) {
      return "Unexpected Error: $e";
    }
  }

  Future<void> _saveMessagesToFirestore(
    String userMessage,
    String aiReply,
  ) async {
    String chatId = state.chatId ?? await _createNewChat();
    final String? userId = await AppStorage.read(key: "uid");

    // Save user message
    await firestore.collection("chats").doc(chatId).collection('messages').add({
      "role": "user",
      "content": userMessage,
      "timestamp": FieldValue.serverTimestamp(),
    });

    // Save AI message
    await firestore.collection("chats").doc(chatId).collection('messages').add({
      "role": "ai",
      "content": aiReply,
      "timestamp": FieldValue.serverTimestamp(),
    });

    // Generate chat title from last 3 messages
    final title = await _generateChatTitle(chatId);

    // Update chat document
    await firestore.collection('chats').doc(chatId).set({
      "title": title,
      "lastUpdated": FieldValue.serverTimestamp(),
      "autoTitleGenerated": true,
      'userId': userId,
      "createdAt": FieldValue.serverTimestamp(),
      'id': chatId,
    }, SetOptions(merge: true));

    emit(state.copyWith(chatId: chatId, chatTitle: title));
  }

  Future<String> _createNewChat() async {
    final String? userId = await AppStorage.read(key: "uid");
    final docRef = firestore.collection('chats').doc();
    await docRef.set({
      "title": "New Chat",
      "createdAt": FieldValue.serverTimestamp(),
      "autoTitleGenerated": false,
      'email': userId,
    });
    return docRef.id;
  }

  Future<String> _generateChatTitle(String chatId) async {
    final messages = await firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .limit(4)
        .get();

    final msgList = messages.docs
        .map((doc) => doc.data())
        .toList()
        .reversed
        .toList();

    if (msgList.isEmpty) return "New Chat";

    final prompt =
        """
Analyze the following conversation and generate a concise 3-5 word title  and dont ever include double quotation:
${msgList.map((m) => "${m['role']}: ${m['content']}").join("\n")}
""";

    final title = await _getChatGptReply(prompt);
    return title;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void stopReply() {
    _cancelReply = true;
    emit(
      state.copyWith(
        isLoading: false,
        isTyping: false,
        status: ChatStatus.failure,
      ),
    );
  }

  void resetChat() {
    emit(
      SavingChatsState(
        messages: [],
        chatId: null,
        chatTitle: null,
        isLoading: false,
        isTyping: false,
        status: ChatStatus.initial,
      ),
    );
  }

  Future<void> loadExistingChat(String chatId) async {
    emit(state.copyWith(isLoading: true, status: ChatStatus.fetching));

    try {
      final messagesSnapshot = await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp')
          .get();

      // Keep dynamic types (String, Timestamp, etc.)
      final messages = messagesSnapshot.docs.map((doc) => doc.data()).toList();

      emit(
        state.copyWith(
          messages: messages,
          isLoading: false,
          chatId: chatId,
          status: ChatStatus.fetched, // fetched = shimmer disappears
        ),
      );
    } on FirebaseException catch (exe) {
      emit(state.copyWith(status: ChatStatus.fetchingFailure, error: exe.code));
    }
  }
}
