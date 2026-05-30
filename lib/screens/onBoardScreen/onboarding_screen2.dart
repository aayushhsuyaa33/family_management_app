import 'package:family_management_app/app/app%20Color/app_color.dart';
import 'package:family_management_app/app/routes/app_routes.dart';
import 'package:family_management_app/app/textStyle/textstyles.dart';
import 'package:family_management_app/app/utils/utils.dart';
import 'package:family_management_app/service/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OnboardingScreen2 extends StatefulWidget {
  const OnboardingScreen2({super.key});

  @override
  State<OnboardingScreen2> createState() => _OnboardingScreen2State();
}

class _OnboardingScreen2State extends State<OnboardingScreen2> {
  Future<void> finishOnBoarding(context) async {
    AppStorage.setIsFirstInstall(false);

    Navigator.pushReplacementNamed(context, AppRoutes.registerScreen);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 50.h),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 30.h),
              Text(
                "Less juggling. More control.",
                style: t1heading(),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10.h),
              Flexible(
                child: Text(
                  "Transform chaos into order. Master the art of family managemnet with tools desgined for the modern parent executive.",
                  style: t2White(),
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
              ),
              Spacer(),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      myIconBox((Icons.calendar_today_outlined)),
                      SizedBox(width: 20.w),
                      myIconBox(Icons.card_travel_outlined),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  myIconBox(Icons.child_care),
                ],
              ),

              Spacer(),
              Padding(
                padding: EdgeInsets.only(bottom: 50.h),
                child: MyButtton(
                  onPressed: () {
                    finishOnBoarding(context);
                  },
                  text: "Start Your Board",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget myIconBox(IconData icon) {
    return Icon(icon, color: AppColor.secondary, size: 70.w);
  }
}
