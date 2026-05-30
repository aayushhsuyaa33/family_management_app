import 'dart:developer';
import 'dart:math' hide log;
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:family_management_app/app/api/api_routes.dart';
import 'package:family_management_app/app/api/firebaseauth_Exception.dart';
import 'package:family_management_app/service/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

part 'role_update_state.dart';

class RoleUpdateCubit extends Cubit<RoleUpdateState> {
  RoleUpdateCubit()
    : super(
        RoleUpdateState(
          updatingChiefStatus: RoleUpdatingStatus.initial,
          updatingMemberStatus: RoleUpdatingStatus.initial,
        ),
      );

  Future<bool> checkBoardOrChiefEmail(String input) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      final query = firestore.collection("users");

      if (input.contains("@")) {
        final querySnapshot = await query
            .where("email", isEqualTo: input)
            .limit(1)
            .get();

        if (querySnapshot.docs.isEmpty) return false;

        final userData = querySnapshot.docs.first.data();
        final role = userData['role'] as String?;
        return role != null && role == "Chief";
      } else {
        // Treat as boardId
        final querySnapshot = await query
            .where("boardId", isEqualTo: input)
            .limit(1)
            .get();

        return querySnapshot.docs.isNotEmpty;
      }
    } catch (e) {
      log("Error checking board/email: $e");
      return false;
    }
  }

  Future<void> updateChiefsRole({
    required String title,
    String? description,
  }) async {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final user = firebaseAuth.currentUser;
    final uid = user?.uid;
    emit(state.copyWith(updatingChiefStatus: RoleUpdatingStatus.loading));

    try {
      String boardCode = generateBoardCode(length: 5);
      final fcmToken = await FirebaseMessaging.instance.getToken();
      await firestore.collection('users').doc(uid).update({
        "role": "Chief",
        'boardId': boardCode,
        'title': title,
        'description': description ?? "",
        'joinStatus': 'Started',
        "fcmToken": fcmToken ?? "",
      });

      final doc = await firestore.collection("users").doc(uid).get();

      final savedBoardId = doc.data()?['boardId'] as String?;
      final savedTitle = doc.data()?['title'] as String?;
      final savedDescription = doc.data()?['description'] as String?;
      final bool checkingIsGoogle = doc.data()?['isGoogle'];

      await firestore.collection("Chiefs").doc(boardCode).set({
        "uid": uid,
        "name": doc.data()?['name'] ?? "",
        "email": doc.data()?['email'] ?? "",
        "createdAt": FieldValue.serverTimestamp(),
        'imagePath': doc.data()?['imagePath'] ?? "",
        "role": "Chief",
        "boardId": savedBoardId,
        'title': title,
        'description': description ?? "",
        'joinStatus': 'Started',
        "fcmToken": fcmToken ?? "",
      });

      if (user != null && !user.emailVerified && checkingIsGoogle == false) {
        await user.sendEmailVerification();
        log("Verification email sent to ${user.email}");
      }

      emit(
        state.copyWith(
          updatingChiefStatus: RoleUpdatingStatus.sucess,
          boardDescription: savedDescription,
          boardId: savedBoardId,
          boardTitle: savedTitle,
          isGoogle: checkingIsGoogle,
        ),
      );

      sendChiefWelcomeEmail(
        email: doc.data()?['email'] ?? "",
        name: doc.data()?['name'] ?? "",
        role: "Chief",
        chiefUid: doc.data()?['uid'] ?? "",
        boardId: savedBoardId ?? "",
      );
      await NotificationService.showLocalBoardCreatedNotification();
      emit(state.copyWith(updatingChiefStatus: RoleUpdatingStatus.initial));
    } on FirebaseAuthException catch (exe) {
      final errorMessage = FirebaseAuthErrorHandler.getMessage(exe);
      emit(
        state.copyWith(
          updatingChiefStatus: RoleUpdatingStatus.failed,
          errorMsg: errorMessage,
        ),
      );
      emit(state.copyWith(updatingChiefStatus: RoleUpdatingStatus.initial));
    }
  }

  Future<void> updateMembersRole({
    required String input, // either boardId or chiefEmail
    String? nickname,
  }) async {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    emit(state.copyWith(updatingMemberStatus: RoleUpdatingStatus.loading));

    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      final uid = firebaseAuth.currentUser?.uid;
      if (uid == null) throw Exception("User not logged in");

      // 1. Get current user info
      final userDoc = await firestore.collection("users").doc(uid).get();
      final userData = userDoc.data()!;
      final userEmail = userData['email'] ?? "";

      String? boardId;
      String? chiefEmail;

      // 2. Detect input type
      if (input.contains('@')) {
        // Treat as email
        chiefEmail = input.trim();
        final query = await firestore
            .collection('users')
            .where('email', isEqualTo: chiefEmail)
            .limit(1)
            .get();

        if (query.docs.isEmpty)
          throw Exception("Chief not found for this email");
        boardId = query.docs.first.data()['boardId'] as String?;
      } else {
        // Treat as boardId
        boardId = input.trim();

        // Optional: fetch chief email for that board
        final query = await firestore
            .collection('users')
            .where('boardId', isEqualTo: boardId)
            .limit(1)
            .get();
        if (query.docs.isNotEmpty) {
          chiefEmail = query.docs.first.data()['email'] as String?;
        }
      }

      if (boardId == null) throw Exception("BoardId or chiefEmail required");

      final chiefUid = await getChiefUid(boardId);

      // 3. Update user's join info
      await firestore.collection("users").doc(uid).update({
        "role": null,
        "boardId": boardId,
        "nickname": nickname ?? "",
        "joinStatus": "pending",
        'chiefId': chiefUid,
        'chiefEmail': chiefEmail ?? "",
        "fcmToken": fcmToken ?? "",
      });

      // 4. Save join request under boardId
      await firestore
          .collection("board")
          .doc(boardId)
          .collection("joinRequests")
          .doc(uid)
          .set({
            'uid': uid,
            'name': userData['name'] ?? "",
            'email': userEmail,
            'imagePath': userData["imagePath"] ?? "",
            'nickname': nickname ?? "",
            'createdAt': FieldValue.serverTimestamp(),
            "boardId": boardId,
            "joinStatus": 'pending',
            'role': null,
            'chiefId': chiefUid,
            'chiefEmail': chiefEmail ?? "",
            "fcmToken": fcmToken ?? "",
          });

      emit(
        state.copyWith(
          updatingMemberStatus: RoleUpdatingStatus.sucess,
          role: "",
          boardNickname: nickname,
          isGoogle: false,
        ),
      );

      sendUserWelcomeEmail(
        email: userData['email'] ?? "",
        name: userData['name'] ?? " ",
      );

      sendUserJoinedNotification(
        chiefEmail: chiefEmail ?? "",
        userEmail: userEmail,
        userName: userData['name'] ?? " ",
        joinedOn: DateTime.now().toString(),
      );
      notifyChief(
        chiefUid: chiefUid ?? "",
        userName: userData['name'] ?? " ",
        boardId: boardId,
        imagePath: userData["imagePath"] ?? "",
      );

      await NotificationService.showLocalBoardJoiningNotification();
      emit(state.copyWith(updatingMemberStatus: RoleUpdatingStatus.initial));
    } on FirebaseAuthException catch (exe) {
      final errorMessage = FirebaseAuthErrorHandler.getMessage(exe);
      emit(
        state.copyWith(
          updatingMemberStatus: RoleUpdatingStatus.failed,
          errorMsg: errorMessage,
        ),
      );
      emit(state.copyWith(updatingMemberStatus: RoleUpdatingStatus.initial));
    } catch (e) {
      emit(
        state.copyWith(
          updatingMemberStatus: RoleUpdatingStatus.failed,
          errorMsg: e.toString(),
        ),
      );
      emit(state.copyWith(updatingMemberStatus: RoleUpdatingStatus.initial));
    }
  }

  String generateBoardCode({int length = 5}) {
    final random = Random();
    int min = pow(10, length - 1).toInt();
    int max = pow(10, length).toInt() - 1;

    return (min + random.nextInt(max - min)).toString();
  }

  Future<String?> getChiefUid(String input) async {
    try {
      QuerySnapshot snapshot;

      if (input.contains("@")) {
        snapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: input)
            .limit(1)
            .get();
      } else {
        snapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('boardId', isEqualTo: input)
            .limit(1)
            .get();
      }

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first['uid'] as String?;
      }
      return null;
    } catch (e) {
      log("Error fetching chief UID: $e");
      return null;
    }
  }

  Future<void> sendChiefWelcomeEmail({
    required String email,
    required String name,
    required String role,
    String? chiefUid,
    String? boardId,
  }) async {
    final Dio dio = Dio();

    try {
      await dio.post(
        ApiRoutes.sendChiefWelcome,
        data: {
          "email": email,
          "name": name,
          "role": role,
          'chiefUid': chiefUid,
          'boardId': boardId,
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
    } on FirebaseException catch (exe) {
      throw Exception(exe);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> sendUserWelcomeEmail({
    required String email,
    required String name,
  }) async {
    final Dio dio = Dio();

    try {
      await dio.post(
        ApiRoutes.sendUserWelcomeEmail,
        data: {"userEmail": email, "userName": name},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
    } on FirebaseException catch (exe) {
      throw Exception(exe);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> sendUserJoinedNotification({
    required String chiefEmail,
    required String userEmail,
    required String userName,
    required String joinedOn,
  }) async {
    final Dio dio = Dio();

    try {
      await dio.post(
        ApiRoutes.sendUserJoinedEmail,
        data: {
          "chiefEmail": chiefEmail,
          "userName": userName,
          "userEmail": userEmail,
          "joinedOn": joinedOn,
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
    } on FirebaseException catch (exe) {
      throw Exception(exe);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> notifyChief({
    required String chiefUid,
    required String userName,
    required String boardId,
    String? imagePath,
  }) async {
    final Dio dio = Dio();

    try {
      await dio.post(
        ApiRoutes.userJoinNotification,
        data: {
          "chiefUid": chiefUid,
          "newUserName": userName,
          "boardId": boardId,
          'imagePath': imagePath,
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
    } on FirebaseException catch (exe) {
      throw Exception(exe);
    } catch (e) {
      throw Exception(e);
    }
  }
}
