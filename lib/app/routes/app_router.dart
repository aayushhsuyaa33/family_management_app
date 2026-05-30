import 'package:family_management_app/app/app%20Color/app_color.dart';
import 'package:family_management_app/app/routes/app_routes.dart';
import 'package:family_management_app/screens/ChatGpt/chat_screen.dart';
import 'package:family_management_app/screens/auth_credential/forget_password_screen.dart';
import 'package:family_management_app/screens/auth_credential/join_status_screen.dart/acceptedstatus_screen.dart';
import 'package:family_management_app/screens/auth_credential/join_status_screen.dart/rejectedstatus_screen.dart';
import 'package:family_management_app/screens/auth_credential/login_screen.dart';
import 'package:family_management_app/screens/auth_credential/register_screen.dart';
import 'package:family_management_app/screens/auth_credential/role_selection_screen.dart';
import 'package:family_management_app/screens/auth_credential/join_status_screen.dart/waiting_screen.dart';
import 'package:family_management_app/screens/bottom_tabs.dart/calender_screen.dart';
import 'package:family_management_app/screens/bottom_tabs.dart/home_screen.dart';
import 'package:family_management_app/screens/bottom_tabs.dart/kids_screen.dart';
import 'package:family_management_app/screens/bottom_tabs.dart/more_screen.dart';
import 'package:family_management_app/screens/bottom_tabs.dart/navigation_screens.dart';
import 'package:family_management_app/screens/bottom_tabs.dart/shopping_screen.dart';
import 'package:family_management_app/screens/bottom_tabs.dart/tasks_screen.dart';

import 'package:family_management_app/screens/calendars/connect_calenders.dart';
import 'package:family_management_app/screens/drawer_navigation/command_center.dart';
import 'package:family_management_app/screens/functionality/add_member.dart';
import 'package:family_management_app/screens/functionality/edit_member.dart';
import 'package:family_management_app/screens/drawer_navigation/profile_screen.dart';
import 'package:family_management_app/screens/functionality/child_screen.dart';
import 'package:family_management_app/screens/functionality/addevents_screen.dart';
import 'package:family_management_app/screens/functionality/addtask_screen.dart';
import 'package:family_management_app/screens/more_options/notification_shower.dart';
import 'package:family_management_app/screens/more_options/score_screen.dart';
import 'package:family_management_app/screens/more_options/voice_command_screen.dart';
import 'package:family_management_app/screens/onBoardScreen/onboarding_Screen1.dart';
import 'package:family_management_app/screens/onBoardScreen/onboarding_screen.dart';
import 'package:family_management_app/screens/onBoardScreen/onboarding_screen2.dart';
import 'package:family_management_app/screens/splash%20screens/splash_screen1.dart';
import 'package:family_management_app/screens/splash%20screens/splash_screen.dart';
import 'package:flutter/material.dart';

