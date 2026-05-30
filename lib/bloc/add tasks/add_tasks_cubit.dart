import 'dart:developer';
import 'dart:io';
import 'dart:math' hide log;
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:family_management_app/app/api/api_routes.dart';
import 'package:family_management_app/bloc/fetch%20User/fetch_user_cubit.dart';
import 'package:family_management_app/bloc/fetch_tasks/fetch_tasks_cubit.dart';
import 'package:family_management_app/service/secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
part 'add_tasks_state.dart';

class AddTasksCubit extends Cubit<AddTasksState> {
  AddTasksCubit()
    : super(
        AddTasksState(
          taskPostingStatus: AddRequestStatus.initial,
          childPostingStatus: AddRequestStatus.initial,
          deletingStatus: AddRequestStatus.initial,
          markingStatus: AddRequestStatus.initial,

          eventPostingStatus: AddRequestStatus.initial,
        ),
      );

  Future<void> addTaskFun({
    required String title,
    required String desc,
    required List<AllUserInfo> selectedUserToAssignTask,
    required String date,
    String? time,
    String? priority,
    String? editTaskId, // <-- Pass this when editing
  }) async {
    log("adding wait ");
    emit(
      state.copyWith(
        taskPostingStatus: AddRequestStatus.loading,
        errorMsg: editTaskId != null
            ? "Updating task... Please Wait"
            : "Assigning task... Please Wait",
      ),
    );

    try {
      final FirebaseFirestore firebaseFireStore = FirebaseFirestore.instance;
      final String boardId = await AppStorage.read(key: "boardId") ?? "";
      final String email = await AppStorage.read(key: "email") ?? "";
      final String chiefName = await AppStorage.read(key: "name") ?? "";

      if (editTaskId != null && selectedUserToAssignTask.isNotEmpty) {
        // Edit mode: update the existing task for the selected user
        final user = selectedUserToAssignTask.first;
        Map<String, dynamic> taskData = {
          "title": title,
          "boardId": boardId,
          "description": desc,
          "assignedRole": user.role,
          "assignedMember": user.name,
          'uid': user.uid,
          'imagePath': user.imagePath,
          'email': user.email,
          "date": date,
          "time": time ?? "",
          "priority": priority,
          "status": "pending",
          "createdBy": email,
          "updatedAt": FieldValue.serverTimestamp(),
        };
        await firebaseFireStore
            .collection("tasks")
            .doc(boardId)
            .collection("allTasks")
            .doc(editTaskId)
            .update(taskData);
      } else {
        // Add mode: create new tasks for each selected user
        for (var user in selectedUserToAssignTask) {
          final firestore = firebaseFireStore
              .collection("tasks")
              .doc(boardId)
              .collection("allTasks")
              .doc();
          final taskId = firestore.id;

          Map<String, dynamic> taskData = {
            "taskId": taskId,
            "title": title,
            "boardId": boardId,
            "description": desc,
            "assignedRole": user.role,
            "assignedMember": user.name,
            'uid': user.uid,
            'imagePath': user.imagePath,
            'email': user.email,
            "date": date,
            "time": time ?? "",
            "priority": priority,
            "status": "pending",
            "createdBy": email,
            "createdAt": FieldValue.serverTimestamp(),
            "isGoogleCal": false,
          };
          await firestore.set(taskData);
        }
        sendTaskAssignedNotification(
          boardId: boardId,
          taskTitle: title,
          description: desc,
          uids: selectedUserToAssignTask.map((user) => user.uid).toList(),
          chiefName: chiefName,
        );
      }
      log("Added");

      emit(
        state.copyWith(
          taskPostingStatus: AddRequestStatus.success,
          errorMsg: editTaskId != null
              ? "Task updated successfully"
              : "Task assigned successfully",
        ),
      );

      Future.delayed(const Duration(milliseconds: 500), () {
        emit(state.copyWith(taskPostingStatus: AddRequestStatus.initial));
      });
    } on FirebaseAuthException catch (exe) {
      log("Adding Failed: ${exe.toString()}");
      emit(
        state.copyWith(
          taskPostingStatus: AddRequestStatus.failure,
          errorMsg: exe.message,
        ),
      );
      Future.delayed(const Duration(milliseconds: 500), () {
        emit(state.copyWith(taskPostingStatus: AddRequestStatus.initial));
      });
    }
  }

