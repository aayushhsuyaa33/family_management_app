import 'dart:async';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:family_management_app/app/api/api_routes.dart';
import 'package:family_management_app/service/secure_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'fetch_tasks_state.dart';

class FetchTasksCubit extends Cubit<FetchTasksState> {
  FetchTasksCubit()
    : super(
        FetchTasksState(
          fetchPendingTaskForHomPageStatus: FetchTaskStatus.initial,
          fetchPendingEventForHomPageStatus: FetchTaskStatus.initial,
          fetchTasksStatus: FetchTaskStatus.initial,
          deleteTaskStatus: FetchTaskStatus.initial,
          markAsDoneStatus: FetchTaskStatus.initial,
          getDateAndRoleForCalanderStatus: FetchTaskStatus.initial,
          getDateAndTimeForChildScheduleStatus: FetchTaskStatus.initial,
          fetchtaskInfo: FetchTaskStatus.initial,
        ),
      );
  StreamSubscription? taskSubscription;
  StreamSubscription? eventSubscription;

  Future<void> fetchPendingTaskForHomPage() async {
    final firestore = FirebaseFirestore.instance;

    emit(
      state.copyWith(
        fetchPendingTaskForHomPageStatus: FetchTaskStatus.loading,
        errorMsg: "Tasks are being fetched... Please wait",
      ),
    );

    try {
      final currentRole = await AppStorage.read(key: "savedRole") ?? "";
      final email = await AppStorage.read(key: "email") ?? "";
      final String boardId = await AppStorage.read(key: "boardId") ?? "";

      // Cancel any previous subscription
      taskSubscription?.cancel();

      // -------------------------
      // Base query for pending tasks
      // -------------------------
      Query<Map<String, dynamic>> taskQuery = firestore
          .collection('tasks')
          .doc(boardId)
          .collection('allTasks')
          .where("status", isEqualTo: "pending");

      if (currentRole != "Chief") {
        taskQuery = taskQuery.where("email", isEqualTo: email);
      }

      taskSubscription = taskQuery.snapshots().listen((snapshot) {
        // Total pending tasks
        final pendingCount = snapshot.docs.length;

        // Count urgent tasks (priority == "High")
        final urgentCount = snapshot.docs
            .where((doc) => doc.data()['priority'] == 'High')
            .length;

        emit(
          state.copyWith(
            fetchPendingTaskForHomPageStatus: FetchTaskStatus.sucess,
            taskCount: pendingCount,
            urgentCount: urgentCount,
          ),
        );
      });

      // -------------------------
      // One-time fetch for urgent tasks
      // -------------------------
    } on FirebaseException catch (e) {
      emit(
        state.copyWith(
          fetchPendingTaskForHomPageStatus: FetchTaskStatus.failed,
          errorMsg: e.message ?? "Firestore error occurred",
        ),
      );
      log("🔥 Firestore error in fetchTasks: ${e.message}");
    }
  }

