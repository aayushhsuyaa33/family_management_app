part of 'pick_image_cubit.dart';

enum PickingState {
  initalPicking,
  picking,
  picked,
  pickingFailed,

  uploading,
  uploaded,
  uploadingFailure,
}

class PickImageState extends Equatable {
  final XFile? pickedFile;
  final PickingState? pickingState;
  final String? errorMsg;

  const PickImageState({this.pickedFile, this.pickingState, this.errorMsg});

  PickImageState copyWith({
    XFile? pickedFile,
    PickingState? pickingState,
    String? errorMsg,
  }) {
    return PickImageState(
      pickedFile: pickedFile ?? this.pickedFile,
      pickingState: pickingState ?? this.pickingState,
      errorMsg: errorMsg ?? this.errorMsg,
    );
  }

  @override
  List<Object?> get props => [pickedFile, pickingState, errorMsg];
}
