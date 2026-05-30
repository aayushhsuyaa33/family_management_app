import 'dart:developer';
import 'package:family_management_app/app/app%20Color/app_color.dart';
import 'package:family_management_app/app/routes/app_routes.dart';
import 'package:family_management_app/app/textStyle/textstyles.dart';
import 'package:family_management_app/app/utils/custom_appbar.dart';
import 'package:family_management_app/app/utils/shimmer.dart';
import 'package:family_management_app/app/utils/utils.dart';
import 'package:family_management_app/bloc/add%20tasks/add_tasks_cubit.dart';
import 'package:family_management_app/app/utils/calender_pick.dart';
import 'package:family_management_app/bloc/fetch%20User/fetch_user_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ChildProfile {
  String? name;
  String? dob;
  String? age;
  String? gender;
  XFile? photo;
  String? imagePath;
  // School Info....................................
  String? schoolName;
  String? schoolAddress;
  String? grade;
  String? classScheduleDate;
  String? classScheduleTime;

  String? allergies;
  String? medicalInformation;
  String? generalNotes;
  String? optionalEnhancements;

  ChildProfile({
    this.name,
    this.dob,
    this.gender,
    this.photo,
    this.schoolName,
    this.grade,
    this.classScheduleDate,
    this.classScheduleTime,
    this.schoolAddress,
    this.allergies,
    this.medicalInformation,
    this.generalNotes,
    this.optionalEnhancements,
    this.age,
    this.imagePath,
  });
}

class AddChildFlow extends StatefulWidget {
  final String? uid;
  const AddChildFlow({super.key, this.uid});
  @override
  State<AddChildFlow> createState() => _AddChildFlowState();
}

class _AddChildFlowState extends State<AddChildFlow> {
  final PageController _controller = PageController();
  int _currentStep = 0;
  bool isLoading = false;
  String? localUid;
  ChildProfile childProfile = ChildProfile();
  List<String> childAppBarSubtitle = [
    "Enter your child's personal details.",
    "Add your child's school information.",
    "Provide your child's health details.",
    "Review your child's profile before saving",
  ];

  void _nextPage() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
      log("Name: ${childProfile.name ?? 'Not set'}");
      log("DOB: ${childProfile.dob?.toString() ?? 'Not set'}");
      log("AGE: ${childProfile.age?.toString() ?? 'Not set'}");
      log("Gender: ${childProfile.gender ?? 'Not set'}");
      log("Photo: ${childProfile.photo?.path ?? 'Not set'}");

