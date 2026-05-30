import 'dart:developer';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:family_management_app/app/app%20Color/app_color.dart';
import 'package:family_management_app/app/routes/app_routes.dart';
import 'package:family_management_app/app/textStyle/textstyles.dart';
import 'package:family_management_app/app/utils/calender_pick.dart';
import 'package:family_management_app/app/utils/custom_appbar.dart';
import 'package:family_management_app/app/utils/utils.dart';
import 'package:family_management_app/bloc/add%20tasks/add_tasks_cubit.dart';
import 'package:family_management_app/bloc/fetch%20User/fetch_user_cubit.dart';
import 'package:family_management_app/bloc/fetch_tasks/fetch_tasks_cubit.dart';

import 'package:flutter/material.dart';
import 'package:family_management_app/app/utils/shimmer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class AddtaskScreen extends StatefulWidget {
  final String? preSelectedDate;
  final String? preSelectedTime;
  final bool isEditTask;
  final String? taskId;
  const AddtaskScreen({
    super.key,
    this.preSelectedDate,
    this.preSelectedTime,
    this.isEditTask = false,
    this.taskId,
  });

  @override
  State<AddtaskScreen> createState() => _AddtaskScreenState();
}

class _AddtaskScreenState extends State<AddtaskScreen> {
  DateTime? selectedDate;
  String? hintDate;
  bool alertShown = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    context.read<FetchUserCubit>().getAllUserBasedonRole();
    if (widget.preSelectedDate != null && widget.preSelectedDate!.isNotEmpty) {
      hintDate = widget.preSelectedDate;
      setState(() {});
    }

