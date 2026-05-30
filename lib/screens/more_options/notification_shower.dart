import 'package:family_management_app/app/routes/app_routes.dart';
import 'package:family_management_app/app/utils/custom_appbar.dart';
import 'package:family_management_app/app/utils/shimmer.dart';
import 'package:family_management_app/bloc/fetch%20Notifications/fetch_notifications_cubit.dart';
import 'package:family_management_app/bloc/fetch%20User/fetch_user_cubit.dart';
import 'package:family_management_app/service/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:family_management_app/app/app Color/app_color.dart';
import 'package:family_management_app/app/textStyle/textstyles.dart';
import 'package:family_management_app/app/utils/utils.dart';

class NotificationShowerScreen extends StatefulWidget {
  const NotificationShowerScreen({super.key});

  @override
  State<NotificationShowerScreen> createState() =>
      _NotificationShowerScreenState();
}

class _NotificationShowerScreenState extends State<NotificationShowerScreen>
    with SingleTickerProviderStateMixin {
  String? savedRole;
  late TabController tabController;

  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    getSecureData();
    tabController = TabController(length: 2, vsync: this);
    _scrollController = ScrollController()..addListener(_scrollListener);
  }

  Future<void> getSecureData() async {
    final userRole = await AppStorage.read(key: "savedRole");
    setState(() {
      savedRole = userRole;
    });
    if (savedRole == "Chief") {
      context.read<FetchNotificationsCubit>().fetchFirstNotificationsForChief();
      context.read<FetchUserCubit>().fetchJoinRequestsNotification();
    } else {
      context.read<FetchNotificationsCubit>().fetchFirstNotificationMember();
    }
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  void switchToJoinRequests() {
    tabController.animateTo(1); // index 1 = Join Requests
  }

  void _scrollListener() {
    final cubit = context.read<FetchNotificationsCubit>();
    if (_scrollController.position.pixels >
            _scrollController.position.maxScrollExtent - 100 &&
        cubit.hasMore) {
      if (savedRole == "Chief") {
        cubit.fetchNextNotificationsChief();
      } else {
        cubit.fetchNextNotificationsMember();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: MyCustomAppBar(
        heading: "Notification",
        isBack: false,
        subTitle: "All activity updates in one place",
      ),
      body: savedRole == "Chief"
          ? DefaultTabController(
              length: 2,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 7.h, horizontal: 5.w),
                child: Column(
                  children: [
                    TabBar(
                      controller: tabController,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: AppColor.secondary,
                      dividerColor: Colors.grey,
                      labelStyle: t2White().copyWith(fontSize: 20.sp),
                      tabs: const [
                        Tab(text: "Notifications"),
                        Tab(text: "Join Requests"),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: tabController,
                        children: [
                          NotificationTab(
                            switchTab: switchToJoinRequests,
                            scrollController: _scrollController,
                          ),
                          JoinRequestsTab(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Padding(
              padding: EdgeInsets.symmetric(vertical: 7.h, horizontal: 5.w),
              child: NotificationTabUsers(scrollController: _scrollController),
            ),
    );
  }
}

class NotificationTab extends StatefulWidget {
  final ScrollController scrollController;
  final VoidCallback switchTab;

  const NotificationTab({
    super.key,
    required this.switchTab,
    required this.scrollController,
  });

  @override
  State<NotificationTab> createState() => _NotificationTabState();
}

class _NotificationTabState extends State<NotificationTab> {
  String timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);

    if (diff.inSeconds < 60) {
      return "${diff.inSeconds}s ago";
    } else if (diff.inMinutes < 60) {
      return "${diff.inMinutes}m ago";
    } else if (diff.inHours < 24) {
      return "${diff.inHours}h ago";
    } else if (diff.inDays < 7) {
      return "${diff.inDays}d ago";
    } else if (diff.inDays < 30) {
      return "${(diff.inDays / 7).floor()}w ago";
    } else if (diff.inDays < 365) {
      return "${(diff.inDays / 30).floor()}mo ago";
    } else {
      return "${(diff.inDays / 365).floor()}y ago";
    }
  }

  // @override
  // void dispose() {
  //   _scrollController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchNotificationsCubit, FetchNotificationsState>(
      builder: (context, state) {
        final notificationList = state.notificationList ?? [];

        if (state.notifiactionStatus == FetchNotificationStatus.loading) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
              child: Column(
                children: List.generate(notificationList.length, (index) {
                  return myTasksShimmerBox(
                    height: 80.h,
                    width: double.infinity,
                  );
                }),
              ),
            ),
          );
        }

        if (notificationList.isEmpty) {
          return Center(
            child: Text("No notifications yet.", style: hintTextStyle()),
          );
        }

        return ListView.builder(
          controller: widget.scrollController,
          itemCount: notificationList.length + 1,

          itemBuilder: (context, index) {
            final cubit = context.read<FetchNotificationsCubit>();
            if (index == notificationList.length) {
              return cubit.hasMore
                  ? Padding(
                      padding: EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 35,
                        child: Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
                    )
                  : const SizedBox.shrink();
            }

            final userDetails = notificationList[index];
            final timeStamp = userDetails['createdAt'];
            final parseDate = timeStamp.toDate();
            final readableDate = timeAgo(parseDate);

            return ListTile(
              onTap: () {
                if (userDetails['type'] == "user_join") {
                  widget.switchTab();
                }
              },
              contentPadding: EdgeInsets.all(8.r),
              leading: MyProfileHolderRectangle(
                fontSize: 25,
                height: 80,
                width: 50,
                name: userDetails['name'],
                imagePath: userDetails['imagePath'],
              ),
              title: Text(
                overflow: TextOverflow.ellipsis,
                maxLines: 1,

                userDetails['title'],
                style: t3White(),
              ),
              subtitle: Text(
                overflow: TextOverflow.ellipsis,
                maxLines: 2,

                userDetails['body'],
                style: hintTextStyle(),
              ),
              trailing: Text(
                readableDate,
                style: hintTextStyle().copyWith(fontSize: 14.sp),
              ),
            );
          },
        );
      },
    );
  }
}

