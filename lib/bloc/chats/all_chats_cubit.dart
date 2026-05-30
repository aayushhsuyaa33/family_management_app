import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:family_management_app/service/secure_storage.dart';

part 'all_chats_state.dart';

class AllChatsCubit extends Cubit<AllChatsState> {
  AllChatsCubit()
    : super(AllChatsState(status: FetchChatStatus.initialFetching));

  StreamSubscription<QuerySnapshot>? _chatSubscription;
  Future<void> fetchChatHistory() async {
    final String? userId = await AppStorage.read(key: 'uid');
    final firestoreDoc = FirebaseFirestore.instance;
    await _chatSubscription?.cancel();
    emit(
      state.copyWith(
        status: FetchChatStatus.fetching,
        error: "History is being fetched",
      ),
    );

    try {
      _chatSubscription = firestoreDoc
          .collection('chats')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen((snapshot) {
            final chatList = snapshot.docs.map((doc) {
              return {'id': doc['id'], 'title': doc['title']};
            }).toList();

            emit(
              state.copyWith(
                chats: chatList,
                error: "Data fetched successfully",
                status: FetchChatStatus.fetched,
              ),
            );
          });
    } catch (exe) {
      emit(
        state.copyWith(
          status: FetchChatStatus.fetchingError,
          error: exe.toString(),
        ),
      );
    }
  }

  Future<void> deleteChat(String chatId) async {
    try {
      // remove from local state immediately
      final updatedChats = List<Map<String, dynamic>>.from(state.chats!)
        ..removeWhere((chat) => chat['id'] == chatId);

      emit(state.copyWith(chats: updatedChats));

      // then delete from Firestore
      await FirebaseFirestore.instance.collection("chats").doc(chatId).delete();
    } catch (e) {
      log("Error deleting chat: $e");
    }
  }

  Future<void> renameChat(String chatId, String newTitle) async {
    try {
      // update local state first
      final updatedChats = state.chats!.map<Map<String, dynamic>>((chat) {
        if (chat['id'] == chatId) {
          return {...chat, 'title': newTitle};
        }
        return chat;
      }).toList();

      emit(state.copyWith(chats: updatedChats));

      // then update Firestore
      await FirebaseFirestore.instance.collection("chats").doc(chatId).update({
        "title": newTitle,
      });
    } catch (e) {
      log("Error renaming chat: $e");
    }
  }
}