    if (widget.preSelectedTime != null && widget.preSelectedTime!.isNotEmpty) {
      setState(() {
        hintTime = widget.preSelectedTime;
      });
    }
    if (widget.isEditTask &&
        widget.taskId != null &&
        widget.taskId!.isNotEmpty) {
      log("Editing task with ID: ${widget.taskId}");
      context.read<FetchTasksCubit>().fetchtaskInfo(taskId: widget.taskId!);
    }
  }

  TimeOfDay? selectedTime;
  String? hintTime;

  String? selectedRole;
  AllUserInfo? selectedMember;
  bool isPrefilled = false;

  String? selectedPriority;

  List<AllUserInfo> selectedUserToAssignTask = [];
  final List<Map<String, dynamic>> priorities = [
    {"label": "High", "color": AppColor.error},
    {"label": "Medium", "color": AppColor.warning},
    {"label": "Low", "color": AppColor.success},
  ];

  Future<void> pickDate(BuildContext context) async {
    DateTime? picked = await calenderPicker(
      context,
      isToday: true,
      lastDate: 2030,
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        String formatted = DateFormat('dd/MM/yyyy').format(picked);
        hintDate = formatted;
      });
    }
  }

  Future<void> pickTime(BuildContext context) async {
    final TimeOfDay? picked = await timePicker(
      context,
      selectedTime: selectedTime,
    );
    if (picked != null) {
      DateTime fullTime = DateTime(0, 1, 1, picked.hour, picked.minute);

      setState(() {
        selectedTime = picked;
        String formatted = DateFormat(' hh:mm a').format(fullTime);
        hintTime = formatted;
      });
    }
  }

  TextEditingController usertitleController = TextEditingController();
  TextEditingController userDescController = TextEditingController();
  TextEditingController userController = TextEditingController();
  // List<String> roleSelection = [
  //   "Chief",
  //   "Lead",
  //   "Board Member",
  //   "Guest",
  //   "Stakeholder",
  // ];
  List<AllUserInfo> personSelectionList = [];

  @override
  Widget build(BuildContext context) {
    final addTaskBloc = context.read<AddTasksCubit>();
    final bool checkEditMode =
        widget.isEditTask && widget.taskId != null && widget.taskId!.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: MyCustomAppBar(
        heading: checkEditMode ? "Edit Task" : "Add Task",
        onBackPressed: () {
          context.read<FetchTasksCubit>().reset();
        },

        subTitle: checkEditMode
            ? "Modify task details and members"
            : "Select members and set priority",
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 25.w),
          child: BlocListener<AddTasksCubit, AddTasksState>(
            listenWhen: (previous, current) =>
                previous.taskPostingStatus != current.taskPostingStatus,
            listener: (context, state) {
              if (state.taskPostingStatus == AddRequestStatus.loading) {
                setState(() {
                  isLoading = true;
                  alertShown = false;
                });
              } else if (state.taskPostingStatus == AddRequestStatus.success &&
                  !alertShown) {
                myAlertBox(
                  context,
                  subtittle: state.errorMsg,
                  heading: "Success",
                  onPressed: () {
                    Future.delayed(Duration(milliseconds: 300), () {
                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.navigationScreen,
                      );
                    });
                  },
                );
                setState(() {
                  isLoading = false;
                });
              } else if (state.taskPostingStatus == AddRequestStatus.failure) {
                myAlertBox(
                  context,
                  subtittle: state.errorMsg,
                  heading: "Assign Task Failed",
                );
                setState(() {
                  isLoading = false;
                });
              }
            },
            child: BlocBuilder<FetchTasksCubit, FetchTasksState>(
              builder: (context, state) {
                if (checkEditMode &&
                    state.fetchtaskInfo == FetchTaskStatus.loading) {
                  return Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 7.h),
                        myShimmerBoxSharp(height: 30.h, width: 100.w),
                        SizedBox(height: 7.h),
                        myShimmerBoxSharp(height: 50.h, width: double.infinity),
                        SizedBox(height: 20.h),
                        myShimmerBoxSharp(height: 30.h, width: 100.w),
                        SizedBox(height: 7.h),
                        myShimmerBoxSharp(
                          height: 110.h,
                          width: double.infinity,
                        ),
                        SizedBox(height: 20.h),
                        myShimmerBoxSharp(height: 30.h, width: 100.w),
                        SizedBox(height: 7.h),
                        myShimmerBoxSharp(height: 50.h, width: double.infinity),
                        SizedBox(height: 20.h),
                        myShimmerBoxSharp(height: 30.h, width: 200.w),
                        SizedBox(height: 7.h),
                        Row(
                          children: [
                            Expanded(
                              child: myShimmerBoxSharp(
                                height: 50.h,
                                width: double.infinity,
                              ),
                            ),
                            Expanded(
                              child: myShimmerBoxSharp(
                                height: 50.h,
                                width: double.infinity,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        myShimmerBoxSharp(height: 30.h, width: 100.w),
                        SizedBox(height: 7.h),
                        myShimmerBoxSharp(height: 50.h, width: double.infinity),
                      ],
                    ),
                  );
                } else if (checkEditMode &&
                    state.fetchtaskInfo == FetchTaskStatus.failed) {
                  return Center(
                    child: Text("Failed to load task data", style: t3White()),
                  );
                } else if (checkEditMode &&
                    state.fetchtaskInfo == FetchTaskStatus.sucess &&
                    state.taskInfoListEdit != null &&
                    state.taskInfoListEdit!.isNotEmpty &&
                    !isPrefilled) {
                  final taskData = state.taskInfoListEdit!.first;

                  usertitleController.text = taskData.title;
                  userDescController.text = taskData.description;
                  hintDate = taskData.date;
                  hintTime = taskData.time;
                  selectedPriority = taskData.priority;
                  isPrefilled = true;
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyUploadTextField(
                      userController: usertitleController,
                      labelText: "  Title",
                      hint: "Grocery Shopping",
                      frontIcon: Icons.title,
                    ),
                    MyUploadTextField(
                      userController: userDescController,
                      labelText: "  Description",
                      hint: "Weekly grocery run - check the family List......",
                      isDesc: true,
                    ),
                    // MyDropDownBUtton(
                    //   labelText: "Select role to assign task",
                    //   role: roleSelection[0],
                    //   itemsList: roleSelection,
                    //   icon: Icons.manage_accounts,
                    //   isRequired: true,
                    //   onChanged: (value) {
                    //     setState(() {
                    //       selectedRole = value ?? "Guest";
                    //       context.read<FetchUserCubit>().getAllUserBasedonRole(
                    //         role: selectedRole!,
                    //       );
                    //     });
                    //   },
                    // ),
                    Row(
                      children: [
                        Text(
                          "Select team members to assign task",
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
                    ),
                    SizedBox(height: 10.h),
                    BlocBuilder<FetchUserCubit, FetchUserState>(
                      builder: (context, state) {
                        if (state.fetchAllUserStatus ==
                            FetchRequestStatus.sucess) {
                          personSelectionList = state.userInfo!;
                        } else if (state.fetchAllUserStatus ==
                            FetchRequestStatus.loading) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 20.h, top: 10),
                            child: myShimmerBox(
                              width: double.infinity,
                              height: 57,
                            ),
                          );
                        }

                        // If no users, show dropdown with a disabled item
                        // if (personSelectionList.isEmpty) {
                        //   return MyDropDownMemberButton(
                        //     selectedEmail: null,
                        //     itemsList: const [],
                        //     icon: Icons.person,
                        //     onChanged: (value) {
                        //       setState(() {
                        //         selectedMember = null;
                        //       });
                        //     }, // disables the dropdown
                        //     hintText: "No user assigned yet",
                        //   );
                        // }

                        return MyDropDownMemberButton(
                          selectedEmail: null, // no user selected initially
                          itemsList: personSelectionList, // full member list
                          icon: Icons.person,
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              if (checkEditMode) {
                                // Only one user can be selected when editing
                                selectedUserToAssignTask = [value];
                              } else {
                                // Multiple users can be selected when adding
                                bool alreadySelected = selectedUserToAssignTask
                                    .any((user) => user.uid == value.uid);

                                if (!alreadySelected) {
                                  selectedUserToAssignTask.add(value);
                                } else {
                                  mySnackBar(
                                    context,
                                    title: "User is already selected",
                                  );
                                }
                              }
                            });
                          },
                        );
                      },
                    ),

                    selectedUserToAssignTask.isNotEmpty && !checkEditMode
                        ? Padding(
                            padding: EdgeInsets.only(left: 5.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 20.h, // adjust based on your layout
                                  child: DefaultTextStyle(
                                    style: t3White().copyWith(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    child: AnimatedTextKit(
                                      isRepeatingAnimation:
                                          false, // only type once
                                      animatedTexts: [
                                        TypewriterAnimatedText(
                                          'Selected Team Members',
                                          speed: Duration(
                                            milliseconds: 70,
                                          ), // typing speed
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                Row(
                                  children: selectedUserToAssignTask.map((
                                    user,
                                  ) {
                                    return Padding(
                                      padding: EdgeInsets.only(right: 10.w),
                                      child: MyProfileHolder(
                                        onPressed: () {
                                          setState(() {
                                            selectedUserToAssignTask.remove(
                                              user,
                                            );
                                          });
                                        },
                                        imagePath: user.imagePath!,
                                        name: user.name,
                                      ),
                                    );
                                  }).toList(),
                                ),
                                SizedBox(height: 20.h),
                              ],
                            ),
                          )
                        : SizedBox(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MyDateAndTimePickerBox(
                          onPressed: () {
                            pickDate(context);
                          },
                          hint: hintDate ?? "dd/mm/yyyy",
                          labelText: ' Schedule Date',
                          isExpanded: false,
                          frontIcon: Icons.calendar_month_outlined,
                        ),

                        MyDateAndTimePickerBox(
                          onPressed: () {
                            pickTime(context);
                          },
                          isRequired: false,
                          hint: hintTime ?? "12:00 AM",
                          labelText: ' Schedule Time',
                          isExpanded: false,
                          frontIcon: Icons.alarm,
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      children: [
                        Text(
                          "Task Priority",
                          style: t3White().copyWith(fontSize: 20.sp),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: List.generate(priorities.length, (index) {
                        final priority = priorities[index];
                        return Padding(
                          padding: EdgeInsets.only(right: 20.w),
                          child: Row(
                            children: [
                              Radio<String>(
                                value: priority["label"],
                                groupValue: selectedPriority,
                                activeColor: priority["color"],
                                onChanged: (value) {
                                  setState(() {
                                    selectedPriority = value!;
                                  });
                                },
                              ),
                              Text(priority["label"], style: t3White()),
                            ],
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: 20.h),
                    MyButtton(
                      text: checkEditMode ? "Update Task" : "Add Task",
                      isLoading: isLoading,
                      onPressed: () {
                        final String title = usertitleController.text
                            .toString();
                        final String desc = userDescController.text.toString();
                        if (title.isEmpty || desc.isEmpty) {
                          myAlertBox(
                            context,
                            subtittle: "Enter the required Field",
                            heading: "Assign Failed",
                          );
                        } else if (selectedUserToAssignTask.isEmpty) {
                          myAlertBox(
                            context,
                            subtittle: "Please assign a role to the task.",
                            heading: "Assign Failed",
                          );
                        } else if (hintDate == null) {
                          myAlertBox(
                            onPressed: () {},
                            context,
                            subtittle: "Please select a date to assign task",
                            heading: "Assign Failed",
                          );
                        } else {
                          addTaskBloc.addTaskFun(
                            title: title,
                            desc: desc,
                            date: hintDate ?? "",
                            priority: selectedPriority ?? "",
                            time: (hintTime?.isNotEmpty ?? false)
                                ? hintTime
                                : " 11:00 AM",
                            selectedUserToAssignTask: selectedUserToAssignTask,
                            editTaskId: checkEditMode
                                ? widget.taskId
                                : null, // <-- Pass editTaskId only when editing
                          );
                        }
                      },
                    ),
                    SizedBox(height: 50.h),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
