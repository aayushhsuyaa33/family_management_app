import 'dart:developer';

import 'package:family_management_app/app/app%20Color/app_color.dart';
import 'package:family_management_app/app/routes/app_routes.dart';
import 'package:family_management_app/app/textStyle/textstyles.dart';
import 'package:family_management_app/app/utils/utils.dart';
import 'package:family_management_app/bloc/register/register_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class RegisterScreen extends StatefulWidget {
  final String? uid;
  final String? boardId;
  const RegisterScreen({super.key, this.uid, this.boardId});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController userEmailController = TextEditingController();
  TextEditingController userPasswordController = TextEditingController();
  TextEditingController userPasswordConformController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  List<bool> isHide = [true, true];

  String selectedMember = "";
  bool isLoading1 = false;

  XFile? pickedImage;

  String? emailError;
  String? passwordError;
  String? confirmPasswordError;
  String? errorName;
  String? uid;
  String? existingImageUrl;
  Future<void> pickImageAndCrop(ImageSource source) async {
    final ImagePicker picker = ImagePicker();

    final XFile? pickedFile = await picker.pickImage(source: source);
    if (pickedFile == null) return;

    final CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      uiSettings: [
        AndroidUiSettings(
          hideBottomControls: false,
          showCropGrid: false,
          toolbarTitle: "Crop Image",
          toolbarColor: AppColor.background, // Dark navy blue
          toolbarWidgetColor: AppColor.textSecondary, // White
          backgroundColor: AppColor.background, // Dark navy
          statusBarColor: AppColor.background, // Slightly lighter navy
          activeControlsWidgetColor: AppColor.secondary, // Gold highlight
          initAspectRatio: CropAspectRatioPreset.square,
          cropStyle: CropStyle.circle,
          lockAspectRatio: false,
        ),
        IOSUiSettings(title: "Crop Image"),
      ],
    );
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    if (croppedFile == null) return;
    setState(() {
      pickedImage = XFile(croppedFile.path);
    });
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

  void _validatePassword(String value) {
    if (value.isEmpty) {
      passwordError = "Password is required";
    } else if (value.length < 8) {
      passwordError = "At least 8 characters";
    } else if (!RegExp(r'[A-Z]').hasMatch(value)) {
      passwordError = "At least 1 capital letter";
    } else if (!RegExp(r'[a-z]').hasMatch(value)) {
      passwordError = "At least 1 lowercase letter";
    } else if (!RegExp(r'[0-9]').hasMatch(value)) {
      passwordError = "At least 1 number";
    } else if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) {
      passwordError = "At least 1 special character";
    } else {
      passwordError = null;
    }
    setState(() {});
  }

  void _validateConfirmPassword(String value) {
    if (value != userPasswordController.text) {
      confirmPasswordError = "Passwords do not match";
    } else {
      confirmPasswordError = null;
    }
    setState(() {});
  }

  void _validateName(String value) {
    if (userNameController.text.isEmpty) {
      errorName = "Name is required";
    } else {
      errorName = null;
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    if (widget.uid != null && widget.uid!.isNotEmpty) {
      context.read<RegisterCubit>().getLeadDetailsForEdit(
        uid: widget.uid,
        boardId: widget.boardId,
      );
    }
  }

  @override
  void dispose() {
    userEmailController.dispose();
    userPasswordController.dispose();
    userPasswordConformController.dispose();
    userNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isUid = widget.uid != null && widget.uid!.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColor.background,
      body: SafeArea(
        child: BlocListener<RegisterCubit, RegisterState>(
          listenWhen: (previous, current) =>
              previous.status != current.status ||
              previous.fetchMemberStatus != current.fetchMemberStatus ||
              previous.loginStatus != current.loginStatus,
          listener: (context, state) {
            if (state.status == RegisterStatus.registering ||
                state.loginStatus == RegisterStatus.registering) {
              setState(() {
                isLoading1 = true;
              });
            } else if (state.status == RegisterStatus.registerFailure ||
                state.loginStatus == RegisterStatus.registerFailure) {
              myAlertBox(
                context,
                heading: "Register Failed ❌",
                subtittle: state.errorMsg,
              );
              setState(() {
                isLoading1 = false;
              });
            } else if (state.status == RegisterStatus.registered) {
              FocusScope.of(context).unfocus();
              setState(() {
                isLoading1 = false;
                uid = state.uid;
              });
              myAlertBox(
                context,
                heading: "Registration Successful🎉",
                subtittle: state.errorMsg,
                onPressed: () {
                  Future.delayed(Duration(milliseconds: 300), () {
                    Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.roleSelectionScreen,
                    );
                  });
                },
              );
            } else if (state.loginStatus == RegisterStatus.registered) {
              FocusScope.of(context).unfocus();
              setState(() {
                isLoading1 = false;
                uid = state.uid;
              });
              Navigator.pushReplacementNamed(
                context,
                AppRoutes.navigationScreen,
              );
            }
            if (state.fetchMemberStatus == RegisterStatus.registered && isUid) {
              final leadDetails = state.userInfo;
              setState(() {
                if (leadDetails != null && leadDetails.isNotEmpty) {
                  userNameController.text = leadDetails[0].name;
                  userEmailController.text = leadDetails[0].email;
                  // pickedImage = leadDetails[0].imagePath;
                  existingImageUrl = leadDetails[0].imagePath;
                  log(
                    "UI Updated with: ${leadDetails[0].name}, ${leadDetails[0].email}",
                  );
                } else {
                  log("leadDetails is empty in UI");
                }
              });
            }
          },
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    SizedBox(height: 20.h),
                    Text("Join the Board", style: t1heading()),
                    Text(
                      isUid
                          ? "Set up your Command Center account"
                          : "Create your command center accont",
                      style: hintTextStyle().copyWith(fontSize: 16.sp),
                    ),
                    SizedBox(height: 15.h),
                    imageHolderWithPlusAndNetwork(
                      isNetworkImage:
                          existingImageUrl != null && pickedImage == null,
                      imagePath:
                          pickedImage ??
                          (existingImageUrl != null
                              ? XFile(existingImageUrl!)
                              : null),
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
                      isCapital: true,
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
                      isEnable: isUid ? false : true,
                    ),

                    MyTextField(
                      userController: userPasswordController,
                      hint: isUid ? "New Password" : "Password",
                      frontIcon: Icons.lock_outline_sharp,
                      isbackIcon: true,
                      errorMsg: passwordError,
                      onChangedValue: _validatePassword,

                      isHide: isHide[0],
                      onPasswordIconClicked: () {
                        setState(() {
                          isHide[0] = !isHide[0];
                        });
                      },
                    ),
                    MyTextField(
                      userController: userPasswordConformController,
                      hint: isUid ? "Confirm New Password" : "Confirm Password",
                      frontIcon: Icons.lock_outline_sharp,
                      isHide: isHide[1],
                      isbackIcon: true,
                      errorMsg: confirmPasswordError,
                      onChangedValue: _validateConfirmPassword,
                      onPasswordIconClicked: () {
                        setState(() {
                          isHide[1] = !isHide[1];
                        });
                      },
                    ),

                    MyButtton(
                      text: isUid ? "Continue" : "Sign Up",
                      isLoading: isLoading1,
                      onPressed: () {
                        _validateEmail(userEmailController.text);
                        _validatePassword(userPasswordController.text);
                        _validateConfirmPassword(
                          userPasswordConformController.text,
                        );
                        _validateName(userNameController.text);
                        if (emailError == null &&
                            passwordError == null &&
                            errorName == null &&
                            confirmPasswordError == null) {
                          isUid
                              ? context
                                    .read<RegisterCubit>()
                                    .updateInviteDetails(
                                      boardId: widget.boardId ?? "",
                                      email: userEmailController.text.trim(),
                                      password: userPasswordController.text
                                          .trim(),
                                      name: userNameController.text.trim(),
                                      profileImage: pickedImage,
                                      uid: widget.uid ?? "",
                                    )
                              : context.read<RegisterCubit>().signUp(
                                  email: userEmailController.text.trim(),
                                  password: userPasswordController.text.trim(),
                                  name: userNameController.text.trim(),
                                  confirmPassword: userPasswordConformController
                                      .text
                                      .trim(),
                                  profileImage: pickedImage,
                                );
                        }
                      },
                    ),

                    SizedBox(height: 30.h),
                    isUid
                        ? SizedBox()
                        : GestureDetector(
                            onTap: () {
                              Navigator.pushReplacementNamed(
                                context,
                                AppRoutes.loginScreen,
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Already have an account? ",
                                  style: t3White(),
                                ),
                                Text(
                                  "Sign In ",
                                  style: t1heading().copyWith(fontSize: 18.sp),
                                ),
                              ],
                            ),
                          ),
                    SizedBox(height: 50.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget myDropDownContainer({
    required String text,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: 58.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColor.secondary.withAlpha(10),
          borderRadius: BorderRadius.circular(10.r),
          border: BoxBorder.all(color: AppColor.secondary),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: Row(
            children: [
              Icon(Icons.person_2_outlined, color: AppColor.secondary),
              SizedBox(width: 5.w),
              Text(selectedMember, style: t3White()),
              Spacer(),
              Icon(Icons.keyboard_arrow_down_outlined, color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }

  Widget dropDownContent({
    required String text1,
    required String text2,
    bool isDividee = true,
    required VoidCallback onPressed,
    Color? boxColor,
    int? index,
    bool isSelectedText = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: boxColor,
          borderRadius: BorderRadius.only(
            topLeft: index == 0 ? Radius.circular(9.r) : Radius.circular(0),
            topRight: index == 0 ? Radius.circular(9.r) : Radius.circular(0),
            bottomLeft: index == 3 ? Radius.circular(9.r) : Radius.circular(0),
            bottomRight: index == 3 ? Radius.circular(9.r) : Radius.circular(0),
          ),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10.h),
                  Text(
                    text1,
                    style: t2White().copyWith(
                      color: isSelectedText
                          ? Colors.black
                          : AppColor.textSecondary,
                    ),
                  ),
                  Text(
                    text2,
                    style: hintTextStyle().copyWith(
                      color: isSelectedText
                          ? Colors.black
                          : AppColor.textSecondary,
                    ),
                  ),
                  SizedBox(height: 10.h),
                ],
              ),
            ),
            Container(
              height: 2,
              color: isDividee ? AppColor.secondary : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}


  // SizedBox(height: 25.h),
  //                 AnimatedSize(
  //                   duration: Duration(milliseconds: 500),
  //                   curve: Curves.easeIn,
  //                   child: isDropdownVisible
  //                       ? Container(
  //                           decoration: BoxDecoration(
  //                             borderRadius: BorderRadius.circular(10.r),
  //                             border: BoxBorder.all(color: AppColor.secondary),
  //                           ),
  //                           child: Column(
  //                             children: [
  //                               dropDownContent(
  //                                 text1: memberSelection[0],
  //                                 text2:
  //                                     "Full access to all features and settings",
  //                                 onPressed: () {
  //                                   selected(0);
  //                                 },
  //                                 index: 0,
  //                                 isSelectedText: selectedIndex == 0
  //                                     ? true
  //                                     : false,
  //                                 boxColor: selectedIndex == 0
  //                                     ? AppColor.secondary
  //                                     : AppColor.secondary.withAlpha(10),
  //                               ),
  //                               dropDownContent(
  //                                 text1: memberSelection[1],
  //                                 text2: "Full access except admin settings",
  //                                 onPressed: () {
  //                                   selected(1);
  //                                 },

  //                                 isSelectedText: selectedIndex == 1
  //                                     ? true
  //                                     : false,
  //                                 boxColor: selectedIndex == 1
  //                                     ? AppColor.secondary
  //                                     : AppColor.secondary.withAlpha(10),
  //                               ),
  //                               dropDownContent(
  //                                 text1: memberSelection[2],
  //                                 text2: "Acces to assigned tasks and events",
  //                                 onPressed: () {
  //                                   selected(2);
  //                                 },
  //                                 isSelectedText: selectedIndex == 2
  //                                     ? true
  //                                     : false,
  //                                 boxColor: selectedIndex == 2
  //                                     ? AppColor.secondary
  //                                     : AppColor.secondary.withAlpha(10),
  //                               ),
  //                               dropDownContent(
  //                                 text1: memberSelection[3],
  //                                 text2: "Temporary view-only access",
  //                                 isDividee: false,
  //                                 onPressed: () {
  //                                   selected(3);
  //                                 },
  //                                 isSelectedText: selectedIndex == 3
  //                                     ? true
  //                                     : false,
  //                                 index: 3,
  //                                 boxColor: selectedIndex == 3
  //                                     ? AppColor.secondary
  //                                     : AppColor.secondary.withAlpha(10),
  //                               ),
  //                             ],
  //                           ),
  //                         )
  //                       : SizedBox.shrink(),
  //                 ),
  //                 isDropdownVisible ? SizedBox(height: 20.h) : Container(),



  
  // List<String> memberSelection = ["Chief", "Lead", "Board Member", "Guest"];

  // void onTap() {
  //   setState(() {
  //     isDropdownVisible = !isDropdownVisible;
  //     isSelectedText = true;
  //   });
  // }

  // void selected(int index) {
  //   setState(() {
  //     selectedIndex = index;
  //     if (index == 0) {
  //       setState(() {
  //         selectedMember = memberSelection[0];
  //         isDropdownVisible = false;
  //       });
  //     } else if (index == 1) {
  //       setState(() {
  //         selectedMember = memberSelection[1];
  //         isDropdownVisible = false;
  //       });
  //     } else if (index == 2) {
  //       setState(() {
  //         selectedMember = memberSelection[2];
  //         isDropdownVisible = false;
  //       });
  //     } else if (index == 3) {
  //       setState(() {
  //         selectedMember = memberSelection[3];
  //         isDropdownVisible = false;
  //       });
  //     }
  //   });
  // }

  // int? selectedIndex;
  // bool isSelectedText = false;