import 'dart:developer';
import 'package:family_management_app/app/routes/app_routes.dart';
import 'package:family_management_app/app/utils/custom_appbar.dart';
import 'package:family_management_app/bloc/fetch%20User/fetch_user_cubit.dart';
import 'package:family_management_app/service/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:family_management_app/app/app%20Color/app_color.dart';
import 'package:family_management_app/app/textStyle/textstyles.dart';
import 'package:family_management_app/app/utils/utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MoreScreen extends StatefulWidget {
  final bool isBack;
  const MoreScreen({super.key, this.isBack = false});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  String? savedUserRole;
  String? savedUserName;
  String? savedUserEmail;

  final List<IconData> iconsList = [
    Icons.security, // Security
    Icons.notifications, // Notifications
    Icons.lightbulb, // AI Smart Suggestions
    Icons.insights, // Mental Lead Tracker
    Icons.mic, // Voice Commands
    Icons.family_restroom, // Family Management
    Icons.settings, // Settings
    Icons.help_outline, // Help and Support
    Icons.logout, // Logout
  ];

  final List<Map<String, String>> moreOptions = [
    {'title': 'admin@homeops.com', 'subtitle': 'Guest'},
    {
      'title': 'Notifications',
      'subtitle': 'Manage push notifications and alerts',
    },
    {
      'title': 'AI Smart Suggestions',
      'subtitle': 'Personalized recommendations for your family',
    },
    {
      'title': 'Mental Load Tracker',
      'subtitle': 'Track and balance family responsibilities',
    },
    {
      'title': 'Voice Commands',
      'subtitle': 'Use voice to add tasks and events',
    },
    {
      'title': 'Family Management',
      'subtitle': 'Manage family members and roles',
    },
    {'title': 'Settings', 'subtitle': 'App preferences and account settings'},
    {'title': 'Help & Support', 'subtitle': 'Get help and contact support'},
    {'title': 'Sign Out', 'subtitle': 'Sign out of your account'},
  ];

  @override
  void initState() {
    super.initState();
    getSecureData();
    // context.read<FetchUserCubit>().fetchJoinRequests();
  }

  Future<void> getSecureData() async {
    final userRole = await AppStorage.read(key: "savedRole");
    final userName = await AppStorage.read(key: "name");
    final useremail = await AppStorage.read(key: "email");
    setState(() {
      savedUserRole = userRole;
      savedUserName = userName;
      savedUserEmail = useremail;
    });
    log("More Section Tab: NAME: $userName, ROLE: $userRole,");
  }

  /// --- ACTION HANDLER ---
  Future<void> handleItemTap(int index, FetchUserCubit bloc) async {
    switch (index) {
      case 0:
        log('Tapped on Profile item');
        break;
      case 1:
        Navigator.pushNamed(context, AppRoutes.notificationShowerScreen);
        break;
      case 2:
        log('Tapped on AI Smart Suggestions');
        break;
      case 3:
        Navigator.pushNamed(context, AppRoutes.scoreScreen);
        log('Tapped on Mental Load Tracker');
        break;
      case 4:
        Navigator.pushNamed(context, AppRoutes.voiceCommandScreen);
        log('Tapped on Voice Commands');
        break;
      case 5:
        log('Tapped on Family Management');
        break;
      case 6:
        log('Tapped on Settings');
        break;
      case 7:
        log('Tapped on Help & Support');
        break;
      case 8:
        myAlertBoxYesNo(
          context,
          onYesPressed: () async {
            await AppStorage.deleteKeysOnLogout();
            bloc.logOut();
          },
        );
        break;
      default:
        log('Tapped on other item');
    }
  }

  /// --- ITEM WIDGET BUILDER ---
  Widget buildMoreOptionItem(
    int index,
    Map<String, String> option,
    FetchUserCubit bloc,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15.h),
      child: GestureDetector(
        onTap: () => handleItemTap(index, bloc),
        child: myTextHolderContainer(
          borderColor: index == 8 ? AppColor.error : AppColor.secondary,
          horizontal: 15.w,
          child: BlocListener<FetchUserCubit, FetchUserState>(
            listenWhen: (previous, current) =>
                previous.logoutStatus != current.logoutStatus,

            listener: (context, state) {
              if (index == 8 &&
                  state.logoutStatus == FetchRequestStatus.sucess) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.loginScreen,
                  (route) => false,
                );
                mySnackBar(context, title: "Logged out successfully");
              }
            },
            child: Row(
              children: [
                // Icon
                index == 0
                    ? Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColor.secondary,
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(5.r),
                          child: Icon(
                            iconsList[index],
                            color: AppColor.blackColor,
                            size: 22.sp,
                          ),
                        ),
                      )
                    : Icon(
                        iconsList[index],
                        color: index == 8 ? AppColor.error : AppColor.secondary,
                        size: 25.sp,
                      ),
                SizedBox(width: 7.w),
                // Title + Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        index == 0 ? savedUserEmail ?? "" : option["title"]!,
                        style: t3White().copyWith(
                          color: index == 8
                              ? AppColor.error
                              : AppColor.textSecondary,
                        ),
                      ),
                      Text(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        index == 0 ? savedUserRole ?? "" : option['subtitle']!,
                        style: hintTextStyle(),
                      ),
                    ],
                  ),
                ),

                // Notification badge
                if (index == 1)
                  BlocBuilder<FetchUserCubit, FetchUserState>(
                    builder: (context, state) {
                      if (state.fetchJoinRequestsNotificationStatus ==
                              FetchRequestStatus.sucess &&
                          state.pendingUserCount! > 0) {
                        return Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            gradient: LinearGradient(
                              colors: [
                                AppColor.error.withOpacity(0.9),
                                AppColor.error,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 6,
                                offset: Offset(2, 2),
                              ),
                            ],
                            border: Border.all(
                              color: Colors.white, // adds a clean outline
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            state.pendingUserCount.toString(),
                            style: hintTextStyle().copyWith(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      } else {
                        return SizedBox();
                      }
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<FetchUserCubit>();

    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: widget.isBack
          ? MyCustomAppBar(
              heading: "More Options",
              subTitle: "Settings and additional features",
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
                    "More Options",
                    style: t1heading().copyWith(fontSize: 30.sp),
                  ),
                  Text("Settings and additional features", style: t3White()),
                ],
              ),
            ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: SingleChildScrollView(
            child: Column(
              children: List.generate(
                moreOptions.length,
                (index) => buildMoreOptionItem(index, moreOptions[index], bloc),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
