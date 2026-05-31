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
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: AppColor.background,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 25),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Less juggling. More control.",
                  style: t1heading().copyWith(height: 1.1),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                Text(
                  "Transform chaos into order. Master the art of family managemnet with tools desgined for the modern parent executive.",
                  style: hintTextStyle().copyWith(fontSize: 16.sp),
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
                SizedBox(height: size.height * 0.07),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    myIconBox((Icons.calendar_today_outlined)),
                    SizedBox(width: 20),
                    myIconBox(Icons.card_travel_outlined),
                  ],
                ),
                SizedBox(height: 20),
                myIconBox(Icons.child_care),
                SizedBox(height: size.height * 0.07),

                MyButtton(
                  onPressed: () {
                    finishOnBoarding(context);
                  },
                  text: "Start Your Board",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget myIconBox(IconData icon) {
    return Icon(
      icon,
      color: AppColor.secondary,
      size: MediaQuery.sizeOf(context).height * 0.07,
    );
  }
}
