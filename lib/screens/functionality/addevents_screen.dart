import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:family_management_app/app/app%20Color/app_color.dart';
import 'package:family_management_app/app/routes/app_routes.dart';
import 'package:family_management_app/app/textStyle/textstyles.dart';
import 'package:family_management_app/app/utils/calender_pick.dart';
import 'package:family_management_app/app/utils/custom_appbar.dart';
import 'package:family_management_app/app/utils/utils.dart';
import 'package:family_management_app/app/utils/shimmer.dart';
import 'package:family_management_app/bloc/add%20tasks/add_tasks_cubit.dart';
import 'package:family_management_app/bloc/fetch%20User/fetch_user_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class AddEventsScreen extends StatefulWidget {
  final String? preSelectedDate;
  final String? preSelectedTime;
  const AddEventsScreen({
    super.key,
    this.preSelectedDate,
    this.preSelectedTime,
  });

  @override
  State<AddEventsScreen> createState() => _AddEventsScreenState();
}

class _AddEventsScreenState extends State<AddEventsScreen> {
  bool alertShown = false;
  DateTime? selectedDate;
  String? hintDate;
  bool isLoading = false;
  TimeOfDay? selectedTime;
  String? hintTime;
  String? selectedRole;
  String? selectedMember;

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
    TimeOfDay now = TimeOfDay.now();

