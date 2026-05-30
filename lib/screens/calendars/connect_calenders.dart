import 'dart:developer';
import 'package:family_management_app/app/app%20Color/app_color.dart';
import 'package:family_management_app/app/api/google_calender_api.dart';
import 'package:family_management_app/app/routes/app_routes.dart';
import 'package:family_management_app/app/textStyle/textstyles.dart';
import 'package:family_management_app/app/utils/custom_appbar.dart';
import 'package:family_management_app/app/utils/utils.dart';
import 'package:family_management_app/bloc/google_calender/cubit/google_calendar_cubit.dart';
import 'package:family_management_app/service/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class ConnectCalendersScreen extends StatefulWidget {
  final String taskId;
  final String? taskTitle;
  final String? taskDescription;
  final String? taskStartDate;
  const ConnectCalendersScreen({
    super.key,
    required this.taskId,
    this.taskTitle,
    this.taskDescription,
    this.taskStartDate,
  });

  @override
  State<ConnectCalendersScreen> createState() => _ConnectCalendersScreenState();
}

class _ConnectCalendersScreenState extends State<ConnectCalendersScreen> {
  final googleCalendarHelper = GoogleCalendarHelper();

  bool isOff = true;
  List<bool> checkBoxValueBool = [false, true, false];
  String selectedValue = "";
  bool selectedValuebool = false;
  int selectedRadioIndex = -1;
  List<String> selectedCheckValue = [];
  List<String> checkBoxValueTitle = [
    "iCloud - Personal",
    "Google - alex@gmail.com",
    "Outlook - Work",
  ];
  String? savedUserRole;
  String? savedUserEmail;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getSecureData();
  }

  Future<void> getSecureData() async {
    final userRole = await AppStorage.read(key: "savedRole");
    final userEmail = await AppStorage.read(key: "email");

    setState(() {
      savedUserRole = userRole;
      savedUserEmail = userEmail;
      checkBoxValueTitle = [
        "iCloud - Personal",
        "Google - ${savedUserEmail ?? 'default@gmail.com'}",
        "Outlook - Work",
      ];
      selectedValue = "Google - ${savedUserEmail ?? 'default@gmail.com'}";
    });
    log("Connect calenderSection: ROLE: $userRole");
    log("Connect calenderSection: ROLE: ${widget.taskTitle}");
    log(savedUserRole!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyCustomAppBar(
        heading: "Connect Calenders",
        subTitle: "Stay organized by connecting your calendars",
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsGeometry.symmetric(
            horizontal: 25.w,
            vertical: 15.h,
          ),
          child: BlocListener<GoogleCalendarCubit, GoogleCalendarState>(
            listenWhen: (previous, current) =>
                previous.addStatus != current.addStatus,
            listener: (context, state) {
              if (state.addStatus == GoogleCalendarStatus.loading) {
                setState(() {
                  isLoading = true;
                });
              } else if (state.addStatus == GoogleCalendarStatus.success) {
                myAlertBox(
                  context,
                  subtittle: state.error,
                  heading: "Success",
                  onPressed: () {
                    Navigator.pop(context); // Close alert first
                    Future.delayed(const Duration(milliseconds: 500), () {
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
              } else if (state.addStatus == GoogleCalendarStatus.failure) {
                mySnackBar(context, title: "❌ Failed: ${state.error}");
                setState(() {
                  isLoading = false;
                });
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        "Show my phone's calenders in Altos HQ",
                        style: t2White(),
                      ),
                    ),
                    SizedBox(width: 5.w),
                    mySwitch(
                      isOff: isOff,
                      onChanged: (value) {
                        setState(() {
                          isOff = !isOff;
                        });
                      },
                    ),
                  ],
                ),

                SizedBox(height: 20.h),
                Column(
                  children: List.generate(3, (index) {
                    return myCheckWithText(
                      checkValue: checkBoxValueBool[index],
                      onPressed: () {
                        setState(() {
                          checkBoxValueBool[index] = !checkBoxValueBool[index];
                          if (selectedCheckValue.contains(
                            checkBoxValueTitle[index],
                          )) {
                            selectedCheckValue.remove(
                              checkBoxValueTitle[index],
                            );
                          } else {
                            selectedCheckValue.add(checkBoxValueTitle[index]);
                          }
                        });
                      },

                      text: checkBoxValueTitle[index],
                    );
                  }),
                ),
                Divider(thickness: 0.2.sp),
                SizedBox(height: 15.h),
                Text('Save new events to', style: t2White()),

                Column(
                  children: List.generate(3, (index) {
                    return RadioListTile(
                      contentPadding: EdgeInsets.zero,
                      activeColor: AppColor.secondary,
                      radioScaleFactor: 1.3.sp,
                      title: Text(
                        checkBoxValueTitle[index],
                        style: t3White().copyWith(fontSize: 20.sp),
                      ),
                      value: checkBoxValueTitle[index],
                      groupValue: selectedValue,
                      onChanged: (value) {
                        setState(() {
                          selectedValue = value!;
                        });
                        log(selectedValue);
                      },
                    );
                  }),
                ),
                SizedBox(height: 50.h),

                MyButtton(
                  text: "Continue",
                  isLoading: isLoading,
                  onPressed: () {
                    final formatter = DateFormat("dd/MM/yyyy hh:mm a");

                    // Merge your date + time into one string
                    final dateTimeString = widget.taskStartDate;
                    final startDate = formatter.parse(dateTimeString!);
                    final endDate = startDate.add(const Duration(hours: 1));

                    context.read<GoogleCalendarCubit>().saveTask(
                      taskId: widget.taskId,
                      title: widget.taskTitle ?? "",
                      description: widget.taskDescription ?? "",
                      startDate: startDate, // your parsed DateTime
                      endDate: endDate, // optional
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget myCheckWithText({
    bool checkValue = false,
    required VoidCallback onPressed,
    required String text,
  }) {
    return GestureDetector(
      onTap: onPressed,

      child: Padding(
        padding: EdgeInsets.only(bottom: 20.h, right: 10.w),
        child: Row(
          children: [
            Expanded(
              child: Text(text, style: t3White().copyWith(fontSize: 20.sp)),
            ),
            Container(
              width: 24.w,
              height: 24.h,
              decoration: BoxDecoration(
                // fill when checked
                border: Border.all(
                  color: AppColor.border, // border color
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: checkValue
                  ? Icon(
                      Icons.check,
                      color: AppColor.border,
                      size: 18.sp,
                    ) // tick when checked
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
