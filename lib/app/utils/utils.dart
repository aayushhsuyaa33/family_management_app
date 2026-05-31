import 'dart:io';
import 'package:family_management_app/app/app%20Color/app_color.dart';
import 'package:family_management_app/app/images/app_images.dart';
import 'package:family_management_app/app/textStyle/textstyles.dart';
import 'package:family_management_app/bloc/fetch%20User/fetch_user_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:loading_indicator/loading_indicator.dart';

class MyButtton extends StatefulWidget {
  final bool isLoading;
  final String text;
  final VoidCallback onPressed;
  final Color buttonColor;

  const MyButtton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.buttonColor = AppColor.secondary,
  });

  @override
  State<MyButtton> createState() => _MyButttonState();
}

class _MyButttonState extends State<MyButtton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // widget.isLoading ? null :
      onTap: widget.onPressed,
      child: Container(
        alignment: Alignment.center,
        width: double.infinity,
        height: 65.h,
        decoration: BoxDecoration(
          color: // disabled color
              widget.buttonColor,
          borderRadius: BorderRadius.circular(35.r),
        ),
        child: widget.isLoading
            ? LoadingAnimationWidget.inkDrop(
                color: AppColor.dropDownColor,
                size: 40.h,
              )
            : Text(widget.text, style: t1()),
      ),
    );
  }
}

class MyNavigationButton extends StatefulWidget {
  final bool isLoading;
  final String text;
  final VoidCallback onPressed;
  final Color buttonColor;

  const MyNavigationButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.buttonColor = AppColor.secondary,
  });

  @override
  State<MyNavigationButton> createState() => _MyNavigationButtonState();
}

class _MyNavigationButtonState extends State<MyNavigationButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isLoading ? null : widget.onPressed,
      child: Container(
        alignment: Alignment.center,

        height: 65.h,
        decoration: BoxDecoration(
          color: // disabled color
              widget.buttonColor,
          borderRadius: BorderRadius.circular(35.r),
        ),
        child: widget.isLoading
            ? LoadingAnimationWidget.inkDrop(
                color: AppColor.dropDownColor,
                size: 40.h,
              )
            : Text(widget.text, style: t1()),
      ),
    );
  }
}

class MyTextField extends StatelessWidget {
  final TextEditingController userController;
  final bool isHide;
  final IconData? frontIcon;
  final bool isbackIcon;
  final String? hint;
  final String? errorMsg;
  final VoidCallback onPasswordIconClicked;
  final ValueChanged<String>? onChangedValue;
  final double bottomPadding;
  final bool isCapital;
  final bool isEnable;

  const MyTextField({
    super.key,
    this.isHide = false,
    required this.userController,
    this.frontIcon,
    this.hint,
    this.isbackIcon = false,
    this.errorMsg,
    this.onChangedValue,
    required this.onPasswordIconClicked,
    this.bottomPadding = 20,
    this.isCapital = false,
    this.isEnable = true,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            autofocus: false,
            enabled: isEnable,
            controller: userController,
            textCapitalization: isCapital
                ? TextCapitalization.sentences
                : TextCapitalization.none,

            onChanged: onChangedValue,
            obscureText: isHide,
            textAlignVertical: TextAlignVertical.center,
            cursorColor: Colors.blue,
            style: t3White(),

            decoration: InputDecoration(
              errorText: errorMsg,
              errorStyle: hintTextStyle().copyWith(
                fontSize: 12.sp,
                color: AppColor.error,
              ),

              contentPadding: EdgeInsets.symmetric(vertical: 17.h),
              filled: true,
              suffixIcon: isbackIcon
                  ? IconButton(
                      onPressed: onPasswordIconClicked,
                      icon: isHide
                          ? Icon(Icons.visibility)
                          : Icon(Icons.visibility_off),
                      color: AppColor.textSecondary.withAlpha(150),
                    )
                  : null,
              fillColor: isEnable
                  ? AppColor.secondary.withAlpha(10)
                  : Colors.grey.withAlpha(70),
              prefixIcon: Padding(
                padding: EdgeInsets.only(left: 10.w, right: 3.w),
                child: Icon(frontIcon, color: AppColor.secondary),
              ),
              prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
              hintText: hint,

              hintStyle: hintTextStyle(),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: AppColor.secondary),
                borderRadius: BorderRadius.circular(10.r),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColor.secondary),
                borderRadius: BorderRadius.circular(10.r),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColor.secondary),
                borderRadius: BorderRadius.circular(10.r),
              ),

              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// class MyTextFieldChat extends StatefulWidget {
//   final TextEditingController userController;

//   final String? hint;

//   final ValueChanged<String>? onChangedValue;
//   final double bottomPadding;

//   const MyTextFieldChat({
//     super.key,
//     required this.userController,
//     this.hint,
//     this.onChangedValue,
//     this.bottomPadding = 7,
//   });

//   @override
//   State<MyTextFieldChat> createState() => _MyTextFieldChatState();
// }

// class _MyTextFieldChatState extends State<MyTextFieldChat> {
//   int lineCount = 1;
//   final RecorderController recorderController = RecorderController();
//   final stt.SpeechToText speech = stt.SpeechToText();

//   bool isRecording = false;

//   @override
//   void initState() {
//     super.initState();
//     widget.userController.addListener(_updateLineCount);
//     widget.userController.addListener(() {
//       setState(() {}); // rebuild when text changes
//     });
//   }

//   void _updateLineCount() {
//     final text = widget.userController.text;
//     // Count the number of lines based on '\n'
//     final newLineCount = '\n'.allMatches(text).length + 1;

//     if (newLineCount != lineCount) {
//       setState(() {
//         lineCount = newLineCount.clamp(1, 3); // min 1, max 3
//       });
//     }
//   }

//   double getRadius() {
//     switch (lineCount) {
//       case 1:
//         return 30.r;
//       case 2:
//         return 20.r;
//       case 3:
//         return 10.r;
//       default:
//         return 5.r;
//     }
//   }