  Future<void> addOrEditChildFun({
    required String name,
    required String age,
    required String gender,
    String? dateofBirth,
    String? uid,
    XFile? profileImage,
    String? schoolName,
    String? schoolAddress,
    String? grade,
    String? classScheduleDate,
    String? classScheduleTime,
    String? allergies,
    String? medicalInformation,
    String? generalNotes,
    String? optionalEnhancements,
  }) async {
    emit(
      state.copyWith(
        childPostingStatus: AddRequestStatus.loading,
        errorMsg: uid != null && uid.isNotEmpty
            ? "Updating Child..."
            : "Adding Child... Please Wait",
      ),
    );

    try {
      final String boardId = await AppStorage.read(key: "boardId") ?? "";
      final firestoreCollection = FirebaseFirestore.instance
          .collection("children")
          .doc(boardId)
          .collection('child');

      final userFireStore = FirebaseFirestore.instance.collection('users');

      String childId = (uid != null && uid.isNotEmpty)
          ? uid
          : firestoreCollection.doc().id;
      DocumentReference firestoreDoc = firestoreCollection.doc(childId);

      // Handle image
      String? imagePath;
      if (profileImage != null) {
        imagePath = await uploadProfileImage(profileImage);
      }

      Map<String, dynamic> taskData = {
        "uid": childId,
        "name": name,
        "age": age,
        "boardId": boardId,
        "date": dateofBirth,
        "gender": gender,
        "createdAt": FieldValue.serverTimestamp(),

        "role": "Stakeholder",
        "schoolName": schoolName,
        "schoolAddress": schoolAddress,
        "grade": grade,
        "classDate": classScheduleDate,
        "classTime": classScheduleTime,
        "allergies": allergies,
        "medicalInfo": medicalInformation,
        "generalNotes": generalNotes,
        "optionalInfo": optionalEnhancements,
      };
      if (imagePath != null && imagePath.isNotEmpty) {
        taskData["imagePath"] = imagePath;
      }

      if (uid != null && uid.isNotEmpty) {
        await firestoreDoc.update(taskData);

        Map<String, dynamic> userData = {
          "name": name,
          "uid": childId,
          'boardId': boardId,
          'role': "Stakeholder",
          'email': age,
        };
        if (imagePath != null && imagePath.isNotEmpty) {
          userData["imagePath"] = imagePath;
        }

        await userFireStore.doc(childId).update(userData);
        emit(
          state.copyWith(
            childPostingStatus: AddRequestStatus.success,
            errorMsg: "StakeHolder $name Updated Successfully",
            taskId: childId,
          ),
        );
        Future.delayed(const Duration(milliseconds: 500), () {
          emit(state.copyWith(childPostingStatus: AddRequestStatus.initial));
        });
      } else {
        await firestoreDoc.set(taskData);
        await userFireStore.doc(childId).set({
          "name": name,
          "imagePath": imagePath,
          "uid": childId,
          'boardId': boardId,
          'role': "Stakeholder",
          'email': age,
          "createdAt": FieldValue.serverTimestamp(),
        });

        emit(
          state.copyWith(
            childPostingStatus: AddRequestStatus.success,
            errorMsg: "StakeHolder $name Added Successfully",
            taskId: childId,
          ),
        );
        Future.delayed(const Duration(milliseconds: 500), () {
          emit(state.copyWith(childPostingStatus: AddRequestStatus.initial));
        });
      }
    } on FirebaseAuthException catch (exe) {
      log(exe.toString());
      emit(
        state.copyWith(
          childPostingStatus: AddRequestStatus.failure,
          errorMsg: exe.message,
        ),
      );
      Future.delayed(const Duration(milliseconds: 500), () {
        emit(state.copyWith(childPostingStatus: AddRequestStatus.initial));
      });
    } catch (e) {
      emit(
        state.copyWith(
          childPostingStatus: AddRequestStatus.failure,
          errorMsg: e.toString(),
        ),
      );
      Future.delayed(const Duration(milliseconds: 500), () {
        emit(state.copyWith(childPostingStatus: AddRequestStatus.initial));
      });
    }
  }

