// import 'dart:developer';
// import 'package:family_management_app/app/app%20Color/app_color.dart';
// import 'package:family_management_app/app/textStyle/textstyles.dart';
// import 'package:family_management_app/app/utils/utils.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:permission_handler/permission_handler.dart';
// class VoiceTextField extends StatefulWidget {
//   final TextEditingController controller;
//   final ValueChanged<String> onChangedValue;

//   const VoiceTextField({
//     super.key,
//     required this.controller,
//     required this.onChangedValue,
//   });

//   @override
//   State<VoiceTextField> createState() => _VoiceTextFieldState();
// }

// class _VoiceTextFieldState extends State<VoiceTextField> {
//   late stt.SpeechToText speech;
//   bool isRecording = false;
//   String recognizedText = "";
//   bool isMicVisible = true;
//   double _soundLevel = 0.0;

//   @override
//   void initState() {
//     super.initState();
//     widget.controller.addListener(_updateLineCount);
//     widget.controller.addListener(() {
//       setState(() {});
//     });

//     speech = stt.SpeechToText();
//   }

//   int lineCount = 1;

//   void _updateLineCount() {
//     final text = widget.controller.text;
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

//   Future<bool> requestMicPermission() async {
//     final status = await Permission.microphone.request();
//     return status.isGranted;
//   }

//   Future<void> startRecording() async {
//     bool granted = await requestMicPermission();
//     if (!granted) {
//       mySnackBar(context, title: "Microphone denied");
//       return;
//     }

//     setState(() {});

//     bool available = await speech.initialize(
//       onStatus: (status) {
//         log("Speech status: $status");
//       },
//       onError: (err) {
//         mySnackBar(context, title: err.errorMsg);
//         log("Error: ${err.errorMsg}");
//       },
//     );
//     if (!available) return;
//     if (!mounted) return;
//     setState(() {
//       recognizedText = "";
//       widget.controller.text = "";
//       isRecording = true;
//     });

//     speech.listen(
//       listenMode: stt.ListenMode.dictation,
//       partialResults: true,
//       onResult: (val) {
//         if (!mounted) return;
//         setState(() {
//           recognizedText = val.recognizedWords;
//           // widget.controller.text = recognizedText;
//           log("Recognized Text: $recognizedText");
//           // widget.controller.selection = TextSelection.fromPosition(
//           //   TextPosition(offset: widget.controller.text.length),
//           // );
//         });
//       },
//       onSoundLevelChange: (level) {
//         if (!mounted) return;
//         setState(() => _soundLevel = level);
//       },

//       localeId: 'en_US',
//     );
//   }

//   Future<void> stopRecording() async {
//     await speech.stop();
//     if (!mounted) return;

//     setState(() {
//       isRecording = false;
//       widget.controller.text = recognizedText.isNotEmpty ? recognizedText : "";
//       widget.controller.selection = TextSelection.fromPosition(
//         TextPosition(offset: widget.controller.text.length),
//       );
//     });

//     log("Recognized Text: $recognizedText");
//     // Optionally, call your send message function here
//     // if (recognizedText.isNotEmpty) _sendMessage();
//   }

//   @override
//   void dispose() {
//     speech.stop();
//     speech.cancel();

//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: 10.h),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           TextField(
//             controller: widget.controller,
//             textCapitalization: TextCapitalization.sentences,
//             maxLines: null,
//             readOnly: isRecording,
//             minLines: 1,
//             textAlignVertical: TextAlignVertical.center,
//             keyboardType: TextInputType.multiline,
//             cursorColor: Colors.blue,
//             style: t3White(),
//             decoration: InputDecoration(
//               contentPadding: EdgeInsets.symmetric(
//                 horizontal: 20.w,
//                 vertical: widget.controller.text.split('\n').length == 1
//                     ? 7.h
//                     : 4.h,
//               ),
//               filled: true,
//               fillColor: AppColor.secondary.withAlpha(10),
//               hint: isRecording
//                   ? Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: List.generate(5, (i) {
//                         final double height = (10 + _soundLevel - i * 2).clamp(
//                           10,
//                           60,
//                         );
//                         return AnimatedContainer(
//                           duration: const Duration(milliseconds: 200),
//                           margin: const EdgeInsets.symmetric(horizontal: 3),
//                           height: height,
//                           width: 6,
//                           decoration: BoxDecoration(
//                             color: Colors.blueAccent,
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                         );
//                       }),
//                     )
//                   : Text("Ask anything", style: hintTextStyle()),
//               // hintText: "Ask anything",
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
//               suffixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
//               suffixIcon: Padding(
//                 padding: EdgeInsets.only(
//                   right: widget.controller.text.isEmpty ? 13.w : 7.w,
//                 ),
//                 child: GestureDetector(
//                   onTap: () async {
//                     if (!isRecording) {
//                       await startRecording();
//                     } else {
//                       await stopRecording();
//                     }
//                   },
//                   child: widget.controller.text.isEmpty
//                       ? Icon(
//                           isRecording ? Icons.stop : Icons.mic,
//                           color: isRecording
//                               ? AppColor.error
//                               : AppColor.secondary,
//                           size: 25.sp,
//                         )
//                       : SizedBox(width: 0.w),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:developer';
import 'package:family_management_app/app/app%20Color/app_color.dart';
import 'package:family_management_app/app/textStyle/textstyles.dart';
import 'package:family_management_app/app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceTextField extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChangedValue;

  const VoiceTextField({
    super.key,
    required this.controller,
    required this.onChangedValue,
  });

  @override
  State<VoiceTextField> createState() => _VoiceTextFieldState();
}

