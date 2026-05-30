part of 'voice_command_cubit.dart';

enum VoiceCommandStatus { initial, loading, success, failure }

class VoiceCommandState extends Equatable {
  final VoiceCommandStatus checkingMemberStatus;
  final VoiceCommandStatus fetchUserInfoStatus;
  final String? errorMessage;
  final List<AllUserInfo>? userInfo;

  const VoiceCommandState({
    this.checkingMemberStatus = VoiceCommandStatus.initial,
    this.errorMessage,
    this.userInfo,
    this.fetchUserInfoStatus = VoiceCommandStatus.initial,
  });

  VoiceCommandState copyWith({
    VoiceCommandStatus? checkingMemberStatus,
    String? errorMessage,
    List<AllUserInfo>? userInfo,
    VoiceCommandStatus? processVoiceCommandStatus,
    VoiceCommandStatus? fetchUserInfoStatus,
  }) {
    return VoiceCommandState(
      checkingMemberStatus: checkingMemberStatus ?? this.checkingMemberStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      userInfo: userInfo ?? this.userInfo,
      fetchUserInfoStatus: fetchUserInfoStatus ?? this.fetchUserInfoStatus,
    );
  }

  @override
  List<Object?> get props => [
    checkingMemberStatus,
    errorMessage,
    userInfo,
    fetchUserInfoStatus,
  ];
}
