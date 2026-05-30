import 'package:family_management_app/app/app%20Color/app_color.dart';
import 'package:family_management_app/app/routes/app_routes.dart';
import 'package:family_management_app/app/textStyle/textstyles.dart';
import 'package:family_management_app/app/utils/utils.dart';
import 'package:family_management_app/bloc/fetch%20User/fetch_user_cubit.dart';
import 'package:family_management_app/service/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';

class MyCustomDrawar extends StatefulWidget {
  const MyCustomDrawar({super.key});

  @override
  State<MyCustomDrawar> createState() => _MyCustomDrawarState();
}

class _MyCustomDrawarState extends State<MyCustomDrawar> {
  String? savedUserRole;
  String? savedUserName;
  String? savedUserImage;
  String? savedUserEmail;
  String? savedBoardId;

  @override
  void initState() {
    super.initState();
    getSecureData();
  }

  void inviteUser() {
    const String message = '''
Hey 👋, join me on this awesome app!
Download it here: https://play.google.com/store/apps/details?id=com.example.app
Or on iOS: https://apps.apple.com/app/idXXXXXXXX
''';
    Share.share(message, subject: "You're invited!");
  }

  Future<void> getSecureData() async {
    final userRole = await AppStorage.read(key: "savedRole");
    final userName = await AppStorage.read(key: "name");
    final userImage = await AppStorage.read(key: "imagePath");
    final useremail = await AppStorage.read(key: "email");
    final userBoardId = await AppStorage.read(key: "boardId");
    setState(() {
      savedUserRole = userRole;
      savedUserName = userName;
      savedUserImage = userImage;
      savedUserEmail = useremail;
      savedBoardId = userBoardId;
    });
  }

  Map<String, List> getIcon(BuildContext context) {
    if (savedUserRole == "Chief" || savedUserRole == "Lead") {
      return {
        "icons": [Icons.settings, Icons.share, Icons.logout],
        "label": ["Settings", "Share", "Log Out"],
        "actions": [
          () => Navigator.pushNamed(
            context,
            AppRoutes.settingScreen,
            arguments: {'isBack': true},
          ),
          () => inviteUser(),
          () {
            myAlertBoxYesNo(
              context,
              onYesPressed: () async {
                await AppStorage.deleteKeysOnLogout();
                context.read<FetchUserCubit>().logOut();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.loginScreen,
                  (route) => false,
                );
              },
            );
          },
        ],
      };
    } else if (savedUserRole == "Board Member") {
      return {
        "icons": [Icons.settings, Icons.share, Icons.logout],
        "label": ["Settings", "Share", "Log Out"],
        "actions": [
          () => Navigator.pushNamed(
            context,
            AppRoutes.settingScreen,
            arguments: {'isBack': true},
          ),
          () => inviteUser(),
          () {
            myAlertBoxYesNo(
              context,
              onYesPressed: () async {
                await AppStorage.deleteKeysOnLogout();
                context.read<FetchUserCubit>().logOut();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.loginScreen,
                  (route) => false,
                );
              },
            );
          },
        ],
      };
    }
    return {
      "icons": [Icons.settings, Icons.share, Icons.logout],
      "label": ["Settings", "Share", "Log Out"],
      "actions": [
        () => Navigator.pushNamed(
          context,
          AppRoutes.settingScreen,
          arguments: {'isBack': true},
        ),
        () => inviteUser(),
        () {
          myAlertBoxYesNo(
            context,
            onYesPressed: () async {
              await AppStorage.deleteKeysOnLogout();
              context.read<FetchUserCubit>().logOut();
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.loginScreen,
                (route) => false,
              );
            },
          );
        },
      ],
    };
  }

  @override
  Widget build(BuildContext context) {
    final roleBaseIcons = getIcon(context);
    return Drawer(
      backgroundColor: AppColor.background,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 70.h, horizontal: 25.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                MyProfileHolder(
                  width: 70,
                  fontSize: 40,
                  height: 70,
                  name: savedUserName ?? "",
                  imagePath: savedUserImage ?? "",
                ),
                SizedBox(width: 15.sp),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        savedUserName ?? "",
                        style: t1heading().copyWith(fontSize: 20.sp),
                      ),
                      Text(
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        "${savedUserRole ?? ""} [${savedBoardId ?? ""}]",
                        style: hintTextStyle().copyWith(fontSize: 18.sp),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            profileInfoROw(
              icon: Icons.email,
              text: savedUserEmail ?? "Email not set",
              onPressed: () {},
            ),

            Divider(thickness: 1, color: AppColor.secondary),
            SizedBox(height: 10.h),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(roleBaseIcons['icons']!.length, (index) {
                return profileInfoROw(
                  onPressed: roleBaseIcons['actions']![index],
                  icon: roleBaseIcons['icons']![index],
                  text: roleBaseIcons['label']![index],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget profileInfoROw({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: GestureDetector(
        onTap: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icon, color: AppColor.secondary),
            SizedBox(width: 10.h),
            Expanded(
              child: Text(
                overflow: TextOverflow.ellipsis,

                text,
                style: t1heading().copyWith(
                  fontSize: 18.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
