import 'package:family_management_app/app/app%20Color/app_color.dart';
import 'package:family_management_app/app/textStyle/textstyles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyCustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String heading;
  final String? subTitle;
  final bool isBack;
  final bool isLastRow;
  final VoidCallback? onSkipClicked;
  final bool isRightDrawer;
  final bool isInvite;
  final VoidCallback? onInviteClicked;
  final VoidCallback? onBackPressed;

  const MyCustomAppBar({
    super.key,
    required this.heading,
    this.subTitle,
    this.isBack = false,
    this.isLastRow = false,
    this.onSkipClicked,
    this.isRightDrawer = false,
    this.isInvite = false,
    this.onInviteClicked,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColor.background,
      automaticallyImplyLeading: isBack,
      actionsPadding: EdgeInsets.only(top: 10),
      actions: [
        isRightDrawer
            ? Builder(
                builder: (context) => IconButton(
                  icon: Icon(Icons.menu, color: AppColor.secondary),
                  onPressed: () {
                    Scaffold.of(context).openEndDrawer();

                    // opens right drawer
                  },
                ),
              )
            : isInvite
            ? Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColor.lightBlueBgCOlor,
                ),

                padding: EdgeInsets.all(4.r),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    onInviteClicked?.call();
                  },
                  icon: Icon(Icons.share),
                  color: AppColor.secondary,
                  iconSize: 25.sp,
                ),
              )
            : SizedBox(),
      ],

      leading: isBack
          ? SizedBox()
          : IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: AppColor.secondary,
                size: 20.sp,
              ),
              onPressed: () {
                Navigator.of(context).maybePop();
                onBackPressed?.call();
              },
            ),
      titleSpacing: 10.w,
      toolbarHeight: 90.h,
      leadingWidth: isBack ? 20.w : 50.w,

      title: Padding(
        padding: EdgeInsets.only(right: 10.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: subTitle == null
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                Text(heading, style: t1heading().copyWith(fontSize: 30.sp)),
                subTitle != null
                    ? Text(subTitle!, style: t3White())
                    : SizedBox(),
              ],
            ),
            Spacer(),

            isLastRow
                ? GestureDetector(
                    onTap: onSkipClicked,
                    child: Text("Skip", style: t3White()),
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
