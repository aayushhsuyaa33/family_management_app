import 'dart:developer';
import 'package:family_management_app/app/app%20Color/app_color.dart';
import 'package:family_management_app/app/routes/app_routes.dart';
import 'package:family_management_app/app/textStyle/textstyles.dart';
import 'package:family_management_app/bloc/fetch%20User/fetch_user_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RejectedstatusScreen extends StatefulWidget {
  final String? boardId;

  const RejectedstatusScreen({super.key, this.boardId});

  @override
  State<RejectedstatusScreen> createState() => _RejectedstatusScreenState();
}

class _RejectedstatusScreenState extends State<RejectedstatusScreen> {
  Future<void> holdOnWaiting(context) async {
    log(widget.boardId!);
  }

  @override
  void initState() {
    super.initState();
    holdOnWaiting(context);
    context.read<FetchUserCubit>().checkWaiting(
      boardId: widget.boardId ?? "45642",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Decorative animation or icon
              Icon(Icons.cancel, size: 100, color: AppColor.secondary),

              const SizedBox(height: 30),

              // Title
              Text(
                "❌ Request Rejected",
                style: t1heading().copyWith(fontSize: 35.sp),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 15),

              // Description
              Text(
                "Your join request has been reviewed by the board’s chief.\n"
                "Unfortunately, it has not been approved.\n\n"
                "You can reach out to the board’s chief for more information or try submitting another request later.",

                style: hintTextStyle(),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.loginScreen,
                    (route) => false,
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Verification failed. ", style: t3White()),
                    Text(
                      "Try again",
                      style: t1heading().copyWith(fontSize: 18.sp),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
