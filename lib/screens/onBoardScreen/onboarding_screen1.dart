import 'package:family_management_app/app/app%20Color/app_color.dart';
import 'package:family_management_app/app/routes/app_routes.dart';
import 'package:family_management_app/app/textStyle/textstyles.dart';
import 'package:family_management_app/app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OnboardingScreen1 extends StatefulWidget {
  const OnboardingScreen1({super.key});

  @override
  State<OnboardingScreen1> createState() => _OnboardingScreen1State();
}

class _OnboardingScreen1State extends State<OnboardingScreen1> {
  List<bool> isChecked = [false, false, false];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Run your home like a boardroom",
                  style: t1heading().copyWith(height: 1.1),
                  textAlign: TextAlign.center,
                  // softWrap: true,
                ),
                SizedBox(height: 20),

                Text(
                  "Organize tasks, coordinate schedules,and manage your family operations with executive-level efficiency",
                  style: hintTextStyle().copyWith(fontSize: 16.sp),
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
                SizedBox(height: 30),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(width: 1, color: AppColor.secondary),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_month,
                              color: AppColor.secondary,
                              size: 30,
                            ),
                            SizedBox(width: 7),
                            Text(
                              "Today's Agenda",
                              style: t1().copyWith(color: AppColor.secondary),
                            ),
                          ],
                        ),
                        SizedBox(height: 15.h),
                        timeDisplayRow(
                          time: "9:00 AM - School pickup",
                          isChecked: isChecked[0],
                          onPressed: (newValue) {
                            setState(() {
                              isChecked[0] = newValue!;
                            });
                          },
                        ),
                        timeDisplayRow(
                          time: "2:00 PM- Grocery shopping",
                          isChecked: isChecked[1],
                          onPressed: (newValue) {
                            setState(() {
                              isChecked[1] = newValue!;
                            });
                          },
                        ),
                        timeDisplayRow(
                          time: "6:00 PM - Family dinner",
                          isChecked: isChecked[2],
                          onPressed: (newValue) {
                            setState(() {
                              isChecked[2] = newValue!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 35),
                MyButtton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.onBoardingScreen2);
                  },
                  text: "Next",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget timeDisplayRow({
    bool isChecked = false,
    String time = "9:00 AM - School pickup",
    required ValueChanged<bool?> onPressed,
  }) {
    return Row(
      children: [
        Icon(
          Icons.watch_later_outlined,
          color: AppColor.secondary,
          size: 18.sp,
        ),
        SizedBox(width: 7),
        Expanded(child: Text(time, maxLines: 1, style: t3White())),

        Checkbox(
          activeColor: AppColor.success,
          value: isChecked,
          onChanged: onPressed,
        ),
      ],
    );
  }
}