      _controller.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  void _prevPage() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _controller.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.uid != null && widget.uid!.isNotEmpty) {
      localUid = widget.uid; // set uid
      context.read<FetchUserCubit>().fetchProfileInfoChild(uid: localUid!);
    }
  }

  void onBackPressed() {
    context.read<FetchUserCubit>().resetState();
    setState(() {
      localUid = null;
      childProfile = ChildProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyCustomAppBar(
        heading: widget.uid != null && widget.uid!.isNotEmpty
            ? "Edit Stakeholder"
            : "Add stakeholder",
        subTitle: childAppBarSubtitle[_currentStep],
        isBack: _currentStep == 0 ? false : true,
        isLastRow: _currentStep == 1 || _currentStep == 2 ? true : false,
        onSkipClicked: _nextPage,
        onBackPressed: () {
          // mySnackBar(context, title: "asdasdsd");
          onBackPressed();
        },
      ),
      body: BlocBuilder<FetchUserCubit, FetchUserState>(
        builder: (context, state) {
          if (state.fetchProfileInfoChildStatus == FetchRequestStatus.loading &&
              widget.uid != null &&
              widget.uid!.isNotEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: myShimmerBoxCircle(height: 120.h, width: 120.w),
                    ),
                    SizedBox(height: 30.h),
                    myShimmerBoxSharp(height: 30.h, width: 100.w),
                    SizedBox(height: 7.h),
                    myShimmerBoxSharp(height: 50.h, width: double.infinity),
                    SizedBox(height: 20.h),
                    myShimmerBoxSharp(height: 30.h, width: 100.w),
                    SizedBox(height: 7.h),
                    myShimmerBoxSharp(height: 50.h, width: double.infinity),
                    SizedBox(height: 20.h),
                    myShimmerBoxSharp(height: 40.h, width: double.infinity),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            );
          }
          if (state.fetchProfileInfoChildStatus == FetchRequestStatus.sucess &&
              state.childInfo != null) {
            childProfile = state.childInfo!;
          }
          return PageView(
            controller: _controller,
            physics: NeverScrollableScrollPhysics(), // prevent swipe
            children: [
              ChildBasicInfoScreen(childProfile: childProfile, uid: localUid),
              ChildSchoolInfoScreen(childProfile: childProfile, uid: localUid),
              ChildHealthInfoScreen(childProfile: childProfile, uid: localUid),
              ChildSummaryScreen(childProfile: childProfile),
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 15.h),
          child: Row(
            children: [
              if (_currentStep > 0)
                Expanded(
                  child: MyNavigationButton(
                    text: "← Back",
                    onPressed: _prevPage,
                  ),
                ),
              SizedBox(width: _currentStep == 0 ? 0 : 25.w),
              if (_currentStep < 3)
                Expanded(
                  child: MyNavigationButton(
                    text: "Next →",
                    onPressed: () {
                      bool canProceed = false;
                      String errorMsg = "Enter the required Field";

                      switch (_currentStep) {
                        case 0:
                          if (childProfile.name != null &&
                              childProfile.name!.isNotEmpty &&
                              childProfile.age != null &&
                              childProfile.age!.isNotEmpty &&
                              childProfile.gender != null) {
                            canProceed = true;
                          }
                          break;

                        case 1:
                          if (childProfile.schoolName != null &&
                              childProfile.schoolName!.isNotEmpty &&
                              childProfile.classScheduleDate != null &&
                              childProfile.classScheduleDate!.isNotEmpty) {
                            canProceed = true;
                          }
                          break;

                        case 2:
                          canProceed = true; // no checks on step 2
                          break;
                      }

                      if (canProceed) {
                        _nextPage();
                      } else {
                        mySnackBar(context, title: errorMsg);
                      }
                    },
                  ),
                ),
              if (_currentStep == 3)
                Expanded(
                  child: BlocListener<AddTasksCubit, AddTasksState>(
                    listenWhen: (previous, current) =>
                        previous.childPostingStatus !=
                        current.childPostingStatus,
                    listener: (context, state) {
                      switch (state.childPostingStatus) {
                        case AddRequestStatus.loading:
                          setState(() {
                            isLoading = true;
                          });
                          break;

                        case AddRequestStatus.success:
                          setState(() {
                            isLoading = false;
                          });

                          myAlertBox(
                            context,
                            subtittle:
                                state.errorMsg ??
                                "Stakeholder ${childProfile.name ?? ""} added successfully",
                            heading: "Success 🎉",
                            onPressed: () {
                              Future.delayed(
                                const Duration(milliseconds: 300),
                                () {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    AppRoutes.navigationScreen,
                                  );
                                },
                              );
                            },
                          );

                          break;

                        case AddRequestStatus.failure:
                          setState(() {
                            isLoading = false;
                          });
                          mySnackBar(
                            context,
                            title: state.errorMsg ?? "Something went wrong",
                          );
                          break;

                        default:
                          break;
                      }
                    },
                    child: MyNavigationButton(
                      text: widget.uid != null && widget.uid!.isNotEmpty
                          ? "Edit"
                          : "Add to Board",
                      isLoading: isLoading,
                      onPressed: () {
                        context.read<AddTasksCubit>().addOrEditChildFun(
                          uid: widget.uid,
                          name: childProfile.name ?? "",
                          age: childProfile.age ?? "",
                          dateofBirth: childProfile.dob ?? "",
                          profileImage: childProfile.photo, // XFile? or null
                          gender: childProfile.gender ?? "",
                          schoolName: childProfile.schoolName ?? "",
                          schoolAddress: childProfile.schoolAddress ?? "",
                          grade: childProfile.grade ?? "",
                          classScheduleDate:
                              childProfile.classScheduleDate ?? "",
                          classScheduleTime:
                              childProfile.classScheduleTime ?? "",
                          allergies: childProfile.allergies ?? "",
                          medicalInformation:
                              childProfile.medicalInformation ?? "",
                          generalNotes: childProfile.generalNotes ?? "",
                          optionalEnhancements:
                              childProfile.optionalEnhancements ?? "",
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChildBasicInfoScreen extends StatefulWidget {
  final ChildProfile childProfile;
  final String? uid;
  const ChildBasicInfoScreen({super.key, required this.childProfile, this.uid});

  @override
  State<ChildBasicInfoScreen> createState() => _ChildBasicInfoScreenState();
}

class _ChildBasicInfoScreenState extends State<ChildBasicInfoScreen> {
  DateTime? selectedDate;
  String? hintDate;
  String? ageChild;
  String? dobChild;
  bool isLoading = false;
  String? netImage;
  TextEditingController childNameController = TextEditingController();
  TextEditingController childAgeController = TextEditingController();

  Future<void> pickDate(BuildContext context) async {
    DateTime? picked = await calenderPicker(
      context,
      selectedDate: selectedDate,
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;

        // Calculate age in years and months
        final today = DateTime.now();
        int years = today.year - picked.year;
        int months = today.month - picked.month;

        if (today.day < picked.day) {
          months -= 1; // adjust if current day is less than birth day
        }

        if (months < 0) {
          years -= 1;
          months += 12;
        }

        // Handle plural vs singular
        String yearText = years == 1 ? "1 year" : "$years years";
        String monthText = months == 1 ? "1 month" : "$months months";

        String ageTextHint = "$yearText and $monthText";

        hintDate = ageTextHint;

        // Age in format "X years and Y months"
        String ageText = "${years}y ${months}m";

        // Format picked date as "MMMM d, y"
        String formatted = DateFormat('MMM d, y').format(picked);

        dobChild = formatted;

        // Store values
        ageChild = ageText;
      });
    }
  }

  final List<String> genders = ["Male", "Female"];
  String selectedGender = '';

  XFile? pickedImage;
  Future<void> pickImageAndCrop(ImageSource source) async {
    final ImagePicker picker = ImagePicker();

    final XFile? pickedFile = await picker.pickImage(source: source);
    if (pickedFile == null) return;

    final CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: "Crop Image",
          toolbarColor: AppColor.background, // Dark navy blue
          toolbarWidgetColor: AppColor.textSecondary, // White
          backgroundColor: AppColor.background, // Dark navy
          statusBarColor: AppColor.background, // Slightly lighter navy
          activeControlsWidgetColor: AppColor.secondary, // Gold highlight
          initAspectRatio: CropAspectRatioPreset.square,
          cropStyle: CropStyle.rectangle,
          lockAspectRatio: false,
        ),
        IOSUiSettings(title: "Crop Image"),
      ],
    );

    if (croppedFile == null) return;

    setState(() {
      pickedImage = XFile(croppedFile.path);
    });
  }

  @override
  void initState() {
    super.initState();

    pickedImage = widget.childProfile.photo ?? null;
    netImage = widget.childProfile.imagePath ?? "";
    childNameController = TextEditingController(
      text: widget.childProfile.name ?? '',
    );
    ageChild = widget.childProfile.age ?? null;
    selectedGender = widget.childProfile.gender ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 25.w),
        child: SingleChildScrollView(
          child: Column(
            children: [
              imageHolderWithPlus(
                imagePath: pickedImage,
                netWorkImage: widget.uid != null ? netImage : "",

                onPressed: () {
                  showImagePickerAlert(
                    context: context,

                    onCameraTap: () async {
                      await pickImageAndCrop(ImageSource.camera);

                      setState(() {
                        widget.childProfile.photo = pickedImage;
                      });
                    },
                    onGalleryTap: () async {
                      await pickImageAndCrop(ImageSource.gallery);
                      setState(() {
                        widget.childProfile.photo = pickedImage;
                      });
                    },
                  );
                },
              ),
              SizedBox(height: 20.h),

              MyUploadTextField(
                userController: childNameController,
                labelText: "  Enter your child's name",
                hint: "Shopiha",
                frontIcon: Icons.face,
                onChangedValue: (value) {
                  widget.childProfile.name = value.trim();
                },
              ),

              MyDateAndTimePickerBox(
                onPressed: () async {
                  // log(ageChild!);
                  await pickDate(context);
                  setState(() {
                    widget.childProfile.age = ageChild;
                    widget.childProfile.dob = dobChild;
                  });
                },
                hint: ageChild != null ? ageChild : "dd/mm/yyyy",
                labelText: ' Enter your child\'s date of birth',
                isExpanded: true,
                frontIcon: Icons.calendar_month_outlined,
                isRequired: true,
              ),
              SizedBox(height: 20.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: List.generate(genders.length, (index) {
                  return Padding(
                    padding: EdgeInsets.only(right: 20.w),
                    child: Row(
                      children: [
                        Radio<String>(
                          value: genders[index],
                          groupValue: selectedGender,
                          activeColor: AppColor.secondary,
                          onChanged: (value) {
                            setState(() {
                              selectedGender = value!;
                              widget.childProfile.gender = selectedGender;
                            });
                          },
                        ),
                        Text(
                          genders[index],
                          style: t3White().copyWith(fontSize: 22.sp),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChildSchoolInfoScreen extends StatefulWidget {
  final ChildProfile childProfile;
  final String? uid;
  const ChildSchoolInfoScreen({
    super.key,
    required this.childProfile,
    this.uid,
  });

  @override
  State<ChildSchoolInfoScreen> createState() => _ChildSchoolInfoScreenState();
}

class _ChildSchoolInfoScreenState extends State<ChildSchoolInfoScreen> {
  String? selectedDateShedule;
  DateTime? selectedDate;

  TimeOfDay? selectedTime;
  String? selectedTimeShedule;

  TextEditingController childSchoolName = TextEditingController();
  TextEditingController childSchoolAddress = TextEditingController();
  TextEditingController childGrade = TextEditingController();

  Future<void> pickDate(BuildContext context) async {
    DateTime? picked = await calenderPicker(
      context,
      selectedDate: selectedDate,
      lastDate: DateTime.now().year + 1,
      isToday: true,
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        String formatedDate = DateFormat('dd/MM/yyyy').format(picked);
        selectedDateShedule = formatedDate;
      });
    }
  }

  Future<void> pickTime() async {
    TimeOfDay now = TimeOfDay.now();

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),

      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.green, // selected date & header background
              onPrimary: Colors.white, // header text & selected date text
              surface: Color(0xFF0A1C34), // calendar background
              onSurface: Colors.white, // default text color
            ),
            dialogBackgroundColor: Color(0xFF0A1C34), // dialog background
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.green, // Cancel/OK button
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final int pickedMinutes = picked.hour * 60 + picked.minute;
      final int nowMinutes = now.hour * 60 + now.minute;

      if (pickedMinutes < nowMinutes) {
        mySnackBar(context, title: "Cannot select past time");
        return;
      }
      DateTime fullTime = DateTime(0, 1, 1, picked.hour, picked.minute);

      setState(() {
        selectedTime = picked;
        String formatted = DateFormat(' hh:mm a').format(fullTime);
        selectedTimeShedule = formatted;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    childSchoolName = TextEditingController(
      text: widget.childProfile.schoolName ?? '',
    );
    childSchoolAddress = TextEditingController(
      text: widget.childProfile.schoolAddress ?? '',
    );
    childGrade = TextEditingController(text: widget.childProfile.grade ?? '');
    selectedTimeShedule = widget.childProfile.classScheduleTime ?? null;
    selectedDateShedule = widget.childProfile.classScheduleDate ?? null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 25.w),
        child: SingleChildScrollView(
          child: Column(
            children: [
              MyUploadTextField(
                userController: childSchoolName,
                isRequired: true,
                labelText: " School Name",
                hint: "Kent State School",
                frontIcon: Icons.school,

                onChangedValue: (value) {
                  setState(() {
                    widget.childProfile.schoolName = childSchoolName.text
                        .trim();
                  });
                },
              ),
              MyUploadTextField(
                userController: childSchoolAddress,
                isRequired: false,
                labelText: " School Address",
                hint: "Kent, Ohio",
                frontIcon: Icons.location_on,

                onChangedValue: (value) {
                  setState(() {
                    widget.childProfile.schoolName = childSchoolName.text
                        .trim();
                  });
                },
              ),

              MyUploadTextField(
                userController: childGrade,
                isDateandTime: true,
                isGpa: true,
                isRequired: false,
                labelText: " Grade",
                hint: "3.38 GPA",
                frontIcon: Icons.format_list_numbered,
                onChangedValue: (value) {
                  setState(() {
                    widget.childProfile.grade = childGrade.text.trim();
                  });
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MyDateAndTimePickerBox(
                    onPressed: () async {
                      await pickDate(context);
                      if (selectedDateShedule != null) {
                        setState(() {
                          widget.childProfile.classScheduleDate =
                              selectedDateShedule ?? "";
                        });
                      }
                    },
                    hint: selectedDateShedule ?? "dd/mm/yyyy",
                    labelText: ' Class Schedule',

                    isExpanded: false,
                    frontIcon: Icons.calendar_month_outlined,
                    isRequired: true,
                  ),

                  MyDateAndTimePickerBox(
                    onPressed: () async {
                      await pickTime();
                      if (selectedTimeShedule != null) {
                        setState(() {
                          widget.childProfile.classScheduleTime =
                              selectedTimeShedule;
                        });
                      }
                    },
                    isRequired: false,
                    hint: selectedTimeShedule ?? "12:00 AM",
                    labelText: ' Schedule Time',
                    isExpanded: false,
                    frontIcon: Icons.alarm,
                  ),
                ],
              ),

              // MyUploadTextField(
              //   userController: childGrade,
              //   isRequired: false,
              //   labelText: " Class Schdule",
              //   hint: "At 4: 00 AM",

              //   frontIcon: Icons.calendar_month_outlined,
              //   onChangedValue: (value) {
              //     setState(() {
              //       widget.childProfile.classSchedule = childClassShedule.text
              //           .trim();
              //     });
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChildHealthInfoScreen extends StatefulWidget {
  final ChildProfile childProfile;
  final String? uid;
  const ChildHealthInfoScreen({
    super.key,
    required this.childProfile,
    this.uid,
  });

  @override
  State<ChildHealthInfoScreen> createState() => _ChildHealthInfoScreenState();
}

class _ChildHealthInfoScreenState extends State<ChildHealthInfoScreen> {
  TextEditingController childAllergies = TextEditingController();
  TextEditingController childMedicalInformation = TextEditingController();
  TextEditingController childGeneralNotes = TextEditingController();
  TextEditingController childOptionalEnhancements = TextEditingController();

  @override
  void initState() {
    super.initState();

    childAllergies = TextEditingController(
      text: widget.childProfile.allergies ?? '',
    );
    childMedicalInformation = TextEditingController(
      text: widget.childProfile.medicalInformation ?? '',
    );
    childGeneralNotes = TextEditingController(
      text: widget.childProfile.generalNotes ?? '',
    );
    childOptionalEnhancements = TextEditingController(
      text: widget.childProfile.optionalEnhancements ?? '',
    );

    // Health & Notes info
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 25.w),
        child: SingleChildScrollView(
          child: Column(
            children: [
              MyUploadTextField(
                // isDesc: true,
                userController: childAllergies,
                isRequired: false,
                labelText: " Allergies",
                hint: "Peanuts, Dairy, etc.",
                frontIcon: Icons.warning,
                onChangedValue: (value) {
                  setState(() {
                    widget.childProfile.allergies = childAllergies.text.trim();
                  });
                },
              ),
              MyUploadTextField(
                isDesc: true,
                isRequired: false,
                userController: childMedicalInformation,
                labelText: " Medical Information",
                hint: "Asthma, Medication details, Doctor contact etc",
                // frontIcon: Icons.local_hospital,
                onChangedValue: (value) {
                  setState(() {
                    widget.childProfile.medicalInformation =
                        childMedicalInformation.text.trim();
                  });
                },
              ),
              MyUploadTextField(
                isDesc: true,
                isRequired: false,
                userController: childGeneralNotes,
                labelText: " General Notes",
                hint: "Special care instructions, Habits, Preferences etc",
                // frontIcon: Icons.note,
                onChangedValue: (value) {
                  setState(() {
                    widget.childProfile.generalNotes = childGeneralNotes.text
                        .trim();
                  });
                },
              ),
              MyUploadTextField(
                isDesc: true,
                isRequired: false,
                userController: childOptionalEnhancements,
                labelText: " Optional Enhancements",
                hint: "Any Other Info",
                // frontIcon: Icons.,
                onChangedValue: (value) {
                  setState(() {
                    widget.childProfile.optionalEnhancements =
                        childOptionalEnhancements.text.trim();
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChildSummaryScreen extends StatefulWidget {
  final ChildProfile childProfile;
  const ChildSummaryScreen({required this.childProfile, super.key});

  @override
  State<ChildSummaryScreen> createState() => _ChildSummaryScreenState();
}

class _ChildSummaryScreenState extends State<ChildSummaryScreen> {
  @override
  void initState() {
    super.initState();
  }

  List<String> childProfileFields = [
    "Child Name",
    "Age",
    "Date of Birth",
    "Gender",

    // .....................School Info
    "School Name",
    "School Address",
    "Grade",
    "Class Schedule",

    // Health Info....................
    "Allergies",
    "Medical Inforamtion",
    "General Notes",
    "Other Info",
  ];

  List<IconData> childProfileIcons = [
    Icons.person, // Child Name
    Icons.cake, // Date of Birth
    Icons.calendar_month_outlined, // Age
    Icons.wc, // Gender
    // School Info
    Icons.school, // School Name
    Icons.location_city, // School Address
    Icons.grade, // Grade
    Icons.schedule, // Class Schedule
    // Health Info
    Icons.healing, // Allergies
    Icons.local_hospital, // Medical Information
    Icons.notes, // General Notes
    Icons.info, // Other Info
  ];

  @override
  Widget build(BuildContext context) {
    List<String?> childProfileValues = [
      widget.childProfile.name,
      widget.childProfile.age,
      widget.childProfile.dob,
      widget.childProfile.gender,
      widget.childProfile.schoolName,
      widget.childProfile.schoolAddress,
      widget.childProfile.grade,
      "${widget.childProfile.classScheduleDate ?? ''} [${widget.childProfile.classScheduleTime ?? ''}]",
      widget.childProfile.allergies,
      widget.childProfile.medicalInformation,
      widget.childProfile.generalNotes,
      widget.childProfile.optionalEnhancements,
    ];
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 25.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                MyProfileHolderLocal(
                  imagePath: widget.childProfile.photo, // XFile? picked by user
                  netImage:
                      widget.childProfile.imagePath, // String? from Firebase
                  name: widget.childProfile.name,
                  fontSize: 35,
                  width: 100,
                  height: 100,
                ),
                SizedBox(height: 15.h),

                // Bacis Info Section/ Column.............................................................
                Container(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Basic Information",
                    style: t1heading().copyWith(fontSize: 25.sp),
                  ),
                ),
                SizedBox(height: 7.h),
                Column(
                  children: List.generate(4, (index) {
                    return MyTextFieldDisable(
                      hint: (childProfileValues[index]?.isEmpty ?? true)
                          ? "Not Provided"
                          : childProfileValues[index],
                      frontIcon: childProfileIcons[index],
                      labelText: " ${childProfileFields[index]}",
                    );
                  }),
                ),
                SizedBox(height: 20.h),

                // School Info Section/ Column.............................................................
                Container(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "School Information",
                    style: t1heading().copyWith(fontSize: 25.sp),
                  ),
                ),
                SizedBox(height: 7.h),
                Column(
                  children: List.generate(4, (index) {
                    return MyTextFieldDisable(
                      hint: (childProfileValues[index + 4]?.isEmpty ?? true)
                          ? "Not Provided"
                          : childProfileValues[index + 4],
                      frontIcon: childProfileIcons[index + 4],
                      labelText: " ${childProfileFields[index + 4]}",
                    );
                  }),
                ),
                SizedBox(height: 20.h),

                // // Medical Information Section .............................................................
                Container(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Health Information",
                    style: t1heading().copyWith(fontSize: 25.sp),
                  ),
                ),
                SizedBox(height: 7.h),
                Column(
                  children: List.generate(4, (index) {
                    return MyTextFieldDisable(
                      hint: (childProfileValues[index + 8]?.isEmpty ?? true)
                          ? "Not Provided"
                          : childProfileValues[index + 8],
                      frontIcon: childProfileIcons[index + 8],
                      labelText: " ${childProfileFields[index + 8]}",
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