//   Future<void> _toggleRecording() async {
//     if (isRecording) {
//       // Stop recording
//       await recorderController.stop();
//       speech.stop();
//       setState(() => isRecording = false);
//     } else {
//       // Initialize speech
//       bool available = await speech.initialize();
//       if (available) {
//         await recorderController.record();
//         setState(() => isRecording = true);

//         speech.listen(
//           onResult: (val) {
//             setState(() {
//               widget.userController.text = val.recognizedWords;
//               widget.userController.selection = TextSelection.fromPosition(
//                 TextPosition(offset: widget.userController.text.length),
//               );
//             });
//           },
//         );
//       }
//     }
//   }

//   @override
//   void dispose() {
//     recorderController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: widget.bottomPadding.h),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           TextField(
//             controller: widget.userController,
//             textCapitalization: TextCapitalization.sentences,
//             onChanged: widget.onChangedValue,
//             maxLines: null, // allow unlimited lines
//             minLines: 1, // optional: minimum height
//             keyboardType: TextInputType.multiline,
//             textAlignVertical: TextAlignVertical.center,
//             cursorColor: Colors.blue,
//             style: t3White(),

//             decoration: InputDecoration(
//               contentPadding: EdgeInsets.symmetric(
//                 horizontal: 20.w,
//                 vertical: widget.userController.text.split('\n').length == 1
//                     ? 7.h
//                     : 4.h,
//               ),
//               filled: true,

//               suffixIcon: Container(
//                 padding: EdgeInsets.only(
//                   right: widget.userController.text.isEmpty ? 13.w : 7.w,
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     widget.userController.text.isEmpty
//                         ? IconButton(
//                             icon: Icon(
//                               isRecording ? Icons.stop : Icons.mic,
//                               color: Colors.blue,
//                               size: 25.sp,
//                             ),
//                             onPressed: _toggleRecording,
//                           )
//                         : SizedBox(width: 0.w),
//                   ],
//                 ),
//               ),
//               suffixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),

//               fillColor: AppColor.secondary.withAlpha(10),

//               hintText: widget.hint,

//               hintStyle: hintTextStyle(),
//               border: OutlineInputBorder(
//                 borderSide: BorderSide(color: AppColor.secondary),
//                 borderRadius: BorderRadius.circular(getRadius()),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderSide: BorderSide(color: AppColor.secondary),
//                 borderRadius: BorderRadius.circular(getRadius()),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderSide: BorderSide(color: AppColor.secondary),
//                 borderRadius: BorderRadius.circular(getRadius()),
//               ),
//             ),
//           ),
//           if (isRecording)
//             Padding(
//               padding: EdgeInsets.only(top: 8.h),
//               child: AudioWaveforms(
//                 size: Size(double.infinity, 40),
//                 recorderController: recorderController,
//                 waveStyle: WaveStyle(
//                   waveColor: Colors.blueAccent,
//                   extendWaveform: true,
//                   showMiddleLine: false,
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

class MyTextFieldDisable extends StatelessWidget {
  final IconData? frontIcon;
  final bool isbackIcon;
  final String? hint;
  final String labelText;
  final double bottomPadding;

  const MyTextFieldDisable({
    super.key,
    required this.labelText,
    this.frontIcon,
    this.hint,
    this.isbackIcon = false,
    this.bottomPadding = 12,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(labelText, style: t3White().copyWith(fontSize: 16.sp)),
          SizedBox(height: 3.h),
          TextField(
            readOnly: true,
            enabled: false,

            textAlignVertical: TextAlignVertical.center,
            cursorColor: Colors.blue,

            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 17.h),
              filled: true,

              fillColor: Colors.blueGrey[900],
              prefixIcon: Padding(
                padding: EdgeInsets.only(left: 10.w, right: 3.w),
                child: Icon(frontIcon, color: AppColor.secondary),
              ),
              prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
              hintText: hint,

              hintStyle: t3White().copyWith(fontSize: 14.sp),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey.shade100.withAlpha(70),
                ),
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MyProfileHolder extends StatelessWidget {
  final String? imagePath;
  final String? name;
  final int width;
  final int height;
  final int fontSize;
  final bool isSelfUSer;
  final bool isLongPressed;
  final bool isSelected;
  final VoidCallback? onPressed;
  final bool isAddedManually;

  const MyProfileHolder({
    super.key,
    this.imagePath,
    this.width = 35,
    this.height = 35,
    this.name,
    this.fontSize = 20,
    this.isSelfUSer = false,
    this.isLongPressed = false,
    this.isSelected = false,
    this.onPressed,
    this.isAddedManually = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imagePath != null && imagePath!.isNotEmpty;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: () {
            onPressed?.call();
          },
          child: Container(
            width: width.w,
            height: height.h,
            decoration: BoxDecoration(
              border: Border.all(width: 1, color: AppColor.secondary),
              image: hasImage
                  ? DecorationImage(
                      image: NetworkImage(imagePath!),
                      fit: BoxFit.cover,
                    )
                  : null,
              color: hasImage ? null : const Color.fromARGB(255, 33, 78, 155),
              shape: BoxShape.circle,
            ),
            child: !hasImage
                ? Center(
                    child: Text(
                      (name != null && name!.isNotEmpty)
                          ? name![0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: fontSize.sp,
                      ),
                    ),
                  )
                : null,
          ),
        ),

        // ✅ Green tick only if self user
        if (isSelfUSer)
          Positioned(
            right: 5, // adjust if you want outside overlap
            bottom: -2,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color.fromARGB(255, 44, 114, 45),
                border: BoxBorder.all(color: AppColor.border),
              ),
              padding: EdgeInsets.all(4.r),
              child: const Icon(Icons.check, color: AppColor.border, size: 14),
            ),
          ),

        if (isAddedManually)
          Positioned(
            right: 0, // adjust if you want outside overlap
            bottom: -2,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade600,
                border: BoxBorder.all(color: AppColor.border),
              ),
              padding: EdgeInsets.all(4.r),
              child: const Icon(Icons.check, color: Colors.white, size: 14),
            ),
          ),
        if (isLongPressed)
          Positioned(
            right: 3,
            bottom: 2,
            child: GestureDetector(
              onTap: () {
                onPressed?.call();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: AppColor.background,
                  shape: BoxShape.circle,
                ),

                child: Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected ? AppColor.secondary : Colors.grey,
                  size: 25.sp,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class MyProfileHolderRectangle extends StatelessWidget {
  final String? imagePath;
  final String? name;
  final int width;
  final int height;
  final int fontSize;

  const MyProfileHolderRectangle({
    super.key,
    this.imagePath,
    this.width = 35,
    this.height = 35,
    this.name,
    this.fontSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imagePath != null && imagePath!.isNotEmpty;

    return Container(
      width: width.w,
      height: height.h,
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: AppColor.secondary),
        image: hasImage
            ? DecorationImage(
                image: NetworkImage(imagePath!),
                fit: BoxFit.cover,
              )
            : null,
        color: hasImage ? null : const Color.fromARGB(255, 33, 78, 155),
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(7.r),
      ),
      child: !hasImage
          ? Center(
              child: Text(
                (name != null && name!.isNotEmpty)
                    ? name![0].toUpperCase()
                    : '?',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize.sp,
                ),
              ),
            )
          : null,
    );
  }
}