class _VoiceTextFieldState extends State<VoiceTextField> {
  bool isRecording = false;
  String recognizedText = "";
  bool isMicVisible = true;
  double _soundLevel = 0.0;

  // @override
  // void initState() {
  //   super.initState();
  //   widget.controller.addListener(_updateLineCount);
  //   widget.controller.addListener(() {
  //     setState(() {});
  //   });

  // }

  int lineCount = 1;

  // void _updateLineCount() {
  //   final text = widget.controller.text;
  //   // Count the number of lines based on '\n'
  //   final newLineCount = '\n'.allMatches(text).length + 1;

  //   if (newLineCount != lineCount) {
  //     setState(() {
  //       lineCount = newLineCount.clamp(1, 3); // min 1, max 3
  //     });
  //   }
  // }

  double getRadius() {
    switch (lineCount) {
      case 1:
        return 30.r;
      case 2:
        return 20.r;
      case 3:
        return 10.r;
      default:
        return 5.r;
    }
  }

  Future<bool> requestMicPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  // Future<void> startRecording() async {
  //   bool granted = await requestMicPermission();
  //   if (!granted) {
  //     mySnackBar(context, title: "Microphone denied");
  //     return;
  //   }

  //   setState(() {});

  //   bool available = await speech.initialize(
  //     onStatus: (status) {
  //       log("Speech status: $status");
  //     },
  //     onError: (err) {
  //       mySnackBar(context, title: err.errorMsg);
  //       log("Error: ${err.errorMsg}");
  //     },
  //   );
  //   if (!available) return;
  //   if (!mounted) return;
  //   setState(() {
  //     recognizedText = "";
  //     widget.controller.text = "";
  //     isRecording = true;
  //   });

  //   speech.listen(
  //     listenMode: stt.ListenMode.dictation,
  //     partialResults: true,
  //     onResult: (val) {
  //       if (!mounted) return;
  //       setState(() {
  //         recognizedText = val.recognizedWords;
  //         // widget.controller.text = recognizedText;
  //         log("Recognized Text: $recognizedText");
  //         // widget.controller.selection = TextSelection.fromPosition(
  //         //   TextPosition(offset: widget.controller.text.length),
  //         // );
  //       });
  //     },
  //     onSoundLevelChange: (level) {
  //       if (!mounted) return;
  //       setState(() => _soundLevel = level);
  //     },

  //     localeId: 'en_US',
  //   );
  // }

  // Future<void> stopRecording() async {
  //   await speech.stop();
  //   if (!mounted) return;

  //   setState(() {
  //     isRecording = false;
  //     widget.controller.text = recognizedText.isNotEmpty ? recognizedText : "";
  //     widget.controller.selection = TextSelection.fromPosition(
  //       TextPosition(offset: widget.controller.text.length),
  //     );
  //   });

  //   log("Recognized Text: $recognizedText");
  //   // Optionally, call your send message function here
  //   // if (recognizedText.isNotEmpty) _sendMessage();
  // }

  // @override
  // void dispose() {
  //   speech.stop();
  //   speech.cancel();

  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: widget.controller,
            textCapitalization: TextCapitalization.sentences,
            maxLines: null,
            readOnly: isRecording,
            minLines: 1,
            textAlignVertical: TextAlignVertical.center,
            keyboardType: TextInputType.multiline,
            cursorColor: Colors.blue,
            style: t3White(),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: widget.controller.text.split('\n').length == 1
                    ? 7.h
                    : 4.h,
              ),
              filled: true,
              fillColor: AppColor.secondary.withAlpha(10),
              hint: isRecording
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (i) {
                        final double height = (10 + _soundLevel - i * 2).clamp(
                          10,
                          60,
                        );
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          height: height,
                          width: 6,
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    )
                  : Text("Ask anything", style: hintTextStyle()),
              // hintText: "Ask anything",
              hintStyle: hintTextStyle(),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: AppColor.secondary),
                borderRadius: BorderRadius.circular(getRadius()),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColor.secondary),
                borderRadius: BorderRadius.circular(getRadius()),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColor.secondary),
                borderRadius: BorderRadius.circular(getRadius()),
              ),
              suffixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
              suffixIcon: Padding(
                padding: EdgeInsets.only(
                  right: widget.controller.text.isEmpty ? 13.w : 7.w,
                ),
                child: GestureDetector(
                  // onTap: () async {
                  //   if (!isRecording) {
                  //     await startRecording();
                  //   } else {
                  //     await stopRecording();
                  //   }
                  // },
                  child: widget.controller.text.isEmpty
                      ? Icon(
                          isRecording ? Icons.stop : Icons.mic,
                          color: isRecording
                              ? AppColor.error
                              : AppColor.secondary,
                          size: 25.sp,
                        )
                      : SizedBox(width: 0.w),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
