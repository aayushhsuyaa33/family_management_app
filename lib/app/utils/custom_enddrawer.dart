import 'package:family_management_app/app/app%20Color/app_color.dart';
import 'package:family_management_app/app/routes/app_routes.dart';
import 'package:family_management_app/app/textStyle/textstyles.dart';
import 'package:family_management_app/app/utils/shimmer.dart';
import 'package:family_management_app/app/utils/utils.dart';
import 'package:family_management_app/bloc/chats/all_chats_cubit.dart';
import 'package:family_management_app/bloc/saving%20chats%20bloc/saving_chats_cubit.dart';
import 'package:family_management_app/service/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyCustomEndDrawar extends StatefulWidget {
  const MyCustomEndDrawar({super.key});

  @override
  State<MyCustomEndDrawar> createState() => _MyCustomEndDrawarState();
}

class _MyCustomEndDrawarState extends State<MyCustomEndDrawar> {
  String? savedUserRole;
  String? savedUserName;
  String? savedUserImage;
  String? savedUserEmail;
  String? savedBoardId;

  @override
  void initState() {
    super.initState();
    getSecureData();
    context.read<AllChatsCubit>().fetchChatHistory();
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

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(25),
      ),
      backgroundColor: AppColor.background,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 50.h, horizontal: 25.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            profileInfoROw(
              icon: Icons.edit_note,
              text: "New Chat",
              onPressed: () {
                context.read<SavingChatsCubit>().resetChat();
                Navigator.of(context).pop();
              },
            ),
            Divider(thickness: 1, color: AppColor.secondary),
            SizedBox(height: 10.h),

            BlocBuilder<AllChatsCubit, AllChatsState>(
              builder: (context, state) {
                final chats = state.chats ?? [];

                if (state.status == FetchChatStatus.fetching) {
                  return Expanded(
                    child: Column(
                      children: List.generate(chats.length, (index) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 17.h),
                          child: myShimmerBoxSharp(
                            height: 35.h,
                            width: double.infinity,
                          ),
                        );
                      }),
                    ),
                  );
                } else if (chats.isEmpty) {
                  return Expanded(
                    child: Center(
                      child: Text(
                        "No History Available Yet",
                        style: hintTextStyle(),
                      ),
                    ),
                  );
                }

                return Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: chats.length,
                    itemBuilder: (context, index) {
                      final chat = chats[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 20.h),
                        child: GestureDetector(
                          onLongPressStart: (details) async {
                            final selected = await showMenu<String>(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadiusGeometry.circular(
                                  15.r,
                                ),
                              ),
                              context: context,
                              color: AppColor.lightBlueBgCOlor,

                              position: RelativeRect.fromLTRB(
                                details.globalPosition.dx,
                                details.globalPosition.dy,
                                MediaQuery.of(context).size.width -
                                    details.globalPosition.dx,
                                MediaQuery.of(context).size.height -
                                    details.globalPosition.dy,
                              ),
                              items: [
                                PopupMenuItem<String>(
                                  value: 'rename',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.edit_outlined,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 10.h),
                                      Text("Rename", style: t3White()),
                                    ],
                                  ),
                                ),
                                PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete_outline,
                                        color: AppColor.error,
                                      ),
                                      SizedBox(width: 10.h),
                                      Text(
                                        "Delete",
                                        style: t3White().copyWith(
                                          color: AppColor.error,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );

                            if (selected == 'delete') {
                              context.read<AllChatsCubit>().deleteChat(
                                chat['id'],
                              );
                            } else if (selected == 'rename') {
                              final controller = TextEditingController(
                                text: chat['title'],
                              );
                              final newTitle = await showDialog<String>(
                                context: context,
                                builder: (context) {
                                  return StatefulBuilder(
                                    builder: (ctx, setState) {
                                      return AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            7.r,
                                          ),
                                        ),
                                        backgroundColor:
                                            AppColor.lightBlueBgCOlor,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 15.w,
                                          vertical: 30.h,
                                        ),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            MyUploadTextField(
                                              userController: controller,
                                              hint: "",
                                              labelText: "Rename Title",
                                              isRequired: false,
                                              onChangedValue: (value) {
                                                setState(() {});
                                              },
                                            ),

                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                GestureDetector(
                                                  onTap: () =>
                                                      Navigator.pop(ctx),
                                                  child: Text(
                                                    "Cancel",
                                                    style: t3White(),
                                                  ),
                                                ),
                                                SizedBox(width: 15.w),
                                                GestureDetector(
                                                  onTap: () {
                                                    if (controller.text
                                                            .trim() !=
                                                        chat['title'].trim()) {
                                                      Navigator.pop(
                                                        ctx,
                                                        controller.text,
                                                      );
                                                    }
                                                  },
                                                  child: Text(
                                                    "Rename",
                                                    style: t3White().copyWith(
                                                      color:
                                                          (controller.text
                                                                      .trim() ==
                                                                  chat['title']
                                                                      .trim() ||
                                                              controller
                                                                  .text
                                                                  .isEmpty)
                                                          ? Colors.grey
                                                          : Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 7.w),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                              );

                              if (newTitle != null &&
                                  newTitle.trim().isNotEmpty) {
                                context.read<AllChatsCubit>().renameChat(
                                  chat['id'],
                                  newTitle.trim(),
                                );
                              }
                            }
                          },
                          onTap: () {
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.chatScreen,
                              arguments: {
                                'chatId': chat['id'],
                                'chatTitle': chat['title'],
                              },
                            );
                          },
                          child: Text(
                            chat['title'],
                            style: t3White().copyWith(fontSize: 22.sp),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            Padding(
              padding: EdgeInsets.only(top: 15.h, bottom: 7.h),
              child: Row(
                children: [
                  MyProfileHolder(
                    width: 50,
                    fontSize: 30,
                    height: 50,
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
          // mainAxisAlignment: MainAxisAlignment.center,
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