class MyProfileHolderLocal extends StatelessWidget {
  final XFile? imagePath;
  final String? netImage;
  final String? name;
  final double width;
  final double height;
  final double fontSize;

  const MyProfileHolderLocal({
    super.key,
    this.imagePath,
    this.netImage,
    this.name,
    this.width = 35,
    this.height = 35,
    this.fontSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage =
        imagePath != null || (netImage != null && netImage!.isNotEmpty);

    DecorationImage? profileImage;
    if (imagePath != null) {
      profileImage = DecorationImage(
        image: FileImage(File(imagePath!.path)),
        fit: BoxFit.cover,
      );
    } else if (netImage != null && netImage!.isNotEmpty) {
      profileImage = DecorationImage(
        image: NetworkImage(netImage!),
        fit: BoxFit.cover,
      );
    }

    return Container(
      width: width.w,
      height: height.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(width: 1, color: AppColor.secondary),
        color: hasImage ? null : const Color.fromARGB(255, 33, 78, 155),
        image: profileImage,
      ),
      child: !hasImage
          ? Center(
              child: Text(
                (name != null && name!.isNotEmpty)
                    ? name![0].toUpperCase()
                    : '?',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize.sp,
                ),
              ),
            )
          : null,
    );
  }
}

class MyTaskHolderBox extends StatelessWidget {
  final IconData icon;
  final String headingText;

  final String subtitle;
  final String feedback;
  final Widget? subWidget;
  final VoidCallback onPressed;
  final bool isNotification;
  final Widget? isChild;