  Future<void> fetchPendingEventForHomPage() async {
    final firestore = FirebaseFirestore.instance;

    emit(
      state.copyWith(
        fetchPendingEventForHomPageStatus: FetchTaskStatus.loading,
        errorMsg: "Events are being fetched... Please wait",
      ),
    );

    try {
      final currentRole = await AppStorage.read(key: "savedRole") ?? "";
      final email = await AppStorage.read(key: "email") ?? "";
      final boardId = await AppStorage.read(key: "boardId") ?? "";

      // Cancel any previous subscription
      eventSubscription?.cancel();

      final today = DateTime.now();
      final todayDateOnly = DateTime(today.year, today.month, today.day);

      final eventsCollection = firestore
          .collection('events')
          .doc(boardId)
          .collection('allEvents');

      // -------------------------
      // Reactive subscription to all pending tasks
      // -------------------------
      Query<Map<String, dynamic>> allPendingQuery = eventsCollection.where(
        'status',
        isEqualTo: 'pending',
      );

      if (currentRole != "Chief") {
        allPendingQuery = allPendingQuery.where('email', isEqualTo: email);
      }

      eventSubscription = allPendingQuery.snapshots().listen((snapshot) {
        int todayCount = 0;
        int futureCount = 0;
        int urgentCount = 0;

        for (var doc in snapshot.docs) {
          final data = doc.data();
          final dateString = (data['date'] ?? '').toString().trim();
          if (dateString.isEmpty) continue;

          final parts = dateString.split('/');
          if (parts.length != 3) continue;

          final taskDate = DateTime(
            int.parse(parts[2]), // year
            int.parse(parts[1]), // month
            int.parse(parts[0]), // day
          );

          // Count today’s tasks
          if (taskDate.isAtSameMomentAs(todayDateOnly)) todayCount++;

          // Count future/upcoming tasks
          if (taskDate.isAfter(todayDateOnly)) futureCount++;

          // Count urgent tasks
          if ((data['priority'] ?? '').toString().toLowerCase() == 'high') {
            urgentCount++;
          }
        }

        log("Today count: $todayCount");
        log("Future count: $futureCount");
        log("Urgent count: $urgentCount");

        // Emit updated state
        emit(
          state.copyWith(
            fetchPendingEventForHomPageStatus: FetchTaskStatus.sucess,
            todayEvent: todayCount,
            upcomingEvent: futureCount,
          ),
        );
      });
    } on FirebaseException catch (e) {
      emit(
        state.copyWith(
          fetchPendingEventForHomPageStatus: FetchTaskStatus.failed,
          errorMsg: e.message ?? "Firestore error occurred",
        ),
      );
      log("🔥 Firestore error: ${e.message}");
    }
  }

  Future<void> fetchTasks() async {
    final firestore = FirebaseFirestore.instance;

    emit(
      state.copyWith(
        fetchTasksStatus: FetchTaskStatus.loading,
        errorMsg: "Tasks are being fetched... Please wait",
      ),
    );

    try {
      // Read locally stored values
      final currentRole = await AppStorage.read(key: "savedRole") ?? "";
      final email = await AppStorage.read(key: "email") ?? "";
      final boardId = await AppStorage.read(key: "boardId") ?? "";

      log(email);

      // ----------------------
      // Build main task query
      // ----------------------
      Query<Map<String, dynamic>> taskQuery = firestore
          .collection('tasks')
          .doc(boardId)
          .collection('allTasks')
          .where("status", isEqualTo: "pending");

      if (currentRole != "Chief") {
        taskQuery = taskQuery.where("email", isEqualTo: email);
      }

      // Fetch pending tasks
      final taskSnapshot = await taskQuery.get();

      // Map documents → TaskInfo models
      final taskList = taskSnapshot.docs.map((doc) {
        final data = doc.data();
        return TaskInfo(
          taskId: doc.id,
          title: data['title'] ?? '',
          role: data['assignedRole'] ?? '',
          description: data['description'] ?? '',
          priority: data['priority'] ?? '',
          date: data['date'] ?? '',
          assignedTo: data['assignedMember'] ?? '',
          time: data['time'] ?? '', // <-- safe default empty string
          isChecked: false,
          imagePath: data['imagePath'] ?? '',
        );
      }).toList();

      final taskCount = taskList.length;

      // Generate new taskId for adding tasks
      final taskId = firestore
          .collection('tasks')
          .doc(boardId)
          .collection('allTasks')
          .doc()
          .id;

      // ----------------------
      // Build urgent task query
      // ----------------------

      // ----------------------
      // Emit fetched state
      // ----------------------
      emit(
        state.copyWith(
          fetchTasksStatus: FetchTaskStatus.sucess,
          errorMsg: "Tasks fetched successfully",
          taskCount: taskCount,
          taskInfoList: taskList,
          taskId: taskId,
        ),
      );
    } on FirebaseException catch (e) {
      emit(
        state.copyWith(
          fetchTasksStatus: FetchTaskStatus.failed,
          errorMsg: e.message ?? "Firestore error occurred",
        ),
      );
      log("🔥 Firestore error in fetchTasks: ${e.message}");
    } catch (e, stack) {
      emit(
        state.copyWith(
          fetchTasksStatus: FetchTaskStatus.failed,
          errorMsg: e.toString(),
        ),
      );
      log("🔥 Unexpected error in fetchTasks: $e\n$stack");
    }
  }

