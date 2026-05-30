part of 'add_tasks_cubit.dart';

enum AddRequestStatus { initial, loading, success, failure }

class AddTasksState extends Equatable {
  final AddRequestStatus taskPostingStatus;
  final AddRequestStatus childPostingStatus;
  final AddRequestStatus deletingStatus;
  final AddRequestStatus markingStatus;
  final AddRequestStatus eventPostingStatus;
  final AddRequestStatus sendInviteLinkStatus;

  final AddRequestStatus addLeadStatus;
  final AddRequestStatus fetchLeadStatus;

  final String? errorMsg;
  final String? taskId;
  final List<TaskInfo>? tasks;
  final List<AllUserInfo>? userInfo;
  final bool hasShownDialog;

  const AddTasksState({
    this.taskPostingStatus = AddRequestStatus.initial,
    this.childPostingStatus = AddRequestStatus.initial,
    this.deletingStatus = AddRequestStatus.initial,
    this.markingStatus = AddRequestStatus.initial,
    this.eventPostingStatus = AddRequestStatus.initial,
    this.addLeadStatus = AddRequestStatus.initial,
    this.fetchLeadStatus = AddRequestStatus.initial,
    this.sendInviteLinkStatus = AddRequestStatus.initial,

    this.errorMsg,
    this.taskId,
    this.tasks,
    this.userInfo,
    this.hasShownDialog = false,
  });
  AddTasksState copyWith({
    AddRequestStatus? taskPostingStatus,
    AddRequestStatus? childPostingStatus,
    AddRequestStatus? deletingStatus,
    AddRequestStatus? markingStatus,
    AddRequestStatus? eventPostingStatus,
    AddRequestStatus? sendInviteLinkStatus,

    AddRequestStatus? addLeadStatus,
    AddRequestStatus? fetchLeadStatus,

    String? errorMsg,
    String? taskId,
    List<TaskInfo>? tasks,
    List<AllUserInfo>? userInfo,
    bool? hasShownDialog,
  }) {
    return AddTasksState(
      taskPostingStatus: taskPostingStatus ?? this.taskPostingStatus,
      childPostingStatus: childPostingStatus ?? this.childPostingStatus,
      deletingStatus: deletingStatus ?? this.deletingStatus,
      markingStatus: markingStatus ?? this.markingStatus,
      eventPostingStatus: eventPostingStatus ?? this.eventPostingStatus,
      sendInviteLinkStatus: sendInviteLinkStatus ?? this.sendInviteLinkStatus,
      addLeadStatus: addLeadStatus ?? this.addLeadStatus,
      fetchLeadStatus: fetchLeadStatus ?? this.fetchLeadStatus,

      errorMsg: errorMsg ?? this.errorMsg,
      taskId: taskId ?? this.taskId,
      tasks: tasks ?? this.tasks,
      userInfo: userInfo ?? this.userInfo,
      hasShownDialog: hasShownDialog ?? this.hasShownDialog,
    );
  }

  @override
  List<Object?> get props => [
    taskPostingStatus,
    childPostingStatus,
    deletingStatus,
    markingStatus,
    eventPostingStatus,
    sendInviteLinkStatus,
    addLeadStatus,
    fetchLeadStatus,

    errorMsg,
    taskId,
    tasks,
    userInfo,
    hasShownDialog,
  ];
}
