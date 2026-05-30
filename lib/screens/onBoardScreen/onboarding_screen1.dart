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
        padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 50.h),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 30.h),
              Flexible(
                child: Text(
                  "Run your home like a boardroom",
                  style: t1heading(),
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
              ),
              SizedBox(height: 10.h),
              Flexible(
                child: Text(
                  "Organize tasks, coordinate schedules,and manage your family operations with executive-level efficiency",
                  style: t2White(),
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
              ),
              Spacer(),

              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7.r),
                  border: Border.all(width: 1, color: AppColor.secondary),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 20.h,
                    horizontal: 20.w,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_month,
                            color: AppColor.secondary,
                            size: 35.r,
                          ),
                          SizedBox(width: 5.w),
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

              Spacer(),
              SizedBox(height: 30.h),
              Padding(
                padding: EdgeInsets.only(bottom: 50.h),
                child: MyButtton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.onBoardingScreen2);
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
        SizedBox(width: 7.w),
        Text(time, style: t3White()),
        Spacer(),
        Checkbox(
          activeColor: AppColor.success,
          value: isChecked,
          onChanged: onPressed,
        ),
      ],
    );
  }
}
