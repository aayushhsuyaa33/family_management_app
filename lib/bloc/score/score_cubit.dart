import 'dart:async';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:family_management_app/screens/more_options/score_screen.dart';
import 'package:family_management_app/service/secure_storage.dart';

part 'score_state.dart';

class ScoreCubit extends Cubit<ScoreState> {
  ScoreCubit()
    : super(
        ScoreState(
          status: ScoreStatus.initial,
          overallScoreStatus: ScoreStatus.initial,
          loadSplitStatus: ScoreStatus.initial,
        ),
      );

  Future<void> fetchScores() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final String boardId = await AppStorage.read(key: 'boardId') ?? "";

    emit(state.copyWith(status: ScoreStatus.loading));

    try {
      final QuerySnapshot<Map<String, dynamic>> members = await firestore
          .collection('board')
          .doc(boardId)
          .collection('joinRequests')
          .get();

      final QuerySnapshot<Map<String, dynamic>> childSnapshot = await firestore
          .collection('children')
          .doc(boardId)
          .collection('child')
          .get();

      final QuerySnapshot<Map<String, dynamic>> taskSnapshot = await firestore
          .collection('tasks')
          .doc(boardId)
          .collection('allTasks')
          .get();

      final QuerySnapshot<Map<String, dynamic>> eventSnapshot = await firestore
          .collection('events')
          .doc(boardId)
          .collection('allEvents')
          .get();

      final allPeople = [
        ...members.docs.map((doc) => doc.data()['name']),
        ...childSnapshot.docs.map((doc) => doc.data()['name']),
      ].toList();

      log("ℹ️ Total members found: ${allPeople.length}");
      final List<MyMember> combinedMembers = [];

      for (final personName in allPeople) {
        // Tasks belonging to this person
        final personTasks = taskSnapshot.docs.where(
          (doc) => doc.data()['assignedMember'] == personName,
        );

        final personEvents = eventSnapshot.docs.where(
          (doc) => doc.data()['assignedMember'] == personName,
        );

        final totalTasks = personTasks.length + personEvents.length;

        final completedTasks =
            personTasks
                .where((doc) => doc.data()['status'] == "completed")
                .length +
            personEvents
                .where((doc) => doc.data()['status'] == "completed")
                .length;

        final role = members.docs.any((doc) => doc.data()['name'] == personName)
            ? members.docs
                      .firstWhere((doc) => doc.data()['name'] == personName)
                      .data()['role'] ??
                  'Member'
            : 'Stakeholder';

        final mentalScore = totalTasks == 0
            ? 0.0
            : (completedTasks / totalTasks).clamp(0.0, 1.0);

        combinedMembers.add(
          MyMember(
            name: personName,
            role: role,
            totalTasks: totalTasks,
            completedTasks: completedTasks,
            mentalScore: mentalScore,
          ),
        );
      }
      combinedMembers.sort((a, b) => a.name.compareTo(b.name));
      emit(
        state.copyWith(
          status: ScoreStatus.success,
          scoreList: combinedMembers,
          errorMessage: "All good",
        ),
      );
      log("✅ Total combined members: ${combinedMembers.length}");
    } catch (exe) {
      emit(
        state.copyWith(
          status: ScoreStatus.failure,
          errorMessage: exe.toString(),
        ),
      );
    }
  }

  Future<void> fetchOverallScore() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final String boardId = await AppStorage.read(key: "boardId") ?? "";
    emit(state.copyWith(overallScoreStatus: ScoreStatus.loading));
    try {
      firestore
          .collection('tasks')
          .doc(boardId)
          .collection('allTasks')
          .snapshots()
          .listen((taskSnapshot) {
            firestore
                .collection('events')
                .doc(boardId)
                .collection('allEvents')
                .snapshots()
                .listen((eventSnapshot) {
                  final int completedTasks =
                      taskSnapshot.docs
                          .where((doc) => doc.data()['status'] == "completed")
                          .length +
                      eventSnapshot.docs
                          .where((doc) => doc.data()['status'] == 'completed')
                          .length;

                  final int totalTasks =
                      taskSnapshot.docs.length + eventSnapshot.docs.length;

                  // final householdPercent = (completedTasks / totalTasks) * 100;

                  calculatePercent(totalTasks, completedTasks);

                  emit(
                    state.copyWith(
                      overallScoreStatus: ScoreStatus.success,
                      houseHoldPercent: calculatePercent(
                        completedTasks,
                        totalTasks,
                      ),
                    ),
                  );
                });
          });
    } catch (exe) {
      emit(
        state.copyWith(
          overallScoreStatus: ScoreStatus.failure,
          errorMessage: exe.toString(),
        ),
      );
    }
  }

  double calculatePercent(int completedTasks, int totalTasks) {
    if (totalTasks == 0) return 0;
    return (completedTasks / totalTasks) * 100;
  }

  Future<void> fetchLoadSplitTasks() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final String boardId = await AppStorage.read(key: "boardId") ?? "";
    emit(state.copyWith(loadSplitStatus: ScoreStatus.loading));

    try {
      // Listen to tasks collection
      firestore
          .collection('tasks')
          .doc(boardId)
          .collection('allTasks')
          .snapshots()
          .listen((taskSnapshot) {
            // Listen to events collection
            firestore
                .collection('events')
                .doc(boardId)
                .collection('allEvents')
                .snapshots()
                .listen((eventSnapshot) {
                  final Map<String, int> roleTaskCount = {};

                  for (var doc in taskSnapshot.docs) {
                    final role = doc.data()['assignedRole'] as String?;
                    if (role != null && role.isNotEmpty && role != "Chief") {
                      roleTaskCount[role] = (roleTaskCount[role] ?? 0) + 1;
                    }
                  }

                  // Count events per role
                  for (var doc in eventSnapshot.docs) {
                    final role = doc.data()['assignedRole'] as String?;
                    if (role != null && role.isNotEmpty && role != "Chief") {
                      roleTaskCount[role] = (roleTaskCount[role] ?? 0) + 1;
                    }
                  }

                  final completedTasks = [
                    ...taskSnapshot.docs.where(
                      (doc) => doc.data()['status'] == 'completed',
                    ),
                    ...eventSnapshot.docs.where(
                      (doc) => doc.data()['status'] == 'completed',
                    ),
                  ].length;

                  final pendingTasks = [
                    ...taskSnapshot.docs.where(
                      (doc) => doc.data()['status'] == 'pending',
                    ),
                    ...eventSnapshot.docs.where(
                      (doc) => doc.data()['status'] == 'pending',
                    ),
                  ].length;

                  final totalTasks = roleTaskCount.values.fold<int>(
                    0,
                    (sum, count) => sum + count,
                  );

                  final completionRate = totalTasks > 0
                      ? (completedTasks / totalTasks) * 100
                      : 0.0;

                  final pendingRate = totalTasks > 0
                      ? (pendingTasks / totalTasks) * 100
                      : 0.0;

                  final roleSplitList = roleTaskCount.entries.map((entry) {
                    final role = entry.key;
                    final tasks = entry.value;
                    final percentage = totalTasks > 0
                        ? (tasks / totalTasks) * 100
                        : 0.0;

                    return {
                      'role': role,
                      'tasks': tasks,
                      'percentage': percentage,
                    };
                  }).toList();

                  emit(
                    state.copyWith(
                      loadSplitStatus: ScoreStatus.success,
                      loadSplitList: roleSplitList,
                      completedTask: completionRate,
                      pendingTask: pendingRate,
                    ),
                  );
                });
          });
    } catch (e) {
      emit(
        state.copyWith(
          loadSplitStatus: ScoreStatus.failure,
          errorMessage: 'Fetching Failed: $e',
        ),
      );
    }
  }

  Future<int> getThisWeekCount(String boardId) async {
    final firestore = FirebaseFirestore.instance;

    DateTime now = DateTime.now();

    // Start of this week (Monday)
    DateTime startOfThisWeek = now.subtract(Duration(days: now.weekday - 1));

    // Start + end of last week
    // DateTime startOfLastWeek = startOfThisWeek.subtract(Duration(days: 7));
    // DateTime endOfLastWeek = startOfThisWeek;

    // tasks
    final taskSnap = await firestore
        .collection('tasks')
        .doc(boardId)
        .collection('allTasks')
        .where('status', isEqualTo: 'completed')
        .where('completedAt', isGreaterThanOrEqualTo: startOfThisWeek)
        .get();

    final eventSnap = await firestore
        .collection('events')
        .doc(boardId)
        .collection('allEvents')
        .where('status', isEqualTo: 'completed')
        .where('completedAt', isGreaterThanOrEqualTo: startOfThisWeek)
        .get();

    return taskSnap.docs.length + eventSnap.docs.length;
  }

  Future<int> getLastWeekCount(String boardId) async {
    final firestore = FirebaseFirestore.instance;

    DateTime now = DateTime.now();

    // Start of this week (Monday)
    DateTime startOfThisWeek = now.subtract(Duration(days: now.weekday - 1));

    // Start + end of last week
    DateTime startOfLastWeek = startOfThisWeek.subtract(Duration(days: 7));
    DateTime endOfLastWeek = startOfThisWeek;

    final taskSnap = await firestore
        .collection('tasks')
        .doc(boardId)
        .collection('allTasks')
        .where('status', isEqualTo: 'completed')
        .where('completedAt', isGreaterThanOrEqualTo: startOfLastWeek)
        .where('completedAt', isLessThan: endOfLastWeek)
        .get();

    final eventSnap = await firestore
        .collection('events')
        .doc(boardId)
        .collection('allEvents')
        .where('status', isEqualTo: 'completed')
        .where('completedAt', isGreaterThanOrEqualTo: startOfLastWeek)
        .where('completedAt', isLessThan: endOfLastWeek)
        .get();

    return taskSnap.docs.length + eventSnap.docs.length;
  }

  Future<void> fetchWeeklyTrend() async {
    final String boardId = await AppStorage.read(key: "boardId") ?? "";
    emit(state.copyWith(weeklyTrendStatus: ScoreStatus.loading));

    try {
      int thisWeek = await getThisWeekCount(boardId);
      int lastWeek = await getLastWeekCount(boardId);

      double percentChange = lastWeek == 0
          ? 100
          : ((thisWeek - lastWeek) / lastWeek) * 100;

      bool isUpTrend = thisWeek >= lastWeek;

      emit(
        state.copyWith(
          weeklyTrendStatus: ScoreStatus.success,
          thisWeekCount: thisWeek,
          lastWeekCount: lastWeek,
          weeklyTrendPercent: percentChange,
          isUpTrend: isUpTrend,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          weeklyTrendStatus: ScoreStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
