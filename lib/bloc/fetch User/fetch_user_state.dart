part of 'fetch_user_cubit.dart';

enum FetchRequestStatus { initial, loading, sucess, failed }

class FetchUserState extends Equatable {
  final FetchRequestStatus logoutStatus;
  final FetchRequestStatus fetchAllUserStatus;
  final FetchRequestStatus fetchJoinRequestForHomePageStatus;
  final FetchRequestStatus fetchJoinRequestsNotificationStatus;
  final FetchRequestStatus checkWaitingStatus;
  final FetchRequestStatus fetchCommandCenterInfoStatus;
  final FetchRequestStatus fetchProfileInfoStatus;
  final FetchRequestStatus fetchProfileInfoChildStatus;

  final FetchRequestStatus approveStatus;
  final FetchRequestStatus rejectStatus;

  final String? errorMsg;
  final String? role;
  final String? email;
  final String? name;
  final String? imagePath;
  final String? uid;
  final String? dob;
  final int? itemCount;
  final List<Map<String, dynamic>>? joinRequestList;
  final List<AllUserInfo>? userInfo;
  final ChildProfile? childInfo;
  final String? boardId;
  final String? rejectedEmail;
  final String? acceptedEmail;
  final String? roleStatus;
  final int? pendingUserCount;

  const FetchUserState({
    this.logoutStatus = FetchRequestStatus.initial,
    this.fetchAllUserStatus = FetchRequestStatus.initial,
    this.fetchJoinRequestForHomePageStatus = FetchRequestStatus.initial,
    this.fetchJoinRequestsNotificationStatus = FetchRequestStatus.initial,

    this.checkWaitingStatus = FetchRequestStatus.initial,
    this.fetchCommandCenterInfoStatus = FetchRequestStatus.initial,
    this.fetchProfileInfoStatus = FetchRequestStatus.initial,
    this.fetchProfileInfoChildStatus = FetchRequestStatus.initial,

    this.approveStatus = FetchRequestStatus.initial,
    this.rejectStatus = FetchRequestStatus.initial,

    this.errorMsg,
    this.role,
    this.dob,
    this.email,
    this.imagePath,
    this.name,
    this.userInfo,
    this.uid,
    this.joinRequestList,
    this.itemCount,
    this.boardId,
    this.rejectedEmail,
    this.acceptedEmail,
    this.roleStatus,
    this.pendingUserCount,
    this.childInfo,
  });

  FetchUserState copyWith({
    FetchRequestStatus? logoutStatus,
    FetchRequestStatus? fetchAllUserStatus,
    FetchRequestStatus? fetchJoinRequestForHomePageStatus,
    FetchRequestStatus? fetchJoinRequestsNotificationStatus,
    FetchRequestStatus? rejectStatus,
    FetchRequestStatus? approveStatus,

    FetchRequestStatus? checkWaitingStatus,
    FetchRequestStatus? fetchCommandCenterInfoStatus,
    FetchRequestStatus? fetchProfileInfoStatus,
    FetchRequestStatus? fetchProfileInfoChildStatus,

    String? errorMsg,
    String? role,
    String? email,
    String? name,
    String? imagePath,
    List<AllUserInfo>? userInfo,
    String? uid,
    int? itemCount,
    List<Map<String, dynamic>>? joinRequestList,
    String? boardId,
    String? rejectedEmail,
    String? acceptedEmail,
    String? roleStatus,
    int? pendingUserCount,
    String? dob,
    ChildProfile? childInfo,
  }) {
    return FetchUserState(
      logoutStatus: logoutStatus ?? this.logoutStatus,
      fetchAllUserStatus: fetchAllUserStatus ?? this.fetchAllUserStatus,
      fetchJoinRequestForHomePageStatus:
          fetchJoinRequestForHomePageStatus ??
          this.fetchJoinRequestForHomePageStatus,
      fetchJoinRequestsNotificationStatus:
          fetchJoinRequestsNotificationStatus ??
          this.fetchJoinRequestsNotificationStatus,

      checkWaitingStatus: checkWaitingStatus ?? this.checkWaitingStatus,
      fetchCommandCenterInfoStatus:
          fetchCommandCenterInfoStatus ?? this.fetchCommandCenterInfoStatus,
      fetchProfileInfoStatus:
          fetchProfileInfoStatus ?? this.fetchProfileInfoStatus,
      fetchProfileInfoChildStatus:
          fetchProfileInfoChildStatus ?? this.fetchProfileInfoChildStatus,
      approveStatus: approveStatus ?? this.approveStatus,
      rejectStatus: rejectStatus ?? this.rejectStatus,

      errorMsg: errorMsg ?? this.errorMsg,
      role: role ?? this.role,
      dob: dob ?? this.dob,
      email: email ?? this.email,
      name: name ?? this.name,
      userInfo: userInfo ?? this.userInfo,
      uid: uid ?? this.uid,
      imagePath: imagePath ?? this.imagePath,
      joinRequestList: joinRequestList ?? this.joinRequestList,
      itemCount: itemCount ?? this.itemCount,
      boardId: boardId ?? this.boardId,
      rejectedEmail: rejectedEmail ?? this.rejectedEmail,
      acceptedEmail: acceptedEmail ?? this.acceptedEmail,
      roleStatus: roleStatus ?? this.roleStatus,
      pendingUserCount: pendingUserCount ?? this.pendingUserCount,
      childInfo: childInfo ?? this.childInfo,
    );
  }

  @override
  List<Object?> get props => [
    logoutStatus,
    fetchAllUserStatus,
    fetchJoinRequestForHomePageStatus,
    fetchJoinRequestsNotificationStatus,

    checkWaitingStatus,
    fetchCommandCenterInfoStatus,
    fetchProfileInfoStatus,
    fetchProfileInfoChildStatus,
    rejectStatus,
    approveStatus,

    errorMsg,
    role,
    email,
    name,
    userInfo,
    uid,
    imagePath,
    joinRequestList,
    itemCount,
    boardId,
    rejectedEmail,
    acceptedEmail,
    roleStatus,
    pendingUserCount,
    dob,
    childInfo,
  ];
}

class AllUserInfo {
  final String uid;
  final String name;
  final String email;
  final String? imagePath;
  final String? role;
  final String? joinStatus;

  AllUserInfo({
    required this.uid,
    required this.email,
    required this.name,
    this.imagePath,
    this.role,
    this.joinStatus,
  });
}
