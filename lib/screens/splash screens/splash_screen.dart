import 'package:family_management_app/app/app%20Color/app_color.dart';
import 'package:family_management_app/app/images/app_images.dart';
import 'package:family_management_app/app/routes/app_routes.dart';
import 'package:family_management_app/app/textStyle/textstyles.dart';
// import 'package:family_management_app/service/notification_service.dart';
import 'package:family_management_app/service/secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;

  late Animation<double> tweenController;
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _handleSplashNavigation(context);
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
    tweenController = Tween<double>(
      begin: 0,
      end: 1.0,
    ).animate(animationController);
    animationController.forward();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  Future<void> _handleSplashNavigation(context) async {
    // await NotificationService.requestPermission();
    SharedPreferences pref = await SharedPreferences.getInstance();
    bool isFirstInstall = pref.getBool("isFirstInstall") ?? true;
    final savedUid = await AppStorage.read(key: 'uid');

    // await Future.delayed(Duration(milliseconds: 1200));
    // if (isFirstInstall) {
    //   Navigator.pushNamedAndRemoveUntil(
    //     context,
    //     AppRoutes.splashScreen1,
    //     (route) => false,
    //   );
    //   return;
    // } else if (savedUid != null) {
    //   Navigator.pushNamedAndRemoveUntil(
    //     context,
    //     AppRoutes.navigationScreen,
    //     (route) => false,
    //   );
    //   return;
    // } else {
    //   Navigator.pushNamedAndRemoveUntil(
    //     context,
    //     AppRoutes.loginScreen,
    //     (route) => false,
    //   );
    //   return;
    // }
  }

  // Aaded comenet
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: AppColor.ba,
      body: AnimatedBuilder(
        animation: tweenController,
        builder: (context, child) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: animationController,
                  child: Container(
                    width: 300.w,
                    height: 300.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.r),
                      image: DecorationImage(
                        image: AssetImage(AppImages.logo),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                Text(
                  'ALTOS HQ',
                  style: t1White().copyWith(
                    fontSize: 35.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColor.secondary,
                  ),
                ),

                // SizedBox(height: 15.h),
              ],
            ),
          );
        },
      ),
    );
  }
}
