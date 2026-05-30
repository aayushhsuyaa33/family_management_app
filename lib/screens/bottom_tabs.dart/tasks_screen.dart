import 'dart:developer';
import 'package:confetti/confetti.dart';
import 'package:family_management_app/app/app%20Color/app_color.dart';
import 'package:family_management_app/app/images/app_images.dart';
import 'package:family_management_app/app/routes/app_routes.dart';
import 'package:family_management_app/app/textStyle/textstyles.dart';
import 'package:family_management_app/app/utils/custom_appbar.dart';
import 'package:family_management_app/app/utils/shimmer.dart';
import 'package:family_management_app/app/utils/utils.dart';
import 'package:family_management_app/bloc/fetch_tasks/fetch_tasks_cubit.dart';
import 'package:family_management_app/service/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:lottie/lottie.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

class TasksScreen extends StatefulWidget {
  final bool isBack;

  const TasksScreen({super.key, this.isBack = false});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  late ConfettiController confettiController;
  TextEditingController searchController = TextEditingController();
  String? savedUserRole;
  String? savedUserName;
  List<String> tasksChecked = [];
  List<String> deletedTaskIds = [];
  List<TaskInfo> filteredTasks = [];
  bool isdeleting = false;
  bool isMarking = false;
  List<Color> confettiColors = [
    Colors.green,
    Colors.blue,
    Colors.pink,
    Colors.orange,
    Colors.purple,
  ];