class AppRouter {
  AppRouter();
  PageRouteBuilder transtionTo(Widget page) {
    return PageRouteBuilder(
      barrierColor: AppColor.background,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return page;
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideAnimation =
            Tween<Offset>(
              begin: const Offset(1.0, 0), // start from right
              end: Offset.zero, // end at original position
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut, // smooth movement
              ),
            );

        return SlideTransition(position: slideAnimation, child: child);
      },
    );
  }

  Route generateRoutes(RouteSettings settings) {
    if (settings.name == AppRoutes.splashScreen) {
      return transtionTo(SplashScreen());
    } else if (settings.name == AppRoutes.splashScreen1) {
      return transtionTo(SplashScreen1());
    } else if (settings.name == AppRoutes.onBoardingScreen) {
      return transtionTo(Onboardingscreen());
    } else if (settings.name == AppRoutes.onBoardingScreen1) {
      return transtionTo(OnboardingScreen1());
    } else if (settings.name == AppRoutes.onBoardingScreen2) {
      return transtionTo(OnboardingScreen2());
    } else if (settings.name == AppRoutes.loginScreen) {
      return transtionTo(LoginScreen());
    } else if (settings.name == AppRoutes.forgetPasswordScreen) {
      return transtionTo(ForgetPasswordScreen());
    } else if (settings.name == AppRoutes.registerScreen) {
      final args = settings.arguments as Map<String, dynamic>?;
      final uid = args?['uid'];
      final boardId = args?['boardId'];
      return transtionTo(RegisterScreen(uid: uid, boardId: boardId));
    } else if (settings.name == AppRoutes.roleSelectionScreen) {
      return transtionTo(RoleSelectionScreen());
    } else if (settings.name == AppRoutes.navigationScreen) {
      return transtionTo(NavigationScreens());
    } else if (settings.name == AppRoutes.homeScreen) {
      final args = settings.arguments as Map<String, dynamic>?;
      final bool isBack = args?['isBack'] ?? false;
      return transtionTo(HomeScreen(isBack: isBack));
    } else if (settings.name == AppRoutes.commandCenterScreen) {
      return transtionTo(CommandCenterScreen());
    } else if (settings.name == AppRoutes.editMemberScreen) {
      final args = settings.arguments as Map<String, dynamic>?;
      final uid = args?['uid'];
      return transtionTo(EditMember(uid: uid ?? ""));
    } else if (settings.name == AppRoutes.profileScreen) {
      final args = settings.arguments as Map<String, dynamic>?;
      final String uid = args?['uid'];
      final String email = args?['email'];
      final bool isChild = args?['isChild'] ?? false;
      return transtionTo(
        ProfileScreen(uid: uid, assignedEmail: email, isChild: isChild),
      );
    } else if (settings.name == AppRoutes.dashBoardScreen) {
      return transtionTo(HomeScreen());
    } else if (settings.name == AppRoutes.tasksScreen) {
      final args = settings.arguments as Map<String, dynamic>?;
      final bool isBack = args?['isBack'] ?? false;
      return transtionTo(TasksScreen(isBack: isBack));
    } else if (settings.name == AppRoutes.kidsScreen) {
      return transtionTo(KidsScreen());
    } else if (settings.name == AppRoutes.calendarScreen) {
      final args = settings.arguments as Map<String, dynamic>?;
      final bool isBack = args?['isBack'] ?? false;
      return transtionTo(CalenderScreen(isBack: isBack));
    } else if (settings.name == AppRoutes.settingScreen) {
      final args = settings.arguments as Map<String, dynamic>?;
      final bool isBack = args?['isBack'] ?? false;
      return transtionTo(MoreScreen(isBack: isBack));
    } else if (settings.name == AppRoutes.addTasksScreen) {
      final args = settings.arguments as Map<String, dynamic>?;
      final String preSelectedDate = args?['preSelectedDate'] ?? "";
      final String preSelectedTime = args?['preSelectedTime'] ?? "";
      final String taskId = args?['taskId'] ?? "";
      final bool isEditTask = args?['isEditTask'] ?? false;
      return transtionTo(
        AddtaskScreen(
          preSelectedDate: preSelectedDate,
          preSelectedTime: preSelectedTime,
          isEditTask: isEditTask,
          taskId: taskId,
        ),
      );
    } else if (settings.name == AppRoutes.addEventsScreen) {
      final args = settings.arguments as Map<String, dynamic>?;
      final String preSelectedDate = args?['preSelectedDate'] ?? "";
      final String preSelectedTime = args?['preSelectedTime'] ?? "";
      return transtionTo(
        AddEventsScreen(
          preSelectedDate: preSelectedDate,
          preSelectedTime: preSelectedTime,
        ),
      );
    } else if (settings.name == AppRoutes.waitingScreen) {
      final args = settings.arguments as Map<String, dynamic>?;
      final String? boardId = args?['boardId'] ?? "";
      return transtionTo(WaitingScreen(boardId: boardId));
    } else if (settings.name == AppRoutes.acceptedScreen) {
      return transtionTo(AcceptedstatusScreen());
    } else if (settings.name == AppRoutes.rejectedScreen) {
      return transtionTo(RejectedstatusScreen());
    } else if (settings.name == AppRoutes.notificationShowerScreen) {
      return transtionTo(NotificationShowerScreen());
    } else if (settings.name == AppRoutes.addChildFlow) {
      final args = settings.arguments as Map<String, dynamic>?;
      final String uid = args?['uid'] ?? "";
      return transtionTo(AddChildFlow(uid: uid));
    } else if (settings.name == AppRoutes.connectCalenderScreen) {
      final args = settings.arguments as Map<String, dynamic>?;
      final String taskId = args?['taskId'] ?? "";
      final String taskTitle = args?['title'] ?? "";
      final String taskDescription = args?['description'] ?? "";
      final String taskStartDate = args?['startDate'] ?? "";
      return transtionTo(
        ConnectCalendersScreen(
          taskId: taskId,
          taskTitle: taskTitle,
          taskDescription: taskDescription,
          taskStartDate: taskStartDate,
        ),
      );
    } else if (settings.name == AppRoutes.addMemberScreen) {
      final args = settings.arguments as Map<String, dynamic>?;
      final uid = args?['uid'];
      return transtionTo(AddMemberScreen(uid: uid ?? ""));
    } else if (settings.name == AppRoutes.chatScreen) {
      final args = settings.arguments as Map<String, dynamic>?;
      final String chatId = args?['chatId'] ?? "";
      final String chatTitle = args?['chatTitle'] ?? "";
      return transtionTo(ChatScreen(chatId: chatId, chatTitle: chatTitle));
    } else if (settings.name == AppRoutes.shoppingScreen) {
      return transtionTo(ShoppingScreen());
    } else if (settings.name == AppRoutes.scoreScreen) {
      return transtionTo(ScoreScreen());
    } else if (settings.name == AppRoutes.voiceCommandScreen) {
      return transtionTo(VoiceCommandScreen());
    } else {
      return transtionTo(SplashScreen());
    }
  }
}
