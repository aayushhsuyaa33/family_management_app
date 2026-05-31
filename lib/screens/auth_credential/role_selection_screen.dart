import 'package:family_management_app/app/app%20Color/app_color.dart';
import 'package:family_management_app/app/images/app_images.dart';
import 'package:family_management_app/app/routes/app_routes.dart';
import 'package:family_management_app/app/textStyle/textstyles.dart';
import 'package:family_management_app/app/utils/utils.dart';
import 'package:family_management_app/bloc/role_update/role_update_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  TextEditingController boardTitleController = TextEditingController();
  TextEditingController boardDescriptionController = TextEditingController();
  TextEditingController boarddIdController = TextEditingController();
  TextEditingController boardNickNameController = TextEditingController();
  bool isLoading = false;
  int selectedIndex = 0;
  int boardExistsint = 0;

  Future<void> onBoardIdEntered(
    String value,
    Function(void Function()) setModalState,
  ) async {
    setModalState(() {
      boardExistsint = -1; // -1 means "checking"
    });

    final exists = await context.read<RoleUpdateCubit>().checkBoardOrChiefEmail(
      value,
    );

    setModalState(() {
      if (exists) {
        boardExistsint = 1;
      } else {
        boardExistsint = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      body: SafeArea(
        child: BlocListener<RoleUpdateCubit, RoleUpdateState>(
          listenWhen: (previous, current) =>
              previous.updatingChiefStatus != current.updatingChiefStatus ||
              previous.updatingMemberStatus != current.updatingMemberStatus,
          listener: (context, state) {
            if (state.updatingChiefStatus == RoleUpdatingStatus.loading ||
                state.updatingMemberStatus == RoleUpdatingStatus.loading) {
              setState(() {
                isLoading = true;
              });
            } else if (state.updatingChiefStatus == RoleUpdatingStatus.sucess) {
              setState(() {
                isLoading = false;
              });
              myAlertBox(
                context,
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  Future.delayed(Duration(milliseconds: 500), () {
                    Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.loginScreen,
                    );
                  });
                },
                subtittle: state.isGoogle
                    ? "Your board has been Sucessfully created"
                    : "A verification link has been sent to your email.\nConfirm to activate your account.",

                heading: state.isGoogle
                    ? "🎉You're all set!"
                    : "🎉You're almost set!",
              );
            } else if (state.updatingMemberStatus ==
                RoleUpdatingStatus.sucess) {
              FocusScope.of(context).unfocus();
              setState(() {
                isLoading = false;
              });
              myAlertBox(
                context,
                onPressed: () {
                  Future.delayed(Duration(milliseconds: 500), () {
                    Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.waitingScreen,
                      arguments: {"boardId": boarddIdController.text.trim()},
                    );
                  });
                },
                heading: "Join Request Sent",
                subtittle: "Please wait for the approval",
              );
            } else if (state.updatingChiefStatus == RoleUpdatingStatus.failed ||
                state.updatingChiefStatus == RoleUpdatingStatus.failed) {
              setState(() {
                isLoading = false;
              });
            }
          },
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "What would you like to do next?",
                    style: t1heading().copyWith(height: 1.1),
                    textAlign: TextAlign.center,
                  ),
                  BoardCard(
                    title: "Create Board",
                    subtitle:
                        "Start a new board as Chief & manage members, roles, & activities.",
                    imagePath: AppImages.createCardImage,
                    onTap: () {
                      setState(() {
                        selectedIndex = 0;
                      });
                      showCustomBoardModalBottomSheet(
                        context,

                        builder: (setModalState) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              MyUploadTextField(
                                userController: boardTitleController,
                                hint: "Alejandra Family Board",
                                labelText: "Board title",
                              ),
                              MyUploadTextField(
                                isDesc: true,
                                isRequired: false,
                                userController: boardDescriptionController,
                                hint:
                                    "Organize family tasks, groceries, and events",
                                labelText: "Board Description",
                              ),
                              MyButtton(
                                text: "Create",
                                isLoading: isLoading,
                                onPressed: () {
                                  setState(() {
                                    selectedIndex = 0;
                                  });
                                  setModalState(() {
                                    isLoading;
                                  });
                                  if (boardTitleController.text
                                      .trim()
                                      .isEmpty) {
                                    myAlertBox(
                                      context,
                                      subtittle: "Enter the title",
                                      heading: "Creation Failed",
                                    );
                                  } else {
                                    context
                                        .read<RoleUpdateCubit>()
                                        .updateChiefsRole(
                                          title: boardTitleController.text
                                              .trim(),
                                          description:
                                              boardDescriptionController.text
                                                  .trim(),
                                        );
                                  }
                                },
                              ),
                              SizedBox(height: 50),
                            ],
                          );
                        },
                      );
                    },
                  ),

                  BoardCard(
                    title: "Join Board",
                    subtitle:
                        "Request to join an existing board using the Chief’s email or Board ID.",
                    imagePath: AppImages.joinCardImage,
                    onTap: () {
                      setState(() {
                        selectedIndex = 1;
                      });
                      showCustomBoardModalBottomSheet(
                        context,

                        builder: (setModalState) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              MyUploadTextField(
                                onChangedValue: (value) {
                                  if (value.isNotEmpty) {
                                    onBoardIdEntered(value, setModalState);
                                  }
                                },
                                userController: boarddIdController,
                                hint: "7245 or user@example.com",
                                labelText: "Board ID or Email address",
                                isCapital: false,

                                backIcon: Icons.check,
                                backIconcolor: boardExistsint == 1
                                    ? AppColor.secondary
                                    : Colors.white30,
                              ),
                              MyUploadTextField(
                                userController: boardNickNameController,
                                hint: "Chiku",
                                labelText: "Your NickName",
                                isRequired: false,
                              ),
                              MyButtton(
                                text: "Join",

                                isLoading: isLoading,
                                onPressed: () {
                                  setState(() {
                                    selectedIndex = 1;
                                  });
                                  setModalState(() {
                                    isLoading;
                                  });
                                  if (boarddIdController.text.trim().isEmpty) {
                                    myAlertBox(
                                      context,
                                      subtittle:
                                          "Enter the Board ID or Email Address",
                                      heading: "Join Failed",
                                    );
                                  } else if (boardExistsint == 1) {
                                    final input = boarddIdController.text
                                        .trim();
                                    context
                                        .read<RoleUpdateCubit>()
                                        .updateMembersRole(
                                          input: input,
                                          nickname: boardNickNameController.text
                                              .trim(),
                                        );
                                  } else {
                                    myAlertBox(
                                      context,
                                      subtittle:
                                          "Enter a vaild Email Address or BoardID",
                                      heading: "Join Failed",
                                    );
                                  }
                                },
                              ),
                              SizedBox(height: 50),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