  Future<String> uploadProfileImage(XFile image) async {
    final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
    try {
      File convertedFile = File(image.path);
      File compressedFile = await compressImage(convertedFile);

      final storageRef = firebaseStorage.ref().child(
        "images/${DateTime.now().millisecondsSinceEpoch}.jpg",
      );
      await storageRef.putFile(compressedFile);
      final downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (exe) {
      throw Exception("Image Uploading Failed : $exe");
    }
  }

  Future<void> deleteTask({
    required List<String> taskId,
    required FetchTasksCubit fetchCubit,
  }) async {
    emit(
      state.copyWith(
        deletingStatus: AddRequestStatus.loading,
        errorMsg: "Deleting selected task.... Please Wait",
      ),
    );
    fetchCubit.removeTasks(taskId);
    try {
      for (var task in taskId) {
        await FirebaseFirestore.instance.collection('tasks').doc(task).delete();
      }
      final int deleteTaskCount = taskId.length;
      final String taskCount = deleteTaskCount == 1 ? "task" : "tasks";

      emit(
        state.copyWith(
          deletingStatus: AddRequestStatus.success,
          errorMsg: "$deleteTaskCount $taskCount deleted sucessfully",
        ),
      );
    } on FirebaseException catch (exe) {
      emit(
        state.copyWith(
          deletingStatus: AddRequestStatus.failure,
          errorMsg: exe.message,
        ),
      );
    }
  }

  Future<void> markAsDoneFun({required List<String> taskId}) async {
    emit(state.copyWith(markingStatus: AddRequestStatus.loading));
    try {
      for (var task in taskId) {
        await FirebaseFirestore.instance.collection('tasks').doc(task).update({
          'isCompleted': true,
        });
      }
      final int markTaskCount = taskId.length;
      final String taskCount = markTaskCount == 1 ? "task" : "tasks";

      emit(
        state.copyWith(
          markingStatus: AddRequestStatus.success,
          errorMsg: "$markTaskCount $taskCount completed Sucessfully",
        ),
      );
    } on FirebaseException catch (exe) {
      emit(
        state.copyWith(
          markingStatus: AddRequestStatus.failure,
          errorMsg: exe.message,
        ),
      );
    }
  }

  Future<File> compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath =
        "${dir.absolute.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";

    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 50,
    );
    return File(result!.path);
  }

  Future<void> getLeadDetailsForEdit({String? uid}) async {
    final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    final boardId = await AppStorage.read(key: 'boardId');

    emit(state.copyWith(fetchLeadStatus: AddRequestStatus.loading));

    try {
      AllUserInfo? userInfo;
      final snapshot = await firebaseFirestore
          .collection('board')
          .doc(boardId)
          .collection("joinRequests")
          .doc(uid)
          .get();

      final data = snapshot.data()!;
      userInfo = AllUserInfo(
        uid: data['uid'] ?? '',
        email: data['email'] ?? '',
        name: data['name'] ?? '',
        imagePath: data['imagePath'] ?? '',
        role: data['role'] ?? '',
      );

      emit(
        state.copyWith(
          fetchLeadStatus: AddRequestStatus.success,
          userInfo: [userInfo],
        ),
      );
    } on FirebaseException catch (exe) {
      emit(
        state.copyWith(
          fetchLeadStatus: AddRequestStatus.failure,
          errorMsg: exe.code,
        ),
      );
    }
  }

  Future<void> addMember({
    required String name,
    String? email,
    XFile? profileImage,
    String? role,
  }) async {
    final firebaseFirestore = FirebaseFirestore.instance;
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    final savedBoardId = await AppStorage.read(key: "boardId") ?? "";
    final chiefName = await AppStorage.read(key: "name") ?? "";
    final chiefEmail = await AppStorage.read(key: "email") ?? "";
    final savedUid = await AppStorage.read(key: 'uid');
    final String password = generateSimplePassword();

    // var uuid = Uuid();
    // String token = uuid.v4();

    emit(
      state.copyWith(
        addLeadStatus: AddRequestStatus.loading,
        errorMsg: "Adding Member... Please Wait",
      ),
    );

    try {
      final firestoreDoc = firebaseFirestore
          .collection("board")
          .doc(savedBoardId)
          .collection('joinRequests');

      final userFireStore = FirebaseFirestore.instance.collection('users');

      String? imagePath;
      if (profileImage != null) {
        imagePath = await uploadProfileImage(profileImage);
      }

      String? userUid;
      if (role != "Guest") {
        UserCredential userCrendital = await firebaseAuth
            .createUserWithEmailAndPassword(email: email!, password: password);
        final user = userCrendital.user;
        userUid = user?.uid;

        sendInvitation(
          email: email,
          password: password,
          name: name,
          role: role!,
        );
      }

      Map<String, dynamic> taskData = {
        "uid": userUid,
        "name": name,
        "email": email,
        "boardId": savedBoardId,
        "createdAt": FieldValue.serverTimestamp(),
        "role": role ?? "Lead",
        "joinStatus": "invited",
        'imagePath': imagePath,
        "password": password,
        "wasLogin": false,
        'isGoogle': false,
        "wasApprovedShown": false,
        'chiefEmail': chiefEmail,
        'chiefName': chiefName,
        "chiefId": savedUid,
      };

      await firestoreDoc.doc(userUid).set(taskData);
      await userFireStore.doc(userUid).set(taskData);

      emit(
        state.copyWith(
          addLeadStatus: AddRequestStatus.success,
          errorMsg: "'$name' added successfully",
        ),
      );
      Future.delayed(const Duration(milliseconds: 500), () {
        emit(state.copyWith(addLeadStatus: AddRequestStatus.initial));
      });
    } on FirebaseException catch (e) {
      emit(
        state.copyWith(
          addLeadStatus: AddRequestStatus.failure,
          errorMsg: e.code,
        ),
      );
      Future.delayed(const Duration(milliseconds: 500), () {
        emit(state.copyWith(addLeadStatus: AddRequestStatus.initial));
      });
    }
  }

  // Future<void> saveLeadUser({
  //   required String name,
  //   String? email,
  //   String? uid,
  //   XFile? profileImage,
  //   String? role,
  //   String? displayRole,
  // }) async {
  //   final firebaseFirestore = FirebaseFirestore.instance;
  //   final savedBoardId = await AppStorage.read(key: "boardId") ?? "";
  //   final savedUid = await AppStorage.read(key: 'uid');

  //   var uuid = Uuid();
  //   String token = uuid.v4();

  //   emit(
  //     state.copyWith(
  //       addLeadStatus: AddRequestStatus.loading,
  //       errorMsg: uid != null && uid.isNotEmpty
  //           ? "Updating Lead User..."
  //           : "Adding Member... Please Wait",
  //     ),
  //   );

  //   try {
  //     final firestoreCollection = firebaseFirestore
  //         .collection("board")
  //         .doc(savedBoardId)
  //         .collection('joinRequests');

  //     final userFireStore = FirebaseFirestore.instance.collection('users');

  //     String leadId = (uid != null && uid.isNotEmpty) ? uid : token;

  //     DocumentReference firestoreDoc = firestoreCollection.doc(leadId);

  //     String? imagePath;
  //     if (profileImage != null) {
  //       imagePath = await uploadProfileImage(profileImage);
  //     }

  //     Map<String, dynamic> taskData = {
  //       "uid": leadId,
  //       "name": name,
  //       "email": email ?? "",
  //       "boardId": savedBoardId,
  //       "createdBy": savedUid,
  //       "createdAt": FieldValue.serverTimestamp(),
  //       "role": role ?? "Lead",
  //       "joinStatus": "pending",
  //       "status": "pending",
  //     };

  //     if (imagePath != null && imagePath.isNotEmpty) {
  //       taskData["imagePath"] = imagePath;
  //     }

  //     if (uid != null && uid.isNotEmpty) {
  //       await firestoreDoc.update(taskData);
  //       await userFireStore.doc(leadId).update(taskData);
  //       emit(
  //         state.copyWith(
  //           addLeadStatus: AddRequestStatus.success,
  //           errorMsg: "$name updated successfully",
  //         ),
  //       );
  //       Future.delayed(const Duration(milliseconds: 500), () {
  //         emit(state.copyWith(addLeadStatus: AddRequestStatus.initial));
  //       });
  //     } else {
  //       await firestoreDoc.set(taskData);
  //       await userFireStore.doc(leadId).set(taskData);
  //       // ApI call will be here

  //       emit(
  //         state.copyWith(
  //           addLeadStatus: AddRequestStatus.success,
  //           errorMsg: "$displayRole '$name' added successfully",
  //         ),
  //       );
  //       Future.delayed(const Duration(milliseconds: 500), () {
  //         emit(state.copyWith(addLeadStatus: AddRequestStatus.initial));
  //       });
  //     }
  //   } on FirebaseException catch (e) {
  //     emit(
  //       state.copyWith(
  //         addLeadStatus: AddRequestStatus.failure,
  //         errorMsg: e.code,
  //       ),
  //     );
  //     Future.delayed(const Duration(milliseconds: 500), () {
  //       emit(state.copyWith(addLeadStatus: AddRequestStatus.initial));
  //     });
  //   }
  // }

  void clearAddLeadState() {
    emit(
      state.copyWith(addLeadStatus: AddRequestStatus.initial, errorMsg: null),
    );
  }

  Future<void> addEventFun({
    required String title,
    required String desc,
    required List<AllUserInfo> selectedUserToAssignEvent,
    required String date,
    String? time,
  }) async {
    emit(
      state.copyWith(
        eventPostingStatus: AddRequestStatus.loading,
        errorMsg: "Adding Events... Please Wait",
      ),
    );

    try {
      final FirebaseFirestore firebaseFireStore = FirebaseFirestore.instance;
      final String boardId = await AppStorage.read(key: "boardId") ?? "";
      final String email = await AppStorage.read(key: "email") ?? "";
      final String chiefName = await AppStorage.read(key: "name") ?? "";

      for (var user in selectedUserToAssignEvent) {
        final firestore = firebaseFireStore
            .collection("events")
            .doc(boardId)
            .collection("allEvents")
            .doc();
        final eventId = firestore.id;

        Map<String, dynamic> taskData = {
          "eventId": eventId,
          "title": title,
          "boardId": boardId,
          "description": desc,
          "assignedRole": user.role,
          "assignedMember": user.name,
          'uid': user.uid,
          'imagePath': user.imagePath,
          'email': user.email,
          "date": date,
          "time": time ?? "",
          "status": "pending",
          "createdBy": email,
          "createdAt": FieldValue.serverTimestamp(),
          "isGoogleCal": false,
        };
        await firestore.set(taskData);
      }
      sendEventAssignedNotification(
        boardId: boardId,
        taskTitle: title,
        description: desc,
        uids: selectedUserToAssignEvent.map((user) => user.uid).toList(),
        chiefName: chiefName,
      );

      emit(
        state.copyWith(
          eventPostingStatus: AddRequestStatus.success,
          errorMsg: "Event assigned successfully",
        ),
      );
      Future.delayed(const Duration(milliseconds: 500), () {
        emit(state.copyWith(eventPostingStatus: AddRequestStatus.initial));
      });
    } on FirebaseAuthException catch (exe) {
      emit(
        state.copyWith(
          eventPostingStatus: AddRequestStatus.failure,
          errorMsg: exe.message,
        ),
      );
      Future.delayed(const Duration(milliseconds: 500), () {
        emit(state.copyWith(eventPostingStatus: AddRequestStatus.initial));
      });
    }
  }

  Future<void> sendInvitation({
    required String name,
    required String role,
    required String email,
    required String password,
  }) async {
    final Dio dio = Dio();

    try {
      await dio.post(
        ApiRoutes.inviteLink,
        data: {
          'name': name,
          'role': role,
          'email': email,
          'password': password,
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
    } on FirebaseException catch (exe) {
      throw Exception(exe);
    } catch (e) {
      throw Exception(e);
    }
  }

  String generateSimplePassword({int length = 6}) {
    const String chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*';
    final Random random = Random.secure();

    return List.generate(
      length,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
  }

  Future<void> sendTaskAssignedNotification({
    required List<String> uids,
    required String taskTitle,
    String? description,
    required String boardId,
    required String chiefName,
  }) async {
    final Dio dio = Dio();
    log('Just cheking the number of times it will run');

    try {
      await dio.post(
        ApiRoutes.sendTaskAssignedNotification,
        data: {
          "userUids": uids,
          'boardId': boardId,
          "taskTitle": taskTitle,
          "description": description ?? "",
          "chiefName": chiefName,
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
    } catch (exe) {
      throw Exception(exe);
    }
  }

  Future<void> sendEventAssignedNotification({
    required List<String> uids,
    required String taskTitle,
    String? description,
    required String boardId,
    required String chiefName,
  }) async {
    final Dio dio = Dio();

    try {
      await dio.post(
        ApiRoutes.sendEventAssignedNotification,
        data: {
          "userUids": uids,
          'boardId': boardId,
          "taskTitle": taskTitle,
          "description": description ?? "",
          "chiefName": chiefName,
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
    } catch (exe) {
      throw Exception(exe);
    }
  }
}
