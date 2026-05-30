import 'dart:developer';
import 'package:family_management_app/app/app%20Color/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CropImage extends StatefulWidget {
  final XFile pickedFile;
  const CropImage({super.key, required this.pickedFile});

  @override
  State<CropImage> createState() => _CropImageState();
}

class _CropImageState extends State<CropImage> {
  @override
  void initState() {
    super.initState();
    cropImage(context);
  }

  Future<void> cropImage(context) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: widget.pickedFile.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: "Crop Image",
          backgroundColor: AppColor.background,
          initAspectRatio: CropAspectRatioPreset.square,
          cropStyle: CropStyle.rectangle,
          statusBarColor: AppColor.secondary,
          lockAspectRatio: false,
          toolbarColor: AppColor.border,
        ),
      ],
    );

    if (croppedFile != null) {
      log("🚀 Cropped file ready: ${croppedFile.path}");
      Navigator.pop(context, XFile(croppedFile.path));
      // Navigator.pop(context, XFile(croppedFile.path));
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: LoadingAnimationWidget.inkDrop(
          color: AppColor.dropDownColor,
          size: 100.h,
        ),
      ),
    );
  }
}
