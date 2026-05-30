import 'package:family_management_app/app/app%20Color/app_color.dart';
import 'package:family_management_app/app/utils/custom_appbar.dart';
import 'package:family_management_app/app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class EditMember extends StatefulWidget {
  final String? uid;
  const EditMember({super.key, this.uid});

  @override
  State<EditMember> createState() => _EditMemberState();
}

class _EditMemberState extends State<EditMember> {
  TextEditingController userNameController = TextEditingController();
  TextEditingController userEmailController = TextEditingController();
  String? errorName;
  XFile? pickedImage;
  String? emailError;

  void _validateName(String value) {
    if (userNameController.text.isEmpty) {
      errorName = "Name is required";
    } else {
      errorName = null;
    }
    setState(() {});
  }

  void _validateEmail(String value) {
    String emailPattern = r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$';
    if (value.isEmpty) {
      emailError = "Email is required";
    } else if (!RegExp(emailPattern).hasMatch(value)) {
      emailError = "Enter a valid email";
    } else {
      emailError = null;
    }
    setState(() {});
  }

  Future<void> pickImageAndCrop(ImageSource source) async {
    final ImagePicker picker = ImagePicker();

    final XFile? pickedFile = await picker.pickImage(source: source);
    if (pickedFile == null) return;

    final CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: "Crop Image",
          toolbarColor: AppColor.background, // Dark navy blue
          toolbarWidgetColor: AppColor.textSecondary, // White
          backgroundColor: AppColor.background, // Dark navy
          statusBarColor: AppColor.background, // Slightly lighter navy
          activeControlsWidgetColor: AppColor.secondary, // Gold highlight
          initAspectRatio: CropAspectRatioPreset.square,
          cropStyle: CropStyle.rectangle,
          lockAspectRatio: false,
        ),
        IOSUiSettings(title: "Crop Image"),
      ],
    );

    if (croppedFile == null) return;
    setState(() {
      pickedImage = XFile(croppedFile.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyCustomAppBar(heading: "Edit Member "),
      body: SafeArea(
        child: Column(
          children: [
            imageHolderWithPlus(
              imagePath: pickedImage,
              onPressed: () {
                showImagePickerAlert(
                  context: context,
                  onCameraTap: () async {
                    pickImageAndCrop(ImageSource.camera);
                  },
                  onGalleryTap: () async {
                    pickImageAndCrop(ImageSource.gallery);
                  },
                );
              },
            ),
            SizedBox(height: 15.h),
            MyTextField(
              userController: userNameController,
              hint: "Name ",
              frontIcon: Icons.perm_identity_outlined,
              isHide: false,
              errorMsg: errorName,
              onPasswordIconClicked: () {},
              onChangedValue: _validateName,
            ),

            MyTextField(
              userController: userEmailController,
              hint: "Email",
              frontIcon: Icons.email_outlined,
              isHide: false,
              onPasswordIconClicked: () {},
              errorMsg: emailError,
              onChangedValue: _validateEmail,
            ),
          ],
        ),
      ),
    );
  }
}