  const MyTaskHolderBox({
    super.key,
    required this.icon,
    required this.subtitle,
    required this.feedback,
    required this.headingText,
    this.subWidget,
    this.isNotification = false,
    this.isChild,

    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 170.w,

        decoration: BoxDecoration(
          color: AppColor.secondary.withAlpha(10),
          borderRadius: BorderRadius.circular(10.r),
          border: BoxBorder.all(width: 1.r, color: AppColor.secondary),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          child: Column(
            children: [
              isNotification && isChild != null
                  ? isChild!
                  : Icon(icon, color: AppColor.secondary, size: 35.sp),
              SizedBox(height: 3.h),
              Text(headingText, style: t2White()),
              subWidget == null
                  ? Text(subtitle, style: t1heading())
                  : subWidget!,
              SizedBox(height: 5.h),
              Text(
                feedback,
                style: hintTextStyle().copyWith(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void myAlertBox(
  BuildContext context, {
  String heading = "Sign In Failed",
  required subtittle,
  VoidCallback? onPressed,
}) async {
  return showDialog(
    barrierColor: AppColor.blackColor.withAlpha(100),

    context: context,

    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        contentPadding: EdgeInsets.only(
          bottom: 10.h,
          top: 15.h,
          left: 20.w,
          right: 20.w,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(heading, style: t2().copyWith(fontWeight: FontWeight.bold)),
            Text(
              subtittle,
              style: t2().copyWith(fontSize: 12.sp),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),

            Divider(),
            GestureDetector(
              // behavior: HitTestBehavior.opaque,
              onTap: () {
                Navigator.pop(context);
                onPressed?.call();
              },
              child: Container(
                alignment: Alignment.center,
                width: double.infinity,
                child: Text(
                  "OK",
                  style: TextStyle(
                    fontSize: 22.sp,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(15),
        ),
      );
    },
  );
}

void myAlertBoxYesNo(
  BuildContext context, {
  String heading = "Logout",
  String subtittle = "Are you Sure you want to logout?",
  required VoidCallback onYesPressed,
}) async {
  return showDialog(
    context: context,

    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        contentPadding: EdgeInsets.only(
          bottom: 10.h,
          top: 15.h,
          left: 20.w,
          right: 20.w,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(heading, style: t2().copyWith(fontWeight: FontWeight.bold)),
            Text(
              subtittle,
              style: t2().copyWith(fontSize: 14.sp),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),

            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onYesPressed,
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        "Yes",
                        style: TextStyle(
                          fontSize: 22.sp,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(height: 30, color: Colors.grey.shade400, width: 1),

                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        textAlign: TextAlign.center,
                        "No",
                        style: TextStyle(
                          fontSize: 22.sp,
                          color: AppColor.error.withAlpha(200),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(15),
        ),
      );
    },
  );
}

void mySnackBar(BuildContext context, {required String title}) {
  ScaffoldMessenger.of(context)
    ..removeCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColor.dropDownColor,
        duration: Duration(seconds: 2),
        content: Text(
          title,
          style: t3().copyWith(color: AppColor.textSecondary),
        ),
      ),
    );
}

Widget myTextHolderContainer({
  required Widget child,
  double horizontal = 25,
  double containerWidth = double.infinity,
  bool isExpanded = true,
  Color borderColor = AppColor.secondary,
}) {
  return Container(
    width: isExpanded ? double.infinity : 160.w,
    decoration: BoxDecoration(
      color: AppColor.secondary.withAlpha(10),
      borderRadius: BorderRadius.circular(10.r),
      border: BoxBorder.all(width: 1, color: borderColor),
    ),
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: horizontal.w),
      child: child,
    ),
  );
}

class MyButttonWithIcon extends StatelessWidget {
  final bool isLoading;
  final String text;
  final VoidCallback onPressed;
  final bool isInfinte;
  final IconData icon;

  const MyButttonWithIcon({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isInfinte = false,
    this.icon = Icons.add,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: isInfinte ? double.infinity : null,
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.h),

        decoration: BoxDecoration(
          color: AppColor.secondary,
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.black87),
            SizedBox(width: isInfinte ? 10.w : 3.w),

            Text(text, style: t2().copyWith(fontSize: 18.sp)),
          ],
        ),
      ),
    );
  }
}

class MyShopButton extends StatelessWidget {
  final bool isLoading;
  final String text;
  final VoidCallback onPressed;
  final bool isInfinte;

  const MyShopButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isInfinte = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        alignment: Alignment.center,
        width: isInfinte ? double.infinity : null,
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.h),
        decoration: BoxDecoration(
          color: AppColor.lightBlueBgCOlor,
          border: BoxBorder.all(color: AppColor.secondary),

          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Text(
          textAlign: TextAlign.center,
          text,
          style: t3White().copyWith(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class ProfileImageHolder extends StatelessWidget {
  final String imagePath;
  final int height;
  final int width;
  const ProfileImageHolder({
    super.key,
    required this.imagePath,
    this.height = 100,
    this.width = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width.w,
      height: height.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: BoxBorder.all(width: 2, color: AppColor.secondary),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.contain,
        ),
        color: Colors.transparent,
      ),
    );
  }
}

class MyDropDownBUtton extends StatefulWidget {
  final List<String> itemsList;
  final IconData icon;
  final String? role;
  final String labelText;
  final ValueChanged<String?> onChanged;
  final IconData? backIcon;
  final bool isRequired;
  final String hintText;

  const MyDropDownBUtton({
    super.key,
    required this.labelText,
    required this.itemsList,
    this.icon = Icons.person,
    this.role,
    this.backIcon,
    required this.onChanged,
    this.isRequired = false,
    this.hintText = "Guest",
  });

  @override
  State<MyDropDownBUtton> createState() => _MyDropDownBUttonState();
}

class _MyDropDownBUttonState extends State<MyDropDownBUtton> {
  String? selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.role;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                widget.labelText,
                style: t3White().copyWith(fontSize: 20.sp),
              ),
              widget.isRequired
                  ? Text(
                      " *",
                      style: t3White().copyWith(
                        fontSize: 20.sp,
                        color: AppColor.error,
                      ),
                    )
                  : Container(),
            ],
          ),

          SizedBox(height: 10.h),
          DropdownButtonFormField<String>(
            // value: selectedValue,
            hint: Text(
              widget.hintText,
              style: hintTextStyle().copyWith(fontSize: 20.sp),
            ),

            style: hintTextStyle().copyWith(
              fontSize: 20.sp,
              color: widget.role == null ? null : AppColor.textSecondary,
            ),

            dropdownColor: AppColor.dropDownColor,
            borderRadius: BorderRadius.circular(15.r),
            icon: Icon(Icons.arrow_drop_down_sharp, color: AppColor.secondary),
            decoration: InputDecoration(
              fillColor: AppColor.secondary.withAlpha(10),
              filled: true,

              prefixIcon: Icon(widget.icon, color: AppColor.secondary),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 1, color: AppColor.secondary),
                borderRadius: BorderRadius.circular(10.r),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 1, color: AppColor.secondary),
                borderRadius: BorderRadius.circular(10.r),
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(width: 1, color: AppColor.secondary),
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),

            items: widget.itemsList
                .map(
                  (String dropDownRole) => DropdownMenuItem(
                    value: dropDownRole,
                    child: Text(dropDownRole),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedValue = value;
              });
              widget.onChanged(value);
            },
          ),
        ],
      ),
    );
  }
}

class MyDropDownMemberButton extends StatefulWidget {
  final List<AllUserInfo> itemsList; // full list of members
  final IconData icon; // left icon
  final String? selectedEmail; // currently selected email
  final ValueChanged<AllUserInfo?> onChanged; // callback with selected user
  final String hintText;

  const MyDropDownMemberButton({
    super.key,
    required this.itemsList,
    this.icon = Icons.person,
    this.selectedEmail,
    required this.onChanged,
    this.hintText = "Select a user",
  });

  @override
  State<MyDropDownMemberButton> createState() => _MyDropDownMemberButtonState();
}

class _MyDropDownMemberButtonState extends State<MyDropDownMemberButton> {
  String? selectedEmail;

