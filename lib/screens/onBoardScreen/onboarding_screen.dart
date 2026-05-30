import 'package:family_management_app/app/app%20Color/app_color.dart';
import 'package:family_management_app/app/images/app_images.dart';
import 'package:family_management_app/app/routes/app_routes.dart';
import 'package:family_management_app/app/textStyle/textstyles.dart';
import 'package:family_management_app/app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Onboardingscreen extends StatefulWidget {
  const Onboardingscreen({super.key});

  @override
  State<Onboardingscreen> createState() => _OnboardingscreenState();
}

class _OnboardingscreenState extends State<Onboardingscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 60.h),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "You're the CEO of your life",
                maxLines: 2,
                style: t1heading(),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 10.h),
              Flexible(
                child: Text(
                  "And this is your command center",
                  style: t2White(),
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
              ),
              Spacer(),

              SizedBox(
                width: 300.w,
                height: 400.h,
                child: Image.asset(AppImages.logo),
              ),
              Spacer(),
              Padding(
                padding: EdgeInsets.only(bottom: 50.h),
                child: MyButtton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.onBoardingScreen1);
                  },
                  text: "Next",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