  Future<void> deleteTask({required List<String> taskId}) async {
    final boardId = await AppStorage.read(key: "boardId") ?? "";
    emit(
      state.copyWith(
        deleteTaskStatus: FetchTaskStatus.loading,
        errorMsg: "Deleting selected task(s)...",
      ),
    );
    if (taskId.isEmpty) return;
    await Future.delayed(Duration(seconds: 1), () {});
    removeTasks(taskId);

    try {
      await Future.wait(
        taskId.map(
          (id) => FirebaseFirestore.instance
              .collection('tasks')
              .doc(boardId)
              .collection("allTasks")
              .doc(id)
              .delete(),
        ),
      );

      final int deleteTaskCount = taskId.length;
      final String taskWord = deleteTaskCount == 1 ? "task" : "tasks";

      emit(
        state.copyWith(
          deleteTaskStatus: FetchTaskStatus.sucess,
          errorMsg: "$deleteTaskCount $taskWord deleted successfully",
        ),
      );
      Future.delayed(Duration(seconds: 1), () {
        emit(state.copyWith(deleteTaskStatus: FetchTaskStatus.initial));
      });
    } on FirebaseException catch (exe) {
      emit(
        state.copyWith(
          deleteTaskStatus: FetchTaskStatus.failed, // keep UI working
          errorMsg: exe.message,
        ),
      );
      Future.delayed(Duration(seconds: 1), () {
        emit(state.copyWith(deleteTaskStatus: FetchTaskStatus.initial));
      });
    }
  }

  Future<void> markAsDoneFun({required List<String> taskId}) async {
    final FirebaseFirestore fireStore = FirebaseFirestore.instance;
    final boardId = await AppStorage.read(key: "boardId") ?? "";
    final userName = await AppStorage.read(key: "name") ?? "";
    final imagePath = await AppStorage.read(key: "imagePath") ?? "";
    final savedRole = await AppStorage.read(key: "savedRole") ?? "";
    emit(
      state.copyWith(
        markAsDoneStatus: FetchTaskStatus.loading,
        errorMsg: "Marking task(s) as completed...",
      ),
    );

    if (state.taskInfoList == null) return;
    final updatedTasks = List<TaskInfo>.from(state.taskInfoList!)
      ..removeWhere((task) => taskId.contains(task.taskId));

    try {
      for (var task in taskId) {
        await fireStore
            .collection('tasks')
            .doc(boardId)
            .collection("allTasks")
            .doc(task)
            .update({
              'status': "completed",
              'priority': "completed",
              'completedAt': FieldValue.serverTimestamp(),
            });
      }

      // 3. Success message
      final int markTaskCount = taskId.length;
      final String taskCount = markTaskCount == 1 ? "task" : "tasks";

      await sendTaskCompleteNotification(
        boardId: boardId,
        taskIds: taskId,
        userName: userName,
        imagePath: imagePath,
        savedRole: savedRole,
      );

      emit(
        state.copyWith(
          markAsDoneStatus: FetchTaskStatus.sucess,
          taskInfoList: updatedTasks,
          errorMsg: "$markTaskCount $taskCount marked as completed",
        ),
      );
      Future.delayed(Duration(seconds: 1), () {
        emit(state.copyWith(markAsDoneStatus: FetchTaskStatus.initial));
      });
    } on FirebaseException catch (exe) {
      // 4. Error (UI still stays with updated list)
      emit(
        state.copyWith(
          markAsDoneStatus: FetchTaskStatus.failed,
          errorMsg: exe.message,
        ),
      );
      Future.delayed(Duration(seconds: 1), () {
        emit(state.copyWith(markAsDoneStatus: FetchTaskStatus.initial));
      });
    }
  }

  Future<void> removeTasks(List<String> taskIds) async {
    final updatedTasks = List<TaskInfo>.from(state.taskInfoList!)
      ..removeWhere((task) => taskIds.contains(task.taskId));
    emit(state.copyWith(taskInfoList: updatedTasks));
  }