  @override
  void initState() {
    super.initState();
    selectedEmail = widget.selectedEmail;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        hint: Text(
          widget.hintText,
          overflow: TextOverflow.ellipsis,
          style: hintTextStyle().copyWith(fontSize: 20.sp),
        ),
        style: hintTextStyle().copyWith(
          fontSize: 20.sp,
          color: selectedEmail == null ? null : AppColor.textSecondary,
        ),
        dropdownColor: AppColor.dropDownColor,
        borderRadius: BorderRadius.circular(15.r),
        icon: widget.itemsList.isEmpty
            ? const SizedBox()
            : Icon(Icons.arrow_drop_down, color: AppColor.secondary),
        decoration: InputDecoration(
          fillColor: AppColor.secondary.withAlpha(10),
          filled: true,
          prefixIcon: Icon(widget.icon, color: AppColor.secondary),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 1, color: AppColor.secondary),
            borderRadius: BorderRadius.circular(10.r),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 1, color: AppColor.secondary),
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
        selectedItemBuilder: (context) {
          // Show only the selected user's name in the field
          return widget.itemsList.map((user) {
            return Text(user.name.isEmpty ? user.email : user.name);
          }).toList();
        },
        items: widget.itemsList.map((user) {
          return DropdownMenuItem<String>(
            value: user.email,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 5.w),
              child: Row(
                children: [
                  // Profile image / holder
                  MyProfileHolder(
                    imagePath: user.imagePath,
                    fontSize: 25,
                    name: user.name,
                  ),
                  SizedBox(width: 10.w),
                  // Member details
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name.isEmpty ? "{No Name}" : user.name,
                        style: hintTextStyle().copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user.email.isEmpty ? "Guest" : user.email,
                        style: hintTextStyle(),
                      ),
                      // if (user. != null)
                      //   Text(
                      //     user.memberClass!,
                      //     style: hintTextStyle().copyWith(
                      //       fontSize: 16.sp,
                      //       color: AppColor.textSecondary,
                      //     ),
                      //   ),
                    ],
                  ),
                  Spacer(),
                  Text(
                    user.role == null || user.role!.isEmpty
                        ? "Guest"
                        : user.role!,
                    style: hintTextStyle(),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        onChanged: (email) {
          if (email == null) return;

          // Find the selected user
          final selectedUser = widget.itemsList.firstWhere(
            (user) => user.email == email,
          );

          // If email is empty, still allow selection but store a placeholder
          setState(() {
            selectedEmail = selectedUser.email.isEmpty ? null : email;
          });

          // Return the selected user object regardless of email
          widget.onChanged(selectedUser);
        },
      ),
    );
  }
}

class MyUploadTextField extends StatelessWidget {
  final TextEditingController userController;
  final IconData? frontIcon;
  final String hint;
  final String labelText;
  final IconData? backIcon;
  final bool isDesc;
  final bool isDateandTime;
  final bool isExpanded;
  final bool isRequired;
  final bool isNumberKeyboard;
  final Color backIconcolor;
  final bool isChild;
  final bool isGpa;
  final bool isCapital;

  final ValueChanged<String>? onChangedValue;
  const MyUploadTextField({
    super.key,
    required this.userController,
    this.backIcon,
    this.frontIcon,
    required this.hint,
    required this.labelText,
    this.isDesc = false,
    this.isDateandTime = false,
    this.isExpanded = true,
    this.isRequired = true,
    this.isNumberKeyboard = false,
    this.onChangedValue,
    this.backIconcolor = AppColor.secondary,
    this.isChild = false,
    this.isGpa = false,
    this.isCapital = true,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: SizedBox(
        width: isExpanded ? double.infinity : 150.w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(labelText, style: t3White().copyWith(fontSize: 20.sp)),

                isRequired
                    ? Text(
                        " *",
                        style: t3White().copyWith(
                          fontSize: 20.sp,
                          color: AppColor.error,
                        ),
                      )
                    : Container(),
              ],
            ),
            SizedBox(height: 7.h),
            TextField(
              textCapitalization: isCapital
                  ? TextCapitalization.sentences
                  : TextCapitalization.none,
              maxLength: isGpa ? 4 : null,
              onChanged: onChangedValue,
              keyboardType: isDateandTime
                  ? TextInputType.datetime
                  : isNumberKeyboard
                  ? TextInputType.numberWithOptions()
                  : null,
              maxLines: isDesc ? 3 : 1,
              controller: userController,
              textAlignVertical: TextAlignVertical.center,
              cursorColor: Colors.blue,
              style: t3White(),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  vertical: 17.h,
                ).copyWith(right: 10.w),
                filled: true,
                fillColor: AppColor.secondary.withAlpha(10),
                suffixIcon: backIcon != null
                    ? Icon(backIcon, color: backIconcolor)
                    : null,
                prefixIcon: frontIcon != null
                    ? Padding(
                        padding: EdgeInsets.only(left: 10.w, right: 3.w),
                        child: Icon(frontIcon, color: AppColor.secondary),
                      )
                    : SizedBox(width: 10.w),

                prefixIconConstraints: BoxConstraints(
                  minWidth: 0,
                  minHeight: 0,
                ),
                hintText: hint,
                hintStyle: hintTextStyle().copyWith(fontSize: 20.sp),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColor.secondary),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColor.secondary),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColor.secondary),
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyDateAndTimePickerBox extends StatelessWidget {
  final IconData? frontIcon;
  final String? hint;
  final String labelText;
  final VoidCallback onPressed;
  final bool isExpanded;
  final bool isRequired;
  final bool backIcon;

  const MyDateAndTimePickerBox({
    super.key,
    this.isExpanded = true,
    required this.onPressed,
    this.frontIcon,
    this.hint,
    required this.labelText,
    this.isRequired = true,
    this.backIcon = false,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(labelText, style: t3White().copyWith(fontSize: 20.sp)),
            isRequired
                ? Text(
                    " *",
                    style: t3White().copyWith(
                      fontSize: 20.sp,
                      color: AppColor.error,
                    ),
                  )
                : Container(),
          ],
        ),
        SizedBox(height: 10.h),
        GestureDetector(
          onTap: onPressed,
          child: myTextHolderContainer(
            isExpanded: isExpanded,
            horizontal: 13.w,
            child: Row(
              children: [
                Icon(frontIcon, color: AppColor.secondary),
                SizedBox(width: 5.w),
                Text(
                  hint!,
                  style: hintTextStyle().copyWith(
                    color: (hint == "12:00 AM" || hint == "dd/mm/yyyy")
                        ? null
                        : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class MySearchField extends StatefulWidget {
  final IconData? icon;
  final String hintText;
  final TextEditingController controller;
  final ValueChanged<String> onChangedValue;
  const MySearchField({
    super.key,
    required this.hintText,
    this.icon = Icons.search,
    required this.onChangedValue,
    required this.controller,
  });

  @override
  State<MySearchField> createState() => _MySearchFieldState();
}

class _MySearchFieldState extends State<MySearchField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.r),
        color: AppColor.dropDownColor,
        boxShadow: [
          BoxShadow(
            color: AppColor.dropDownColor,
            offset: Offset(0, 1),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: TextField(
        onChanged: widget.onChangedValue,
        cursorColor: AppColor.secondary,
        controller: widget.controller,
        style: t3White().copyWith(fontSize: 18.sp),
        decoration: InputDecoration(
          prefixIconConstraints: BoxConstraints(maxWidth: 50.w),
          hintStyle: hintTextStyle().copyWith(fontSize: 18.sp),
          hintText: widget.hintText,
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 15.w, right: 10.w),
            child: Icon(Icons.search, color: AppColor.secondary),
          ),
          filled: true,
          fillColor: AppColor.dropDownColor,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.r),
            borderSide: const BorderSide(color: AppColor.secondary),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.r),
            borderSide: const BorderSide(color: AppColor.secondary),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.r),
            borderSide: const BorderSide(color: AppColor.secondary),
          ),
        ),
      ),
    );
  }
}

