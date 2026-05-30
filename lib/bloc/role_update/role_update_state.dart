part of 'role_update_cubit.dart';

enum RoleUpdatingStatus { initial, loading, sucess, failed }

class RoleUpdateState extends Equatable {
  final RoleUpdatingStatus updatingChiefStatus;
  final RoleUpdatingStatus updatingMemberStatus;
  final String? errorMsg;
  final String? boardTitle;
  final String? boardDescription;
  final String? boardId;
  final String? boardNickname;
  final String? role;
  final bool isGoogle;
  final String? uid;

  const RoleUpdateState({
    this.errorMsg,
    this.updatingChiefStatus = RoleUpdatingStatus.initial,
    this.updatingMemberStatus = RoleUpdatingStatus.initial,
    this.uid,
    this.boardDescription,
    this.boardTitle,
    this.boardId,
    this.boardNickname,
    this.role,
    this.isGoogle = false,
  });

  RoleUpdateState copyWith({
    RoleUpdatingStatus? updatingChiefStatus,
    RoleUpdatingStatus? updatingMemberStatus,
    String? errorMsg,
    String? uid,
    String? boardTitle,
    String? boardDescription,
    String? boardId,
    String? boardNickname,
    String? role,
    bool? isGoogle,
  }) {
    return RoleUpdateState(
      errorMsg: errorMsg ?? this.errorMsg,
      uid: uid ?? this.uid,

      updatingChiefStatus: updatingChiefStatus ?? this.updatingChiefStatus,
      updatingMemberStatus: updatingMemberStatus ?? this.updatingMemberStatus,
      boardDescription: boardDescription ?? this.boardDescription,
      boardTitle: boardTitle ?? this.boardTitle,
      boardId: boardId ?? this.boardId,
      boardNickname: boardNickname ?? this.boardNickname,
      role: role ?? this.role,
      isGoogle: isGoogle ?? this.isGoogle,
    );
  }

  @override
  List<Object?> get props => [
    updatingChiefStatus,
    updatingMemberStatus,
    errorMsg,
    uid,
    boardDescription,
    boardTitle,
    boardId,
    boardNickname,
    role,
    isGoogle,
  ];
}
