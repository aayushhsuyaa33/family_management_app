import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

part 'pick_image_state.dart';

class PickImageCubit extends Cubit<PickImageState> {
  PickImageCubit()
    : super(PickImageState(pickingState: PickingState.initalPicking));

  final ImagePicker picker = ImagePicker();

  Future<void> pickImage(ImageSource source) async {
    final picking = await picker.pickImage(source: source);
    if (picking == null) return;
    emit(
      state.copyWith(
        pickedFile: picking,
        errorMsg: "Image Picked Sucessfully",
        pickingState: PickingState.picked,
      ),
    );
  }

  void resetPickState() {
    emit(
      state.copyWith(
        pickingState: PickingState.initalPicking, // or whatever default
        pickedFile: null,
      ),
    );
  }
}







// void deleteImage(int index) {
  //   emit(
  //     state.copyWith(
  //       pickingState: PickingState.imageDeleted,
  //       errorMsg: "Image Deleted Successfully",
  //     ),
  //   );
  //   state.pickedFile!.removeAt(index);
  // }

  // void resetPickState() {
  //   emit(
  //     state.copyWith(
  //       pickingState: PickingState.initPicking, // or whatever default
  //       pickedFile: null,
  //     ),
  //   );
  // }