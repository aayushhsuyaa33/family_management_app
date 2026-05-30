part of 'fetch_notifications_cubit.dart';

enum FetchNotificationStatus { initial, loading, success, failed }

class FetchNotificationsState extends Equatable {
  final FetchNotificationStatus notifiactionStatus;
  final FetchNotificationStatus notifiactionStatusMember;
  final String? errorMsg;
  final List<Map<String, dynamic>>? notificationList;
  final List<Map<String, dynamic>>? notificationListMember;
  const FetchNotificationsState({
    this.notifiactionStatus = FetchNotificationStatus.initial,
    this.notifiactionStatusMember = FetchNotificationStatus.initial,
    this.errorMsg,
    this.notificationList,
    this.notificationListMember,
  });

  FetchNotificationsState copyWith({
    FetchNotificationStatus? notifiactionStatus,
    String? errorMsg,
    List<Map<String, dynamic>>? notificationList,
    List<Map<String, dynamic>>? notificationListMember,
    FetchNotificationStatus? notifiactionStatusMember,
  }) {
    return FetchNotificationsState(
      errorMsg: errorMsg ?? this.errorMsg,
      notifiactionStatus: notifiactionStatus ?? this.notifiactionStatus,
      notificationList: notificationList ?? this.notificationList,
      notifiactionStatusMember:
          notifiactionStatusMember ?? this.notifiactionStatusMember,
      notificationListMember:
          notificationListMember ?? this.notificationListMember,
    );
  }

  @override
  List<Object?> get props => [
    errorMsg,
    notifiactionStatus,
    notificationList,
    notifiactionStatusMember,
    notificationListMember,
  ];
}
