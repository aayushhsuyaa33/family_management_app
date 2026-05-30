import 'package:flutter/material.dart';

Future<DateTime?> calenderPicker(
  BuildContext context, {
  DateTime? selectedDate,
  int? lastDate,
  bool isToday = false,
}) async {
  return await showDatePicker(
    context: context,
    initialDate: selectedDate ?? DateTime.now(),
    firstDate: isToday ? DateTime.now() : DateTime(2000),
    lastDate: lastDate != null ? DateTime(lastDate) : DateTime.now(),
    barrierColor: Colors.black.withAlpha(70), // dark overlay
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: Theme.of(context).copyWith(
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.white), // input text color
            bodyMedium: TextStyle(color: Colors.white), // hint/label color
          ),
          inputDecorationTheme: const InputDecorationTheme(
            hintStyle: TextStyle(color: Colors.white),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.green),
            ),
          ),
          colorScheme: const ColorScheme.dark(
            primary: Colors.green, // selected date & header background
            onPrimary: Colors.white, // header text & selected date text
            surface: Color(0xFF0A1C34), // calendar background
            onSurface: Colors.white, // default text color
          ),
          dialogBackgroundColor: const Color(0xFF0A1C34), // dialog background
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
}

Future<TimeOfDay?> timePicker(
  BuildContext context, {
  TimeOfDay? selectedTime,
}) async {
  return showTimePicker(
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
}
