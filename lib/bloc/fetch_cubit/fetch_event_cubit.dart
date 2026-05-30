import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:family_management_app/service/secure_storage.dart';
part 'fetch_event_state.dart';

class FetchEventCubit extends Cubit<FetchEventState> {
  FetchEventCubit()
    : super(FetchEventState(status: FetchKidsStatus.initialFetching));

  Future<void> fetchRecentEvent() async {
    final String boardId = await AppStorage.read(key: 'boardId') ?? "";
    final FirebaseFirestore fireStore = FirebaseFirestore.instance;
    emit(state.copyWith(status: FetchKidsStatus.fetching));
    try {
      // log("asdsadasdasdsdda");
      final now = DateTime.now();

      final childDocs = await fireStore
          .collection('children')
          .doc(boardId)
          .collection('child')
          .get();

      final kidsList = childDocs.docs.map((doc) {
        final data = doc.data();
        return KidsInfo(
          kidName: data['name'] ?? "",
          kidAge: data['age'] ?? "",
          uid: data['uid'] ?? "",
        );
      }).toList();

      List<KidsInfo> updatedKids = [];

      for (var kid in kidsList) {
        final eventSnap = await fireStore
            .collection('events')
            .doc(boardId)
            .collection('allEvents')
            .where('uid', isEqualTo: kid.uid)
            .get();
        log("uiddd${kid.uid}, ${kid.kidAge}");

        final events = eventSnap.docs.map((doc) {
          final data = doc.data();
          final title = data['title'] ?? "";
          final dateStr = data['date'] ?? ""; // "09/09/2025"
          final dateParts = dateStr.split('/'); // ["09","09","2025"]
          final date = DateTime(
            int.parse(dateParts[2]),
            int.parse(dateParts[1]),
            int.parse(dateParts[0]),
          );
          return {'title': title, 'date': date};
        }).toList();

        final nextEvents = events.where((e) => e['date'].isAfter(now)).toList()
          ..sort((a, b) => a['date'].compareTo(b['date'])); // ascending

        final recentEvents =
            events.where((e) => e['date'].isBefore(now)).toList()
              ..sort((a, b) => b['date'].compareTo(a['date'])); // descending

        final nextEventTitle = nextEvents.isNotEmpty
            ? nextEvents.first['title']
            : "No upcoming event";

        log(nextEventTitle);
        final recentEventTitle = recentEvents.isNotEmpty
            ? recentEvents.first['title']
            : "No recent activity";

        updatedKids.add(
          kid.copyWith(
            kidNextEvent: nextEventTitle,
            kidRecentEvent: recentEventTitle,
          ),
        );
      }

      final eventSnap = await fireStore
          .collection('events')
          .doc(boardId)
          .collection('allEvents')
          .get();

      final allEvents = eventSnap.docs.map((doc) {
        final data = doc.data();
        final title = data['title'] ?? "";
        final kidName = data['assignedMember'] ?? "";
        final dateStr = data['date'] ?? ""; // "dd/MM/yyyy"
        final dateParts = dateStr.split('/');
        final date = DateTime(
          int.parse(dateParts[2]),
          int.parse(dateParts[1]),
          int.parse(dateParts[0]),
        );
        return {'title': title, 'kidName': kidName, 'date': date};
      }).toList();

      final globalUpcoming =
          allEvents.where((e) => e['date'].isAfter(now)).toList()
            ..sort((a, b) => a['date'].compareTo(b['date']));

      log(globalUpcoming.toString());
      emit(
        state.copyWith(
          status: FetchKidsStatus.fetched,
          kidsInfo: updatedKids,
          globalUpcomingEvents: globalUpcoming,
        ),
      );
    } on FirebaseException catch (exe) {
      emit(
        state.copyWith(
          status: FetchKidsStatus.fetchingError,
          errorMsg: exe.code,
        ),
      );
    }
  }
}