  @override
  void initState() {
    super.initState();
    getSecureData();
    context.read<FetchTasksCubit>().fetchTasks();
    confettiController = ConfettiController(
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    confettiController.dispose();
    super.dispose();
  }

  void onSearchChanged(String query) {
    final allTasks = context.read<FetchTasksCubit>().state.taskInfoList ?? [];

    if (query.isEmpty) {
      filteredTasks = allTasks;
    } else {
      filteredTasks = allTasks.where((task) {
        final titleLower = task.title.toLowerCase();
        final descLower = task.description.toLowerCase();
        final queryLower = query.toLowerCase();
        return titleLower.contains(queryLower) ||
            descLower.contains(queryLower);
      }).toList();
    }

    setState(() {}); // refresh UI
  }

  Future<void> getSecureData() async {
    final userRole = await AppStorage.read(key: "savedRole");
    final userName = await AppStorage.read(key: "name");

    setState(() {
      savedUserRole = userRole;
      savedUserName = userName;
    });
    log("Task Section TAB: NAME: $userName, ROLE: $userRole,");
  }

  final List<Map<String, dynamic>> expandedIcons = [
    {"icon": Icons.add, "color": AppColor.secondary},
    {"icon": Icons.done, "color": AppColor.success},
    {"icon": Icons.delete_outline, "color": AppColor.error},
    {"icon": Icons.done, "color": AppColor.success},
    {"icon": Icons.calendar_month_outlined, "color": AppColor.secondary},
  ];

  @override
  Widget build(BuildContext context) {
    final taskBloc = context.read<FetchTasksCubit>();
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: widget.isBack
          ? MyCustomAppBar(
              heading: "Task Management",
              subTitle: " Manage and assign tasks",
            )
          : AppBar(
              backgroundColor: AppColor.background,
              automaticallyImplyLeading: false,
              toolbarHeight: 80.h,
              titleSpacing: 20.w,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Task Management",
                    style: t1heading().copyWith(fontSize: 30.sp),
                  ),
                  Text(" Manage and assign tasks", style: t3White()),
                ],
              ),
            ),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: confettiColors,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: BlocListener<FetchTasksCubit, FetchTasksState>(
              listenWhen: (previous, current) {
                // 👇 only listen when delete or mark-as-done status changes
                return previous.deleteTaskStatus != current.deleteTaskStatus ||
                    previous.markAsDoneStatus != current.markAsDoneStatus;
              },
              listener: (context, state) async {
                if (state.deleteTaskStatus == FetchTaskStatus.loading) {
                  setState(() {
                    isdeleting = true;
                  });
                } else if (state.deleteTaskStatus == FetchTaskStatus.sucess) {
                  mySnackBar(
                    context,
                    title: state.errorMsg ?? "Task Deleted Sucessfully",
                  );
                  setState(() {
                    tasksChecked.clear();
                    isdeleting = false;
                  });
                  context.read<FetchTasksCubit>().fetchPendingTaskForHomPage();
                } else if (state.deleteTaskStatus == FetchTaskStatus.failed) {
                  mySnackBar(
                    context,
                    title: state.errorMsg ?? "Deleting failed",
                  );
                  setState(() {
                    isdeleting = false;
                  });
                } else if (state.markAsDoneStatus == FetchTaskStatus.loading) {
                  setState(() {
                    isMarking = true;
                  });
                } else if (state.markAsDoneStatus == FetchTaskStatus.sucess) {
                  mySnackBar(
                    context,
                    title: state.errorMsg ?? "Task Marked Sucesfully",
                  );
                  confettiController.play();
                  setState(() {
                    tasksChecked.clear();
                    isMarking = false;
                  });
                  context.read<FetchTasksCubit>().fetchPendingTaskForHomPage();
                } else if (state.markAsDoneStatus == FetchTaskStatus.failed) {
                  mySnackBar(
                    context,
                    title: state.errorMsg ?? "Marking failed",
                  );
                  setState(() {
                    isMarking = false;
                  });
                } else {
                  setState(() {
                    isdeleting = false;
                    isMarking = false;
                  });
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (widget.isBack) SizedBox(height: 10.h),
                  BlocBuilder<FetchTasksCubit, FetchTasksState>(
                    builder: (context, state) {
                      List<Widget> actionIcons = [];

                      if (savedUserRole == "Chief") {
                        if (tasksChecked.isEmpty) {
                          // Show Add icon
                          actionIcons.add(
                            Padding(
                              padding: EdgeInsets.only(left: 10.w),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.addTasksScreen,
                                  );
                                },
                                child: Icon(
                                  expandedIcons[0]['icon'],
                                  size: 27.sp,
                                  color: expandedIcons[0]['color'],
                                ),
                              ),
                            ),
                          );
                        } else {
                          // Show Done + Delete icons
                          actionIcons.addAll([
                            // Done icon
                            Padding(
                              padding: EdgeInsets.only(left: 10.w),
                              child: GestureDetector(
                                onTap: () {
                                  myAlertBoxYesNo(
                                    context,
                                    onYesPressed: () async {
                                      Navigator.pop(context);
                                      taskBloc.markAsDoneFun(
                                        taskId: tasksChecked,
                                      );
                                    },
                                    heading: "Confirm Completion?",
                                    subtittle:
                                        "Do you really want to mark this task as done?",
                                  );
                                },
                                child: Icon(
                                  expandedIcons[1]['icon'],
                                  size: 27.sp,
                                  color: expandedIcons[1]['color'],
                                ),
                              ),
                            ),
                            // Deleet
                            // Delete icon.................................................................................
                            Padding(
                              padding: EdgeInsets.only(left: 10.w),
                              child: GestureDetector(
                                onTap: () {
                                  myAlertBoxYesNo(
                                    context,
                                    onYesPressed: () async {
                                      Navigator.pop(context);
                                      taskBloc.deleteTask(taskId: tasksChecked);
                                    },
                                    heading: "Confirm Deletion?",
                                    subtittle:
                                        "Are you sure you want to delete this task?",
                                  );
                                },
                                child: Icon(
                                  expandedIcons[2]['icon'],
                                  size: 27.sp,
                                  color: expandedIcons[2]['color'],
                                ),
                              ),
                            ),
                          ]);
                        }
                      } else {
                        // Not Chief
                        if (tasksChecked.length == 1) {
                          // Done + Calendar icon
                          final selectedTaskId = tasksChecked.first;
                          final selectedTask = state.taskInfoList!.firstWhere(
                            (task) => task.taskId == selectedTaskId,
                          );

                          actionIcons.addAll([
                            // Done icon
                            Padding(
                              padding: EdgeInsets.only(left: 10.w),
                              child: GestureDetector(
                                onTap: () {
                                  myAlertBoxYesNo(
                                    context,
                                    onYesPressed: () {
                                      Navigator.pop(context);
                                      taskBloc.markAsDoneFun(
                                        taskId: tasksChecked,
                                      );
                                    },
                                    heading: "Confirm Completion?",
                                    subtittle:
                                        "Do you really want to mark this task as done?",
                                  );
                                },
                                child: Icon(
                                  expandedIcons[3]['icon'],
                                  size: 27.sp,
                                  color: expandedIcons[3]['color'],
                                ),
                              ),
                            ),
                            // Calendar icon
                            Padding(
                              padding: EdgeInsets.only(left: 10.w),
                              child: GestureDetector(
                                onTap: () {
                                  log(selectedTask.date + selectedTask.time!);
                                  myAlertBoxYesNo(
                                    context,
                                    onYesPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.connectCalenderScreen,
                                        arguments: {
                                          "taskId": selectedTask.taskId,
                                          "title": selectedTask.title,
                                          "description":
                                              selectedTask.description,
                                          "startDate":
                                              selectedTask.date +
                                              selectedTask.time!,
                                        },
                                      );
                                    },
                                    heading: "Add to Calendar?",
                                    subtittle:
                                        "Are you sure you want to add this task?",
                                  );
                                },
                                child: Icon(
                                  expandedIcons[4]['icon'],
                                  size: 27.sp,
                                  color: expandedIcons[4]['color'],
                                ),
                              ),
                            ),
                          ]);
                        } else if (tasksChecked.length > 1) {
                          // Done only
                          actionIcons.add(
                            Padding(
                              padding: EdgeInsets.only(left: 10.w),
                              child: GestureDetector(
                                onTap: () {
                                  myAlertBoxYesNo(
                                    context,
                                    onYesPressed: () {
                                      int deleteTaskCount = tasksChecked.length;
                                      final String taskCount =
                                          deleteTaskCount == 1
                                          ? "task"
                                          : "tasks";
                                      mySnackBar(
                                        context,
                                        title:
                                            "$deleteTaskCount $taskCount completed successfully",
                                      );
                                      setState(() {
                                        tasksChecked.clear();
                                      });
                                    },
                                    heading: "Confirm Completion?",
                                    subtittle:
                                        "Do you really want to mark these tasks as done?",
                                  );
                                },
                                child: Icon(
                                  expandedIcons[3]['icon'],
                                  size: 27.sp,
                                  color: expandedIcons[3]['color'],
                                ),
                              ),
                            ),
                          );
                        }
                      }

                      return Row(
                        children: [
                          Expanded(
                            child: MySearchField(
                              hintText: "Search for tasks",
                              controller: searchController,
                              onChangedValue: onSearchChanged,
                            ),
                          ),
                          ...actionIcons,
                        ],
                      );
                    },
                  ),

                  SizedBox(height: 20.h),
                  BlocBuilder<FetchTasksCubit, FetchTasksState>(
                    builder: (context, state) {
                      // While loading tasks → shimmer
                      if (state.fetchTasksStatus == FetchTaskStatus.loading) {
                        return Expanded(
                          child: ListView.builder(
                            itemCount: state.taskCount ?? 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return myTasksShimmerBox(
                                width: double.infinity,
                                height: 110.h,
                                itemCount: state.taskCount ?? 2,
                              );
                            },
                          ),
                        );
                      }

                      // Prepare filtered tasks based on search text
                      final allTasks = state.taskInfoList ?? [];
                      final filteredTasks = searchController.text.isEmpty
                          ? allTasks
                          : allTasks.where((task) {
                              final query = searchController.text.toLowerCase();
                              final titleLower = task.title.toLowerCase();
                              final descLower = task.description.toLowerCase();
                              final assignedLower = task.assignedTo!
                                  .toLowerCase();
                              return titleLower.contains(query) ||
                                  descLower.contains(query) ||
                                  assignedLower.contains(query);
                            }).toList();

                      // No tasks available
                      if (filteredTasks.isEmpty) {
                        return Expanded(child: Lottie.asset(AppImages.noTask));
                      }

                      // Show task list
                      return Expanded(
                        child: ListView.builder(
                          itemCount: filteredTasks.length,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.only(bottom: 30.h),
                          itemBuilder: (context, index) {
                            final taskInfo = filteredTasks[index];

                            // Animate opacity if task is being deleted or marked
                            final hideTask =
                                (tasksChecked.contains(taskInfo.taskId) &&
                                    isdeleting) ||
                                (tasksChecked.contains(taskInfo.taskId) &&
                                    isMarking);

                            return AnimatedOpacity(
                              opacity: hideTask ? 0.0 : 1.0,
                              duration: const Duration(seconds: 1),
                              child: listTile(
                                onEditPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.addTasksScreen,
                                    arguments: {
                                      "isEditTask": true,
                                      "taskId": taskInfo.taskId,
                                    },
                                  );
                                },
                                heading: taskInfo.title,
                                subTitle: taskInfo.description,
                                level: taskInfo.priority,
                                time: taskInfo.date,
                                isChecked: taskInfo.isChecked,
                                name: taskInfo.assignedTo!.isEmpty
                                    ? ""
                                    : "@${taskInfo.assignedTo}",
                                onPressed: (newValue) {
                                  setState(() {
                                    taskInfo.isChecked = newValue!;
                                    if (taskInfo.isChecked) {
                                      tasksChecked.add(taskInfo.taskId);
                                    } else {
                                      tasksChecked.remove(taskInfo.taskId);
                                    }
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget listTile({
    required String heading,
    required String subTitle,
    required String level,
    String? time,
    String? name,
    required ValueChanged<bool?> onPressed,
    int selectedIndex = 0,
    bool isChecked = false,
    required VoidCallback onEditPressed,
  }) {
    Color newColor() {
      if (level == "Low") {
        return AppColor.success;
      } else if (level == "Medium") {
        return AppColor.warning;
      } else if (level == "Completed") {
        return AppColor.border;
      }
      return AppColor.error;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 15.h),
      child: myTextHolderContainer(
        horizontal: 10,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            SizedBox(
              height: 35,
              child: Checkbox(
                checkColor: selectedIndex == 1 ? AppColor.background : null,
                activeColor: selectedIndex == 1
                    ? AppColor.border
                    : AppColor.success,
                side: BorderSide(color: AppColor.border),
                value: isChecked,
                onChanged: onPressed,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    heading,
                    style: t3White().copyWith(fontSize: 25.sp),
                  ),
                  Text(
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    subTitle,
                    style: hintTextStyle(),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      level.isNotEmpty
                          ? Row(
                              children: [
                                Icon(
                                  Icons.watch_later_outlined,
                                  color: newColor(),
                                  size: 15.sp,
                                ),
                                SizedBox(width: 3.w),
                                Text(
                                  level,
                                  style: t3White().copyWith(
                                    fontSize: 14.sp,
                                    color: selectedIndex == 1
                                        ? AppColor.secondary
                                        : newColor(),
                                  ),
                                ),
                              ],
                            )
                          : SizedBox(),
                      SizedBox(width: level.isEmpty ? 0.w : 15.w),
                      Row(
                        children: [
                          Icon(
                            Icons.watch_later_outlined,
                            color: Colors.white30,
                            size: 15.sp,
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            time!,
                            style: hintTextStyle().copyWith(fontSize: 14.sp),
                          ),
                        ],
                      ),
                      SizedBox(width: 15.w),
                      name != null
                          ? Expanded(
                              child: Text(
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                name,
                                style: hintTextStyle().copyWith(
                                  color: AppColor.text,
                                ),
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ],
              ),
            ),
            savedUserRole == "Chief"
                ? IconButton(onPressed: onEditPressed, icon: Icon(Icons.edit))
                : SizedBox(),
          ],
        ),
      ),
    );
  }
}
