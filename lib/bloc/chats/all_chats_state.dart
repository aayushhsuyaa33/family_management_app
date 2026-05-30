part of 'all_chats_cubit.dart';

enum FetchChatStatus {
  initialFetching,
  fetching,
  fetched,
  fetchingError,
  empty,
}

class AllChatsState extends Equatable {
  final List<Map<String, dynamic>>? chats;
  final String? error;
  final FetchChatStatus status;

  const AllChatsState({this.chats, this.error, required this.status});

  AllChatsState copyWith({
    List<Map<String, dynamic>>? chats,
    String? error,
    FetchChatStatus? status,
  }) {
    return AllChatsState(
      chats: chats ?? this.chats,
      error: error ?? this.error,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [status, chats, error];
}
