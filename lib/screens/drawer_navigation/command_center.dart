import 'dart:developer';
import 'package:family_management_app/app/app%20Color/app_color.dart';
import 'package:family_management_app/app/routes/app_routes.dart';

import 'package:family_management_app/app/textStyle/textstyles.dart';
import 'package:family_management_app/app/utils/custom_appbar.dart';
import 'package:family_management_app/app/utils/custom_drawar.dart';
import 'package:family_management_app/app/utils/shimmer.dart';
import 'package:family_management_app/app/utils/utils.dart';
import 'package:family_management_app/bloc/fetch%20User/fetch_user_cubit.dart';
import 'package:family_management_app/bloc/fetch_cubit/fetch_event_cubit.dart';
import 'package:family_management_app/bloc/fetch_tasks/fetch_tasks_cubit.dart';
import 'package:family_management_app/service/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CommandCenterScreen extends StatefulWidget {
  const CommandCenterScreen({super.key});

  @override
  State<CommandCenterScreen> createState() => _CommandCenterScreenState();
}

class _CommandCenterScreenState extends State<CommandCenterScreen> {
  String savedUserRole = "";
  String savedUserName = "";
  String savedUserImage = "";
  String savedBoardId = "";
  String savedUserId = "";
  String savedUserEmail = "";

  bool isLongPressedChief = false;
  bool isLongPressedLead = false;
  bool isLongPressedKid = false;

  bool isDeletingChief = false;
  bool isDeletingLead = false;
  bool isDeletingKid = false;