Widget imageHolderWithPlus({
  XFile? imagePath,
  String? netWorkImage,
  String? name,
  required VoidCallback onPressed,
}) {
  final hasImage =
      imagePath != null || (netWorkImage != null && netWorkImage.isNotEmpty);

  return Padding(
    padding: EdgeInsets.symmetric(vertical: 10.h),
    child: GestureDetector(
      onTap: onPressed,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main Circle (Profile Image / Placeholder)
          Container(
            key: ValueKey(imagePath?.path ?? netWorkImage ?? ''),
            width: 100.w,
            height: 100.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(width: 2, color: AppColor.secondary),
              color: hasImage ? null : AppColor.dropDownColor,
              image: imagePath != null
                  ? DecorationImage(
                      image: FileImage(File(imagePath.path)),
                      fit: BoxFit.cover,
                    )
                  : (netWorkImage != null && netWorkImage.isNotEmpty)
                  ? DecorationImage(
                      image: NetworkImage(netWorkImage),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: !hasImage
                ? Center(
                    child: Icon(
                      Icons.person,
                      color: Colors.white70,
                      size: 70.sp,
                    ),
                  )
                : null,
          ),

          // Plus Icon Overlay
          Positioned(
            bottom: 2.h,
            right: 3.w,
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColor.dropDownAlternativeColor,
                border: Border.all(
                  color: AppColor.secondary.withAlpha(150),
                  width: 1,
                ),
              ),
              child: Icon(Icons.add_a_photo, color: Colors.white, size: 15.sp),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget imageHolderWithPlusAndNetwork({
  XFile? imagePath,
  required VoidCallback onPressed,
  bool isNetworkImage = false,
}) {
  // Determine if a valid image exists
  bool hasImage = imagePath != null && imagePath.path.trim().isNotEmpty;

  return Padding(
    padding: EdgeInsets.symmetric(vertical: 10.h),
    child: GestureDetector(
      onTap: onPressed,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main Circle (Profile Image / Placeholder)
          Container(
            key: ValueKey(imagePath?.path),
            width: 100.w,
            height: 100.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(width: 2, color: AppColor.secondary),
              color: AppColor.dropDownColor,
              image: hasImage
                  ? DecorationImage(
                      image: isNetworkImage
                          ? NetworkImage(imagePath.path)
                          : FileImage(File(imagePath.path)) as ImageProvider,
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: !hasImage
                ? Icon(Icons.person, color: Colors.white70, size: 70.sp)
                : null,
          ),

          // Plus Icon Overlay
          Positioned(
            bottom: 2.h,
            right: 3.w,
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColor.dropDownAlternativeColor, // green background
                border: Border.all(
                  color: AppColor.secondary.withAlpha(150),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.add_a_photo, // plus icon
                color: Colors.white, // white icon
                size: 15.sp,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget imageHolderWithCamera({
  XFile? imagePath,
  required VoidCallback onPressed,
}) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 10.h),
    child: GestureDetector(
      onTap: onPressed,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            key: ValueKey(imagePath?.path),
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(width: 2, color: AppColor.secondary),
              image: DecorationImage(
                image: imagePath != null
                    ? FileImage(File(imagePath.path))
                    : AssetImage(AppImages.profilePlaceholder) as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Camera Icon Overlay
          Positioned(
            bottom: 0,
            right: -1,
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColor.dropDownColor,
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: Icon(
                Icons.camera_alt,
                color: AppColor.textSecondary,
                size: 15.sp,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

void showImagePickerAlert({
  required BuildContext context,
  required VoidCallback onCameraTap,
  required VoidCallback onGalleryTap,
}) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withAlpha(70),
    builder: (_) => AlertDialog(
      backgroundColor: AppColor.surface,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: AppColor.border, width: 2),
      ),
      title: Text(
        "Choose Image Source",
        style: t1heading().copyWith(fontSize: 20.sp),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Camera Option
          ListTile(
            leading: Icon(Icons.camera_alt, color: AppColor.text),
            title: Text("Camera", style: t3White()),
            onTap: () {
              Navigator.pop(context);
              onCameraTap();
            },
          ),
          Divider(color: AppColor.border),

          // Gallery Option
          ListTile(
            leading: Icon(Icons.photo, color: AppColor.text),
            title: Text("Gallery", style: t3White()),
            onTap: () {
              Navigator.pop(context);
              onGalleryTap();
            },
          ),
        ],
      ),
    ),
  );
}

void showChildDetailsAlert({
  required BuildContext context,
  required String text,
  required IconData icon,
}) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: AppColor.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.r),
        side: BorderSide(color: AppColor.secondary, width: 1),
      ),

      content: Column(
        mainAxisSize: MainAxisSize.min,

        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20.h),
          Row(
            children: [
              Icon(icon, color: AppColor.secondary),
              SizedBox(width: 10),
              Expanded(child: Text(text, style: t3White())),
            ],
          ),
          SizedBox(height: 10),

          // Additional Info
          SizedBox(height: 10.h),
          Container(
            alignment: Alignment.center,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close", style: t3White()),
            ),
          ),
        ],
      ),
    ),
  );
}

