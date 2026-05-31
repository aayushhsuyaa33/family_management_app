import 'package:family_management_app/app/app%20Color/app_color.dart';
import 'package:family_management_app/app/routes/app_routes.dart';
import 'package:family_management_app/app/textStyle/textstyles.dart';
import 'package:family_management_app/app/utils/utils.dart';
import 'package:family_management_app/bloc/login/login_cubit.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;
  String? emailError;
  bool isSignedUp = false;

  void _validateEmail(String value) {
    String emailPattern = r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$';
    if (value.isEmpty) {
      emailError = "Email is required";
    } else if (!RegExp(emailPattern).hasMatch(value)) {
      emailError = "Enter a valid email";
    } else {
      emailError = null;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,

        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios),
          color: AppColor.secondary,
        ),
      ),
      backgroundColor: AppColor.background,
      body: Center(
        child: BlocListener<LoginCubit, LoginState>(
          listener: (context, state) {
            if (state.status == LoginStatus.forgetting) {
              setState(() {
                isLoading = true;
              });
            } else if (state.status == LoginStatus.forgetSucessful) {
              setState(() {
                isLoading = false;
                isSignedUp = true;
              });
              myAlertBox(context, subtittle: state.errorMsg!);
            } else if (state.status == LoginStatus.forgetFailure) {
              setState(() {
                isLoading = false;
              });
              myAlertBox(context, subtittle: state.errorMsg!);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Forgot Password", style: t1heading()),
                Text(
                  "Enter your email to reset your password",
                  style: hintTextStyle().copyWith(fontSize: 16.sp),
                ),
                SizedBox(height: 30.h),
                MyTextField(
                  userController: emailController,
                  hint: "Email",
                  frontIcon: Icons.email_outlined,
                  errorMsg: emailError,
                  onChangedValue: _validateEmail,
                  isHide: false,
                  onPasswordIconClicked: () {},
                ),
                SizedBox(height: 10),
                MyButtton(
                  text: "Reset Password",
                  isLoading: isLoading,

                  onPressed: () {
                    _validateEmail(emailController.text.trim());

                    if (emailError == null) {
                      context.read<LoginCubit>().sendPasswordResetEmail(
                        emailController.text.trim(),
                      );
                    }
                  },
                ),
                SizedBox(height: 30.h),

                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.loginScreen,
                    );
                  },

                  child: AnimatedOpacity(
                    opacity: isSignedUp ? 1 : 0,
                    duration: Duration(seconds: 1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Already reset your password? ", style: t3White()),
                        Text(
                          "Login in ",
                          style: t1heading().copyWith(fontSize: 18.sp),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
