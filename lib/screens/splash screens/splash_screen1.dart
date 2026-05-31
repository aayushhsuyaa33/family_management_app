import 'package:family_management_app/app/app%20Color/app_color.dart';
import 'package:family_management_app/app/images/app_images.dart';
import 'package:family_management_app/app/routes/app_routes.dart';
import 'package:family_management_app/app/textStyle/textstyles.dart';
import 'package:flutter/material.dart';

class SplashScreen1 extends StatefulWidget {
  const SplashScreen1({super.key});

  @override
  State<SplashScreen1> createState() => _SplashScreen1State();
}

class _SplashScreen1State extends State<SplashScreen1>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    checkFlowAndNavigate(context);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = Tween<double>(begin: 0.0, end: 250.0).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> checkFlowAndNavigate(context) async {
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, AppRoutes.onBoardingScreen);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: AppColor.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("HOME OPS", style: t1heading()),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: size.height * 0.4,
                  maxWidth: size.width * 0.8,
                ),
                child: Image.asset(AppImages.logo),
              ),
              Text(
                "RUN THE COMMAND CENTER FOR YOUR HOME",
                textAlign: TextAlign.center,
                style: t1().copyWith(color: AppColor.secondary),
              ),
              const SizedBox(height: 25),
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Container(
                    width: _animation.value,
                    height: 4,
                    color: AppColor.secondary,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