  final List<String> selectedChiefs = [];
  final List<String> selectedLeads = [];
  final List<String> selectedKids = [];

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSecureData();
    context.read<FetchUserCubit>().fetchCommandCenterInfo();
  }

  Future<void> _loadSecureData() async {
    savedUserRole = await AppStorage.read(key: "savedRole") ?? "";
    savedUserName = await AppStorage.read(key: "name") ?? "";
    savedUserImage = await AppStorage.read(key: "imagePath") ?? "";
    savedUserEmail = await AppStorage.read(key: "email") ?? "";
    savedBoardId = await AppStorage.read(key: "boardId") ?? "";
    savedUserId = await AppStorage.read(key: "uid") ?? "";

    log(
      "NAME: $savedUserName, ROLE: $savedUserRole, IMAGE: $savedUserImage, EMAIL: $savedUserEmail, BoardId: $savedBoardId, Uid: $savedUserId",
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final fetchBloc = context.read<FetchUserCubit>();
    return Scaffold(
      backgroundColor: AppColor.background,
      endDrawer: MyCustomDrawar(),
      appBar: MyCustomAppBar(
        heading: "Command Center",
        subTitle: "Stay connected with your team",
        isInvite: true,
        onInviteClicked: fetchBloc.inviteUser,
        isRightDrawer: true,
      ),

      body: WillPopScope(
        onWillPop: () async {
          if (isLongPressedChief) {
            setState(() {
              isLongPressedChief = false;
              selectedChiefs.clear();
            });
            return false;
          }
          if (isLongPressedKid) {
            setState(() {
              isLongPressedKid = false;
              selectedKids.clear();
            });
            return false;
          }
          if (isLongPressedLead) {
            setState(() {
              isLongPressedLead = false;
              selectedLeads.clear();
            });
            return false;
          }
          return true;
        },
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: 15.h,
              horizontal: 20.w,
            ).copyWith(right: 5.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildChiefRow(),
                SizedBox(height: 15.h),

                _buildLeadRow(),
                SizedBox(height: 15.h),

                _buildKidsRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChiefRow() {
    return BlocBuilder<FetchUserCubit, FetchUserState>(
      builder: (context, state) {
        if (state.fetchCommandCenterInfoStatus == FetchRequestStatus.loading) {
          return Padding(
            padding: EdgeInsets.only(right: 20.w, top: 5.h),
            child: Column(
              children: [
                myShimmerBoxCircle(height: 95.h, width: 95.h),
                SizedBox(height: 5.h),
                myShimmerBoxSharp(width: 100.w, height: 20.sp),
              ],
            ),
          );
        }

        final chiefUsers =
            state.userInfo?.where((user) {
              return user.role == "Chief" || user.role == "Co-chief";
            }).toList() ??
            [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "Chief of Operations",
                  style: t1White().copyWith(fontSize: 25.sp),
                ),
                SizedBox(width: 5.w),
                Icon(Icons.workspace_premium),
                Spacer(),
                iconRow(
                  onAddIconPressed: () {
                    if (!isLongPressedChief &&
                        !isLongPressedKid &&
                        !isLongPressedLead) {
                      Navigator.pushNamed(context, AppRoutes.addMemberScreen);
                    }
                  },
                  onDeleteIconPressed: () async {
                    if (selectedChiefs.isEmpty &&
                        !isLongPressedLead &&
                        !isLongPressedKid &&
                        chiefUsers.length > 1) {
                      setState(() => isLongPressedChief = true);
                      return;
                    } else if (chiefUsers.length == 1)
                      return;

                    setState(() {
                      isDeletingChief = true;
                      isLongPressedChief = false;
                    });
                    await context
                        .read<FetchUserCubit>()
                        .deleteUserFromFirestore(selectedChiefs);

                    context.read<FetchEventCubit>().fetchRecentEvent();
                    context.read<FetchTasksCubit>().getDateAndRoleForCalander();

                    if (selectedChiefs.isNotEmpty) {
                      mySnackBar(
                        context,
                        title:
                            "${selectedChiefs.length} Co-chief${selectedChiefs.length > 1 ? 's' : ''} removed successfully",
                      );
                    }
                    setState(() {
                      selectedChiefs.clear();
                      isDeletingChief = false;
                    });
                  },
                  onEditPressed: () {
                    if (selectedChiefs.isEmpty &&
                        !isLongPressedKid &&
                        !isLongPressedLead &&
                        chiefUsers.length > 1) {
                      setState(() {
                        isLongPressedChief = true;
                      });
                      return;
                    } else if (chiefUsers.length == 1)
                      return;
                    final selectedChiefUid = selectedChiefs.first;

                    final selectedChiefUser = chiefUsers
                        .where((u) => u.uid == selectedChiefUid)
                        .firstOrNull;

                    if (selectedChiefs.isEmpty &&
                        !isLongPressedKid &&
                        !isLongPressedLead) {
                      setState(() {
                        isLongPressedChief = true;
                      });
                    } else if (selectedChiefs.length == 1 &&
                        selectedChiefUser!.joinStatus != "invited") {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.addMemberScreen,
                        arguments: {'uid': selectedChiefs.first},
                      );
                    } else if (selectedChiefUser!.joinStatus == "invited" &&
                        selectedChiefs.length == 1) {
                      mySnackBar(
                        context,
                        title: "Editing locked until proposal approval.",
                      );
                    }
                  },
                  color: !isLongPressedKid && !isLongPressedLead
                      ? AppColor.secondary
                      : Colors.transparent,
                ),
              ],
            ),
            SizedBox(height: 5.h),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(chiefUsers.length, (index) {
                  final chief = chiefUsers[index];
                  return AnimatedOpacity(
                    opacity:
                        isDeletingChief && selectedChiefs.contains(chief.uid)
                        ? 0
                        : 1,
                    duration: const Duration(milliseconds: 800),

                    child: MyCommandCenterProfileHolder(
                      name: chief.name,
                      imagePath: chief.imagePath,
                      role: chief.role,
                      status: chief.joinStatus,
                      isLongPressed:
                          isLongPressedChief && chief.role != "Chief",
                      isSelected:
                          selectedChiefs.contains(chief.uid) &&
                          chief.role != "Chief",
                      onPressed: () {
                        if (savedUserRole == "Chief" ||
                            savedUserRole == "Co-chief" ||
                            savedUserId == chief.uid) {
                          if (isLongPressedChief) {
                            setState(() {
                              selectedChiefs.contains(chief.uid)
                                  ? selectedChiefs.remove(chief.uid)
                                  : selectedChiefs.add(chief.uid);
                            });
                          } else if (!isLongPressedLead && !isLongPressedKid) {
                            if (chief.joinStatus != "invited") {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.profileScreen,
                                arguments: {
                                  'uid': chief.uid,
                                  'email': chief.email,
                                  'isChild': false,
                                },
                              );
                            } else {
                              mySnackBar(
                                context,
                                title:
                                    "Access blocked until the user accepts the invite.",
                              );
                            }
                          }
                        }
                      },
                      onLongPressed: () {
                        if (!isLongPressedKid &&
                            !isLongPressedLead &&
                            chief.role != "Chief") {
                          setState(() {
                            isLongPressedChief = true;
                            selectedChiefs.add(chief.uid);
                          });
                        }
                      },
                      // isSelfUser: savedUserId == chief.uid,
                    ),
                  );
                }),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLeadRow() {
    return BlocBuilder<FetchUserCubit, FetchUserState>(
      builder: (context, state) {
        if (state.fetchCommandCenterInfoStatus == FetchRequestStatus.loading) {
          return Padding(
            padding: EdgeInsets.only(right: 20.w, top: 5.h),
            child: Column(
              children: [
                myShimmerBoxCircle(height: 95.h, width: 95.h),
                SizedBox(height: 5.h),
                myShimmerBoxSharp(width: 100.w, height: 20.sp),
              ],
            ),
          );
        }

        final leadUsers =
            state.userInfo?.where((user) {
              return user.role == "Lead" ||
                  user.role == "Unit Lead" ||
                  user.role == "Unit lead";
            }).toList() ??
            [];

        if (leadUsers.isEmpty) {
          return Column(
            children: [
              Row(
                children: [
                  Text(
                    "Unit Lead (Support)",
                    style: t1White().copyWith(fontSize: 25.sp),
                  ),
                  SizedBox(width: 5.w),
                  Icon(Icons.manage_accounts),
                  Spacer(),

                  IconButton(
                    color: !isLongPressedChief && !isLongPressedKid
                        ? AppColor.secondary
                        : Colors.transparent,
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.addMemberScreen);
                    },
                    icon: Icon(Icons.add),
                  ),
                ],
              ),
              Center(
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  height: 135.h,
                  child: Text("No Lead User Added Yet", style: hintTextStyle()),
                ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "Unit Lead (Support)",
                  style: t1White().copyWith(fontSize: 25.sp),
                ),
                SizedBox(width: 5.w),
                Icon(Icons.manage_accounts),
                Spacer(),

                iconRow(
                  onAddIconPressed: () {
                    if (!isLongPressedChief &&
                        !isLongPressedKid &&
                        !isLongPressedLead) {
                      Navigator.pushNamed(context, AppRoutes.addMemberScreen);
                    }
                  },
                  onDeleteIconPressed: () async {
                    if (selectedLeads.isEmpty &&
                        !isLongPressedChief &&
                        !isLongPressedKid) {
                      setState(() => isLongPressedLead = true);
                      return;
                    }
                    setState(() {
                      isDeletingLead = true;
                      isLongPressedLead = false;
                    });
                    await context
                        .read<FetchUserCubit>()
                        .deleteUserFromFirestore(selectedLeads);

                    context.read<FetchEventCubit>().fetchRecentEvent();
                    context.read<FetchTasksCubit>().getDateAndRoleForCalander();

                    if (selectedLeads.isNotEmpty) {
                      mySnackBar(
                        context,
                        title:
                            "${selectedLeads.length} lead Member${selectedKids.length > 1 ? 's' : ''} removed successfully",
                      );
                    }
                    setState(() {
                      selectedLeads.clear();
                      isDeletingLead = false;
                    });
                  },
                  onEditPressed: () {
                    if (selectedLeads.isEmpty &&
                        !isLongPressedKid &&
                        !isLongPressedChief) {
                      setState(() {
                        isLongPressedLead = true;
                      });
                      return;
                    }
                    final selectedLeadUid = selectedLeads.first;

                    final selectedLeadUser = leadUsers
                        .where((u) => u.uid == selectedLeadUid)
                        .first;
                    if (selectedLeads.length == 1 &&
                        selectedLeadUser.joinStatus != "invited") {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.addMemberScreen,
                        arguments: {'uid': selectedLeads.first},
                      );
                    } else if (selectedLeadUser.joinStatus == "invited" &&
                        selectedLeads.length == 1) {
                      mySnackBar(
                        context,
                        title: "Editing locked until proposal approval.",
                      );
                    }
                  },
                  color: !isLongPressedKid && !isLongPressedChief
                      ? AppColor.secondary
                      : Colors.transparent,
                ),
              ],
            ),
            SizedBox(height: 5.h),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: List.generate(leadUsers.length, (index) {
                  final lead = leadUsers[index];
                  return AnimatedOpacity(
                    opacity: isDeletingLead && selectedLeads.contains(lead.uid)
                        ? 0
                        : 1,
                    duration: const Duration(milliseconds: 800),
                    child: MyCommandCenterProfileHolder(
                      name: lead.name,
                      imagePath: lead.imagePath,
                      role: lead.role,
                      status: lead.joinStatus,
                      isLongPressed: isLongPressedLead,
                      isSelected: selectedLeads.contains(lead.uid),

                      onPressed: () {
                        if (savedUserRole == "Chief" ||
                            savedUserRole == "Co-chief" ||
                            savedUserId == lead.uid) {
                          if (isLongPressedLead) {
                            setState(() {
                              selectedLeads.contains(lead.uid)
                                  ? selectedLeads.remove(lead.uid)
                                  : selectedLeads.add(lead.uid);
                            });
                          } else if (!isLongPressedChief && !isLongPressedKid) {
                            if (lead.joinStatus != 'invited') {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.profileScreen,
                                arguments: {
                                  'uid': lead.uid,
                                  'email': lead.email,
                                  'isChild': false,
                                },
                              );
                            } else {
                              mySnackBar(
                                context,
                                title:
                                    "Access blocked until the user accepts the invite.",
                              );
                            }
                          }
                        }
                      },

                      onLongPressed: () {
                        if (!isLongPressedKid && !isLongPressedChief) {
                          setState(() {
                            isLongPressedLead = true;
                            selectedLeads.add(lead.uid);
                          });
                        }
                      },
                    ),
                  );
                }),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildKidsRow() {
    return BlocBuilder<FetchUserCubit, FetchUserState>(
      builder: (context, state) {
        if (state.fetchCommandCenterInfoStatus == FetchRequestStatus.loading) {
          return Padding(
            padding: EdgeInsets.only(right: 20.w, top: 5.h),
            child: Column(
              children: [
                myShimmerBoxCircle(height: 95.h, width: 95.h),
                SizedBox(height: 5.h),
                myShimmerBoxSharp(width: 100.w, height: 20.sp),
              ],
            ),
          );
        }

        final kidUsers =
            state.userInfo?.where((user) {
              return user.role == "Stakeholder";
            }).toList() ??
            [];

        if (kidUsers.isEmpty) {
          return Column(
            children: [
              Row(
                children: [
                  Text(
                    "Stakeholders (Kids)",
                    style: t1White().copyWith(fontSize: 25.sp),
                  ),
                  SizedBox(width: 5.w),
                  Icon(Icons.child_care),
                  Spacer(),

                  IconButton(
                    color: !isLongPressedChief && !isLongPressedLead
                        ? AppColor.secondary
                        : Colors.transparent,
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.addChildFlow);
                    },
                    icon: Icon(Icons.add),
                  ),
                ],
              ),
              Center(
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  height: 135.h,
                  child: Text(
                    "No Stakeholder Added Yet",
                    style: hintTextStyle(),
                  ),
                ),
              ),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "Stakeholders (Kids)",
                  style: t1White().copyWith(fontSize: 25.sp),
                ),
                SizedBox(width: 5.w),
                Icon(Icons.child_care),
                Spacer(),

                iconRow(
                  onAddIconPressed: () {
                    if (!isLongPressedChief &&
                        !isLongPressedKid &&
                        !isLongPressedLead) {
                      Navigator.pushNamed(context, AppRoutes.addChildFlow);
                    }
                  },
                  onDeleteIconPressed: () async {
                    if (selectedKids.isEmpty &&
                        !isLongPressedLead &&
                        !isLongPressedChief) {
                      setState(() => isLongPressedKid = true);
                      return;
                    }
                    setState(() {
                      isDeletingKid = true;
                      isLongPressedKid = false;
                    });
                    await context
                        .read<FetchUserCubit>()
                        .deleteUserFromFirestore(selectedKids);

                    context.read<FetchEventCubit>().fetchRecentEvent();
                    context.read<FetchTasksCubit>().getDateAndRoleForCalander();
                    if (selectedKids.isNotEmpty) {
                      mySnackBar(
                        context,
                        title:
                            "${selectedKids.length} Stakeholder${selectedKids.length > 1 ? 's' : ''} removed successfully",
                      );
                    }
                    setState(() {
                      selectedKids.clear();
                      isDeletingKid = false;
                    });
                  },
                  onEditPressed: () {
                    if (selectedKids.isEmpty &&
                        !isLongPressedChief &&
                        !isLongPressedLead) {
                      setState(() {
                        isLongPressedKid = true;
                      });
                    } else if (selectedKids.isNotEmpty &&
                        selectedKids.length == 1) {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.addChildFlow,
                        arguments: {'uid': selectedKids.first},
                      );
                    }
                  },
                  color: !isLongPressedLead && !isLongPressedChief
                      ? AppColor.secondary
                      : Colors.transparent,
                ),
              ],
            ),
            SizedBox(height: 5.h),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,

              clipBehavior: Clip.none,
              child: Row(
                children: List.generate(kidUsers.length, (index) {
                  final kids = kidUsers[index];
                  return AnimatedOpacity(
                    opacity: isDeletingKid && selectedKids.contains(kids.uid)
                        ? 0
                        : 1,
                    duration: const Duration(milliseconds: 800),

                    child: MyCommandCenterProfileHolder(
                      name: kids.name,
                      imagePath: kids.imagePath,
                      role: kids.role,
                      isLongPressed: isLongPressedKid,
                      isSelected: selectedKids.contains(kids.uid),
                      onPressed: () {
                        if (savedUserRole == "Chief" ||
                            savedUserRole == "Co-chief") {
                          if (isLongPressedKid) {
                            setState(() {
                              selectedKids.contains(kids.uid)
                                  ? selectedKids.remove(kids.uid)
                                  : selectedKids.add(kids.uid);
                            });
                          } else if (!isLongPressedLead &&
                              !isLongPressedChief) {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.profileScreen,
                              arguments: {
                                'uid': kids.uid,
                                'email': kids.name,
                                'isChild': true,
                              },
                            );
                          }
                        }
                      },
                      onLongPressed: () {
                        if (!isLongPressedChief && !isLongPressedLead) {}
                        setState(() {
                          isLongPressedKid = true;
                          selectedKids.add(kids.uid);
                        });
                      },

                      // isSelfUser: savedUserId == kids.uid,
                    ),
                  );
                }),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget iconRow({
    required VoidCallback onDeleteIconPressed,
    required VoidCallback onAddIconPressed,
    required VoidCallback onEditPressed,
    Color color = AppColor.secondary,
  }) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_horiz, color: color),
      onSelected: (value) {
        switch (value) {
          case "add":
            onAddIconPressed();
            break;
          case 'edit':
            onEditPressed();
            break;
          case 'delete':
            onDeleteIconPressed();
            break;
        }
      },
      color: AppColor.dropDownColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.r)),
      itemBuilder: (_) => [
        PopupMenuItem<String>(
          value: 'add',
          child: Text(
            'Add',
            style: hintTextStyle().copyWith(
              color:
                  selectedChiefs.isEmpty &&
                      selectedKids.isEmpty &&
                      selectedLeads.isEmpty
                  ? Colors.white
                  : Colors.grey,
            ),
          ),
        ),
        PopupMenuItem<String>(
          value: 'edit',
          child: Text(
            'Edit',
            style: hintTextStyle().copyWith(
              color:
                  selectedKids.length > 1 ||
                      selectedLeads.length > 1 ||
                      selectedChiefs.length > 1
                  ? Colors.grey.shade700
                  : Colors.white,
            ),
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: Text(
            'Delete',
            style: hintTextStyle().copyWith(color: AppColor.error),
          ),
        ),
      ],
    );
  }
}

