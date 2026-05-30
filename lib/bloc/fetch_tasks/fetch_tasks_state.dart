part of 'fetch_tasks_cubit.dart';

enum FetchTaskStatus { initial, loading, sucess, failed }

class FetchTasksState extends Equatable {
  final FetchTaskStatus fetchPendingTaskForHomPageStatus;
  final FetchTaskStatus fetchPendingEventForHomPageStatus;
  final FetchTaskStatus fetchTasksStatus;
  final FetchTaskStatus deleteTaskStatus;
  final FetchTaskStatus markAsDoneStatus;

  final FetchTaskStatus getDateAndRoleForCalanderStatus;
  final FetchTaskStatus getDateAndTimeForChildScheduleStatus;
  final FetchTaskStatus fetchtaskInfo;

  final String? errorMsg;
  final int? taskCount;
  final List<TaskInfo>? taskInfoList;
  final List<TaskInfo>? taskInfoListEdit;
  final List<ClassSchedule>? classSchedule;
  final String? taskId;
  final int? urgentCount;
  final List<TaskInfo>? mergedList;

  final int? upcomingEvent;
  final int? todayEvent;

  const FetchTasksState({
    this.fetchPendingTaskForHomPageStatus = FetchTaskStatus.initial,
    this.fetchPendingEventForHomPageStatus = FetchTaskStatus.initial,
    this.fetchtaskInfo = FetchTaskStatus.initial,

    this.fetchTasksStatus = FetchTaskStatus.initial,
    this.deleteTaskStatus = FetchTaskStatus.initial,
    this.markAsDoneStatus = FetchTaskStatus.initial,

    this.getDateAndRoleForCalanderStatus = FetchTaskStatus.initial,
    this.getDateAndTimeForChildScheduleStatus = FetchTaskStatus.initial,

    this.errorMsg,
    this.taskCount,
    this.taskInfoList,
    this.taskId,
    this.classSchedule,
    this.urgentCount,
    this.upcomingEvent,
    this.todayEvent,
    this.mergedList,
    this.taskInfoListEdit,
  });

  FetchTasksState copyWith({
    FetchTaskStatus? fetchPendingTaskForHomPageStatus,
    FetchTaskStatus? fetchPendingEventForHomPageStatus,
    FetchTaskStatus? fetchTasksStatus,
    FetchTaskStatus? deleteTaskStatus,
    FetchTaskStatus? markAsDoneStatus,
    FetchTaskStatus? fetchtaskInfo,

    FetchTaskStatus? getDateAndRoleForCalanderStatus,
    FetchTaskStatus? getDateAndTimeForChildScheduleStatus,
    String? errorMsg,
    int? taskCount,
    List<TaskInfo>? taskInfoList,
    List<TaskInfo>? taskInfoListEdit,
    List<TaskInfo>? mergedList,
    String? taskId,
    int? urgentCount,
    List<ClassSchedule>? classSchedule,
    int? upcomingEvent,
    int? todayEvent,
  }) {
    return FetchTasksState(
      fetchPendingTaskForHomPageStatus:
          fetchPendingTaskForHomPageStatus ??
          this.fetchPendingTaskForHomPageStatus,
      fetchPendingEventForHomPageStatus:
          fetchPendingEventForHomPageStatus ??
          this.fetchPendingEventForHomPageStatus,
      fetchTasksStatus: fetchTasksStatus ?? this.fetchTasksStatus,
      deleteTaskStatus: deleteTaskStatus ?? this.deleteTaskStatus,
      markAsDoneStatus: markAsDoneStatus ?? this.markAsDoneStatus,
      fetchtaskInfo: fetchtaskInfo ?? this.fetchtaskInfo,
      taskInfoListEdit: taskInfoListEdit ?? this.taskInfoListEdit,

      getDateAndRoleForCalanderStatus:
          getDateAndRoleForCalanderStatus ??
          this.getDateAndRoleForCalanderStatus,
      getDateAndTimeForChildScheduleStatus:
          getDateAndTimeForChildScheduleStatus ??
          this.getDateAndTimeForChildScheduleStatus,

      errorMsg: errorMsg ?? this.errorMsg,
      taskCount: taskCount ?? this.taskCount,
      taskInfoList: taskInfoList ?? this.taskInfoList,
      mergedList: mergedList ?? this.mergedList,
      taskId: taskId ?? this.taskId,
      urgentCount: urgentCount ?? this.urgentCount,
      classSchedule: classSchedule ?? this.classSchedule,
      upcomingEvent: upcomingEvent ?? this.upcomingEvent,
      todayEvent: todayEvent ?? this.todayEvent,
    );
  }

  @override
  List<Object?> get props => [
    fetchPendingTaskForHomPageStatus,
    fetchPendingEventForHomPageStatus,
    fetchtaskInfo,
    fetchTasksStatus,
    deleteTaskStatus,
    markAsDoneStatus,
    getDateAndRoleForCalanderStatus,
    getDateAndTimeForChildScheduleStatus,
    errorMsg,
    taskCount,
    taskInfoList,
    taskId,
    urgentCount,
    classSchedule,
    todayEvent,
    upcomingEvent,
    mergedList,
    taskInfoListEdit,
  ];
}

class TaskInfo {
  String title;
  String taskId;
  String description;
  String priority;
  String date;
  String? time;
  String? assignedTo;
  bool isChecked;
  String? role;
  String? imagePath;
  bool isGoogleCal;
  String? assignedEmail;
  TaskInfo({
    required this.title,
    required this.taskId,
    required this.description,
    required this.priority,
    required this.date,
    this.assignedTo,
    this.role,
    this.isChecked = false,
    this.imagePath,
    this.time,
    this.isGoogleCal = false,
    this.assignedEmail,
  });
}

class ClassSchedule {
  final String title;
  final DateTime date;
  final String? assignedTo;
  final String? imagePath;
  final String? id;

  ClassSchedule({
    required this.title,
    required this.date,
    this.assignedTo,
    this.imagePath,
    this.id,
  });
}
