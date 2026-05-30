import 'dart:developer';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:family_management_app/app/app%20Color/app_color.dart';
import 'package:family_management_app/app/textStyle/textstyles.dart';
import 'package:family_management_app/app/utils/custom_enddrawer.dart';
import 'package:family_management_app/app/utils/shimmer.dart';
import 'package:family_management_app/app/utils/voice_input.dart';
import 'package:family_management_app/bloc/saving%20chats%20bloc/saving_chats_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_indicator/loading_indicator.dart';

class ChatScreen extends StatefulWidget {
  final String? chatId;
  final String? chatTitle;

  const ChatScreen({super.key, this.chatId, this.chatTitle});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.chatId != null && widget.chatId!.isNotEmpty) {
      log("Not Null");

      context.read<SavingChatsCubit>().loadExistingChat(widget.chatId!);
    } else {
      log("NUll");
      context.read<SavingChatsCubit>().resetChat();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<SavingChatsCubit>();
    return Scaffold(
      endDrawer: MyCustomEndDrawar(),
      onEndDrawerChanged: (isOpened) {
        FocusScope.of(context).unfocus();
      },
      backgroundColor: AppColor.background,
      appBar: AppBar(
        backgroundColor: AppColor.background,
        automaticallyImplyLeading: false,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu, color: AppColor.secondary),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
        ],
        leading: IconButton(
          padding: EdgeInsets.zero,
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: AppColor.secondary,
            size: 20.sp,
          ),
          onPressed: () {
            // widget.chatId null;
            widget.chatTitle == null;
            context.read<SavingChatsCubit>().resetChat();
            Navigator.of(context).maybePop();
          },
        ),
        titleSpacing: 10.w,

        title: Padding(
          padding: EdgeInsets.only(right: 10.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Avia", style: t1heading().copyWith(fontSize: 30.sp)),
                  Text("Your personal AI Assistant", style: t3White()),
                ],
              ),
            ],
          ),
        ),
      ),

      body: SafeArea(
        child: BlocConsumer<SavingChatsCubit, SavingChatsState>(
          listener: (context, state) {
            if (state.status == ChatStatus.sending) {
              FocusScope.of(context).unfocus();
              setState(() {
                _controller.clear();
                isLoading = true;
              });
            } else {
              setState(() {
                isLoading = false;
              });
            }
          },

          builder: (context, state) {
            final message = state.messages ?? [];
            if (state.status == ChatStatus.fetching) {
              return Padding(
                padding: EdgeInsets.only(right: 10.w, top: 10.h),
                child: Container(
                  alignment: Alignment.topRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      myShimmerBoxSharp(height: 40.h, width: 200.w),
                      SizedBox(height: 15.h),
                      myShimmerBoxSharp(height: 70.h, width: 340.w),
                    ],
                  ),
                ),
              );
            }

            return GestureDetector(
              behavior: HitTestBehavior
                  .opaque, // important to catch taps on empty space
              onTap: () {
                FocusScope.of(
                  context,
                ).unfocus(); // unfocus when tapping anywhere
              },
              child: Column(
                children: [
                  message.isEmpty
                      ? Expanded(
                          child: Center(
                            child: DefaultTextStyle(
                              style: t2White(),
                              child: AnimatedTextKit(
                                repeatForever: false,

                                totalRepeatCount: 1,

                                animatedTexts: [
                                  TyperAnimatedText(
                                    "What can I help you with ?",
                                    speed: const Duration(milliseconds: 70),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : Flexible(
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            controller: context
                                .read<SavingChatsCubit>()
                                .scrollController,
                            padding: const EdgeInsets.all(10),
                            itemCount: message.length,
                            itemBuilder: (context, index) {
                              final msg = message[index];
                              final isUser = msg["role"] == "user";
                              return Align(
                                alignment: isUser
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isUser
                                        ? Colors.blue[200]
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    msg["content"] ?? "",
                                    style: t3White().copyWith(
                                      color: isUser
                                          ? Colors.black
                                          : Colors.white,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                  if (isLoading)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 25.w,
                        vertical: 4,
                      ),
                      child: Container(
                        alignment: Alignment.topLeft,
                        height: 30.h,
                        width: double.infinity,
                        child: LoadingIndicator(
                          indicatorType: Indicator.lineScaleParty,
                          colors: [
                            Colors.cyanAccent,
                            Colors.lightGreenAccent,
                            Colors.amberAccent,
                            Colors.pinkAccent,
                          ],
                        ),
                      ),
                    ),

                  SizedBox(height: 20.h),

                  // Input Row
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 0,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(width: 12.w),
                          // Expanded(
                          //   child: VoiceTextField(
                          //     controller: _controller,
                          //     onChangedValue: (value) {},
                          //   ),
                          // ),
                          SizedBox(width: 12.w),
                          GestureDetector(
                            onTap: () {
                              final text = _controller.text.trim();
                              if (state.isLoading || state.isTyping) {
                                bloc.stopReply(); // stop AI typing
                              } else if (text.isNotEmpty) {
                                bloc.sendMessage(text); // send user message
                              }
                            },
                            child: Icon(
                              context
                                          .watch<SavingChatsCubit>()
                                          .state
                                          .isTyping ||
                                      isLoading
                                  ? Icons.stop_circle
                                  : Icons.send,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
