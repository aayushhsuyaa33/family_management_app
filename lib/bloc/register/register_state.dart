part of 'register_cubit.dart';

enum RegisterStatus {
  initialregister,
  registering,
  registered,
  registerFailure,
}

class RegisterState extends Equatable {
  final RegisterStatus status;
  final RegisterStatus fetchMemberStatus;
  final RegisterStatus loginStatus;
  final String? errorMsg;
  final String? uid;
  final String? name;
  final String? email;
  final String? boardId;
  final List<AllUserInfo>? userInfo;

  const RegisterState({
    this.errorMsg,
    this.status = RegisterStatus.initialregister,
    this.fetchMemberStatus = RegisterStatus.initialregister,
    this.loginStatus = RegisterStatus.initialregister,
    this.uid,
    this.name,
    this.email,
    this.boardId,
    this.userInfo,
  });

  RegisterState copyWith({
    RegisterStatus? status,
    String? errorMsg,
    String? uid,
    String? name,
    String? email,
    String? boardId,
    RegisterStatus? fetchMemberStatus,
    RegisterStatus? loginStatus,
    List<AllUserInfo>? userInfo,
  }) {
    return RegisterState(
      errorMsg: errorMsg ?? this.errorMsg,
      uid: uid ?? this.uid,
      status: status ?? this.status,
      name: name ?? this.name,
      email: email ?? this.email,
      boardId: boardId ?? this.boardId,
      fetchMemberStatus: fetchMemberStatus ?? this.fetchMemberStatus,
      userInfo: userInfo ?? this.userInfo,
      loginStatus: loginStatus ?? this.loginStatus,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMsg,
    uid,
    name,
    email,
    boardId,
    fetchMemberStatus,
    userInfo,
    loginStatus,
  ];
}