void showMyAddOptionsAlert({
  required BuildContext context,
  required VoidCallback onAddTaskTap,
  required VoidCallback onAddEventTap,
  required VoidCallback onAddChildTap,
}) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: AppColor.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: AppColor.border, width: 2),
      ),
      title: Text("Create New", style: t1heading().copyWith(fontSize: 20.sp)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Add Task
          ListTile(
            leading: Icon(Icons.check_circle_outline, color: AppColor.text),
            title: Text("Add Task", style: t3White()),
            onTap: () {
              Navigator.pop(context);
              onAddTaskTap();
            },
          ),
          Divider(color: AppColor.border),

          // Add Event
          ListTile(
            leading: Icon(Icons.event, color: AppColor.text),
            title: Text("Add Event", style: t3White()),
            onTap: () {
              Navigator.pop(context);
              onAddEventTap();
            },
          ),

          // Add Appointment
          Divider(color: AppColor.border),

          // Add Appointment
          ListTile(
            leading: Icon(Icons.child_care, color: AppColor.text),
            title: Text("Add Child", style: t3White()),
            onTap: () {
              Navigator.pop(context);
              onAddChildTap();
            },
          ),
        ],
      ),
    ),
  );
}

void showMyAddOptionsAlertTask({
  required BuildContext context,
  required VoidCallback onAddTaskTap,
  required VoidCallback onAddEventTap,
}) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: AppColor.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: AppColor.border, width: 2),
      ),
      title: Text("Create New", style: t1heading().copyWith(fontSize: 20.sp)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Add Task
          ListTile(
            leading: Icon(Icons.check_circle_outline, color: AppColor.text),
            title: Text("Add Task", style: t3White()),
            onTap: () {
              Navigator.pop(context);
              onAddTaskTap();
            },
          ),
          Divider(color: AppColor.border),

          // Add Event
          ListTile(
            leading: Icon(Icons.event, color: AppColor.text),
            title: Text("Add Event", style: t3White()),
            onTap: () {
              Navigator.pop(context);
              onAddEventTap();
            },
          ),
        ],
      ),
    ),
  );
}

class BoardCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final VoidCallback onTap;

  const BoardCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.35,
          decoration: BoxDecoration(
            color: AppColor.dropDownColor,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.white12,
                blurRadius: 5,
                spreadRadius: 1,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(color: AppColor.secondary, width: 1),
          ),
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              children: [
                Text(
                  title,
                  style: t1heading().copyWith(color: AppColor.textSecondary),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Image.asset(imagePath, fit: BoxFit.cover, height: 150.h),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        subtitle,
                        textAlign: TextAlign.start,
                        style: hintTextStyle(),
                      ),
                    ),
                    SizedBox(width: 5.w),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColor.secondary,
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: onTap,
                          child: Icon(
                            Icons.keyboard_double_arrow_right_rounded,
                            size: 25.sp,

                            color: AppColor.dropDownColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void showCustomBoardModalBottomSheet(
  BuildContext context, {

  required Widget Function(void Function(VoidCallback) setState) builder,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    enableDrag: true,
    isDismissible: true,
    backgroundColor: AppColor.dropDownColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Wrap(
              children: [
                builder(
                  setModalState,
                ), // You can call setModalState to update UI
              ],
            );
          },
        ),
      ),
    ),
  );
}

void showCustomBoardModalBottomSheetForAdding(
  BuildContext context, {
  required Widget Function(void Function(VoidCallback) setState) builder,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    enableDrag: true,
    isDismissible: true,
    backgroundColor: AppColor.dropDownColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Wrap(
              children: [
                builder(
                  setModalState,
                ), // You can call setModalState to update UI
              ],
            );
          },
        ),
      ),
    ),
  );
}

class MyAcceptButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color buttonColor;
  final bool isLoading;

  const MyAcceptButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.buttonColor = AppColor.secondary,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 7.h, horizontal: 7.w),
          decoration: BoxDecoration(
            color: buttonColor,
            borderRadius: BorderRadius.circular(7.r),
          ),
          child: isLoading
              ? SizedBox(
                  height: 20.h,
                  child: LoadingIndicator(
                    indicatorType: Indicator.ballBeat,
                    colors: [Colors.white, Colors.green, Colors.amber],
                  ),
                )
              : Text(
                  text,
                  style: hintTextStyle().copyWith(
                    fontSize: 18.sp,
                    color: AppColor.textSecondary,
                  ),
                ),
        ),
      ),
    );
  }
}

Widget mySwitch({
  required bool isOff,
  required ValueChanged<bool> onChanged,
  Color boxColor = AppColor.secondary,
}) {
  return Switch(
    value: isOff,

    activeColor: boxColor, // thumb color ON
    activeTrackColor: Colors.transparent, // track color ON
    inactiveThumbColor: Colors.grey, // thumb color OFF
    inactiveTrackColor: Colors.transparent, // track color OFF
    trackOutlineColor: WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(WidgetState.selected)) {
        return boxColor; // outline when active
      }
      return Colors.grey.shade700.withAlpha(200); // outline when inactive
    }),
    onChanged: onChanged,
  );
}

