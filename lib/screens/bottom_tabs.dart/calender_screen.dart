import 'dart:developer';
import 'package:family_management_app/app/app%20Color/app_color.dart';
import 'package:family_management_app/app/routes/app_routes.dart';
import 'package:family_management_app/app/textStyle/textstyles.dart';
import 'package:family_management_app/app/utils/custom_appbar.dart';
import 'package:family_management_app/app/utils/utils.dart';
import 'package:family_management_app/bloc/fetch%20User/fetch_user_cubit.dart';
import 'package:family_management_app/bloc/fetch_tasks/fetch_tasks_cubit.dart';
import 'package:family_management_app/bloc/google_calender/cubit/google_calendar_cubit.dart';
import 'package:family_management_app/service/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalenderScreen extends StatefulWidget {
  final bool isBack;
  const CalenderScreen({super.key, this.isBack = false});

  @override
  State<CalenderScreen> createState() => _CalenderScreenState();
}

class _CalenderScreenState extends State<CalenderScreen> {
  final CalendarController _monthcalendarController = CalendarController();
  final CalendarController _weekCalendarController = CalendarController();
  final CalendarController _dayCalendarController = CalendarController();

  String monthLabel = '';
  String weekLabel = "";
  String dayLabel = "";

  Color arrowColor = Colors.white;
  int selectedIndex = 2;
  String? selectedMember;
  String? savedRole;
  String? savedEmail;

  // final List<String> roles = ['Chief', 'Lead', 'Board', 'Guest', 'Kid'];
  final List<String> userMembers = ["User"];
  List<String> filters = ["Day", "Week", "Month"];

  bool isToogleOff = false;

