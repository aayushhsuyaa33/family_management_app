import 'dart:developer';

import 'package:family_management_app/app/routes/app_routes.dart';
import 'package:family_management_app/app/textStyle/textstyles.dart';
import 'package:family_management_app/app/utils/shimmer.dart';
import 'package:family_management_app/bloc/add%20tasks/add_tasks_cubit.dart';
import 'package:family_management_app/bloc/register/register_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:family_management_app/app/app%20Color/app_color.dart';
import 'package:family_management_app/app/utils/custom_appbar.dart';
import 'package:family_management_app/app/utils/utils.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class AddMemberScreen extends StatefulWidget {
  final String? uid;

  const AddMemberScreen({super.key, this.uid});

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  TextEditingController userNameController = TextEditingController();
  TextEditingController userEmailController = TextEditingController();
  List<String> roleSelection = ["Co-chief", "Unit Lead", "Guest"];
  List<String> storedRoleList = ["Co-chief", "Lead", "Guest"];
  String? storedRole;
  String? selectedRole;
  String? errorName;
  XFile? pickedImage;
  String? emailError;
  bool isLoading = false;
  String? existingImageUrl;
  String? localUid;
  bool isInitialized = false;
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
  void initState() {
    super.initState();
    if (widget.uid != null && widget.uid!.isNotEmpty) {
      localUid = widget.uid;
      context.read<AddTasksCubit>().getLeadDetailsForEdit(uid: localUid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyCustomAppBar(
        onBackPressed: () {
          context.read<AddTasksCubit>().clearAddLeadState();
        },
        heading: widget.uid != null && widget.uid!.isNotEmpty
            ? "Edit Member"
            : "Add a New Member",
        subTitle: widget.uid != null && widget.uid!.isNotEmpty
            ? "Update the Lead user details"
            : "Manually add a Lead user to the board",
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 20.h),
          child: SingleChildScrollView(
            child: BlocBuilder<AddTasksCubit, AddTasksState>(
              builder: (context, state) {
                if (state.fetchLeadStatus == AddRequestStatus.loading &&
                    widget.uid != null &&
                    widget.uid!.isNotEmpty) {
                  return Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: myShimmerBoxCircle(
                            height: 120.h,
                            width: 120.w,
                          ),
                        ),
                        SizedBox(height: 30.h),
                        myShimmerBoxSharp(height: 30.h, width: 100.w),
                        SizedBox(height: 7.h),
                        myShimmerBoxSharp(height: 50.h, width: double.infinity),
                        SizedBox(height: 20.h),
                        myShimmerBoxSharp(height: 30.h, width: 100.w),
                        SizedBox(height: 7.h),
                        myShimmerBoxSharp(height: 50.h, width: double.infinity),
                        SizedBox(height: 20.h),
                        myShimmerBoxSharp(height: 30.h, width: 100.w),
                        SizedBox(height: 7.h),
                        myShimmerBoxSharp(height: 50.h, width: double.infinity),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  );
                } else if (state.fetchLeadStatus == AddRequestStatus.success &&
                    localUid != null &&
                    !isInitialized) {
                  final leadDetails = state.userInfo ?? [];
                  userNameController.text = leadDetails[0].name;
                  userEmailController.text = leadDetails[0].email;
                  selectedRole = leadDetails[0].role;
                  existingImageUrl = leadDetails[0].imagePath;
                  isInitialized = true;
                }
                return Column(
                  children: [
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

                    MyUploadTextField(
                      userController: userNameController,
                      hint: "Name ",
                      frontIcon: Icons.perm_identity_outlined,
                      labelText: " Name",
                      onChangedValue: _validateName,
                    ),

                    MyDropDownBUtton(
                      labelText: widget.uid != null && widget.uid!.isNotEmpty
                          ? "Update role for this member"
                          : "Select role for this member",
                      role: roleSelection.last,
                      hintText: "Select Role",

                      itemsList: roleSelection,
                      icon: Icons.manage_accounts,
                      isRequired: true,
                      onChanged: (value) {
                        setState(() {
                          selectedRole = value ?? "";
                          int index = roleSelection.indexOf(value!);
                          storedRole = storedRoleList[index];
                        });
                      },
                    ),
                    selectedRole != "Guest"
                        ? Row(
                            children: [
                              Text(
                                " Email",
                                style: t3White().copyWith(fontSize: 20.sp),
                              ),
                              Text(
                                " *",
                                style: t3White().copyWith(
                                  fontSize: 20.sp,
                                  color: AppColor.error,
                                ),
                              ),
                            ],
                          )
                        : SizedBox(),
                    SizedBox(height: 7.h),

                    selectedRole != "Guest"
                        ? MyTextField(
                            userController: userEmailController,
                            hint: "Email",
                            frontIcon: Icons.email_outlined,
                            isHide: false,
                            onPasswordIconClicked: () {},
                            errorMsg: emailError,
                            onChangedValue: _validateEmail,
                          )
                        : SizedBox(),

                    SizedBox(height: selectedRole != "Guest" ? 30 : 10),
                    BlocListener<AddTasksCubit, AddTasksState>(
                      listenWhen: (previous, current) =>
                          previous.addLeadStatus != current.addLeadStatus,
                      listener: (context, state) {
                        if (state.addLeadStatus == AddRequestStatus.loading) {
                          setState(() {
                            isLoading = true;
                          });
                        } else if (state.addLeadStatus ==
                            AddRequestStatus.success) {
                          setState(() {
                            isLoading = false;
                          });
                          myAlertBox(
                            context,
                            heading: "🎉 Success!",
                            subtittle: state.errorMsg ?? "",
                            onPressed: () {
                              Future.delayed(Duration(milliseconds: 500), () {
                                Navigator.pushReplacementNamed(
                                  context,
                                  AppRoutes.navigationScreen,
                                );
                              });
                            },
                          );
                        } else if (state.addLeadStatus ==
                            AddRequestStatus.failure) {
                          setState(() {
                            isLoading = false;
                          });

                          myAlertBox(context, subtittle: state.errorMsg!);
                        }
                      },
                      child: MyButtton(
                        text: widget.uid != null && widget.uid!.isNotEmpty
                            ? "Update Support"
                            : "Add Support",
                        isLoading: isLoading,
                        onPressed: () async {
                          String name = userNameController.text;
                          String email = userEmailController.text;

                          _validateName(name);
                          if (selectedRole != "Guest") {
                            _validateEmail(email);
                          }

                          if (name.isEmpty || selectedRole == null) {
                            myAlertBox(
                              context,
                              subtittle: "Some fields are missing",
                              heading: "❗ Error",
                            );
                            return;
                          }

                          if (selectedRole != "Guest" && (email.isEmpty)) {
                            myAlertBox(
                              context,
                              subtittle: "Email is required for this role",
                              heading: "❗ Error",
                            );
                            return;
                          }

                          context.read<AddTasksCubit>().addMember(
                            name: name,
                            email: email,
                            role: selectedRole,
                            profileImage: pickedImage,
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  String getGuestUniqueId() {
    return "guest_${DateTime.now().millisecondsSinceEpoch}";
  }
}
