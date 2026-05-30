import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

Widget myShimmerBox({double width = 90, double height = 60}) {
  return Shimmer.fromColors(
    baseColor: Color(0xFF152A4F),
    highlightColor: Color(0xFF1E3A70),
    child: Column(
      children: [
        Container(
          height: height.h,
          width: width.w,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: Color(0xFF152A4F),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ],
    ),
  );
}

Widget myShimmerBoxSharp({double width = 90, double height = 60}) {
  return Shimmer.fromColors(
    baseColor: Color(0xFF152A4F),
    highlightColor: Color(0xFF1E3A70),
    child: Column(
      children: [
        Container(
          height: height.h,
          width: width.w,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: Color(0xFF152A4F),
            borderRadius: BorderRadius.circular(6.r),
          ),
        ),
      ],
    ),
  );
}

Widget myShimmerBoxCircle({double width = 90, double height = 60}) {
  return Shimmer.fromColors(
    baseColor: Color(0xFF152A4F),
    highlightColor: Color(0xFF1E3A70),
    child: Column(
      children: [
        Container(
          height: height.h,
          width: width.w,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: Color(0xFF152A4F),
            shape: BoxShape.circle,
          ),
        ),
      ],
    ),
  );
}

Widget myShimmerCommandCenterBox({double width = 90, double height = 90}) {
  return Shimmer.fromColors(
    baseColor: Color(0xFF152A4F),
    highlightColor: Color(0xFF1E3A70),
    child: Column(
      children: [
        Container(
          // height: height.h,
          // width: width.w,
          height: 90.h,
          width: 90.w,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: Color(0xFF152A4F),
            shape: BoxShape.circle,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ],
    ),
  );
}

Widget myShimmerTextBox({double width = 90, double height = 60}) {
  return Shimmer.fromColors(
    baseColor: Colors.grey.shade700,
    highlightColor: Colors.grey.shade500,
    child: Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey.shade700,
        borderRadius: BorderRadius.circular(6),
      ),
    ),
  );
}

Widget myTasksShimmerBox({
  double width = 90,
  double height = 60,
  int itemCount = 6,
}) {
  return Shimmer.fromColors(
    baseColor: Color(0xFF152A4F),
    highlightColor: Color(0xFF1E3A70),
    child: Padding(
      padding: EdgeInsets.all(5.0),
      child: Container(
        height: height.h,
        width: width.w,

        decoration: BoxDecoration(
          color: Color(0xFF152A4F),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );
}
