import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_management_app/app/app%20Color/app_color.dart';
import 'package:family_management_app/app/routes/app_routes.dart';
import 'package:family_management_app/app/textStyle/textstyles.dart';
import 'package:family_management_app/app/utils/utils.dart';
import 'package:family_management_app/bloc/login/login_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController userEmailController = TextEditingController();
  TextEditingController userPasswordController = TextEditingController();
  bool isHide = true;
  bool isLoading1 = false;
  bool isDialogOpen = false;
  String? emailError;
  bool isGoogleLogin = false;

  String? uid;

  String? passwordError;
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

  void _validatePassword(String value) {
    if (value.isEmpty) {
      passwordError = "Password is required";
    } else {
      passwordError = null;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      body: BlocListener<LoginCubit, LoginState>(
        listener: (context, state) async {
          if (state.status == LoginStatus.logging) {
            setState(() {
              isLoading1 = true;
            });
          } else if (state.status == LoginStatus.logged) {
            setState(() {
              isLoading1 = false;
            });

            Navigator.pushReplacementNamed(context, AppRoutes.navigationScreen);
          } else if (state.status == LoginStatus.loginFailure) {
            setState(() {
              isLoading1 = false;
            });
            myAlertBox(context, subtittle: state.errorMsg!);
          } else if (state.status == LoginStatus.googleLoginSuccessful) {
            final userDocRef = FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser?.uid);

            final snapshot = await userDocRef.get();

            bool isRoleExists =
                snapshot.exists && snapshot.data()?['role'] != null;
            log(isRoleExists.toString());
            if (isRoleExists == true) {
              Navigator.pushReplacementNamed(
                context,
                AppRoutes.navigationScreen,
              );
            } else if (isRoleExists == false) {
              await GoogleSignIn().signOut();
              Navigator.pushReplacementNamed(
                context,
                AppRoutes.roleSelectionScreen,
              );
            } else {}
          } else if (state.status == LoginStatus.googleLogin) {
            setState(() {
              isGoogleLogin = true;
            });
          } else if (state.status == LoginStatus.googleLoginFailure) {
            setState(() {
              isGoogleLogin = false;
            });
            myAlertBox(context, subtittle: state.errorMsg!);
          } else if (state.status == LoginStatus.navigateToRoleUpdate) {
            setState(() {
              isLoading1 = false;
            });
            myAlertBox(context, subtittle: state.errorMsg!);
            await Future.delayed(Duration(seconds: 2));
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.roleSelectionScreen,
            );
          } else if (state.status == LoginStatus.isInvited) {
            setState(() {
              uid = state.uid;
            });

            Navigator.pushReplacementNamed(
              context,
              AppRoutes.registerScreen,
              arguments: {
                'uid': state.uid ?? "",
                'boardId': state.boardId ?? "",
              },
            );
          }
        },
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Welcome Back", style: t1heading()),
                    Text(
                      "Sign in to your command center",
                      style: hintTextStyle().copyWith(fontSize: 16.sp),
                    ),

                    SizedBox(height: 30),
                    MyTextField(
                      userController: userEmailController,
                      hint: "Email",
                      frontIcon: Icons.email_outlined,
                      errorMsg: emailError,
                      onChangedValue: _validateEmail,
                      isHide: false,
                      onPasswordIconClicked: () {},
                    ),
                    MyTextField(
                      userController: userPasswordController,
                      hint: "Password",
                      frontIcon: Icons.lock_outline_sharp,
                      errorMsg: passwordError,
                      onChangedValue: _validatePassword,
                      isHide: isHide,
                      isbackIcon: true,
                      onPasswordIconClicked: () {
                        setState(() {
                          isHide = !isHide;
                        });
                      },
                      bottomPadding: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.forgetPasswordScreen,
                        );
                      },
                      child: Container(
                        alignment: Alignment.topRight,
                        child: Text(
                          "Forgot Password ?  ",
                          style: t3White().copyWith(color: AppColor.secondary),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    BlocBuilder<LoginCubit, LoginState>(
                      builder: (context, state) {
                        return MyButtton(
                          text: "Sign In",
                          isLoading: isLoading1,
                          onPressed: () async {
                            _validateEmail(userEmailController.text.trim());
                            _validatePassword(
                              userPasswordController.text.toString(),
                            );
                            if (passwordError == null && emailError == null) {
                              context.read<LoginCubit>().login(
                                email: userEmailController.text.toString(),
                                password: userPasswordController.text
                                    .toString(),
                              );
                            }
                          },
                        );
                      },
                    ),
                    SizedBox(height: 20),

                    Text(
                      "------------ Or Continue With -------------",
                      style: hintTextStyle(),
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: List.generate(2, (index) {
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: GestureDetector(
                              onTap: () async {
                                if (index == 0) {
                                  context.read<LoginCubit>().signInWithGoogle();
                                } else {
                                  mySnackBar(
                                    context,
                                    title: "Apple Sign will be enabled soon",
                                  );
                                }
                              },
                              child: Container(
                                height: 50.h,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 25, 47, 85),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: SvgPicture.asset(
                                    index == 0
                                        ? "assets/svg/google.svg"
                                        : "assets/svg/apple.svg",
                                    width: 30.w,
                                    height: 30.h,
                                    color: index == 1 ? Colors.white : null,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: 30),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.registerScreen,
                        );
                      },

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't have an account? ", style: t3White()),
                          Text(
                            "Sign Up ",
                            style: t1heading().copyWith(fontSize: 18.sp),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              isGoogleLogin
                  ? Container(
                      height: MediaQuery.of(context).size.height * 1,
                      color: Colors.black26,
                    )
                  : const SizedBox.shrink(),
              isGoogleLogin
                  ? CircularProgressIndicator(color: AppColor.secondary)
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
