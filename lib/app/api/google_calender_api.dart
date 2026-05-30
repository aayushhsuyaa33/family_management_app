import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

/// Helper class to save tasks in Google Calendar
class GoogleCalendarHelper {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [calendar.CalendarApi.calendarScope],
  );

  /// Call this to save a task
  Future<void> saveTask({
    required BuildContext context,
    required String title,
    required String description,
    required DateTime startDate,
    DateTime? endDate,
  }) async {
    try {
      log("entiring try catch blcok");
      // Sign in user if needed
      GoogleSignInAccount? user = await _googleSignIn.signInSilently();
      user ??= await _googleSignIn.signIn();
      if (user == null) throw Exception("Google Sign-In failed");

      final auth = await user.authentication;

      // Create an authenticated client using accessToken only
      final client = authenticatedClient(
        http.Client(),
        AccessCredentials(
          AccessToken(
            'Bearer',
            auth.accessToken!,
            DateTime.now().toUtc().add(const Duration(hours: 1)),
          ),
          auth.idToken,
          [calendar.CalendarApi.calendarScope],
        ),
      );

      final calendarApi = calendar.CalendarApi(client);

      // Create event
      final event = calendar.Event(
        summary: title,
        description: description,
        start: calendar.EventDateTime(dateTime: startDate.toUtc()),
        end: calendar.EventDateTime(
          dateTime: (endDate ?? startDate.add(const Duration(hours: 1)))
              .toUtc(),
        ),
      );

      await calendarApi.events.insert(event, "primary");

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Task saved to Google Calendar")),
        );
      }
    } catch (e) {
      log("❌ Error saving task to Google Calendar: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("❌ Failed: $e")));
      }
    }
  }
}