  @override
  void initState() {
    super.initState();
    getRole();

    // context.read<FetchTasksCubit>().getDateAndRoleForCalander();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FetchTasksCubit>().getDateAndRoleForCalander();
    });
    _weekCalendarController.addPropertyChangedListener((_) {
      _updateWeekName();
    });
    _updateMonthName();
    _updateDayLabel((DateTime.now()));
    _fetchAllData();
  }

  void _fetchAllData() {
    context.read<FetchTasksCubit>().getDateAndRoleForCalander();
    context.read<FetchUserCubit>().getAllUserBasedonRole();
  }

  Future<void> getRole() async {
    final userRole = await AppStorage.read(key: "savedRole");
    final String userEmail = await AppStorage.read(key: "email") ?? "";
    setState(() {
      savedRole = userRole;
      savedEmail = userEmail;
    });
  }

  // Month Update...................Month..................................................
  void _updateMonthName() {
    final String monthName = DateFormat(
      'MMMM yyyy',
    ).format(_monthcalendarController.displayDate ?? DateTime.now());
    setState(() {
      monthLabel = monthName;
    });
  }

  void _goToNextMonth() {
    setState(() {
      _monthcalendarController.displayDate = DateTime(
        _monthcalendarController.displayDate!.year,
        _monthcalendarController.displayDate!.month + 1,
        1,
      );
      _updateMonthName();
    });
  }

  void _goToPreviousMonth() {
    setState(() {
      _monthcalendarController.displayDate = DateTime(
        _monthcalendarController.displayDate!.year,
        _monthcalendarController.displayDate!.month - 1,
        1,
      );
      _updateMonthName();
    });
  }

  void _updateWeekName() {
    if (_weekCalendarController.displayDate != null) {
      final DateTime startDate = _getWeekStartDate(
        _weekCalendarController.displayDate ?? DateTime.now(),
      );
      final DateTime endDate = startDate.add(const Duration(days: 6));
      final String monthStart = DateFormat('MMM').format(startDate);
      final String monthEnd = DateFormat('MMM').format(endDate);
      final String formatted =
          "Week of $monthStart ${startDate.day} - $monthEnd ${endDate.day}, ${endDate.year}";
      weekLabel = formatted;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    }
  }

  DateTime _getWeekStartDate(DateTime date) {
    // assuming week starts from Sunday
    final int dayOfWeek = date.weekday % 7; // Sunday = 0
    return date.subtract(Duration(days: dayOfWeek));
  }

  void _updateDayLabel(DateTime date) {
    dayLabel = DateFormat('EEEE, MMM dd, yyyy').format(date);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  Color getRoleColor(String? role) {
    if (role == "Chief") {
      return AppColor.dropDownAlternativeColor;
    } else if (role == "Lead") {
      return AppColor.success;
    } else if (role == "Board Member") {
      return AppColor.secondary;
    } else if (role == "Guest") {
      return Colors.red;
    }
    if (role == "Stakeholder") {
      return const Color(0xFF9C27B0);
    } else {
      return AppColor.dropDownAlternativeColor;
    }
  }

  String getDateForFilter() {
    if (selectedIndex == 0) {
      return dayLabel;
    } else if (selectedIndex == 1) {
      return weekLabel;
    } else {
      return monthLabel;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: widget.isBack
          ? MyCustomAppBar(
              heading: "Executive Calendar",
              subTitle: " Your Schedule at a Glance",
            )
          : AppBar(
              backgroundColor: AppColor.background,
              automaticallyImplyLeading: false,
              toolbarHeight: 80.h,
              titleSpacing: 20.w,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Executive Calendar",
                    style: t1heading().copyWith(fontSize: 30.sp),
                  ),
                  Text(" Your Schedule at a Glance", style: t3White()),
                ],
              ),
              actionsPadding: EdgeInsets.only(right: 10.r, bottom: 10.h),
              actions: [
                savedRole == "Chief"
                    ? IconButton(
                        onPressed: () {
                          showMyAddOptionsAlertTask(
                            context: context,

                            onAddTaskTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.addTasksScreen,
                              );
                            },
                            onAddEventTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.addEventsScreen,
                              );
                            },
                          );
                        },
                        icon: Icon(Icons.add),
                        color: AppColor.secondary,
                      )
                    : SizedBox(),
              ],
            ),
      body: BlocListener<FetchUserCubit, FetchUserState>(
        listener: (context, state) {
          if (state.fetchAllUserStatus == FetchRequestStatus.sucess) {
            setState(() {
              userMembers.addAll(
                state.userInfo!.map((user) => user.name).toList(),
              );
            });
          }
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: SingleChildScrollView(
            child: BlocListener<GoogleCalendarCubit, GoogleCalendarState>(
              listener: (context, state) {
                if (state.deleteStatus == GoogleCalendarStatus.success) {
                  mySnackBar(context, title: state.error!);
                } else if (state.deleteStatus == GoogleCalendarStatus.failure) {
                  mySnackBar(context, title: "Error: ${state.error}");
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        savedRole == "Chief"
                            ? SizedBox(height: 40.h, child: myDropDownButton())
                            : SizedBox(),
                        Row(
                          children: List.generate(3, (index) {
                            return filterContainer(
                              text: filters[index],
                              onPressed: () {
                                setState(() {});
                                selectedIndex = index;
                              },
                              textColor: selectedIndex == index
                                  ? AppColor.secondary
                                  : Colors.white,
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  GestureDetector(
                    onTap: () {
                      DateTime currentMonth = DateTime.now();
                      if (selectedIndex == 0) {
                        showDayEventsDialog(
                          context: context,

                          initialDate: currentMonth,
                        );
                      } else if (selectedIndex == 1) {
                        showWeekEventsDialog(
                          context: context,
                          initialDate: currentMonth,
                        );
                      } else {
                        showMonthEventsDialog(
                          context: context,
                          monthYear: DateFormat(
                            'MMMM yyyy',
                          ).format(currentMonth),
                          onPrev: () {},
                          onNext: () {},

                          events: [
                            {
                              "time": "10:00 AM",
                              "title": "Team Meeting",
                              "desc": "Discuss project updates",
                            },
                            {
                              "time": "2:00 PM",
                              "title": "Design Review",
                              "desc": "Review UI/UX designs",
                            },
                            {
                              "time": "4:00 PM",
                              "title": "Call Client",
                              "desc": "Weekly follow-up",
                            },
                          ],
                        );
                      }
                    },
                    child: myTextHolderContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_month_outlined,
                                size: 30.sp,
                                color: AppColor.secondary,
                              ),
                              SizedBox(width: 5.w),
                              Text(
                                getDateForFilter(),
                                style: t3White().copyWith(fontSize: 22.sp),
                              ),
                            ],
                          ),
                          Text("0 events scheduled", style: hintTextStyle()),
                        ],
                      ),

                      horizontal: 25,
                    ),
                  ),

                  SizedBox(height: 20.h),
                  selectedIndex == 2
                      ? Card(
                          elevation: 12,
                          color: AppColor.dropDownColor,
                          shadowColor: Color(0xFF050F1A),

                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    onPressed: _goToPreviousMonth,
                                    icon: const Icon(
                                      Icons.arrow_left,
                                      size: 28,
                                    ),
                                  ),
                                  Text(
                                    "Altos HQ Calendar",
                                    style: const TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      _goToNextMonth();
                                    },
                                    icon: const Icon(
                                      Icons.arrow_right,
                                      size: 28,
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 4.h),

                              // Month name
                              Text(
                                monthLabel,
                                style: const TextStyle(
                                  fontSize: 22,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              SizedBox(height: 15.h),

                              // Calendar
                              BlocBuilder<FetchTasksCubit, FetchTasksState>(
                                builder: (context, state) {
                                  if (state.mergedList == null ||
                                      state.mergedList!.isEmpty) {
                                    return SfCalendar(
                                      todayHighlightColor: AppColor.secondary,
                                      controller: _monthcalendarController,
                                      view: CalendarView.month,
                                      backgroundColor: Colors.transparent,
                                      headerHeight: 0,
                                      showNavigationArrow: false,
                                      viewNavigationMode:
                                          ViewNavigationMode.none,
                                      showDatePickerButton: false,
                                      viewHeaderStyle: const ViewHeaderStyle(
                                        dayTextStyle: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                        ),
                                      ),
                                      monthViewSettings:
                                          const MonthViewSettings(
                                            showAgenda: false,
                                            showTrailingAndLeadingDates: true,
                                          ),
                                      selectionDecoration: BoxDecoration(
                                        color: Colors.transparent,
                                      ),
                                      monthCellBuilder: (context, details) {
                                        final bool isCurrentMonth =
                                            details.date.month ==
                                            _monthcalendarController
                                                .displayDate!
                                                .month;
                                        final bool isToday =
                                            DateTime.now().day ==
                                                details.date.day &&
                                            DateTime.now().month ==
                                                details.date.month &&
                                            DateTime.now().year ==
                                                details.date.year;

                                        return GestureDetector(
                                          onTap: () {
                                            if (savedRole == "Chief") {
                                              DateTime date = details.date;

                                              String formattedDate =
                                                  "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";

                                              DateTime today = DateTime.now();

                                              DateTime todayDateOnly = DateTime(
                                                today.year,
                                                today.month,
                                                today.day,
                                              );

                                              if (date.isBefore(
                                                todayDateOnly,
                                              )) {
                                                mySnackBar(
                                                  context,
                                                  title:
                                                      "Tasks & events cannot be scheduled in the past.",
                                                );
                                              } else {
                                                // This includes today or future dates
                                                showMyAddOptionsAlertTask(
                                                  context: context,
                                                  onAddTaskTap: () {
                                                    Navigator.pushNamed(
                                                      context,
                                                      AppRoutes.addTasksScreen,
                                                      arguments: {
                                                        'preSelectedDate':
                                                            formattedDate,
                                                      },
                                                    );
                                                  },
                                                  onAddEventTap: () {
                                                    Navigator.pushNamed(
                                                      context,
                                                      AppRoutes.addEventsScreen,
                                                      arguments: {
                                                        'preSelectedDate':
                                                            formattedDate,
                                                      },
                                                    );
                                                  },
                                                );
                                              }
                                            }
                                          },
                                          child: Container(
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.white24,
                                                width: 0.2,
                                              ),
                                            ),
                                            child: Text(
                                              details.date.day.toString(),
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: isCurrentMonth
                                                    ? isToday
                                                          ? AppColor.border
                                                          : Colors.white
                                                    : Colors.grey.shade700,
                                                fontWeight: isToday
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }

                                  return SfCalendar(
                                    viewNavigationMode: ViewNavigationMode.none,
                                    onViewChanged: (value) {},
                                    view: CalendarView.month,
                                    controller: _monthcalendarController,
                                    backgroundColor: Colors.transparent,
                                    headerHeight: 0,
                                    showNavigationArrow: false,
                                    showDatePickerButton: false,
                                    todayHighlightColor: AppColor.secondary,
                                    viewHeaderStyle: const ViewHeaderStyle(
                                      dayTextStyle: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    monthViewSettings: MonthViewSettings(
                                      // agendaItemHeight: 0,
                                      // agendaViewHeight: 150,

                                      // showAgenda: true,
                                      showTrailingAndLeadingDates: true,
                                    ),
                                    selectionDecoration: BoxDecoration(
                                      color: Colors.transparent,
                                    ),
                                    monthCellBuilder: (context, details) {
                                      final bool isCurrentMonth =
                                          details.date.month ==
                                          _monthcalendarController
                                              .displayDate!
                                              .month;
                                      final bool isToday =
                                          DateTime.now().day ==
                                              details.date.day &&
                                          DateTime.now().month ==
                                              details.date.month &&
                                          DateTime.now().year ==
                                              details.date.year;

                                      final tasksForDay = state.mergedList
                                          ?.where((task) {
                                            final taskDate = DateFormat(
                                              "dd/MM/yyyy",
                                            ).parse(task.date);
                                            return taskDate.year ==
                                                    details.date.year &&
                                                taskDate.month ==
                                                    details.date.month &&
                                                taskDate.day ==
                                                    (details.date.day);
                                          })
                                          .toList();

                                      Color getRoleColor(String? role) {
                                        if (role == "Chief") return Colors.blue;
                                        if (role == "Lead") return Colors.green;
                                        if (role == "Board Member")
                                          return AppColor.secondary;
                                        if (role == "Guest") return Colors.red;
                                        if (role == "Stakeholder")
                                          return Colors.teal;
                                        return Colors.white;
                                      }

                                      return GestureDetector(
                                        onTap: () {
                                          if (savedRole == "Chief") {
                                            DateTime date = details.date;

                                            String formattedDate =
                                                "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";

                                            DateTime today = DateTime.now();
                                            DateTime todayDateOnly = DateTime(
                                              today.year,
                                              today.month,
                                              today.day,
                                            );

                                            if (tasksForDay.isEmpty &&
                                                date.isBefore(todayDateOnly)) {
                                              mySnackBar(
                                                context,
                                                title:
                                                    "Tasks & events cannot be scheduled in the past.",
                                              );
                                            } else {
                                              showMyAddOptionsAlertTask(
                                                context: context,
                                                onAddTaskTap: () {
                                                  Navigator.pushNamed(
                                                    context,
                                                    AppRoutes.addTasksScreen,
                                                    arguments: {
                                                      'preSelectedDate':
                                                          formattedDate,
                                                    },
                                                  );
                                                },
                                                onAddEventTap: () {
                                                  Navigator.pushNamed(
                                                    context,
                                                    AppRoutes.addEventsScreen,
                                                    arguments: {
                                                      'preSelectedDate':
                                                          formattedDate,
                                                    },
                                                  );
                                                },
                                              );
                                            }
                                          }
                                        },

                                        child: Container(
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: isToday && isCurrentMonth
                                                ? Colors.transparent
                                                : Colors.transparent,
                                            border: Border.all(
                                              color: Colors.white24,
                                              width: 0.1,
                                            ),
                                          ),
                                          child: tasksForDay!.isNotEmpty
                                              ? SizedBox(
                                                  height: 60,
                                                  child: Stack(
                                                    alignment: Alignment.center,
                                                    clipBehavior: Clip.none,
                                                    children: [
                                                      for (
                                                        var i = 0;
                                                        i < tasksForDay.length;
                                                        i++
                                                      )
                                                        Positioned(
                                                          top:
                                                              tasksForDay
                                                                      .length >
                                                                  1
                                                              ? i * 10.0
                                                              : null,
                                                          child: MyProfileHolder(
                                                            onPressed: () {
                                                              if (tasksForDay
                                                                  .isNotEmpty) {
                                                                for (var task
                                                                    in tasksForDay) {
                                                                  // log(

                                                                  // );

                                                                  myCalendarAlertBox(
                                                                    isEmail:
                                                                        savedEmail ==
                                                                        task.assignedEmail,
                                                                    context,
                                                                    isOff: task
                                                                        .isGoogleCal,
                                                                    onYesPressed: () async {
                                                                      log(
                                                                        task.date +
                                                                            task.time!,
                                                                      );
                                                                      if (!task
                                                                          .isGoogleCal) {
                                                                        await Navigator.pushNamed(
                                                                          context,
                                                                          AppRoutes
                                                                              .connectCalenderScreen,
                                                                          arguments: {
                                                                            "taskId":
                                                                                task.taskId,
                                                                            "title":
                                                                                task.title,
                                                                            "description":
                                                                                task.description,
                                                                            "startDate":
                                                                                task.date +
                                                                                task.time!,
                                                                          },
                                                                        );
                                                                        Navigator.pop(
                                                                          context,
                                                                        );
                                                                      } else {
                                                                        context
                                                                            .read<
                                                                              GoogleCalendarCubit
                                                                            >()
                                                                            .removeTaskFromGoogleCalendar(
                                                                              taskId: task.taskId,
                                                                            );
                                                                        Future.delayed(
                                                                          Duration(
                                                                            milliseconds:
                                                                                500,
                                                                          ),
                                                                          () {
                                                                            Navigator.pop(
                                                                              context,
                                                                            );
                                                                          },
                                                                        );
                                                                      }
                                                                    },

                                                                    title: task
                                                                        .title,
                                                                    description:
                                                                        task.description,
                                                                    selectedDate: details
                                                                        .date
                                                                        .day
                                                                        .toString()
                                                                        .padLeft(
                                                                          2,
                                                                          '0',
                                                                        ),
                                                                    boxColor:
                                                                        getRoleColor(
                                                                          task.role,
                                                                        ),
                                                                    selectedDay:
                                                                        DateFormat(
                                                                          'MMMM',
                                                                        ).format(
                                                                          details
                                                                              .date,
                                                                        ),
                                                                    userName: task
                                                                        .assignedTo
                                                                        ?.split(
                                                                          " ",
                                                                        )[0],
                                                                    userRole:
                                                                        task.role,
                                                                    imagePath: task
                                                                        .imagePath,
                                                                  );
                                                                }
                                                              }
                                                            },

                                                            imagePath:
                                                                tasksForDay[i]
                                                                    .imagePath,
                                                            name:
                                                                tasksForDay[i]
                                                                    .assignedTo ??
                                                                "",
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                )
                                              : Text(
                                                  details.date.day.toString(),
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    color: isCurrentMonth
                                                        ? isToday
                                                              ? AppColor.border
                                                              : Colors.white
                                                        : Colors.grey.shade700,
                                                    fontWeight: isToday
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                                  ),
                                                ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        )
                      : selectedIndex == 1
                      ? Container(
                          height: 450.h,

                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7.r),
                            color: AppColor.background,
                          ),

                          child: BlocBuilder<FetchTasksCubit, FetchTasksState>(
                            builder: (context, state) {
                              List<Meeting> getAppointments(
                                List<TaskInfo> tasks,
                              ) {
                                return tasks.map((task) {
                                  final date = DateFormat(
                                    "dd/MM/yyyy",
                                  ).parse(task.date);
                                  final rawTime =
                                      task.time?.trim() ?? "12:50 PM";
                                  // log(rawTime);

                                  final time = DateFormat(
                                    "hh:mm a",
                                  ).parse(rawTime);

                                  final dateTime = DateTime(
                                    date.year,
                                    date.month,
                                    date.day,
                                    time.hour,
                                  );

                                  final endTime = dateTime.add(
                                    Duration(hours: 3),
                                  );
                                  return Meeting(
                                    eventName: task.title,
                                    imagePath: task.imagePath ?? "",
                                    from: dateTime,
                                    userName: task.assignedTo ?? "",
                                    to: endTime,
                                    role: task.role,
                                    description: task.description,
                                  );
                                }).toList();
                              }

                              return SfCalendar(
                                // time
                                cellEndPadding: 0,
                                view: CalendarView.week,
                                viewHeaderHeight: 40,
                                headerHeight: 0,
                                controller: _weekCalendarController,
                                selectionDecoration: BoxDecoration(
                                  color: Colors.transparent,
                                ),

                                todayHighlightColor: Colors.transparent,
                                firstDayOfWeek: 1,

                                timeSlotViewSettings: TimeSlotViewSettings(
                                  timeTextStyle: t3White().copyWith(
                                    fontSize: 15.sp,
                                  ),
                                  timeRulerSize: 40,
                                  startHour: 6, // start hour
                                  endHour: 24, // end hour
                                  timeIntervalHeight:
                                      40, // optional: height for each hour slot
                                ),
                                onTap: (CalendarTapDetails details) {
                                  if (savedRole == "Chief") {
                                    if (details.targetElement ==
                                            CalendarElement.calendarCell &&
                                        details.date != null) {
                                      DateTime selectedDate = details.date!;
                                      DateTime today = DateTime.now();
                                      today = DateTime(
                                        today.year,
                                        today.month,
                                        today.day,
                                      );

                                      if (selectedDate.isBefore(today)) {
                                        mySnackBar(
                                          context,
                                          title:
                                              "Tasks & events cannot be scheduled in the past.",
                                        );
                                      } else {
                                        String formattedDate =
                                            "${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}";

                                        DateTime selectedDateTime =
                                            details.date!;
                                        String formattedTime = DateFormat(
                                          'hh:mm a',
                                        ).format(selectedDateTime);

                                        showMyAddOptionsAlertTask(
                                          context: context,
                                          onAddTaskTap: () {
                                            Navigator.pushNamed(
                                              context,
                                              AppRoutes.addTasksScreen,
                                              arguments: {
                                                'preSelectedDate':
                                                    formattedDate,
                                                'preSelectedTime':
                                                    formattedTime,
                                              },
                                            );
                                          },
                                          onAddEventTap: () {
                                            Navigator.pushNamed(
                                              context,
                                              AppRoutes.addEventsScreen,
                                              arguments: {
                                                'preSelectedDate':
                                                    formattedDate,
                                                'preSelectedTime':
                                                    formattedTime,
                                              },
                                            );
                                          },
                                        );
                                      }
                                    }
                                  }
                                },

                                viewHeaderStyle: ViewHeaderStyle(
                                  backgroundColor: Colors.transparent,
                                  dayTextStyle: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),

                                  dateTextStyle: TextStyle(
                                    color: Colors.transparent,
                                    fontSize: 0,
                                  ),
                                ),
                                cellBorderColor: Colors.white24,

                                dataSource: MeetingDataSource(
                                  getAppointments(state.mergedList ?? []),
                                ),
                                appointmentBuilder: (context, details) {
                                  final Meeting meeting =
                                      details.appointments.first;

                                  return GestureDetector(
                                    onTap: () {
                                      myCalendarAlertBoxWeek(
                                        context,
                                        imagePath: meeting.imagePath,
                                        userName: meeting.userName,
                                        userRole: meeting.role,

                                        title: meeting.eventName,
                                        description: meeting.description ?? "",
                                        selectedDate: details.date.day
                                            .toString()
                                            .padLeft(2, '0'),
                                        boxColor: getRoleColor(meeting.role),
                                        selectedDay: DateFormat(
                                          'MMMM',
                                        ).format(details.date),
                                      );
                                    },
                                    child: Container(
                                      alignment: Alignment.center,

                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(7),
                                        // color: AppColor.secondary,
                                        color: getRoleColor(meeting.role ?? ""),
                                        border: Border.all(
                                          color: AppColor.secondary,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.max,

                                        children: [
                                          MyProfileHolder(
                                            imagePath: meeting.imagePath,
                                            name: meeting.userName,
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            meeting.userName
                                                .toString()
                                                .split(" ")
                                                .first,
                                            style: hintTextStyle().copyWith(
                                              color: Colors.white,
                                            ),
                                            maxLines: 1,
                                            textAlign: TextAlign.center,
                                          ),
                                          SizedBox(height: 4.h),
                                          Text(
                                            meeting.eventName
                                                .toString()
                                                .split(" ")
                                                .first,
                                            style: t3White(),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        )
                      : BlocBuilder<FetchTasksCubit, FetchTasksState>(
                          builder: (context, state) {
                            List<Meeting> getAppointments(
                              List<TaskInfo> tasks,
                            ) {
                              return tasks.map((task) {
                                final date = DateFormat(
                                  "dd/MM/yyyy",
                                ).parse(task.date);
                                final rawTime = task.time?.trim() ?? "12:50 PM";
                                // log(rawTime);

                                final time = DateFormat(
                                  "hh:mm a",
                                ).parse(rawTime);

                                final dateTime = DateTime(
                                  date.year,
                                  date.month,
                                  date.day,
                                  time.hour,
                                );

                                final endTime = dateTime.add(
                                  Duration(hours: 1),
                                );
                                return Meeting(
                                  eventName: task.title,
                                  imagePath: task.imagePath ?? "",
                                  from: dateTime,
                                  userName: task.assignedTo ?? "",
                                  to: endTime,
                                  role: task.role,
                                  description: task.description,
                                  date: task.date,
                                );
                              }).toList();
                            }

                            return Container(
                              height: 450.h,

                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7.r),
                                color: AppColor.background,
                              ),
                              child: SfCalendar(
                                cellEndPadding: 0,
                                controller: _dayCalendarController,

                                viewHeaderHeight: 0,
                                headerHeight: 0,
                                todayHighlightColor: Colors.transparent,
                                timeSlotViewSettings: TimeSlotViewSettings(
                                  timeTextStyle: t3White().copyWith(
                                    fontSize: 15.sp,
                                  ),
                                  timeRulerSize: 40,
                                  startHour: 8, // start hour
                                  endHour: 19, // end hour
                                  timeIntervalHeight: 60,
                                ),
                                view: CalendarView.day,
                                viewHeaderStyle: ViewHeaderStyle(
                                  backgroundColor: Colors.transparent,
                                  dayTextStyle: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),

                                onTap: (CalendarTapDetails details) {
                                  if (savedRole == "Chief") {
                                    if (details.targetElement ==
                                            CalendarElement.calendarCell &&
                                        details.date != null) {
                                      DateTime selectedDate = details.date!;
                                      DateTime today = DateTime.now();
                                      today = DateTime(
                                        today.year,
                                        today.month,
                                        today.day,
                                      );

                                      if (selectedDate.isBefore(today)) {
                                        mySnackBar(
                                          context,
                                          title:
                                              "Tasks & events cannot be scheduled in the past.",
                                        );
                                      } else {
                                        String formattedDate =
                                            "${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}";

                                        DateTime selectedDateTime =
                                            details.date!;
                                        String formattedTime = DateFormat(
                                          'hh:mm a',
                                        ).format(selectedDateTime);

                                        showMyAddOptionsAlertTask(
                                          context: context,
                                          onAddTaskTap: () {
                                            Navigator.pushNamed(
                                              context,
                                              AppRoutes.addTasksScreen,
                                              arguments: {
                                                'preSelectedDate':
                                                    formattedDate,
                                                'preSelectedTime':
                                                    formattedTime,
                                              },
                                            );
                                          },
                                          onAddEventTap: () {
                                            Navigator.pushNamed(
                                              context,
                                              AppRoutes.addEventsScreen,
                                              arguments: {
                                                'preSelectedDate':
                                                    formattedDate,
                                                'preSelectedTime':
                                                    formattedTime,
                                              },
                                            );
                                          },
                                        );
                                      }
                                    }
                                  }
                                },

                                onViewChanged: (ViewChangedDetails details) {
                                  // Get middle date of visible dates to represent the day
                                  final DateTime midDate =
                                      details.visibleDates[details
                                              .visibleDates
                                              .length ~/
                                          2];
                                  _updateDayLabel(midDate);
                                },

                                dataSource: MeetingDataSource(
                                  getAppointments(state.mergedList ?? []),
                                ), // your appointments
                                appointmentBuilder: (context, details) {
                                  final Meeting meeting =
                                      details.appointments.first;

                                  return Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 25.w,
                                    ),
                                    decoration: BoxDecoration(
                                      color: getRoleColor(meeting.role ?? ""),
                                      border: Border.all(
                                        color: AppColor.secondary,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        // Image
                                        MyProfileHolder(
                                          imagePath: meeting.imagePath,
                                          name: meeting.userName,
                                          height: 60,
                                          fontSize: 35,
                                          width: 60,
                                        ),
                                        SizedBox(width: 10.w),

                                        Flexible(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                meeting.eventName,
                                                style: t3White().copyWith(
                                                  fontSize: 20.sp,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                textAlign: TextAlign.start,
                                              ),
                                              Text(
                                                meeting.userName
                                                    .split(" ")
                                                    .first,
                                                style: hintTextStyle().copyWith(
                                                  color: Colors.white,
                                                ),
                                                maxLines: 1,
                                                textAlign: TextAlign.start,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget filterContainer({
    required String text,

    required VoidCallback onPressed,
    Color textColor = Colors.white,
  }) {
    return Padding(
      padding: EdgeInsets.only(left: 7, right: 7),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
            color: AppColor.dropDownAlternativeColor.withAlpha(100),
            borderRadius: BorderRadius.circular(7.r),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 7.h, horizontal: 12.w),
            child: Text(
              text,
              style: t3White().copyWith(fontSize: 22.sp, color: textColor),
            ),
          ),
        ),
      ),
    );
  }

  Widget myDropDownButton() {
    return Padding(
      padding: EdgeInsets.only(left: 0, right: 7),
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.dropDownAlternativeColor.withAlpha(100),
          borderRadius: BorderRadius.circular(7.r),
        ),

        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            dropdownColor: AppColor.dropDownColor,
            borderRadius: BorderRadius.circular(15.r),
            value: selectedMember,

            hint: Text(
              "User",
              style: t3White().copyWith(fontSize: 22.sp, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
              weight: 15,
            ),

            isExpanded: false,
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 0),
            alignment: Alignment.center,
            items: userMembers.map((role) {
              return DropdownMenuItem<String>(
                value: role,
                alignment: Alignment.center,
                child: Text(
                  role.split(' ').first,
                  style: t3White().copyWith(
                    fontSize: 20.sp,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                selectedMember = value;
                if (selectedMember == "User") {
                  context.read<FetchTasksCubit>().getDateAndRoleForCalander();
                } else {
                  context.read<FetchTasksCubit>().getDateAndRoleForCalander(
                    name: selectedMember,
                  );
                }

                // keep UI value as is

                // Map for Firestore internally
                // String firestoreRole = value;
                // if (value == "Kid")
                //   firestoreRole = "Stakeholder";
                // else if (value == "Board")
                //   firestoreRole = "Board Member";

                // log("UI Role: $selectedRole, Firestore Role: $firestoreRole");
              });
            },
          ),
        ),
      ),
    );
  }

  void showMonthEventsDialog({
    required BuildContext context,
    required String monthYear,
    required VoidCallback onPrev,
    required VoidCallback onNext,
    required List<Map<String, String>> events,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        String currentMonth = monthYear;

        return StatefulBuilder(
          builder: (context, setState) {
            // 🔹 Parse "October 2025" → DateTime
            final selectedDate = DateFormat('MMMM yyyy').parse(currentMonth);
            final selectedMonth = selectedDate.month;
            final selectedYear = selectedDate.year;

            // 🔹 Filter events based on current month & year
            final filteredEvents = events.where((event) {
              try {
                final eventDate = DateFormat(
                  'dd/MM/yyyy',
                ).parse(event['date'] ?? '');
                return eventDate.month == selectedMonth &&
                    eventDate.year == selectedYear;
              } catch (e) {
                return false;
              }
            }).toList();

            return Dialog(
              backgroundColor: AppColor.dropDownAlternativeColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: SizedBox(
                height: 400,
                child: Column(
                  children: [
                    // Header with month and navigation arrows
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              onPrev();
                              setState(() {
                                currentMonth = _getPrevMonth(currentMonth);
                              });
                            },
                            icon: const Icon(Icons.arrow_left),
                          ),
                          Text(
                            currentMonth,
                            style: t3White().copyWith(fontSize: 22.sp),
                          ),
                          IconButton(
                            onPressed: () {
                              onNext();
                              setState(() {
                                currentMonth = _getNextMonth(currentMonth);
                              });
                            },
                            icon: const Icon(Icons.arrow_right),
                          ),
                        ],
                      ),
                    ),

                    Divider(color: AppColor.secondary, thickness: 1, height: 0),
                    const SizedBox(height: 8),

                    // Event list from BLoC
                    Expanded(
                      child: BlocBuilder<FetchTasksCubit, FetchTasksState>(
                        builder: (context, state) {
                          if (state.mergedList == null ||
                              state.mergedList!.isEmpty) {
                            return Center(
                              child: Text(
                                "No tasks or events",
                                style: hintTextStyle(),
                              ),
                            );
                          }

                          // 🔹 Merge BLoC data and static events
                          final allEvents = [
                            ...filteredEvents,
                            ...state.mergedList!.map(
                              (e) => {
                                'title': e.title ?? '',
                                'desc': e.description ?? '',
                                'date': e.date ?? '',
                                'time': e.time ?? '',
                              },
                            ),
                          ];

                          // 🔹 Filter again for current month
                          final displayEvents = allEvents.where((event) {
                            try {
                              final eventDate = DateFormat(
                                'dd/MM/yyyy',
                              ).parse(event['date']!);
                              return eventDate.month == selectedMonth &&
                                  eventDate.year == selectedYear;
                            } catch (e) {
                              return false;
                            }
                          }).toList();

                          if (displayEvents.isEmpty) {
                            return Center(
                              child: Text(
                                "No tasks or events this month",
                                style: hintTextStyle(),
                              ),
                            );
                          }

                          return ListView.builder(
                            itemCount: displayEvents.length,
                            itemBuilder: (context, index) {
                              final event = displayEvents[index];
                              return InkWell(
                                onTap: () {},
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // 🕓 Time
                                      SizedBox(
                                        width: 70,
                                        child: Text(
                                          event['time'] ?? '',
                                          style: hintTextStyle(),
                                        ),
                                      ),
                                      SizedBox(width: 20.w),

                                      // 📝 Title and description
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              event['title'] ?? '',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: t1heading().copyWith(
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              event['desc'] ?? '',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: hintTextStyle(),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Spacer(),
                                      Text(
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        event['date'] ?? '',
                                        style: hintTextStyle(),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _getNextMonth(String currentMonth) {
    final date = DateFormat('MMMM yyyy').parse(currentMonth);
    final newDate = DateTime(date.year, date.month + 1);
    return DateFormat('MMMM yyyy').format(newDate);
  }

  String _getPrevMonth(String currentMonth) {
    final date = DateFormat('MMMM yyyy').parse(currentMonth);
    final newDate = DateTime(date.year, date.month - 1);
    return DateFormat('MMMM yyyy').format(newDate);
  }
}

// ----------------- DAY EVENTS -----------------
// void showDayEventsDialog({
//   required BuildContext context,
//   required DateTime selectedDate,
//   required List<Map<String, String>> events,
// }) {
//   showDialog(
//     context: context,
//     builder: (context) {
//       return Dialog(
//         backgroundColor: AppColor.dropDownAlternativeColor,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         child: SizedBox(
//           height: 400,
//           child: Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 12,
//                   vertical: 12,
//                 ),
//                 child: Text(
//                   DateFormat('EEEE, MMM d, yyyy').format(selectedDate),
//                   style: t3White().copyWith(fontSize: 20.sp),
//                 ),
//               ),
//               Divider(color: AppColor.secondary, thickness: 1),
//               Expanded(
//                 child: _buildFilteredEventList(
//                   events,
//                   (eventDate) =>
//                       eventDate.day == selectedDate.day &&
//                       eventDate.month == selectedDate.month &&
//                       eventDate.year == selectedDate.year,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     },
//   );
// }

// Widget _buildFilteredEventList(
//   List<Map<String, String>> events,
//   bool Function(DateTime) filter,
// ) {
//   final displayEvents = events.where((event) {
//     try {
//       final date = DateFormat('dd/MM/yyyy').parse(event['date'] ?? '');
//       return filter(date);
//     } catch (e) {
//       return false;
//     }
//   }).toList();

//   if (displayEvents.isEmpty) {
//     return Center(child: Text("No tasks or events", style: hintTextStyle()));
//   }

//   return ListView.builder(
//     itemCount: displayEvents.length,
//     itemBuilder: (context, index) {
//       final event = displayEvents[index];
//       return Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(
//               width: 70,
//               child: Text(event['time'] ?? '', style: hintTextStyle()),
//             ),
//             SizedBox(width: 20.w),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     event['title'] ?? '',
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: t1heading().copyWith(fontSize: 16),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     event['desc'] ?? '',
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: hintTextStyle(),
//                   ),
//                 ],
//               ),
//             ),
//             Spacer(),
//             Text(
//               event['date'] ?? '',
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               style: hintTextStyle(),
//             ),
//           ],
//         ),
//       );
//     },
//   );
// }
void showDayEventsDialog({
  required BuildContext context,
  required DateTime initialDate,
}) {
  DateTime selectedDate = initialDate;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: AppColor.dropDownAlternativeColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: SizedBox(
              height: 450,
              child: Column(
                children: [
                  // Header with prev/next buttons and date
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              selectedDate = selectedDate.subtract(
                                const Duration(days: 1),
                              );
                            });
                          },
                          icon: const Icon(Icons.arrow_left),
                        ),
                        Text(
                          DateFormat('EEEE, MMM d, yyyy').format(selectedDate),
                          style: t3White().copyWith(fontSize: 20.sp),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              selectedDate = selectedDate.add(
                                const Duration(days: 1),
                              );
                            });
                          },
                          icon: const Icon(Icons.arrow_right),
                        ),
                      ],
                    ),
                  ),

                  Divider(color: AppColor.secondary, thickness: 1),
                  const SizedBox(height: 8),

                  // Event list from BLoC
                  Expanded(
                    child: BlocBuilder<FetchTasksCubit, FetchTasksState>(
                      builder: (context, state) {
                        if (state.mergedList == null ||
                            state.mergedList!.isEmpty) {
                          return Center(
                            child: Text(
                              "No tasks or events",
                              style: hintTextStyle(),
                            ),
                          );
                        }

                        // Merge BLoC events into a list of maps
                        final allEvents = state.mergedList!.map((e) {
                          return {
                            'title': e.title ?? '',
                            'desc': e.description ?? '',
                            'date': e.date ?? '',
                            'time': e.time ?? '',
                          };
                        }).toList();

                        // Filter events for the selected day
                        final displayEvents = allEvents.where((event) {
                          try {
                            final eventDate = DateFormat(
                              'dd/MM/yyyy',
                            ).parse(event['date'] ?? '');
                            return eventDate.day == selectedDate.day &&
                                eventDate.month == selectedDate.month &&
                                eventDate.year == selectedDate.year;
                          } catch (e) {
                            return false;
                          }
                        }).toList();

                        if (displayEvents.isEmpty) {
                          return Center(
                            child: Text(
                              "No tasks or events for this day",
                              style: hintTextStyle(),
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: displayEvents.length,
                          itemBuilder: (context, index) {
                            final event = displayEvents[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 70,
                                    child: Text(
                                      event['time'] ?? '',
                                      style: hintTextStyle(),
                                    ),
                                  ),
                                  SizedBox(width: 20.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          event['title'] ?? '',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: t1heading().copyWith(
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          event['desc'] ?? '',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: hintTextStyle(),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    event['date'] ?? '',
                                    style: hintTextStyle(),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

void showWeekEventsDialog({
  required BuildContext context,
  required DateTime initialDate,
}) {
  // initialDate can be any date in the week
  DateTime selectedDate = initialDate;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          // Calculate start (Monday) and end (Sunday) of the week
          final weekStart = selectedDate.subtract(
            Duration(days: selectedDate.weekday - 1),
          );
          final weekEnd = weekStart.add(const Duration(days: 6));

          // Format header like "Oct 12 - Oct 18, 2025"
          final headerText =
              '${DateFormat('MMM d').format(weekStart)} - ${DateFormat('d, yyyy').format(weekEnd)}';

          return Dialog(
            backgroundColor: AppColor.dropDownAlternativeColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: SizedBox(
              height: 450,
              child: Column(
                children: [
                  // Header with prev/next buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              selectedDate = selectedDate.subtract(
                                const Duration(days: 7),
                              );
                            });
                          },
                          icon: const Icon(Icons.arrow_left),
                        ),
                        Text(
                          headerText,
                          style: t3White().copyWith(fontSize: 20.sp),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              selectedDate = selectedDate.add(
                                const Duration(days: 7),
                              );
                            });
                          },
                          icon: const Icon(Icons.arrow_right),
                        ),
                      ],
                    ),
                  ),

                  Divider(color: AppColor.secondary, thickness: 1),
                  const SizedBox(height: 8),

                  // Event list from BLoC
                  Expanded(
                    child: BlocBuilder<FetchTasksCubit, FetchTasksState>(
                      builder: (context, state) {
                        if (state.mergedList == null ||
                            state.mergedList!.isEmpty) {
                          return Center(
                            child: Text(
                              "No tasks or events",
                              style: hintTextStyle(),
                            ),
                          );
                        }

                        // Convert BLoC events to a standard map
                        final allEvents = state.mergedList!.map((e) {
                          return {
                            'title': e.title ?? '',
                            'desc': e.description ?? '',
                            'date': e.date ?? '',
                            'time': e.time ?? '',
                          };
                        }).toList();

                        // Filter events in the week
                        final displayEvents = allEvents.where((event) {
                          try {
                            final eventDate = DateFormat(
                              'dd/MM/yyyy',
                            ).parse(event['date'] ?? '');
                            return eventDate.isAfter(
                                  weekStart.subtract(const Duration(days: 1)),
                                ) &&
                                eventDate.isBefore(
                                  weekEnd.add(const Duration(days: 1)),
                                );
                          } catch (e) {
                            return false;
                          }
                        }).toList();

                        if (displayEvents.isEmpty) {
                          return Center(
                            child: Text(
                              "No tasks or events this week",
                              style: hintTextStyle(),
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: displayEvents.length,
                          itemBuilder: (context, index) {
                            final event = displayEvents[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 70,
                                    child: Text(
                                      event['time'] ?? '',
                                      style: hintTextStyle(),
                                    ),
                                  ),
                                  SizedBox(width: 20.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          event['title'] ?? '',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: t1heading().copyWith(
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          event['desc'] ?? '',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: hintTextStyle(),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    event['date'] ?? '',
                                    style: hintTextStyle(),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

class Meeting {
  Meeting({
    required this.eventName,
    required this.from,
    required this.to,
    required this.userName,
    required this.imagePath,
    this.role,
    this.description,
    this.date,
  });

  String eventName;
  DateTime from;
  DateTime to;
  String userName;
  String imagePath;
  String? role;
  String? description;
  String? date;
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) => appointments![index].from;

  @override
  DateTime getEndTime(int index) => appointments![index].to;

  @override
  String getSubject(int index) => appointments![index].eventName;
}