  // Future<void> getDateAndRoleForCalander({String? name}) async {
  //   emit(
  //     state.copyWith(
  //       getDateAndRoleForCalanderStatus: FetchTaskStatus.loading,
  //       errorMsg: "Tasks are being fetched... Please wait",
  //     ),
  //   );

  //   try {
  //     final savedRole = await AppStorage.read(key: 'savedRole');
  //     String email = await AppStorage.read(key: "email") ?? "";
  //     String boardId = await AppStorage.read(key: "boardId") ?? "";
  //     final firestore = FirebaseFirestore.instance;
  //     // ------------------ Fetch Tasks ------------------
  //     Query taskQuery = firestore
  //         .collection('tasks')
  //         .doc(boardId)
  //         .collection("allTasks");

  //     if (savedRole != "Chief") {
  //       taskQuery = taskQuery.where('email', isEqualTo: email);
  //     }
  //     if (name != null && name.isNotEmpty) {
  //       taskQuery = taskQuery.where('assignedMember', isEqualTo: name);
  //     }
  //     final tasksnapshot = await taskQuery
  //         .where('status', isEqualTo: 'pending')
  //         .get();

  //     final userList = tasksnapshot.docs.map((doc) {
  //       final data = doc.data() as Map<String, dynamic>;
  //       return TaskInfo(
  //         taskId: doc.id,
  //         title: data['title'] ?? '',
  //         date: data['date'] ?? '',
  //         role: data['assignedRole'] ?? '',
  //         assignedTo: data['assignedMember'] ?? '',
  //         description: data['description'] ?? '',
  //         priority: data['priority'] ?? '',
  //         imagePath: data['imagePath'] ?? "",
  //         time: data['time'] ?? "",
  //       );
  //     }).toList();

  //     // ------------------ Fetch events ------------------
  //     Query eventQuery = firestore
  //         .collection('events')
  //         .doc(boardId)
  //         .collection('allEvents');

  //     if (savedRole != "Chief") {
  //       eventQuery = eventQuery.where('assignedEmail', isEqualTo: email);
  //     }
  //     if (name != null && name.isNotEmpty) {
  //       eventQuery = eventQuery.where('assignedMember', isEqualTo: name);
  //     }

  //     final eventSnapshot = await eventQuery.get();

  //     final eventList = eventSnapshot.docs.map((doc) {
  //       final data = doc.data() as Map<String, dynamic>;
  //       return TaskInfo(
  //         taskId: doc.id,
  //         title: data['title'] ?? '',
  //         date: data['date'] ?? '',
  //         role: data['assignedRole'] ?? '',
  //         assignedTo: data['assignedMember'] ?? '',
  //         description: data['description'] ?? '',
  //         priority: data['priority'] ?? '',
  //         imagePath: data['imagePath'] ?? '',
  //       );
  //     }).toList();

  //     final mergedList = [...userList, ...eventList];

  //     emit(
  //       state.copyWith(
  //         getDateAndRoleForCalanderStatus: FetchTaskStatus.sucess,
  //         errorMsg: "Tasks fetched Successfully",
  //         mergedList: mergedList,
  //       ),
  //     );
  //   } on FirebaseException catch (exe) {
  //     emit(
  //       state.copyWith(
  //         getDateAndRoleForCalanderStatus: FetchTaskStatus.failed,
  //         errorMsg: exe.message,
  //       ),
  //     );
  //   }
  // }
  StreamSubscription? eventSubscriptionCalendar;
  StreamSubscription? taskSubscriptionCalendar;

