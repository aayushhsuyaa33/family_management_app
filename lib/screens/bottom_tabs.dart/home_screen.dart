import 'dart:developer';
import 'package:badges/badges.dart' as badges;
import 'package:family_management_app/app/api/google_calender_api.dart';
import 'package:family_management_app/app/app%20Color/app_color.dart';
import 'package:family_management_app/app/routes/app_routes.dart';
import 'package:family_management_app/app/textStyle/textstyles.dart';
import 'package:family_management_app/app/utils/custom_appbar.dart';
import 'package:family_management_app/app/utils/utils.dart';
import 'package:family_management_app/bloc/fetch%20User/fetch_user_cubit.dart';
import 'package:family_management_app/bloc/fetch_tasks/fetch_tasks_cubit.dart';
import 'package:family_management_app/bloc/score/score_cubit.dart';
import 'package:family_management_app/service/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:family_management_app/app/utils/shimmer.dart';

class HomeScreen extends StatefulWidget {
  final bool isBack;
  const HomeScreen({super.key, this.isBack = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? taskCount;
  String? urgentCount;
  String? savedUserRole;
  String? savedUserName;
  String? savedUserImage;
  String? pendingUserCount;
  String? savedBoardId;

  @override
  void initState() {
    super.initState();
    getSecureData();
    _fetchAllData();
  }

  void _fetchAllData() {
    context.read<FetchUserCubit>().fetchJoinRequestsForHomePage();
    context.read<FetchTasksCubit>().fetchPendingTaskForHomPage();
    context.read<FetchTasksCubit>().fetchPendingEventForHomPage();
    context.read<ScoreCubit>().fetchOverallScore();
  }

  String getRoleTitle(String role) {
    switch (role) {
      case 'Chief' || "Co-chief":
        return 'Chief Executive Officer';
      case 'Lead' || "Unit Lead":
        return 'Lead Coordinator';
      case 'Board Member':
        return 'Board Member';
      case 'Guest':
        return 'Guest User';
      default:
        return 'Member';
    }
  }

  final googleCalendarHelper = GoogleCalendarHelper();

  Future<void> getSecureData() async {
    final userRole = await AppStorage.read(key: "savedRole");
    final userName = await AppStorage.read(key: "name");
    final userImage = await AppStorage.read(key: "imagePath");
    final useremail = await AppStorage.read(key: "email");
    final userBoardID = await AppStorage.read(key: "boardId");

    setState(() {
      savedUserRole = userRole;
      savedUserName = userName;
      savedUserImage = userImage;
      savedBoardId = userBoardID;
    });
    log(
      "Home Section Tab: NAME: $userName, ROLE: $userRole, IMAGE: $userImage, EMAIL: $useremail, UserBoardId: $savedBoardId",
    );
    log(savedUserRole!);
  }

  List<IconData> icons = [
    Icons.check_box_outlined,
    Icons.calendar_month_outlined,
    Icons.trending_up,
    Icons.notifications_none_outlined,
  ];

  List<String> headings = [
    "Active Tasks",
    "Today's Events",
    "Efficiency Score",
    "Notifications",
  ];

  List<String> noHeadings = [
    "Add Tasks",
    "Add Events",
    "Efficiency Score",
    "Notifications",
  ];
  List<String> subtitles = ["3", "10", "87%", "2"];
  List<String> feedbacks = [
    "1 urgent",
    "0 upcoming",
    "+5% this week",
    "1 requires action",
  ];

  List<String> quickActionsTitle = [
    "Add Task",
    "Add Event",
    "Create List",
    "Add Child",
    "Grocery Run",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      // drawer: MyCustomDrawar(),
      appBar: widget.isBack
          ? MyCustomAppBar(heading: "Altos HQ")
          : AppBar(
              backgroundColor: AppColor.background,
              iconTheme: IconThemeData(color: AppColor.secondary, size: 25.sp),
              title: Text(
                "Altos HQ",
                style: t1heading().copyWith(fontSize: 30.sp),
              ),
              centerTitle: true,
              actionsPadding: EdgeInsets.only(right: 15.w),
              automaticallyImplyLeading: false,
              leadingWidth: 80,
              leading: Builder(
                builder: (context) {
                  return Padding(
                    padding: EdgeInsets.all(5.w),
                    child: MyProfileHolder(
                      imagePath: savedUserImage ?? "",
                      name: savedUserName ?? "",
                      height: 100,
                      width: 100,
                      fontSize: 22,
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.commandCenterScreen,
                        );
                      },
                    ),
                  );
                },
              ),
              actions: [
                savedUserRole == "Chief"
                    ? GestureDetector(
                        onTap: () {
                          showMyAddOptionsAlert(
                            context: context,
                            onAddChildTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.addChildFlow,
                              );
                            },
                            onAddTaskTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.addTasksScreen,
                              );
                            },
                            onAddEventTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.addEventsScreen,
                              );
                            },
                          );
                        },
                        child: Icon(Icons.add, size: 35.sp),
                      )
                    : SizedBox(),
              ],
            ),

      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 17.w, right: 17.w, bottom: 70.h),
            child: RefreshIndicator(
              color: AppColor.dropDownColor,
              backgroundColor: Colors.white,
              onRefresh: () async {
                context.read<FetchUserCubit>().fetchJoinRequestsForHomePage();
                context.read<FetchTasksCubit>().fetchPendingTaskForHomPage();
                context.read<FetchTasksCubit>().fetchPendingEventForHomPage();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 7.h),
                    Text(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      "Welcome back, ${savedUserName?.split(" ").first ?? ""}",
                      style: t1heading().copyWith(fontSize: 28.sp),
                    ),
                    Text(
                      " ${getRoleTitle(savedUserRole ?? "")}",
                      style: t1heading().copyWith(
                        fontSize: 18.sp,
                        color: AppColor.textSecondary,
                      ),
                    ),

                    SizedBox(height: 15.h),
                    BlocBuilder<FetchTasksCubit, FetchTasksState>(
                      builder: (context, state) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // First Task Box (taskCount with shimmer)
                            MyTaskHolderBox(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.tasksScreen,
                                  arguments: {'isBack': true},
                                );
                              },
                              icon: icons[0],
                              headingText: headings[0],
                              subtitle: state.taskCount?.toString() ?? "",
                              subWidget:
                                  state.fetchPendingTaskForHomPageStatus ==
                                      FetchTaskStatus.loading
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 5,
                                      ),
                                      child: myShimmerTextBox(
                                        width: 40,
                                        height: 35,
                                      ),
                                    )
                                  : Text(
                                      state.taskCount?.toString() ?? "NA",
                                      style: t1heading(),
                                    ),
                              feedback:
                                  (state.fetchPendingTaskForHomPageStatus ==
                                      FetchTaskStatus.loading
                                  ? "Loading..."
                                  : pendingUserCount == "0"
                                  ? "No urgent task"
                                  : "${state.urgentCount ?? "0"} requires action"),
                            ),

                            // Second Task Box (remains unchanged)
                            MyTaskHolderBox(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.calendarScreen,
                                  arguments: {"isBack": true},
                                );
                              },
                              icon: icons[1],
                              headingText: headings[1],
                              subtitle: state.taskCount?.toString() ?? "",
                              subWidget:
                                  state.fetchPendingEventForHomPageStatus ==
                                      FetchTaskStatus.loading
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 5,
                                      ),
                                      child: myShimmerTextBox(
                                        width: 40,
                                        height: 35,
                                      ),
                                    )
                                  : Text(
                                      state.todayEvent?.toString() ?? "NA",
                                      style: t1heading(),
                                    ),
                              feedback:
                                  (state.fetchPendingEventForHomPageStatus ==
                                      FetchTaskStatus.loading
                                  ? "Loading..."
                                  : pendingUserCount == "0"
                                  ? "No upcoming event"
                                  : "${state.upcomingEvent ?? "0"} upcoming event"),
                            ),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Third Task Box (static content, no shimmer needed)
                        BlocBuilder<ScoreCubit, ScoreState>(
                          builder: (context, state) {
                            final houseHoldPercent =
                                state.houseHoldPercent ?? 0;
                            return MyTaskHolderBox(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.scoreScreen,
                                );
                              },
                              icon: icons[2],
                              headingText: headings[2],
                              subtitle:
                                  state.overallScoreStatus ==
                                      ScoreStatus.loading
                                  ? "N/A"
                                  : "${houseHoldPercent.toStringAsFixed(0)}%",
                              feedback: state.isUpTrend
                                  ? "+${state.weeklyTrendPercent?.toStringAsFixed(1) ?? 0}% this week "
                                  : "-${state.weeklyTrendPercent?.toStringAsFixed(1) ?? 0}% this week",
                            );
                          },
                        ),

                        // Fourth Task Box (urgentCount with shimmer)
                        BlocBuilder<FetchUserCubit, FetchUserState>(
                          builder: (context, state) {
                            return MyTaskHolderBox(
                              isChild: badges.Badge(
                                showBadge:
                                    (state.pendingUserCount ?? 0) >
                                    0, // only show if count > 0
                                badgeContent: Text(
                                  state.pendingUserCount.toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.sp,
                                  ),
                                ),
                                badgeStyle: badges.BadgeStyle(
                                  badgeColor: Colors.red,
                                  padding: EdgeInsets.all(5.r),
                                  elevation: 2,
                                ),
                                position: badges.BadgePosition.topEnd(
                                  top: -6,
                                  end: 1,
                                ),
                                child: Icon(
                                  icons[3],
                                  color: AppColor.secondary,
                                  size: 35.sp,
                                ),
                              ),
                              isNotification: true,
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.notificationShowerScreen,
                                );
                              },
                              icon: icons[3],
                              headingText: headings[3],
                              subtitle:
                                  state.fetchJoinRequestForHomePageStatus ==
                                      FetchRequestStatus.loading
                                  ? ""
                                  : state.pendingUserCount?.toString() ?? "0",
                              subWidget:
                                  state.fetchJoinRequestForHomePageStatus ==
                                      FetchRequestStatus.loading
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 5,
                                      ),
                                      child: myShimmerTextBox(
                                        width: 40,
                                        height: 35,
                                      ),
                                    )
                                  : Text(
                                      state.pendingUserCount?.toString() ?? "0",
                                      style: t1heading(),
                                    ),
                              feedback:
                                  (state.fetchJoinRequestForHomePageStatus ==
                                      FetchRequestStatus.loading
                                  ? "Loading..."
                                  : pendingUserCount == "0"
                                  ? "No new notifications"
                                  : "${state.pendingUserCount ?? ""} requires action"),
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      " AI Insights",
                      style: t1heading().copyWith(fontSize: 20.sp),
                    ),
                    SizedBox(height: 10.h),
                    myTextHolderContainer(
                      child: Text(
                        softWrap: true,
                        "Welcome to your new board 🚀 \nStart by adding your first task, event, or goal. Avia will learn your productivity patterns and provide smarter insights over time.",
                        style: t3White(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  top: 50.h,
                  left: 17.w,
                  right: 17.w,
                  bottom: 15.h,
                ),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.chatScreen);
                  },
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColor.background,
                      borderRadius: BorderRadius.circular(20.r),
                      border: BoxBorder.all(
                        width: 1.w,
                        color: AppColor.secondary,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 10.h,
                        horizontal: 25.w,
                      ),
                      child: Row(
                        children: [
                          Text(
                            "Ask Avia - Your AI Assistant",
                            style: t3White(),
                          ),
                          Spacer(),
                          Icon(Icons.mic_outlined, color: AppColor.secondary),
                        ],
                      ),
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
}