    final TimeOfDay? picked = await timePicker(
      context,
      selectedTime: selectedTime,
    );
    if (picked != null) {
      final int pickedMinutes = picked.hour * 60 + picked.minute;
      final int nowMinutes = now.hour * 60 + now.minute;

      if (pickedMinutes < nowMinutes) {
        mySnackBar(context, title: "Cannot select past time");
        return;
      }
      DateTime fullTime = DateTime(0, 1, 1, picked.hour, picked.minute);

      setState(() {
        selectedTime = picked;
        String formatted = DateFormat(' hh:mm a').format(fullTime);
        hintTime = formatted;
      });
    }
  }

  List<AllUserInfo> selectedUserToAssignEvent = [];

  TextEditingController usertitleController = TextEditingController();
  TextEditingController userDescController = TextEditingController();
  TextEditingController userController = TextEditingController();
  List<String> roleSelection = [
    "Chief",
    "Lead",
    "Board Member",
    "Guest",
    "Stakeholder",
  ];
  List<AllUserInfo> personSelectionList = [];

  @override
  void initState() {
    super.initState();
    context.read<FetchUserCubit>().getAllUserBasedonRole();

    if (widget.preSelectedDate != null && widget.preSelectedDate!.isNotEmpty) {
      setState(() {
        hintDate = widget.preSelectedDate;
      });
    }

    if (widget.preSelectedTime != null && widget.preSelectedTime!.isNotEmpty) {
      setState(() {
        hintTime = widget.preSelectedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final addEventBloc = context.read<AddTasksCubit>();
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: MyCustomAppBar(
        heading: "Add Event",
        subTitle: "Pick participants and schedule it",
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 25.w),
          child: BlocListener<AddTasksCubit, AddTasksState>(
            listenWhen: (previous, current) =>
                previous.eventPostingStatus != current.eventPostingStatus,
            listener: (context, state) {
              if (state.eventPostingStatus == AddRequestStatus.loading) {
                setState(() {
                  isLoading = true;
                  alertShown = false;
                });
              } else if (state.eventPostingStatus == AddRequestStatus.success &&
                  !alertShown) {
                myAlertBox(
                  context,
                  subtittle: state.errorMsg,
                  heading: "Success",
                  onPressed: () {
                    Future.delayed(const Duration(milliseconds: 300), () {
                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.navigationScreen,
                      );
                    });
                  },
                );

                // usertitleController.clear();
                // userDescController.clear();
                // selectedRole = "";
                // selectedUserToAssignEvent.clear();
                // selectedDate = null;
                // hintDate = null;
                // selectedTime = null;
                // hintTime = null;

                setState(() {
                  isLoading = false;
                });
              } else if (state.eventPostingStatus == AddRequestStatus.failure) {
                myAlertBox(
                  context,
                  subtittle: state.errorMsg,
                  heading: "Assign Event Failed",
                );
                setState(() {
                  isLoading = false;
                });
              }
            },
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyUploadTextField(
                    userController: usertitleController,
                    labelText: " Event Title",
                    hint: "Prepare slides for presentation",
                    frontIcon: Icons.title,
                  ),
                  MyUploadTextField(
                    userController: userDescController,
                    labelText: " Description",
                    hint:
                        "Include agenda, key points, and action items .......",
                    isDesc: true,
                  ),
                  // MyDropDownBUtton(
                  //   labelText: "Select role to assign event",
                  //   role: roleSelection[0],
                  //   itemsList: roleSelection,
                  //   icon: Icons.manage_accounts,
                  //   isRequired: true,
                  //   onChanged: (value) {
                  //     setState(() {
                  //       selectedRole = value ?? "Guest";
                  //       context.read<FetchUserCubit>().getAllUserBasedonRole(
                  //         // role: selectedRole!,
                  //       );
                  //     });
                  //   },
                  // ),
                  Row(
                    children: [
                      Text(
                        "Select team members to assign events ",
                        style: t3White().copyWith(fontSize: 20.sp),
                      ),
                      Text(
                        "*",
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
                      if (personSelectionList.isEmpty) {
                        return MyDropDownMemberButton(
                          selectedEmail: null,
                          itemsList: const [],
                          icon: Icons.person,
                          onChanged: (value) {
                            setState(() {
                              selectedMember = null;
                            });
                          }, // disables the dropdown
                          hintText: "No user assigned yet",
                        );
                      }
                      return MyDropDownMemberButton(
                        selectedEmail: null,
                        itemsList: personSelectionList,
                        icon: Icons.person,
                        onChanged: (value) {
                          setState(() {
                            if (value != null &&
                                !selectedUserToAssignEvent.any(
                                  (user) => user.uid == value.uid,
                                )) {
                              selectedUserToAssignEvent.add(value);
                            } else {
                              mySnackBar(
                                context,
                                title: "User is selected already",
                              );
                            }
                          });
                        },
                      );
                    },
                  ),

                  selectedUserToAssignEvent.isNotEmpty
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
                                children: selectedUserToAssignEvent.map((user) {
                                  return Padding(
                                    padding: EdgeInsets.only(right: 10.w),
                                    child: MyProfileHolder(
                                      onPressed: () {
                                        setState(() {
                                          selectedUserToAssignEvent.remove(
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

                  SizedBox(height: 20.h),
                  MyButtton(
                    text: "Assign Event",
                    isLoading: isLoading,
                    onPressed: () {
                      final String title = usertitleController.text.toString();
                      final String desc = userDescController.text.toString();
                      if (title.isEmpty || desc.isEmpty) {
                        myAlertBox(
                          context,
                          subtittle: "Enter the required Field",
                          heading: "Assign Failed",
                        );
                      } else if (selectedUserToAssignEvent.isEmpty) {
                        myAlertBox(
                          context,
                          subtittle: "Please assign a role to the event.",
                          heading: "Assign Failed",
                        );
                      } else if (hintDate == null) {
                        myAlertBox(
                          onPressed: () {},
                          context,
                          subtittle: "Please select a date to assign event",
                          heading: "Assign Failed",
                        );
                      } else {
                        addEventBloc.addEventFun(
                          title: title,
                          desc: title,
                          date: hintDate ?? "",
                          time: hintTime ?? "11:00 AM",
                          selectedUserToAssignEvent: selectedUserToAssignEvent,
                        );
                      }
                    },
                  ),
                  SizedBox(height: 50.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
