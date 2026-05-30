part of 'login_cubit.dart';

enum LoginStatus {
  initialLogin,
  logging,
  logged,
  loginFailure,
  navigateToRoleUpdate,
  isInvited,

  googleLogin,
  googleLoginFailure,
  googleLoginSuccessful,
  forgetSucessful,
  forgetting,
  forgetFailure,
}

class LoginState extends Equatable {
  final LoginStatus status;
  final String? errorMsg;
  final String? uid;
  final String? boardId;

  const LoginState({
    this.errorMsg,
    required this.status,
    this.uid,
    this.boardId,
  });

  LoginState copyWith({
    LoginStatus? status,
    String? errorMsg,
    String? uid,
    String? boardId,
  }) {
    return LoginState(
      errorMsg: errorMsg ?? this.errorMsg,
      status: status ?? this.status,
      uid: uid ?? this.uid,
      boardId: boardId ?? this.boardId,
    );
  }

  @override
  List<Object?> get props => [errorMsg, status, uid, boardId];
}
