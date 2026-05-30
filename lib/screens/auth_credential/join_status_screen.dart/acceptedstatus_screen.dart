import 'package:confetti/confetti.dart';
import 'package:family_management_app/app/app%20Color/app_color.dart';
import 'package:family_management_app/app/routes/app_routes.dart';
import 'package:family_management_app/app/textStyle/textstyles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AcceptedstatusScreen extends StatefulWidget {
  const AcceptedstatusScreen({super.key});
  @override
  State<AcceptedstatusScreen> createState() => _AcceptedstatusScreenState();
}

class _AcceptedstatusScreenState extends State<AcceptedstatusScreen> {
  late ConfettiController confettiController;

  @override
  void initState() {
    super.initState();
    confettiController = ConfettiController();
    confettiController.play();
  }

  @override
  void dispose() {
    confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified, size: 100, color: AppColor.secondary),

                  const SizedBox(height: 30),

                  // Title
                  Text(
                    "✅ Request Approved\nCongratulations!",
                    style: t1heading().copyWith(fontSize: 30.sp),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 15),

                  // Description
                  Text(
                    "Your join request has been approved by the board’s chief.\n"
                    "You now have full access to the board.\n\n"
                    "Start collaborating with your board members right away!",
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
                        Text(
                          "Your account has been verified! ",
                          style: t3White(),
                        ),
                        Text(
                          "Continue",
                          style: t1heading().copyWith(fontSize: 18.sp),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: true,
                  colors: [
                    Colors.green,
                    Colors.blue,
                    Colors.pink,
                    Colors.orange,
                    Colors.purple,
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