class MyCommandCenterProfileHolder extends StatelessWidget {
  final String name;
  final VoidCallback onPressed;
  final String? imagePath;
  final Color strokeColor;
  final String? role;
  final bool isSelfUser;
  final String? status;

  final VoidCallback onLongPressed;
  final bool isLongPressed;
  final bool isSelected;

  const MyCommandCenterProfileHolder({
    super.key,
    required this.name,
    required this.onPressed,
    this.imagePath,
    this.strokeColor = AppColor.secondary,
    this.role,
    this.isSelfUser = false,

    required this.onLongPressed,
    this.isLongPressed = false,
    this.isSelected = false,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imagePath != null && imagePath!.isNotEmpty;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            children: [
              GestureDetector(
                onTap: onPressed,
                onLongPress: onLongPressed,
                child: Container(
                  width: 100.w,
                  height: 100.h,

                  decoration: BoxDecoration(
                    border: Border.all(width: 4, color: strokeColor),
                    image: hasImage
                        ? DecorationImage(
                            image: NetworkImage(imagePath!),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: hasImage ? null : AppColor.dropDownAlternativeColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.lightBlueBgCOlor,
                        offset: const Offset(4, 4),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: !hasImage
                      ? Center(
                          child: Text(
                            name[0].toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 50.sp,
                            ),
                          ),
                        )
                      : null,
                ),
              ),
              SizedBox(height: 5.h),
              Text(
                name,
                style: hintTextStyle().copyWith(
                  fontSize: 20.sp,
                  color: AppColor.secondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          if (status == 'invited')
            GestureDetector(
              onTap: onPressed,
              onLongPress: onLongPressed,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withAlpha(150),
                ),
              ),
            ),
          if (role == "Chief")
            Positioned(
              right: 7,
              bottom: 25,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColor.dropDownAlternativeColor,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                padding: EdgeInsets.all(4),
                // child: Icon(
                //   FontAwesomeIcons.crown,
                //   color: Colors.white,
                //   size: 14,
                // ),
              ),
            ),

          // Co-Chief
          if (role == "Co-chief" && !isLongPressed)
            Positioned(
              right: 7,
              bottom: 25,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: status == "accepted"
                      ? AppColor.indigoColor
                      : AppColor.textTertiary,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                padding: EdgeInsets.all(4),
                // child: Icon(
                //   status == "accepted"
                //       ? FontAwesomeIcons.shieldHalved
                //       : Icons.hourglass_top,
                //   color: Colors.white,
                //   size: 14.sp,
                // ),
              ),
            ),

          // Unit Lead
          if ((role == "Unit Lead" || role == "Lead") && !isLongPressed)
            Positioned(
              right: 7,
              bottom: 25,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: status == "accepted"
                      ? AppColor.success
                      : AppColor.textTertiary,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                padding: EdgeInsets.all(4),
                child: Icon(
                  status == "accepted" ? Icons.star : Icons.hourglass_top,
                  color: Colors.white,
                  size: 15.sp,
                ),
              ),
            ),

          if (role == "Stakeholder" && !isLongPressed)
            Positioned(
              right: 7,
              bottom: 25,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColor.purpleColor,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                padding: EdgeInsets.all(4),
                child: Icon(Icons.child_care, color: Colors.white, size: 14),
              ),
            ),

          if (isLongPressed)
            Positioned(
              right: 7,
              bottom: 25,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColor.background,
                  shape: BoxShape.circle,
                ),

                child: Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected ? AppColor.secondary : Colors.grey,
                  size: 25.sp,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
