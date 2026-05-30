part of 'saving_chats_cubit.dart';

enum ChatStatus {
  initial,
  sending,
  typing,
  success,
  failure,

  fetching,
  fetched,
  fetchingFailure,
}

class SavingChatsState extends Equatable {
  final List<Map<String, dynamic>>? messages;
  final bool isLoading;
  final bool isTyping;
  final String? chatId;
  final String? chatTitle;
  final ChatStatus status;
  final String? error;

  const SavingChatsState({
    this.messages,
    this.isLoading = false,
    this.isTyping = false,
    this.chatId,
    this.chatTitle,
    this.status = ChatStatus.initial,
    this.error,
  });

  SavingChatsState copyWith({
    List<Map<String, dynamic>>? messages,
    bool? isLoading,
    bool? isTyping,
    String? chatId,
    String? chatTitle,
    ChatStatus? status,
    String? error,
  }) {
    return SavingChatsState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isTyping: isTyping ?? this.isTyping,
      chatId: chatId ?? this.chatId,
      chatTitle: chatTitle ?? this.chatTitle,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
    messages,
    isLoading,
    isTyping,
    chatId,
    chatTitle,
    status,
    error,
  ];
}
