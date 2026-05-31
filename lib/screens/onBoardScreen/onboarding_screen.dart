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
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: AppColor.background,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "You're the CEO of your life",
                maxLines: 2,
                style: t1heading().copyWith(height: 1.1),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15),
              Text(
                "And this is your command center",
                style: hintTextStyle().copyWith(fontSize: 18.sp),
                textAlign: TextAlign.center,
                softWrap: true,
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: size.height * 0.4,
                  maxWidth: size.width * 0.8,
                ),
                child: Image.asset(AppImages.logo),
              ),
              SizedBox(height: 20),
              MyButtton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.onBoardingScreen1);
                },
                text: "Next",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
