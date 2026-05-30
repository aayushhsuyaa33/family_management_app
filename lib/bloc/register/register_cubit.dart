import 'dart:developer';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:family_management_app/app/api/api_routes.dart';
import 'package:family_management_app/app/api/firebaseauth_Exception.dart';
import 'package:family_management_app/bloc/fetch%20User/fetch_user_cubit.dart';
import 'package:family_management_app/service/secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit()
    : super(RegisterState(status: RegisterStatus.initialregister));

  Future<void> signUp({
    required String email,
    required String password,
    required String confirmPassword,
    required String name,
    XFile? profileImage,
  }) async {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    emit(
      state.copyWith(
        status: RegisterStatus.registering,
        errorMsg: "Registering... please wait",
      ),
    );

    try {
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception("User creation failed!");
      }
      String imagePath = "";

      if (profileImage != null) {
        imagePath = await uploadProfileImage(profileImage, user.uid);
      }

      await firestore.collection("users").doc(user.uid).set({
        "uid": user.uid,
        "name": name,
        "email": email,
        "createdAt": FieldValue.serverTimestamp(),
        "imagePath": imagePath,
        "role": null,
        "joinStatus": null,
        "wasApprovedShown": false,
        "wasLogin": false,
        'isGoogle': false,
      });

      emit(
        state.copyWith(
          status: RegisterStatus.registered,
          errorMsg: "Your account has been successfully created",
          uid: user.uid,
          email: email,
          name: name,
        ),
      );
      emit(state.copyWith(status: RegisterStatus.initialregister));
    } on FirebaseAuthException catch (exe) {
      final errorMessage = FirebaseAuthErrorHandler.getMessage(exe);
      emit(
        state.copyWith(
          status: RegisterStatus.registerFailure,
          errorMsg: errorMessage,
        ),
      );
      emit(state.copyWith(status: RegisterStatus.initialregister));
    }
  }

  Future<String> uploadProfileImage(XFile image, String uid) async {
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

  Future<void> getLeadDetailsForEdit({String? uid, String? boardId}) async {
    final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

    emit(state.copyWith(fetchMemberStatus: RegisterStatus.registering));

    try {
      final snapshot = await firebaseFirestore
          .collection('board')
          .doc(boardId)
          .collection("joinRequests")
          .doc(uid)
          .get();

      if (!snapshot.exists) {
        log("Document does NOT exist for UID: $uid");
        emit(
          state.copyWith(
            fetchMemberStatus: RegisterStatus.registerFailure,
            errorMsg: "User not found",
          ),
        );
        return;
      }

      final data = snapshot.data();
      if (data == null) {
        log("Snapshot data is null");
        emit(
          state.copyWith(
            fetchMemberStatus: RegisterStatus.registerFailure,
            errorMsg: "Data not found",
          ),
        );
        return;
      }
      final userInfo = AllUserInfo(
        uid: data['uid'] ?? '',
        email: data['email'] ?? '',
        name: data['name'] ?? '',
        imagePath: data['imagePath'] ?? '',
        role: data['role'] ?? '',
      );

      emit(
        state.copyWith(
          fetchMemberStatus: RegisterStatus.registered,
          userInfo: [userInfo],
        ),
      );
    } on FirebaseException catch (exe) {
      emit(
        state.copyWith(
          fetchMemberStatus: RegisterStatus.registerFailure,
          errorMsg: exe.code,
        ),
      );
    }
  }

  Future<void> updateInviteDetails({
    required String name,
    required String uid,
    required String password,
    required String boardId,
    XFile? profileImage,
    required String email,
  }) async {
    final firebaseFirestore = FirebaseFirestore.instance;
    final firebaseAuth = FirebaseAuth.instance;

    emit(
      state.copyWith(
        loginStatus: RegisterStatus.registering,
        errorMsg: "logging in...... Please wait",
      ),
    );

    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      User? user = FirebaseAuth.instance.currentUser;
      final firestoreDoc = firebaseFirestore
          .collection("board")
          .doc(boardId)
          .collection('joinRequests');

      final userFireStore = FirebaseFirestore.instance.collection('users');

      String? imagePath;
      if (profileImage != null) {
        imagePath = await uploadProfileImage(profileImage, uid);
      }

      Map<String, dynamic> taskData = {
        "name": name,
        "joinedAt": FieldValue.serverTimestamp(),
        "joinStatus": "accepted",
        "fcmToken": fcmToken ?? "",
      };
      if (imagePath != null) {
        taskData['imagePath'] = imagePath;
      }
      if (user != null) {
        await user.updatePassword(password);
        log("Password updated successfully!");
      } else {
        ("No user is signed in.");
      }

      await firestoreDoc.doc(uid).update(taskData);
      await userFireStore.doc(uid).update(taskData);

      final userDoc = await firebaseFirestore
          .collection('users')
          .doc(uid)
          .get();

      final savedRole = userDoc.data()?['role'] as String?;
      final chiefName = userDoc.data()?['chiefName'] as String?;
      final chiefId = userDoc.data()?['chiefId'] as String?;

      final chiefEmail = userDoc.data()?['chiefEmail'] as String?;
      final existingImage = userDoc.data()?['imagePath'] as String?;

      await AppStorage.save(key: "email", data: email);
      await AppStorage.save(key: "name", data: name);
      await AppStorage.save(key: "uid", data: uid);
      await AppStorage.save(key: "savedRole", data: savedRole!);
      await AppStorage.save(key: "boardId", data: boardId);
      await AppStorage.save(key: "imagePath", data: existingImage ?? "");

      log(
        "SavedUserData → email=$email | name=$name | uid=$uid | role=$savedRole | boardId=$boardId | imagePath=${imagePath ?? ''} | chiefName=$chiefName | chiefEmail=$chiefEmail",
      );

      await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      emit(
        state.copyWith(
          loginStatus: RegisterStatus.registered,
          errorMsg: "Setup Succesful",
        ),
      );
      userAcceptedNotification(
        chiefUid: chiefId ?? "",
        userName: name,
        boardId: boardId,
        imagePath: existingImage,
      );

      sendInvitationAcceptedEmail(
        chiefEmail: chiefEmail ?? "",
        chiefName: chiefName ?? "",
        acceptedDate: DateTime.now().toString(),
        role: savedRole,
        userEmail: email,
        userUid: uid,
        boardId: boardId,
      );

      Future.delayed(const Duration(milliseconds: 500), () {
        emit(state.copyWith(loginStatus: RegisterStatus.initialregister));
      });
    } on FirebaseException catch (e) {
      emit(
        state.copyWith(
          loginStatus: RegisterStatus.registerFailure,
          errorMsg: e.code,
        ),
      );
      Future.delayed(const Duration(milliseconds: 500), () {
        emit(state.copyWith(loginStatus: RegisterStatus.initialregister));
      });
    }
  }

  Future<void> sendInvitationAcceptedEmail({
    required String chiefName,
    required String chiefEmail,
    required String userEmail,
    required String role,
    required String acceptedDate,
    required String boardId,
    required String userUid,
  }) async {
    final Dio dio = Dio();

    try {
      await dio.post(
        ApiRoutes.accptedLink,
        data: {
          "chiefName": chiefName,
          "chiefEmail": chiefEmail,
          "userEmail": userEmail,
          "role": role,
          "acceptedDate": acceptedDate,
          "boardId": boardId,
          "userUid": userUid,
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
    } on FirebaseException catch (exe) {
      log(exe.toString());
      throw Exception(exe);
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  Future<void> userAcceptedNotification({
    required String chiefUid,
    required String userName,
    required String boardId,
    String? imagePath,
  }) async {
    final Dio dio = Dio();

    try {
      await dio.post(
        ApiRoutes.userAcceptedNotification,
        data: {
          "chiefUid": chiefUid,
          "newUserName": userName,
          'boardId': boardId,
          'imagePath': imagePath,
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
    } on FirebaseException catch (exe) {
      log(exe.toString());
      throw Exception(exe);
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }
}