  Future<void> getDateAndRoleForCalander({String? name}) async {
    final savedRole = await AppStorage.read(key: 'savedRole');
    String email = await AppStorage.read(key: "email") ?? "";
    String boardId = await AppStorage.read(key: "boardId") ?? "";
    final firestore = FirebaseFirestore.instance;

    // ------------------ Tasks ------------------
    Query taskQuery = firestore
        .collection('tasks')
        .doc(boardId)
        .collection("allTasks");
    if (savedRole != "Chief") {
      taskQuery = taskQuery.where('email', isEqualTo: email);
    }
    if (name != null && name.isNotEmpty)
      taskQuery = taskQuery.where('assignedMember', isEqualTo: name);
    taskQuery = taskQuery.where('status', isEqualTo: 'pending');

    taskSubscription = taskQuery.snapshots().listen((snapshot) {
      final userList = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return TaskInfo(
          taskId: doc.id,
          title: data['title'] ?? '',
          date: data['date'] ?? '',
          role: data['assignedRole'] ?? '',
          assignedTo: data['assignedMember'] ?? '',
          description: data['description'] ?? '',
          priority: data['priority'] ?? '',
          imagePath: data['imagePath'] ?? "",
          time: data['time'] ?? "",
          isGoogleCal: data['isGoogleCal'],
          assignedEmail: data['email'],
        );
      }).toList();

      // ------------------ Fetch events inside task listener or separately ------------------
      Query eventQuery = firestore
          .collection('events')
          .doc(boardId)
          .collection('allEvents');
      if (savedRole != "Chief") {
        eventQuery = eventQuery.where('email', isEqualTo: email);
      }
      if (name != null && name.isNotEmpty) {
        eventQuery = eventQuery.where('assignedMember', isEqualTo: name);
      }

      eventSubscription = eventQuery.snapshots().listen((eventSnapshot) {
        final eventList = eventSnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return TaskInfo(
            taskId: doc.id,
            title: data['title'] ?? '',
            date: data['date'] ?? '',
            role: data['assignedRole'] ?? '',
            assignedTo: data['assignedMember'] ?? '',
            description: data['description'] ?? '',
            priority: data['priority'] ?? '',
            imagePath: data['imagePath'] ?? '',
            time: data['time'] ?? "",
            isGoogleCal: data['isGoogleCal'],
            assignedEmail: data['email'],
          );
        }).toList();

        // ------------------ Merge lists and emit ------------------
        final mergedList = [...userList, ...eventList];

        emit(
          state.copyWith(
            getDateAndRoleForCalanderStatus: FetchTaskStatus.sucess,
            mergedList: mergedList,
            errorMsg: "Tasks fetched Successfully",
          ),
        );
      });
    });
  }

  @override
  Future<void> close() {
    taskSubscriptionCalendar?.cancel();
    eventSubscriptionCalendar?.cancel();
    return super.close();
  }

  Future<void> fetchtaskInfo({required String taskId}) async {
    emit(state.copyWith(fetchtaskInfo: FetchTaskStatus.loading));

    try {
      final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
      final String? boardId = await AppStorage.read(key: "boardId");

      final snapshot = await firebaseFirestore
          .collection('tasks')
          .doc(boardId)
          .collection('allTasks')
          .doc(taskId)
          .get();

      if (snapshot.exists) {
        final data = snapshot.data()!;
        final taskData = TaskInfo(
          taskId: data['taskId'] ?? '',
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          date: data['date'] ?? '',
          time: data['time'] ?? '',
          priority: data['priority'] ?? '',
          isGoogleCal: data['isGoogleCal'] ?? false,
        );
        emit(
          state.copyWith(
            fetchtaskInfo: FetchTaskStatus.sucess,
            taskInfoListEdit: [taskData],
          ),
        );
      }
    } on FirebaseException catch (exe) {
      emit(
        state.copyWith(
          fetchtaskInfo: FetchTaskStatus.failed,
          errorMsg: exe.toString(),
        ),
      );
    }
  }

  void reset() {
    emit(
      state.copyWith(
        fetchtaskInfo: FetchTaskStatus.initial,
        // taskInfoList: null,
      ),
    );
  }

  Future<void> sendTaskCompleteNotification({
    required List<String> taskIds,
    required String boardId,
    required String userName,
    required String savedRole,
    String? imagePath,
  }) async {
    final Dio dio = Dio();
    try {
      await dio.post(
        ApiRoutes.sendTaskCompleteNotification,
        data: {
          "taskIds": taskIds,
          "boardId": boardId,
          "userName": userName,
          "imagePath": imagePath,
          "savedRole": savedRole,
        },
      );
    } catch (exe) {
      throw Exception(exe.toString());
    }
  }
}
