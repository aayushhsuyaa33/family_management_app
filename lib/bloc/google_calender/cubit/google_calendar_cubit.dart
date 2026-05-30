import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:family_management_app/service/secure_storage.dart';
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
part 'google_calendar_state.dart';

class GoogleCalendarCubit extends Cubit<GoogleCalendarState> {
  GoogleCalendarCubit()
    : super(
        GoogleCalendarState(
          addStatus: GoogleCalendarStatus.initial,
          deleteStatus: GoogleCalendarStatus.initial,
        ),
      );

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/calendar',
      'https://www.googleapis.com/auth/calendar.events',
    ],
  );

  /// 🔹 Save a task to Google Calendar
  Future<void> saveTask({
    required String title,
    required String description,
    required DateTime startDate,
    DateTime? endDate,
    required String taskId,
  }) async {
    final firebaseFirestore = FirebaseFirestore.instance;
    final String boardId = await AppStorage.read(key: 'boardId') ?? "";
    final String expectedEmail = await AppStorage.read(key: 'email') ?? "";
    log("🔍 Expected email: $expectedEmail");

    emit(state.copyWith(addStatus: GoogleCalendarStatus.loading));

    try {
      log("➡️ Attempting to save task to Google Calendar");

      // Try silent sign-in first
      GoogleSignInAccount? user = await _googleSignIn.signInSilently();

      // If user is null, prompt for manual sign-in
      user ??= await _googleSignIn.signIn();

      // If still null, throw error
      if (user == null) throw Exception("Google Sign-In failed");

      log("👤 Signed in as: ${user.email}");

      // Check if signed-in account matches expected account
      if (user.email.trim() != expectedEmail.trim()) {
        log("⚠️ Wrong account: ${user.email}");

        // Disconnect wrong account so next attempt re-prompts the user
        await _googleSignIn.disconnect();

        emit(
          state.copyWith(
            addStatus: GoogleCalendarStatus.failure,
            error: "Only the linked account ($expectedEmail) can be used.",
          ),
        );

        // Reset state after short delay
        Future.delayed(const Duration(milliseconds: 800), () {
          emit(state.copyWith(addStatus: GoogleCalendarStatus.initial));
        });
        return;
      }

      // ✅ Account matches — continue saving event
      final auth = await user.authentication;

      final client = authenticatedClient(
        http.Client(),
        AccessCredentials(
          AccessToken(
            'Bearer',
            auth.accessToken!,
            DateTime.now().toUtc().add(const Duration(hours: 1)),
          ),
          auth.idToken,
          [
            'https://www.googleapis.com/auth/calendar',
            'https://www.googleapis.com/auth/calendar.events',
          ],
        ),
      );

      final calendarApi = calendar.CalendarApi(client);

      final event = calendar.Event(
        summary: title,
        description: description,
        start: calendar.EventDateTime(dateTime: startDate.toUtc()),
        end: calendar.EventDateTime(
          dateTime: (endDate ?? startDate.add(const Duration(hours: 1)))
              .toUtc(),
        ),
      );

      final insertedEvent = await calendarApi.events.insert(event, "primary");
      log("✅ Task saved to Google Calendar: ${insertedEvent.id}");

      final updateData = {
        "isGoogleCal": true,
        "googleEventId": insertedEvent.id,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final taskRef = firebaseFirestore
          .collection('tasks')
          .doc(boardId)
          .collection('allTasks')
          .doc(taskId);

      final eventRef = firebaseFirestore
          .collection('events')
          .doc(boardId)
          .collection('allEvents')
          .doc(taskId);

      Future<void> safeUpdate(DocumentReference ref) async {
        final doc = await ref.get();
        if (doc.exists) {
          await ref.update(updateData);
          log("✅ Updated: ${ref.path}");
        } else {
          log("⚠️ Skipped missing document: ${ref.path}");
        }
      }

      await safeUpdate(taskRef);
      await safeUpdate(eventRef);

      // await firebaseFirestore
      //     .collection('tasks')
      //     .doc(boardId)
      //     .collection('allTasks')
      //     .doc(taskId)
      //     .update({
      //       "isGoogleCal": true,
      //       "googleEventId": insertedEvent.id,
      //       'updatedAt': FieldValue.serverTimestamp(),
      //     });

      // await firebaseFirestore
      //     .collection('events')
      //     .doc(boardId)
      //     .collection('allEvents')
      //     .doc(taskId)
      //     .update({
      //       "isGoogleCal": true,
      //       "googleEventId": insertedEvent.id,
      //       'updatedAt': FieldValue.serverTimestamp(),
      //     });

      emit(
        state.copyWith(
          addStatus: GoogleCalendarStatus.success,
          error: "✅ Task successfully added to Google Calendar.",
        ),
      );

      Future.delayed(const Duration(milliseconds: 800), () {
        emit(state.copyWith(addStatus: GoogleCalendarStatus.initial));
      });
    } catch (e) {
      log("❌ Error saving task to Google Calendar: $e");

      emit(
        state.copyWith(
          addStatus: GoogleCalendarStatus.failure,
          error: e.toString(),
        ),
      );

      Future.delayed(const Duration(milliseconds: 800), () {
        emit(state.copyWith(addStatus: GoogleCalendarStatus.initial));
      });
    }
  }

  /// 🔹 Remove a task from Google Calendar
  Future<void> removeTaskFromGoogleCalendar({required String taskId}) async {
    final firebaseFirestore = FirebaseFirestore.instance;
    final String boardId = await AppStorage.read(key: "boardId") ?? "";

    try {
      // Emit loading state
      emit(
        state.copyWith(
          deleteStatus: GoogleCalendarStatus.loading,
          error: "🗑️ Attempting to remove task from Google Calendar",
        ),
      );
      log("🗑️ Attempting to remove task from Google Calendar");

      // Sign in silently
      GoogleSignInAccount? user = await _googleSignIn.signInSilently();
      if (user == null) throw Exception("User not signed in");

      final auth = await user.authentication;

      // Create authenticated client
      final client = authenticatedClient(
        http.Client(),
        AccessCredentials(
          AccessToken(
            'Bearer',
            auth.accessToken!,
            DateTime.now().toUtc().add(const Duration(hours: 1)),
          ),
          auth.idToken,
          [
            'https://www.googleapis.com/auth/calendar',
            'https://www.googleapis.com/auth/calendar.events',
          ],
        ),
      );

      final calendarApi = calendar.CalendarApi(client);

      // Firestore document references
      final taskRef = firebaseFirestore
          .collection('tasks')
          .doc(boardId)
          .collection('allTasks')
          .doc(taskId);

      final eventRef = firebaseFirestore
          .collection('events')
          .doc(boardId)
          .collection('allEvents')
          .doc(taskId);

      // Data to update Firestore
      final updateData = {
        'isGoogleCal': false,
        'googleEventId': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Safe delete helper
      Future<void> safeDelete(DocumentReference ref) async {
        final doc = await ref.get();

        if (!doc.exists) {
          log("⚠️ Skipped missing document: ${ref.path}");
          return;
        }

        final data = doc.data() as Map<String, dynamic>?;

        if (data == null || !data.containsKey('googleEventId')) {
          log("⚠️ No Google event ID found for document: ${ref.path}");
          return;
        }

        final String? eventId = data['googleEventId'] as String?;
        if (eventId == null || eventId.isEmpty) {
          log("⚠️ Google event ID is empty for document: ${ref.path}");
          return;
        }

        try {
          // Delete from Google Calendar
          await calendarApi.events.delete('primary', eventId);
          log("✅ Google Calendar event deleted: $eventId");

          // Update Firestore
          await ref.update(updateData);
          log("✅ Firestore updated: ${ref.path}");
        } catch (e) {
          log("❌ Failed to delete Google Calendar event for ${ref.path}: $e");
        }
      }

      // Delete from both tasks and events
      await safeDelete(taskRef);
      await safeDelete(eventRef);

      // Emit success state
      emit(
        state.copyWith(
          deleteStatus: GoogleCalendarStatus.success,
          error: "✅ Task deleted from Google Calendar",
        ),
      );

      Future.delayed(const Duration(milliseconds: 500), () {
        emit(state.copyWith(deleteStatus: GoogleCalendarStatus.initial));
      });
    } catch (e) {
      log("❌ Error removing task from Google Calendar: $e");
      emit(
        state.copyWith(
          deleteStatus: GoogleCalendarStatus.failure,
          error: e.toString(),
        ),
      );
      Future.delayed(const Duration(milliseconds: 500), () {
        emit(state.copyWith(deleteStatus: GoogleCalendarStatus.initial));
      });
    }
  }
}