Future<void> myCalendarAlertBox(
  BuildContext context, {
  required String title,
  required String description,
  String? selectedDate,
  String? selectedDay,
  Color? boxColor,
  String? imagePath,
  String? userName,
  String? userRole,
  required VoidCallback onYesPressed,
  bool isOff = false,
  bool isEmail = true,
}) {
  String getDaySuffix(int day) {
    if (day >= 11 && day <= 13) {
      return "th";
    }
    switch (day % 10) {
      case 1:
        return "st";
      case 2:
        return "nd";
      case 3:
        return "rd";
      default:
        return "th";
    }
  }

  return showDialog(
    context: context,

    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.circular(17.r),
            ),
            backgroundColor: AppColor.dropDownAlternativeColor,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: boxColor,
                        borderRadius: BorderRadius.circular(7.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(5.r),
                        child: Text(
                          textAlign: TextAlign.center,

                          "${selectedDate}${getDaySuffix(int.tryParse(selectedDate ?? "") ?? 0)}\n${selectedDay?.substring(0, 3) ?? ""}",
                          style: t3White(),
                        ),
                      ),
                    ),
                    SizedBox(width: 7.w),
                    Text(
                      "Add to Calender",
                      style: t3White().copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp,
                      ),
                    ),
                    Spacer(),

                    mySwitch(
                      isOff: isOff,

                      onChanged: (value) async {
                        if (isEmail) {
                          // Show confirmation dialog
                          bool confirmed = await showYesNoDialogCal(
                            context,
                            value,
                            onYesPressed,
                          );

                          if (confirmed) {
                            // Only toggle if user pressed Yes
                            setState(() {
                              isOff = value; // visually toggle inside alert
                            });
                          }
                        } else {
                          myAlertBox(
                            context,
                            subtittle:
                                "Only assigned users can update Google Calendar.",
                            heading: "Failed",
                          );
                        }
                      },
                      boxColor: boxColor!,
                    ),

                    // Icon(Icons.more_horiz, color: Colors.white),
                  ],
                ),
                SizedBox(height: 10.h),
                Divider(),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Column(
                      children: [
                        MyProfileHolder(
                          width: 70,
                          height: 70,
                          name: userName ?? "",
                          fontSize: 35,
                          imagePath: imagePath ?? "",
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          userName ?? "",
                          style: t1heading().copyWith(fontSize: 20.sp),
                        ),
                        Text(userRole ?? "", style: hintTextStyle()),
                      ],
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(height: 15.h),
                          Text("Title: $title", style: t3White()),
                          Text(description, style: hintTextStyle()),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Future<bool> showYesNoDialogCal(
  BuildContext context,
  bool value,
  VoidCallback onPressed,
) async {
  String heading = value ? "Add to Calendar?" : "Remove from Calendar?";
  String subtitle = value
      ? "Are you sure you want to add this task?"
      : "Are you sure you want to remove this task?";

  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          contentPadding: EdgeInsets.only(
            bottom: 10.h,
            top: 15.h,
            left: 20.w,
            right: 20.w,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(heading, style: t2().copyWith(fontWeight: FontWeight.bold)),
              Text(
                subtitle,
                style: t2().copyWith(fontSize: 14.sp),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),

              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        Navigator.of(context).pop(true);
                        onPressed();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          "Yes",
                          style: TextStyle(
                            fontSize: 22.sp,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(height: 30, color: Colors.grey.shade400, width: 1),

                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        Navigator.of(context).pop(false);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          textAlign: TextAlign.center,
                          "No",
                          style: TextStyle(
                            fontSize: 22.sp,
                            color: AppColor.error.withAlpha(200),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(15),
          ),
        ),
      ) ??
      false; // return false if dialog dismissed
}

class LoadMoreButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final bool hasMore;

  const LoadMoreButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.hasMore = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasMore) {
      return Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(
          "No more tasks ✨",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade600,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50), // full width
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    "Load More",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_downward, size: 20),
                ],
              ),
      ),
    );
  }
}

Future<void> myCalendarAlertBoxWeek(
  BuildContext context, {
  required String title,
  required String description,
  String? selectedDate,
  String? selectedDay,
  Color? boxColor,
  String? imagePath,
  String? userName,
  String? userRole,
}) {
  String getDaySuffix(int day) {
    if (day >= 11 && day <= 13) {
      return "th";
    }
    switch (day % 10) {
      case 1:
        return "st";
      case 2:
        return "nd";
      case 3:
        return "rd";
      default:
        return "th";
    }
  }

  return showDialog(
    context: context,

    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(17.r),
        ),
        backgroundColor: AppColor.dropDownAlternativeColor,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: boxColor,
                    borderRadius: BorderRadius.circular(7.r),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(5.r),
                    child: Text(
                      textAlign: TextAlign.center,

                      "${selectedDate}${getDaySuffix(int.tryParse(selectedDate ?? "") ?? 0)}\n${selectedDay?.substring(0, 3) ?? ""}",
                      style: t3White(),
                    ),
                  ),
                ),

                Spacer(),
                Text(
                  "Calender",
                  style: t3White().copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                  ),
                ),
                Spacer(),
                Icon(Icons.more_horiz, color: Colors.white),
              ],
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Column(
                  children: [
                    MyProfileHolder(
                      width: 70,
                      height: 70,
                      name: userName ?? "",
                      fontSize: 35,
                      imagePath: imagePath ?? "",
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      userName ?? "",
                      style: t1heading().copyWith(fontSize: 20.sp),
                    ),
                    Text(userRole ?? "", style: hintTextStyle()),
                  ],
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(height: 15.h),
                      Text("Title: $title", style: t3White()),
                      Text(description, style: hintTextStyle()),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
