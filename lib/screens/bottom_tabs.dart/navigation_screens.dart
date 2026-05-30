import 'package:family_management_app/app/api/app_exit.dart';
import 'package:family_management_app/app/app%20Color/app_color.dart';
import 'package:family_management_app/app/utils/utils.dart';
import 'package:family_management_app/bloc/fetch%20User/fetch_user_cubit.dart';
import 'package:family_management_app/bloc/fetch_cubit/fetch_event_cubit.dart';
import 'package:family_management_app/bloc/fetch_tasks/fetch_tasks_cubit.dart';
import 'package:family_management_app/screens/bottom_tabs.dart/calender_screen.dart';
import 'package:family_management_app/screens/bottom_tabs.dart/home_screen.dart';
import 'package:family_management_app/screens/bottom_tabs.dart/more_screen.dart';
import 'package:family_management_app/screens/bottom_tabs.dart/shopping_screen.dart';
import 'package:family_management_app/screens/bottom_tabs.dart/tasks_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NavigationScreens extends StatefulWidget {
  const NavigationScreens({super.key});

  @override
  State<NavigationScreens> createState() => _NavigationScreensState();
}

class _NavigationScreensState extends State<NavigationScreens> {
  int selectedIndex = 0;

  Map<String, List> getNavigationTabItems(BuildContext context) {
    return {
      "icons": [
        Icons.chrome_reader_mode,
        Icons.check_box_outlined,
        Icons.calendar_month_outlined,
        // Icons.child_care,
        Icons.shopify,
        Icons.compare_arrows,
      ],
      "page": [
        HomeScreen(),
        TasksScreen(),
        CalenderScreen(),
        // KidsScreen(),
        ShoppingScreen(),
        MoreScreen(),
      ],
      "label": ["Home", "Tasks", "Calendar", "Shop", "More"],
    };
  }

  void toggleIndex(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  DateTime? _lastPressed;

  void _onPopInvokedWithResult(bool didPop, Object? result) {
    if (didPop) return; // if something already popped, do nothing

    final now = DateTime.now();
    if (_lastPressed == null ||
        now.difference(_lastPressed!) > const Duration(seconds: 2)) {
      _lastPressed = now;

      mySnackBar(context, title: "Press back again to exit");
      return; // don’t exit yet
    }

    // ✅ close the app
    AppExitHelper.minimizeApp();
  }

  @override
  Widget build(BuildContext context) {
    final items = getNavigationTabItems(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _onPopInvokedWithResult,

      child: Scaffold(
        backgroundColor: AppColor.background,
        body: items['page']![selectedIndex],
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(height: 1, color: AppColor.secondary),
            SizedBox(height: 5),
            BottomNavigationBar(
              backgroundColor: Colors.transparent,
              onTap: toggleIndex,
              type: BottomNavigationBarType.fixed,
              iconSize: 25.sp,
              selectedItemColor: AppColor.secondary,
              unselectedItemColor: AppColor.textSecondary,
              currentIndex: selectedIndex,
              items: List.generate(items['icons']!.length, (index) {
                return BottomNavigationBarItem(
                  icon: Icon(items['icons']![index]),
                  label: items['label']![index],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