class JoinRequestsTab extends StatefulWidget {
  const JoinRequestsTab({super.key});

  @override
  State<JoinRequestsTab> createState() => _JoinRequestsTabState();
}

class _JoinRequestsTabState extends State<JoinRequestsTab> {
  final List<String> roles = ["Co-chief", "Unit Lead", "Board Member", "Guest"];
  String? selectedRole;
  bool isLoadingAccepted = false;
  bool isLoadingRejected = false;
  List<String> selectedUid = [];

  String timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);

    if (diff.inSeconds < 60) {
      return "${diff.inSeconds}s ago";
    } else if (diff.inMinutes < 60) {
      return "${diff.inMinutes}m ago";
    } else if (diff.inHours < 24) {
      return "${diff.inHours}h ago";
    } else if (diff.inDays < 7) {
      return "${diff.inDays}d ago";
    } else if (diff.inDays < 30) {
      return "${(diff.inDays / 7).floor()}w ago";
    } else if (diff.inDays < 365) {
      return "${(diff.inDays / 30).floor()}mo ago";
    } else {
      return "${(diff.inDays / 365).floor()}y ago";
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<FetchUserCubit>();
    return BlocListener<FetchUserCubit, FetchUserState>(
      listenWhen: (previous, current) =>
          previous.approveStatus != current.approveStatus ||
          previous.rejectStatus != current.rejectStatus,

      listener: (context, state) {
        if (state.approveStatus == FetchRequestStatus.loading) {
          setState(() => isLoadingAccepted = true);
        } else if (state.rejectStatus == FetchRequestStatus.loading) {
          setState(() => isLoadingRejected = true);
        } else if (state.approveStatus == FetchRequestStatus.sucess) {
          setState(() {
            isLoadingAccepted = false;
            selectedUid.clear();
          });
          mySnackBar(context, title: state.errorMsg ?? "");
        } else if (state.rejectStatus == FetchRequestStatus.sucess) {
          setState(() {
            isLoadingRejected = false;
            selectedUid.clear();
          });
          mySnackBar(context, title: state.errorMsg ?? "");
        } else if (state.approveStatus == FetchRequestStatus.failed) {
          setState(() {
            isLoadingAccepted = false;
            selectedUid.clear();
          });
          mySnackBar(context, title: state.errorMsg ?? "");
        } else if (state.rejectStatus == FetchRequestStatus.failed) {
          setState(() {
            isLoadingRejected = false;
            selectedUid.clear();
          });
          mySnackBar(context, title: state.errorMsg ?? "");
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: BlocBuilder<FetchUserCubit, FetchUserState>(
          builder: (context, state) {
            final joinUserList = state.joinRequestList ?? [];
            if (state.fetchJoinRequestsNotificationStatus ==
                FetchRequestStatus.loading) {
              SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Column(
                    children: List.generate(
                      state.joinRequestList?.length ?? 5,
                      (index) {
                        return myTasksShimmerBox(
                          height: 80.h,
                          width: double.infinity,
                        );
                      },
                    ),
                  ),
                ),
              );
            }

            if (joinUserList.isEmpty) {
              return Center(
                child: Text("No join Requests yet.", style: hintTextStyle()),
              );
            }
            return ListView.builder(
              itemCount: joinUserList.length,

              itemBuilder: (context, index) {
                final userDetails = joinUserList[index];
                final timestamp = userDetails['createdAt'];
                final createdDate = timestamp.toDate();
                final readableTime = timeAgo(createdDate);

                return SafeArea(
                  child: Card(
                    color: AppColor.dropDownColor,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 5.h,
                        horizontal: 3.w,
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 5.w),
                        leading: MyProfileHolder(
                          name: userDetails['name'],
                          height: 60,
                          width: 60,
                          imagePath: userDetails['imagePath'],
                          fontSize: 25,
                        ),
                        horizontalTitleGap: 7,
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                overflow: TextOverflow.ellipsis,
                                " ${userDetails['name']} has joined your crew .",
                                style: t1White().copyWith(fontSize: 18.sp),
                              ),
                            ),
                            Text(
                              " $readableTime ",
                              style: hintTextStyle().copyWith(fontSize: 14.sp),
                            ),
                            SizedBox(width: 7.w),
                          ],
                        ),

                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: MyAcceptButton(
                                text: "Accept",
                                isLoading:
                                    isLoadingAccepted &&
                                    selectedUid.contains(userDetails['uid']),
                                onPressed: () {
                                  showAssignRoleDialog(
                                    index: index,
                                    name: userDetails['name'],
                                    onPressed: () {
                                      Navigator.of(context).maybePop();
                                      setState(() {
                                        selectedUid.add(userDetails['uid']);
                                      });
                                      bloc.acceptJoinRequest(
                                        userDetails['email'],
                                        userDetails['uid'],
                                        selectedRole ?? "Lead",
                                        userDetails['name'] ?? "",
                                      );
                                    },
                                  );
                                },
                                buttonColor: AppColor.dropDownAlternativeColor,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: MyAcceptButton(
                                text: "Reject",
                                isLoading:
                                    isLoadingRejected &&
                                    selectedUid.contains(userDetails['uid']),
                                onPressed: () async {
                                  myAlertBoxYesNo(
                                    context,
                                    onYesPressed: () {
                                      Navigator.of(context).maybePop();
                                      setState(() {
                                        selectedUid.add(userDetails['uid']);
                                      });
                                      context
                                          .read<FetchUserCubit>()
                                          .rejectJoinRequest(
                                            userDetails['uid'],
                                            userDetails['name'],
                                          );
                                    },
                                    heading: "❌ Remove Member",
                                    subtittle:
                                        "Are you sure you to remove this ${userDetails['name'].split(' ')[0]}?",
                                  );
                                },
                                buttonColor: const Color.fromARGB(
                                  255,
                                  180,
                                  58,
                                  49,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void showAssignRoleDialog({
    required int index,
    required VoidCallback onPressed,
    required String name,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColor.dropDownColor,
          title: RichText(
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              text: "Assign role to ",
              style: t3White().copyWith(fontSize: 17.sp),
              children: [
                TextSpan(
                  text: "@${name.split(' ')[0]}",
                  style: t1heading().copyWith(
                    color: AppColor.textTertiary,
                    fontSize: 17.sp,
                  ),
                ),
              ],
            ),
          ),

          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    children: List.generate(roles.length, (index) {
                      final role = roles[index];
                      return RadioListTile<String>(
                        contentPadding: EdgeInsets.zero,
                        activeColor: AppColor.secondary,

                        value: role,
                        visualDensity: VisualDensity(
                          vertical: -3,
                        ), // reduces vertical space
                        groupValue: selectedRole,
                        title: Text(
                          role,
                          style: hintTextStyle().copyWith(
                            fontSize: 18.sp,
                            color: AppColor.textSecondary,
                          ),
                        ),

                        onChanged: (value) {
                          setState(() {
                            selectedRole = value;
                          });
                        },
                      );
                    }),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Cancel',
                          style: hintTextStyle().copyWith(
                            color: AppColor.error,
                            fontSize: 18.sp,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: onPressed,
                        child: Text(
                          'Assign',
                          style: hintTextStyle().copyWith(
                            color: AppColor.border,
                            fontSize: 18.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class NotificationTabUsers extends StatefulWidget {
  final ScrollController scrollController;
  const NotificationTabUsers({super.key, required this.scrollController});

  @override
  State<NotificationTabUsers> createState() => _NotificationTabUsersState();
}

class _NotificationTabUsersState extends State<NotificationTabUsers> {
  String timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);

    if (diff.inSeconds < 60) {
      return "${diff.inSeconds}s ago";
    } else if (diff.inMinutes < 60) {
      return "${diff.inMinutes}m ago";
    } else if (diff.inHours < 24) {
      return "${diff.inHours}h ago";
    } else if (diff.inDays < 7) {
      return "${diff.inDays}d ago";
    } else if (diff.inDays < 30) {
      return "${(diff.inDays / 7).floor()}w ago";
    } else if (diff.inDays < 365) {
      return "${(diff.inDays / 30).floor()}mo ago";
    } else {
      return "${(diff.inDays / 365).floor()}y ago";
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchNotificationsCubit, FetchNotificationsState>(
      builder: (context, state) {
        final notificationList = state.notificationListMember ?? [];

        if (state.notifiactionStatusMember == FetchNotificationStatus.loading) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
              child: Column(
                children: List.generate(notificationList.length, (index) {
                  return myTasksShimmerBox(
                    height: 80.h,
                    width: double.infinity,
                  );
                }),
              ),
            ),
          );
        }
        if (notificationList.isEmpty) {
          return Center(
            child: Text("No notifications yet.", style: hintTextStyle()),
          );
        }
        return ListView.builder(
          controller: widget.scrollController,
          itemCount: notificationList.length + 1,
          itemBuilder: (context, index) {
            final cubit = context.read<FetchNotificationsCubit>();

            if (index == notificationList.length) {
              return cubit.hasMore
                  ? Padding(
                      padding: EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 35,
                        child: Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
                    )
                  : const SizedBox.shrink();
            }

            final userDetails = notificationList[index];
            final timeStamp = userDetails['createdAt'];
            final parseDate = timeStamp.toDate();
            final readableDate = timeAgo(parseDate);

            return ListTile(
              onTap: () {
                if (userDetails['type'] == "task_assigned") {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.tasksScreen,
                    arguments: {'isBack': true},
                  );
                } else if (userDetails['type'] == "event_assigned") {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.calendarScreen,
                    arguments: {'isBack': true},
                  );
                }
              },
              contentPadding: EdgeInsets.all(8.r),

              leading: userDetails['type'] == "task_assigned"
                  ? Icon(Icons.task, size: 30.r, color: AppColor.secondary)
                  : userDetails['type'] == "event_assigned"
                  ? Icon(Icons.event, size: 30.r, color: AppColor.secondary)
                  : MyProfileHolderRectangle(
                      fontSize: 25,
                      height: 80,
                      width: 50,
                      name: userDetails['name'],
                      imagePath: userDetails['imagePath'],
                    ),
              title: Text(
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                userDetails['title'],
                style: t3White(),
              ),
              subtitle: Text(
                overflow: TextOverflow.ellipsis,
                maxLines: 2,

                userDetails['body'],
                style: hintTextStyle(),
              ),
              trailing: Text(
                readableDate,
                style: hintTextStyle().copyWith(fontSize: 14.sp),
              ),
            );
          },
        );
      },
    );
  }
}
