import 'dart:developer';
import 'package:family_management_app/app/app%20Color/app_color.dart';
import 'package:family_management_app/app/routes/app_routes.dart';
import 'package:family_management_app/app/utils/shimmer.dart';
import 'package:family_management_app/app/textStyle/textstyles.dart';
import 'package:family_management_app/app/utils/custom_appbar.dart';
import 'package:family_management_app/app/utils/utils.dart';
import 'package:family_management_app/bloc/fetch%20User/fetch_user_cubit.dart';
import 'package:family_management_app/bloc/fetch_tasks/fetch_tasks_cubit.dart';
import 'package:family_management_app/service/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileScreen extends StatefulWidget {
  final String? uid;
  final String? assignedEmail;
  final bool isChild;

  const ProfileScreen({
    super.key,
    required this.uid,
    required this.assignedEmail,
    this.isChild = false,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? savedUserRole;
  String? savedUserName;
  String? savedUserImage;
  String? savedUserEmail;
  int selectedIndex = 0;
  bool isOff = false;
  List<String> tabTitles = ['TODAY', 'TOMORROW', 'ADD'];
  @override
  void initState() {
    super.initState();
    getSecureData();
    widget.isChild
        ? context.read<FetchUserCubit>().fetchProfileInfoChild(
            uid: widget.uid ?? "",
          )
        : context.read<FetchUserCubit>().fetchProfileInfo(
            uid: widget.uid ?? "",
          );

    context.read<FetchTasksCubit>().fetchTasks();
    context.read<FetchTasksCubit>().getDateAndRoleForCalander(
      name: "Stakeholder",
    );
  }

  List<IconData> icon = [
    Icons.warning_amber_outlined,
    Icons.phone_outlined,
    Icons.monitor_heart,
  ];
  List<String> iconText = ["ALLERGIES", 'EMERGENCY\nCONTACT', 'PEDIATRICIAN'];

  List<String> title = ["8:30 AM Drop off", "4:00 PM Dance class"];
  List<String> subTitle = ["Doug", "Grandma"];
  List<bool> switchButton = [false, true];

  Future<void> getSecureData() async {
    final userRole = await AppStorage.read(key: "savedRole");
    final userName = await AppStorage.read(key: "name");
    final userImage = await AppStorage.read(key: "imagePath");
    final useremail = await AppStorage.read(key: "email");

    setState(() {
      savedUserRole = userRole;
      savedUserName = userName;
      savedUserImage = userImage;
      savedUserEmail = useremail;
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskBloc = context.read<FetchTasksCubit>();
    return Scaffold(
      appBar: MyCustomAppBar(
        onBackPressed: () {
          context.read<FetchUserCubit>().resetState();
        },
        heading: "Profile Info",
        subTitle: "View and manage your team members’ details",
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: 10.h,
              horizontal: widget.isChild ? 10.w : 20.w,
            ).copyWith(right: 0.w, bottom: 120.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // This is the profile info Column......................................................
                widget.assignedEmail == savedUserEmail
                    ? Column(
                        children: [
                          Text(
                            savedUserName ?? "",
                            style: t1heading().copyWith(fontSize: 30.sp),
                          ),
                          Text(savedUserRole ?? "", style: t3White()),
                          SizedBox(height: 10.h),
                          MyProfileHolder(
                            width: 100,
                            height: 100,
                            fontSize: 50,
                            name: savedUserName ?? "",
                            imagePath: savedUserImage ?? "",
                          ),
                          SizedBox(height: 15.h),
                          Text(savedUserEmail ?? "", style: t1White()),
                        ],
                      )
                    : widget.isChild
                    ? BlocBuilder<FetchUserCubit, FetchUserState>(
                        builder: (context, state) {
                          if (state.fetchProfileInfoChildStatus ==
                              FetchRequestStatus.sucess) {
                            final childInfo = state.childInfo;

                            String childAgeShowing =
                                childInfo?.age?.split("y")[0] ?? "";

                            return Column(
                              children: [
                                MyProfileHolder(
                                  width: 100,
                                  height: 100,
                                  fontSize: 50,
                                  name: childInfo?.name ?? "",
                                  imagePath: childInfo?.imagePath ?? "",
                                ),
                                SizedBox(height: 7.h),
                                Text(
                                  childInfo?.name ?? "",
                                  style: t1heading().copyWith(fontSize: 35.sp),
                                ),

                                Text(
                                  "Age: ${childAgeShowing}y [${childInfo?.dob ?? ""}]",

                                  style: t1White(),
                                ),
                              ],
                            );
                          } else if (state.fetchProfileInfoChildStatus ==
                              FetchRequestStatus.loading) {
                            return Column(
                              children: [
                                myShimmerBoxCircle(width: 100, height: 100),
                                SizedBox(height: 12.h),
                                myShimmerBoxSharp(height: 30.h, width: 150.w),
                                SizedBox(height: 5.h),
                                myShimmerBoxSharp(height: 20.h, width: 220.w),
                                SizedBox(height: 5.h),
                              ],
                            );
                          } else {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        },
                      )
                    : BlocBuilder<FetchUserCubit, FetchUserState>(
                        builder: (context, state) {
                          if (state.fetchProfileInfoStatus ==
                              FetchRequestStatus.sucess) {
                            return Column(
                              children: [
                                Text(
                                  state.name ?? "",
                                  style: t1heading().copyWith(fontSize: 30.sp),
                                ),
                                Text(state.role ?? "", style: t3White()),
                                SizedBox(height: 10.h),
                                MyProfileHolder(
                                  width: 100,
                                  height: 100,
                                  fontSize: 50,
                                  name: state.name ?? "",
                                  imagePath: state.imagePath ?? "",
                                ),
                                SizedBox(height: 15.h),
                                Text(state.email ?? "", style: t1White()),
                              ],
                            );
                          } else if (state.fetchProfileInfoStatus ==
                              FetchRequestStatus.loading) {
                            return Column(
                              children: [
                                myShimmerBoxSharp(height: 30.h, width: 220.w),
                                SizedBox(height: 7.h),
                                myShimmerBoxSharp(height: 18, width: 70),
                                SizedBox(height: 10.h),
                                myShimmerBoxCircle(width: 100, height: 100),
                                SizedBox(height: 15.h),
                                myShimmerBoxSharp(height: 22, width: 250),
                                SizedBox(height: 3.h),
                              ],
                            );
                          } else {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        },
                      ),
                SizedBox(height: 20.h),

                widget.isChild
                    ? BlocBuilder<FetchUserCubit, FetchUserState>(
                        builder: (context, state) {
                          return Padding(
                            padding: EdgeInsets.only(right: 5.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: List.generate(3, (index) {
                                return myIconContainer(
                                  onPressed: () {
                                    if (index == 0) {
                                      showChildDetailsAlert(
                                        context: context,
                                        text:
                                            state.childInfo?.allergies ??
                                            "No Allergies",
                                        icon: Icons.warning,
                                      );
                                    } else if (index == 1) {
                                      showChildDetailsAlert(
                                        context: context,
                                        text: "+977 9869874834",
                                        icon: Icons.phone,
                                      );
                                    } else {
                                      showChildDetailsAlert(
                                        context: context,
                                        text: "An Apple a day ",
                                        icon: Icons.health_and_safety,
                                      );
                                    }
                                  },
                                  icon: icon[index],
                                  text: iconText[index],
                                );
                              }),
                            ),
                          );
                        },
                      )
                    : Container(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Tasks",
                          style: t1heading().copyWith(fontSize: 30),
                        ),
                      ),
                SizedBox(height: 20.h),

                widget.isChild
                    ? Expanded(
                        child: BlocBuilder<FetchTasksCubit, FetchTasksState>(
                          builder: (context, state) {
                            final tasks = state.taskInfoList ?? [];

                            // Filter tasks by date
                            // final today = DateTime.now();
                            // final tomorrow = DateTime.now().add(
                            //   Duration(days: 1),
                            // );

                            DateTime? parseDate(String dateStr) {
                              try {
                                final parts = dateStr.split(
                                  '/',
                                ); // "20/09/2025" -> ["20", "09", "2025"]
                                if (parts.length != 3) return null;
                                final day = int.parse(parts[0]);
                                final month = int.parse(parts[1]);
                                final year = int.parse(parts[2]);
                                return DateTime(year, month, day);
                              } catch (_) {
                                return null;
                              }
                            }

                            final today = DateTime.now();
                            final tomorrow = today.add(Duration(days: 1));

                            final todayTasks = tasks.where((task) {
                              if (task.date.isEmpty) return false;
                              final taskDate = parseDate(task.date);
                              if (taskDate == null) return false;

                              return taskDate.year == today.year &&
                                  taskDate.month == today.month &&
                                  taskDate.day == today.day;
                            }).toList();

                            final tomorrowTasks = tasks.where((task) {
                              if (task.date.isEmpty) return false;
                              final taskDate = parseDate(task.date);
                              if (taskDate == null) return false;

                              return taskDate.year == tomorrow.year &&
                                  taskDate.month == tomorrow.month &&
                                  taskDate.day == tomorrow.day;
                            }).toList();
                            return Column(
                              children: [
                                Text(
                                  "Daily Schedule".toUpperCase(),
                                  style: t1heading().copyWith(
                                    fontSize: 30.sp,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                SizedBox(height: 15.h),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20.w,
                                  ),
                                  child: Stack(
                                    alignment: Alignment.bottomLeft,
                                    children: [
                                      Container(
                                        height: 0.3.h,
                                        width: double.infinity,
                                        color: Colors.grey[500],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: List.generate(tabTitles.length, (
                                          index,
                                        ) {
                                          return GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                log(tasks[0].date);
                                                selectedIndex = index;
                                              });
                                            },
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                right: 20.w,
                                              ),
                                              child: IntrinsicWidth(
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      tabTitles[index],
                                                      style: t3White().copyWith(
                                                        fontSize:
                                                            selectedIndex ==
                                                                index
                                                            ? 25.sp
                                                            : 20.sp,
                                                        fontWeight:
                                                            selectedIndex ==
                                                                index
                                                            ? FontWeight.w500
                                                            : FontWeight.w200,
                                                        color:
                                                            selectedIndex ==
                                                                index
                                                            ? AppColor.secondary
                                                            : Colors.grey[500],
                                                      ),
                                                    ),
                                                    SizedBox(height: 8.h),
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color:
                                                            selectedIndex ==
                                                                index
                                                            ? AppColor.secondary
                                                            : Colors
                                                                  .transparent,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              2.r,
                                                            ),
                                                      ),
                                                      height: 1.4.h,
                                                      width: double.infinity,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                      ),
                                    ],
                                  ),
                                ),

                                // Shimmer while fetching
                                state.getDateAndRoleForCalanderStatus ==
                                        FetchTaskStatus.loading
                                    ? Expanded(
                                        child: ListView.builder(
                                          padding: EdgeInsets.only(
                                            bottom: 20.h,
                                          ),
                                          itemCount: todayTasks.length,
                                          itemBuilder: (context, index) =>
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                  vertical: 8.h,
                                                  horizontal: 20.w,
                                                ),
                                                child: myShimmerBoxSharp(
                                                  height: 70.h,
                                                  width: double.infinity,
                                                ),
                                              ),
                                        ),
                                      )
                                    : selectedIndex ==
                                          0 // Today
                                    ? Expanded(
                                        child: todayTasks.isEmpty
                                            ? Center(
                                                child: Text(
                                                  "No tasks or events assigned yet.",
                                                  style: t3White(),
                                                ),
                                              )
                                            : ListView.builder(
                                                padding: EdgeInsets.only(
                                                  bottom: 20.h,
                                                ),
                                                itemCount: todayTasks.length,
                                                itemBuilder: (context, index) {
                                                  final task =
                                                      todayTasks[index];
                                                  return textWithSwitchController(
                                                    title:
                                                        task.title ??
                                                        "Untitled Task",
                                                    subTitle:
                                                        task.description ?? "",
                                                    isOff: false,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        switchButton[index] =
                                                            value;
                                                      });
                                                    },
                                                  );
                                                },
                                              ),
                                      )
                                    : selectedIndex ==
                                          1 // Tomorrow
                                    ? Expanded(
                                        child: tomorrowTasks.isEmpty
                                            ? Center(
                                                child: Text(
                                                  "No tasks or events assigned yet.",
                                                  style: t3White(),
                                                ),
                                              )
                                            : ListView.builder(
                                                padding: EdgeInsets.only(
                                                  bottom: 20.h,
                                                ),
                                                itemCount: tomorrowTasks.length,
                                                itemBuilder: (context, index) {
                                                  final task =
                                                      tomorrowTasks[index];
                                                  return textWithSwitchController(
                                                    title:
                                                        task.title ??
                                                        "Untitled Task",
                                                    subTitle:
                                                        task.description ?? "",
                                                    isOff: false,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        switchButton[index] =
                                                            value;
                                                      });
                                                    },
                                                  );
                                                },
                                              ),
                                      )
                                    : Expanded(
                                        child: Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              addButtonContainer(
                                                icon: Icons.add,
                                                text: "Add Event",
                                                onPressed: () {
                                                  Navigator.pushNamed(
                                                    context,
                                                    AppRoutes.addTasksScreen,
                                                    arguments: {'isBack': true},
                                                  );
                                                },
                                              ),
                                              addButtonContainer(
                                                icon: Icons.task_alt,
                                                text: "Add Chores",
                                                onPressed: () {
                                                  Navigator.pushNamed(
                                                    context,
                                                    AppRoutes.addEventsScreen,
                                                    arguments: {'isBack': true},
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                              ],
                            );
                          },
                        ),
                      )
                    : BlocBuilder<FetchTasksCubit, FetchTasksState>(
                        builder: (context, state) {
                          final taskInfoList = state.taskInfoList ?? [];
                          final taskList = taskInfoList
                              .where(
                                (task) =>
                                    task.assignedTo == widget.assignedEmail,
                              )
                              .toList();
                          if (state.fetchTasksStatus ==
                              FetchTaskStatus.loading) {
                            return Column(
                              children: List.generate(taskList.length, (index) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 5.h,
                                  ).copyWith(right: 20.w),
                                  child: myShimmerBoxSharp(
                                    height: 50.h,
                                    width: double.infinity,
                                  ),
                                );
                              }),
                            );
                          }
                          if (state.fetchTasksStatus ==
                              FetchTaskStatus.sucess) {
                            return taskList.isEmpty
                                ? Container(
                                    height: 300.h,
                                    alignment: Alignment.center,
                                    child: Text(
                                      "No Pending Tasks.....",
                                      style: hintTextStyle().copyWith(
                                        fontSize: 20.sp,
                                      ),
                                    ),
                                  )
                                : Column(
                                    children: List.generate(taskList.length, (
                                      index,
                                    ) {
                                      return Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              taskList[index].title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: t2White().copyWith(
                                                fontSize: 22.sp,
                                                color: AppColor.textSecondary,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 5.w),
                                          Row(
                                            children: [
                                              acceptButton(
                                                index: 0,
                                                onYesClick: () {
                                                  myAlertBoxYesNo(
                                                    context,
                                                    onYesPressed: () {
                                                      Navigator.pop(context);
                                                      taskBloc.markAsDoneFun(
                                                        taskId: [
                                                          taskInfoList[index]
                                                              .taskId,
                                                        ],
                                                      );
                                                      mySnackBar(
                                                        context,
                                                        title:
                                                            "${taskInfoList[index].title} task completed sucessfully",
                                                      );
                                                    },
                                                    heading: "Confirm Accept?",
                                                    subtittle:
                                                        "Do you really want to accept this task?",
                                                  );
                                                },
                                                onNoClick: () {},
                                              ),
                                              acceptButton(
                                                index: 1,
                                                onYesClick: () {},
                                                onNoClick: () {
                                                  myAlertBoxYesNo(
                                                    context,
                                                    onYesPressed: () {
                                                      Navigator.pop(context);
                                                      taskBloc.deleteTask(
                                                        taskId: [
                                                          taskInfoList[index]
                                                              .taskId,
                                                        ],
                                                      );
                                                      mySnackBar(
                                                        context,
                                                        title:
                                                            "${taskInfoList[index].title} deleted sucessfully",
                                                      );
                                                    },
                                                    heading:
                                                        "Confirm Deletion?",
                                                    subtittle:
                                                        "Are you sure you want to delete this task?",
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    }),
                                  );
                          } else {
                            return Center(child: CircularProgressIndicator());
                          }
                        },
                      ),
                // Padding(
                //   padding: EdgeInsets.only(right: 10.w, top: 20.h),
                //   child: myTextHolderContainer(
                //     child: Text(
                //       textAlign: TextAlign.center,
                //       "Calendar",
                //       style: t1heading().copyWith(fontSize: 25.sp),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),

          // Bottom assistant bar
          Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              child: Container(
                alignment: Alignment.center,
                color: AppColor.background,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 20.h,
                  ).copyWith(right: 10.w, bottom: 70.h),
                  child: myTextHolderContainer(
                    child: Row(
                      children: [
                        Text("Ask Avia - Your AI Assistant", style: t3White()),
                        Spacer(),
                        Icon(Icons.mic_outlined, color: AppColor.secondary),
                        SizedBox(width: 15.w),
                        Icon(Icons.message),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget acceptButton({
    required int index,
    required VoidCallback onYesClick,
    required VoidCallback onNoClick,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15.h, right: 10.w),
      child: GestureDetector(
        onTap: index == 0 ? onYesClick : onNoClick,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColor.secondary.withAlpha(10),
            borderRadius: BorderRadius.circular(7.r),
            border: BoxBorder.all(width: 1, color: AppColor.secondary),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.h),
            child: Text(
              index == 0 ? "Accept" : "Decline",
              style: hintTextStyle().copyWith(
                color: AppColor.secondary,
                fontSize: 20.sp,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget myIconContainer({
    required VoidCallback onPressed,

    required String text,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 95.h,

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7.r),
          border: Border.all(width: 1, color: AppColor.secondary),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 7.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30.sp),
              SizedBox(height: 10.h),
              Text(
                text,
                textAlign: TextAlign.center,

                style: t1heading().copyWith(fontSize: 16.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget textWithSwitchController({
    required String title,
    required String subTitle,
    required bool isOff,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.h).copyWith(top: 15.h),
      child: Column(
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(" $title", style: t3White()),

                  Text(
                    " $subTitle",
                    style: hintTextStyle().copyWith(fontSize: 20.sp),
                  ),
                ],
              ),
              Spacer(),
              Switch(
                value: isOff,

                activeColor: AppColor.secondary, // thumb color ON
                activeTrackColor: Colors.transparent, // track color ON
                inactiveThumbColor: Colors.grey, // thumb color OFF
                inactiveTrackColor: Colors.transparent, // track color OFF
                trackOutlineColor: WidgetStateProperty.resolveWith<Color>((
                  states,
                ) {
                  if (states.contains(WidgetState.selected)) {
                    return AppColor.secondary; // outline when active
                  }
                  return Colors.grey.shade700.withAlpha(
                    200,
                  ); // outline when inactive
                }),
                onChanged: onChanged,
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Container(
            height: 0.3.h,
            width: double.infinity,
            color: Colors.grey[500],
          ),
        ],
      ),
    );
  }

  Widget addButtonContainer({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 25.w),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7.r),
            color: AppColor.secondary.withAlpha(10),
            border: Border.all(width: 1, color: AppColor.secondary),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 15.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon),
                SizedBox(width: 7.w),
                Text(text, style: t1heading().copyWith(fontSize: 20.sp)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// Container(
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     color: AppColor.background,
//                     borderRadius: BorderRadius.circular(10.r),
//                     border: BoxBorder.all(
//                       width: 1.w,
//                       color: AppColor.secondary,
//                     ),
//                   ),
//                   child: Padding(
//                     padding: EdgeInsets.symmetric(
//                       vertical: 15.h,
//                       horizontal: 25.w,
//                     ),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: Row(
//                             children: [
//                               Text(
//                                 "Ask Avia - Your AI Assistant",
//                                 style: t3White(),
//                               ),
//                               Spacer(),
//                               Icon(
//                                 Icons.mic_outlined,
//                                 color: AppColor.secondary,
//                               ),
//                             ],
//                           ),
//                         ),
                       
//                       ],
//                     ),
//                   ),
//                 ),
