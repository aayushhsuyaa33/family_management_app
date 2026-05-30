import 'package:family_management_app/app/images/app_images.dart';
import 'package:family_management_app/app/routes/app_routes.dart';
import 'package:family_management_app/app/utils/shimmer.dart';

import 'package:family_management_app/bloc/fetch_cubit/fetch_event_cubit.dart';
import 'package:flutter/material.dart';
import 'package:family_management_app/app/app%20Color/app_color.dart';
import 'package:family_management_app/app/textStyle/textstyles.dart';
import 'package:family_management_app/app/utils/utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class KidsScreen extends StatefulWidget {
  const KidsScreen({super.key});

  @override
  State<KidsScreen> createState() => _KidsScreenState();
}

class _KidsScreenState extends State<KidsScreen> {
  List<Color> iconColorsList = [AppColor.success, AppColor.secondary];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.background,
        automaticallyImplyLeading: false,
        toolbarHeight: 80.h,

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Kids DashBoard",
              style: t1heading().copyWith(fontSize: 30.sp),
            ),
            Text(
              "Monitor and manage your children's activities",
              style: t3White(),
            ),
          ],
        ),
      ),
      backgroundColor: AppColor.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BlocBuilder<FetchEventCubit, FetchEventState>(
                builder: (context, state) {
                  final kidsList = state.kidsInfo ?? [];
                  if (state.status == FetchKidsStatus.fetching) {
                    return Column(
                      children: List.generate(kidsList.length, (index) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 15.h),
                          child: myShimmerBox(
                            width: double.infinity,
                            height: 200.h,
                          ),
                        );
                      }),
                    );
                  }

                  return kidsList.isEmpty
                      ? SizedBox(
                          height: 500.h,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(AppImages.oopsImage),
                              Text(
                                "No Stakeholder added yet",
                                style: t3White(),
                              ),
                            ],
                          ),
                        )
                      : SizedBox(
                          height: 490.h,
                          child: ListView.builder(
                            physics: AlwaysScrollableScrollPhysics(),
                            itemCount: kidsList.length,
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, index) {
                              final kidsProfile = kidsList[index];

                              return Padding(
                                padding: EdgeInsets.only(bottom: 20.h),
                                child: myTextHolderContainer(
                                  horizontal: 20.w,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          iconWithColumn(
                                            heading:
                                                kidsProfile.kidName ??
                                                "Unknown",
                                            icon: Icons.child_care,
                                            subtitle:
                                                "${kidsProfile.kidAge?.split("y").first ?? "N/A"} years old",
                                            isBold: true,
                                          ),
                                          Spacer(),
                                          iconContainer(
                                            color:
                                                iconColorsList[index %
                                                    iconColorsList.length],
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10.h),
                                      iconWithColumn(
                                        heading: "NEXT EVENT",
                                        icon: Icons.calendar_month_outlined,
                                        subtitle:
                                            kidsProfile.kidNextEvent ??
                                            "No upcoming event",
                                      ),
                                      SizedBox(height: 10.h),
                                      iconWithColumn(
                                        heading: "RECENT ACTIVITY",
                                        icon: Icons.account_tree_rounded,
                                        subtitle:
                                            kidsProfile.kidRecentEvent ??
                                            "No recent activity",

                                        isGreen: true,
                                      ),

                                      SizedBox(height: 20.h),
                                      MyButttonWithIcon(
                                        text: "View Full Profile",
                                        onPressed: () {
                                          Navigator.pushNamed(
                                            context,
                                            AppRoutes.profileScreen,
                                            arguments: {
                                              'isChild': true,
                                              "uid": kidsProfile.uid!,
                                              'email': kidsProfile.kidName,
                                            },
                                          );
                                        },
                                        isInfinte: true,
                                        icon: Icons.menu_book_outlined,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                },
              ),

              SizedBox(height: 30.h),
              Text(
                " Upcoming Milestones",
                style: t1heading().copyWith(fontSize: 25.sp),
              ),
              SizedBox(height: 10.h),
              BlocBuilder<FetchEventCubit, FetchEventState>(
                builder: (context, state) {
                  final globalList = state.globalUpcomingEvents ?? [];

                  if (state.status == FetchKidsStatus.fetching) {
                    return myTextHolderContainer(
                      child: Column(
                        children: List.generate(globalList.length, (index) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 7.h),
                            child: myShimmerBoxSharp(
                              width: double.infinity,
                              height: 25.h,
                            ),
                          );
                        }),
                      ),
                    );
                  }
                  return globalList.isEmpty
                      ? Center(
                          child: Text(
                            "No upcoming MileStones",
                            style: t3White(),
                          ),
                        )
                      : myTextHolderContainer(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(globalList.length, (index) {
                              return Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      "• ${(globalList[index]['kidName'] ?? "Unknown").toString().split(' ').first}: ${globalList[index]['title'] ?? "No upcoming event"}",
                                      style: t3White(),
                                    ),
                                  ),
                                  SizedBox(width: 5.w),

                                  Text(
                                    "- ${(globalList[index]['date'] ?? "2025-01-01").toString().substring(0, 10)}",

                                    style: t3White(),
                                  ),
                                ],
                              );
                            }),
                          ),
                        );
                },
              ),
              // SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget iconWithColumn({
    required String heading,
    required IconData icon,
    required String subtitle,
    bool isBold = false,
    isGreen = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 25.sp,
          color: isGreen ? AppColor.success : AppColor.secondary,
        ),
        SizedBox(width: 10.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(heading, style: isBold ? t1White() : hintTextStyle()),
            Text(subtitle, style: hintTextStyle()),
          ],
        ),
      ],
    );
  }

  Widget iconContainer({Color color = AppColor.success}) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(8.r),

      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Icon(Icons.favorite_outline, color: AppColor.textSecondary),
    );
  }
}
