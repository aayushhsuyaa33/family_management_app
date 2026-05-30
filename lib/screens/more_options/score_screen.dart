import 'package:family_management_app/app/app%20Color/app_color.dart';
import 'package:family_management_app/app/textStyle/textstyles.dart';
import 'package:family_management_app/app/utils/custom_appbar.dart';
import 'package:family_management_app/app/utils/shimmer.dart';
import 'package:family_management_app/bloc/score/score_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';

class ScoreScreen extends StatefulWidget {
  const ScoreScreen({super.key});

  @override
  State<ScoreScreen> createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController;

  List<String> headings = [
    "LeaderShip\nLoad Split",
    "Execution Rate",
    "Balance",
  ];

  Color getRoleColor(String? role) {
    if (role == "Chief" || role == "Co-chief") {
      return AppColor.warning;
    } else if (role == "Lead" || role == "Unit Lead") {
      return AppColor.success;
    } else if (role == "Board Member") {
      return AppColor.secondary;
    } else if (role == "Guest") {
      return AppColor.error;
    }
    if (role == "Stakeholder") {
      return const Color(0xFF9C27B0);
    } else {
      return Color(0xFF9C27B0);
    }
  }

  @override
  void initState() {
    super.initState();
    context.read<ScoreCubit>().fetchScores();
    context.read<ScoreCubit>().fetchOverallScore();
    context.read<ScoreCubit>().fetchLoadSplitTasks();
    context.read<ScoreCubit>().fetchWeeklyTrend();

    animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    animationController.forward();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyCustomAppBar(
        heading: "Executive Snapshot",
        subTitle: "Overview of your performance",
        isBack: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Household Index",
                  style: t3White().copyWith(
                    color: AppColor.secondary,
                    fontSize: 25.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                BlocBuilder<ScoreCubit, ScoreState>(
                  builder: (context, state) {
                    final double percent = state.houseHoldPercent ?? 0;
                    if (state.overallScoreStatus == ScoreStatus.loading) {
                      return myShimmerTextBox(height: 50.h, width: 65.w);
                    }
                    return Text(
                      "${percent.toStringAsFixed(0)}%",
                      style: t2White().copyWith(fontSize: 50.sp),
                    );
                  },
                ),
                BlocBuilder<ScoreCubit, ScoreState>(
                  builder: (context, state) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          state.isUpTrend
                              ? "Up this week ${state.weeklyTrendPercent?.toStringAsFixed(1) ?? 0}%"
                              : "Down this week ${state.weeklyTrendPercent?.toStringAsFixed(1) ?? 0}%)",
                          style: hintTextStyle(),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          state.isUpTrend
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          color: state.isUpTrend ? Colors.green : Colors.red,
                          size: 18.sp,
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 30.h),
                // BlocBuilder<ScoreCubit, ScoreState>(
                //   builder: (context, state) {
                //     final pieCharList = state.loadSplitList ?? [];

                //     return Row(
                //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: [
                //         Column(
                //           children: [
                //             Text(
                //               textAlign: TextAlign.center,
                //               headings[0],
                //               style: t3White().copyWith(
                //                 color: AppColor.secondary,
                //                 fontSize: 21.sp,
                //                 fontWeight: FontWeight.w500,
                //               ),
                //             ),
                //             SizedBox(height: 20.h),
                //             SizedBox(
                //               height: 100.h,
                //               width: 120.w,
                //               child: Stack(
                //                 alignment: Alignment.center,
                //                 children: [
                //                   AnimatedBuilder(
                //                     animation: animationController,
                //                     builder: (context, child) {
                //                       return Transform.rotate(
                //                         angle:
                //                             animationController.value *
                //                             2 *
                //                             3.1416,
                //                         child: PieChart(
                //                           PieChartData(
                //                             sectionsSpace: 0,
                //                             centerSpaceRadius: 45.r,
                //                             startDegreeOffset: -90,
                //                             sections:
                //                                 pieCharList.every(
                //                                   (e) => e['tasks'] == 0,
                //                                 )
                //                                 ? [
                //                                     PieChartSectionData(
                //                                       value: 1,
                //                                       color:
                //                                           Colors.grey.shade400,
                //                                       showTitle: false,
                //                                       radius: 20.r,
                //                                     ),
                //                                   ]
                //                                 : pieCharList.map((roleData) {
                //                                     return PieChartSectionData(
                //                                       value:
                //                                           (roleData['tasks']
                //                                                   as int)
                //                                               .toDouble(),
                //                                       color: getRoleColor(
                //                                         roleData['role'],
                //                                       ),
                //                                       showTitle: true,
                //                                       title:
                //                                           '${(roleData['percentage'] as double).toStringAsFixed(0)}%',
                //                                       radius: 20.r,
                //                                       titleStyle: TextStyle(
                //                                         fontSize: 12.sp,
                //                                         fontWeight:
                //                                             FontWeight.bold,
                //                                         color: Colors.white,
                //                                       ),
                //                                     );
                //                                   }).toList(),
                //                           ),
                //                         ),
                //                       );
                //                     },
                //                   ),
                //                   Center(
                //                     child: Column(
                //                       mainAxisAlignment:
                //                           MainAxisAlignment.center,
                //                       children: [
                //                         Text("Pending", style: hintTextStyle()),

                //                         Text(
                //                           "${state.pendingTask?.toStringAsFixed(0) ?? 0}%",
                //                           style: TextStyle(
                //                             fontSize: 30.sp,
                //                             fontWeight: FontWeight.bold,
                //                             color: Colors.white,
                //                           ),
                //                         ),
                //                       ],
                //                     ),
                //                   ),
                //                 ],
                //               ),
                //             ),
                //           ],
                //         ),
                //         Column(
                //           children: [
                //             Text(
                //               textAlign: TextAlign.center,
                //               headings[1],
                //               style: t3White().copyWith(
                //                 color: AppColor.secondary,
                //                 fontSize: 21.sp,
                //                 fontWeight: FontWeight.w500,
                //               ),
                //             ),

                //             SizedBox(
                //               height: 170.h,
                //               child: Center(
                //                 child: Text(
                //                   "${state.completedTask?.toStringAsFixed(0) ?? 0}%",
                //                   style: t2White().copyWith(fontSize: 50.sp),
                //                 ),
                //               ),
                //             ),
                //           ],
                //         ),

                //         Column(
                //           children: [
                //             Text(
                //               textAlign: TextAlign.center,
                //               headings[2],
                //               style: t3White().copyWith(
                //                 color: AppColor.secondary,
                //                 fontSize: 21.sp,
                //                 fontWeight: FontWeight.w500,
                //               ),
                //             ),
                //             SizedBox(
                //               height: 140.h,
                //               child: Column(
                //                 mainAxisAlignment: MainAxisAlignment.center,
                //                 children: [
                //                   Row(
                //                     children: [
                //                       Icon(Icons.arrow_upward, size: 35.sp),
                //                       SizedBox(width: 5.w),
                //                       Text(
                //                         '+2 hr',
                //                         style: t3White().copyWith(
                //                           fontSize: 24.sp,
                //                         ),
                //                       ),
                //                     ],
                //                   ),
                //                   SizedBox(height: 15.h),
                //                   Row(
                //                     children: [
                //                       Icon(Icons.nightlight_round, size: 35.sp),
                //                       SizedBox(width: 5.w),
                //                       Text(
                //                         '7.4 hr',
                //                         style: t3White().copyWith(
                //                           fontSize: 24.sp,
                //                         ),
                //                       ),
                //                     ],
                //                   ),
                //                 ],
                //               ),
                //             ),
                //           ],
                //         ),
                //       ],
                //     );
                //   },
                // ),
                SizedBox(height: 10.h),
                Container(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Efficiency Score",
                    style: t3White().copyWith(
                      color: AppColor.secondary,
                      fontSize: 25.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                BlocBuilder<ScoreCubit, ScoreState>(
                  builder: (context, state) {
                    final membersScore = state.scoreList ?? [];
                    if (state.status == ScoreStatus.loading) {
                      return Column(
                        children: List.generate(membersScore.length, (index) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 10.h),
                            child: myShimmerBoxSharp(
                              height: 120.h,
                              width: double.infinity,
                            ),
                          );
                        }),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: membersScore.length,
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 10.h),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 10.h,
                              horizontal: 15.w,
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.dropDownAlternativeColor,
                              borderRadius: BorderRadius.circular(7.r),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  height: 120.h,
                                  width: 100.w,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      PieChart(
                                        PieChartData(
                                          sectionsSpace: 0,
                                          centerSpaceRadius: 40.r,
                                          startDegreeOffset: -90,
                                          sections: [
                                            PieChartSectionData(
                                              value: membersScore[index]
                                                  .completedTasks
                                                  .toDouble(),
                                              color: getRoleColor(
                                                membersScore[index].role,
                                              ),
                                              showTitle: false,
                                              radius: 15.r,
                                            ),
                                            PieChartSectionData(
                                              value:
                                                  membersScore[index]
                                                          .totalTasks ==
                                                      0
                                                  ? 1 // fallback value so the grey part still shows
                                                  : (membersScore[index]
                                                                .totalTasks -
                                                            membersScore[index]
                                                                .completedTasks)
                                                        .toDouble(),

                                              color: Colors.grey[200],
                                              showTitle: false,
                                              radius: 15.r,
                                            ),
                                          ],
                                        ),
                                      ),

                                      Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "completed",
                                              style: hintTextStyle(),
                                            ),

                                            Text(
                                              membersScore[index].totalTasks ==
                                                      0
                                                  ? "0%"
                                                  : "${(membersScore[index].mentalScore * 100).toStringAsFixed(0)}%",

                                              style: t2White().copyWith(
                                                fontSize: 30.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 20.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        membersScore[index].name,
                                        style: t3White().copyWith(
                                          fontSize: 22.sp,
                                          fontWeight: FontWeight.w600,
                                          color: AppColor.secondary,
                                        ),
                                      ),

                                      Text(
                                        "Role: ${membersScore[index].role}",
                                        style: t3White().copyWith(
                                          fontSize: 18.sp,
                                        ),
                                      ),

                                      Text(
                                        "Tasks: ${membersScore[index].completedTasks}/${membersScore[index].totalTasks}",
                                        style: t3White().copyWith(
                                          fontSize: 18.sp,
                                        ),
                                      ),

                                      Text(
                                        "Mental Score: ${(membersScore[index].mentalScore * 100).toStringAsFixed(0)}%",
                                        style: t3White().copyWith(
                                          fontSize: 18.sp,
                                        ),
                                      ),
                                      SizedBox(height: 5.h),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            "${getMoodIcon(membersScore[index].mentalScore)} ${getMoodText(membersScore[index].mentalScore)}",
                                            textAlign: TextAlign.center,
                                            style: t3White().copyWith(
                                              fontSize: 18.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String getMoodIcon(double score) {
    if (score >= 0.9) return "😄";
    if (score >= 0.7) return "🙂";
    if (score >= 0.5) return "😐";

    return "😞";
  }

  String getMoodText(double score) {
    if (score >= 0.9) return "Excellent";
    if (score >= 0.7) return "Good";
    if (score >= 0.5) return "Average";

    return "Stressed";
  }
}

class MyMember {
  final String name;
  final String role;
  final int totalTasks;
  final int completedTasks;
  final double mentalScore;

  MyMember({
    required this.name,
    required this.role,
    required this.totalTasks,
    required this.completedTasks,
    required this.mentalScore,
  });

  // double get efficiency => (completedTasks / totalTasks) * 100;
}
