import 'dart:async';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:family_management_app/app/api/firebaseauth_Exception.dart';
import 'package:family_management_app/service/secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginState(status: LoginStatus.initialLogin));

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  String capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  Future<void> login({required String email, required String password}) async {
    // final String? freshFcmToken = await FirebaseMessaging.instance.getToken();
    emit(
      state.copyWith(
        status: LoginStatus.logging,
        errorMsg: "Logging in please wait",
      ),
    );

    try {
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      final user = userCredential.user;
      final userUid = user?.uid;

      final userDoc = await firestore.collection('users').doc(userUid).get();

      final savedName = userDoc.data()?['name'] as String?;
      final savedEmail = userDoc.data()?['email'] as String?;
      final savedRole = userDoc.data()?['role'] as String?;
      final savedUid = userDoc.data()?['uid'] as String?;
      final savedBoardId = userDoc.data()?['boardId'] as String?;
      final savedImagePath = userDoc.data()?['imagePath'] as String?;

      if (userDoc.data()?['role'] == null &&
          userDoc.data()?['joinStatus'] == "pending") {
        emit(
          state.copyWith(
            status: LoginStatus.loginFailure,
            errorMsg: "You are not assigned a role yet.",
          ),
        );
        return;
      } else if (userDoc.data()?['role'] == "Chief" &&
          user!.emailVerified == false) {
        emit(
          state.copyWith(
            status: LoginStatus.loginFailure,
            errorMsg: "Please verify your email first to continue.",
          ),
        );
        return;
      } else if (userDoc.data()?['role'] == null &&
          userDoc.data()?['joinStatus'] == null) {
        emit(
          state.copyWith(
            status: LoginStatus.navigateToRoleUpdate,
            errorMsg: "You haven’t completed your setup yet.",
          ),
        );
        return;
      } else if (userDoc.data()?['role'] != null &&
          userDoc.data()?['joinStatus'] == 'invited') {
        emit(
          state.copyWith(
            status: LoginStatus.isInvited,
            errorMsg: "Please Setup your account",
            uid: userUid,
            boardId: savedBoardId,
          ),
        );
        return;
      }

      await AppStorage.save(key: "email", data: savedEmail!);
      await AppStorage.save(key: "name", data: capitalizeFirst(savedName!));
      await AppStorage.save(key: "uid", data: savedUid!);
      await AppStorage.save(key: "savedRole", data: savedRole!);
      await AppStorage.save(key: "boardId", data: savedBoardId!);
      await AppStorage.save(key: "imagePath", data: savedImagePath!);

      emit(
        state.copyWith(
          status: LoginStatus.logged,
          errorMsg: "Logged in successfully",
        ),
      );

      // await firestore.collection('users').doc(userUid).update({
      //   "wasLogin": true,
      //   "fcmToken": freshFcmToken,
      // });
    } on FirebaseAuthException catch (exe) {
      final errorMessage = FirebaseAuthErrorHandler.getMessage(exe);

      emit(
        state.copyWith(
          status: LoginStatus.loginFailure,
          errorMsg: errorMessage,
        ),
      );
    }
  }

  Future<void> signInWithGoogle() async {
    final String? freshFcmToken = await FirebaseMessaging.instance.getToken();
    emit(
      state.copyWith(
        status: LoginStatus.googleLogin,
        errorMsg: "Google Signing in... Please Wait",
      ),
    );

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        emit(
          state.copyWith(
            status: LoginStatus.googleLoginFailure,
            errorMsg: "Sign-in canceled by user",
          ),
        );
        log("Sign-in canceled by user");
        return;
      }

      final googleAuth = await googleUser.authentication;

      // ⚡ Changed: removed intermediate variable creation, directly create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // ⚡ Changed: directly sign in user
      final userCredential = await firebaseAuth.signInWithCredential(
        credential,
      );
      final googleUsers = userCredential.user;

      if (googleUsers == null) {
        emit(
          state.copyWith(
            status: LoginStatus.googleLoginFailure,
            errorMsg: "Google sign-in failed. Please try again.",
          ),
        );
        return;
      }

      final displayName = googleUsers.displayName ?? "";
      final email = googleUsers.email ?? "";
      final photoUrl = googleUsers.photoURL ?? "";

      log(
        "User => UID: ${googleUsers.uid}, Name: $displayName, Email: $email, Photo: $photoUrl",
      );

      final userDocs = firestore.collection('users').doc(googleUsers.uid);
      final userDoc = await userDocs.get();

      if (userDoc.exists) {
        final savedGoogleRole = userDoc.data()?['role'] as String?;
        final savedGoogleBoardId = userDoc.data()?['boardId'] as String?;

        if (savedGoogleRole != null) {
          // ⚡ Changed: save multiple values at once (parallel writes) for faster performance
          await Future.wait([
            AppStorage.save(key: "savedRole", data: savedGoogleRole),
            AppStorage.save(key: "uid", data: googleUsers.uid),
            AppStorage.save(key: "boardId", data: savedGoogleBoardId ?? ""),
            userDocs.update({"wasLogin": true, "fcmToken": freshFcmToken}),
          ]);
        }

        if (savedGoogleRole == null &&
            userDoc.data()?['joinStatus'] == "pending") {
          emit(
            state.copyWith(
              status: LoginStatus.googleLoginFailure,
              errorMsg: "You are not assigned a role yet.",
            ),
          );
          await GoogleSignIn().signOut();
          return;
        }
      } else if (!userDoc.exists) {
        // ⚡ Changed: directly create user document if not exists
        await userDocs.set({
          'uid': googleUsers.uid,
          'name': displayName,
          'createdAt': FieldValue.serverTimestamp(),
          'email': email,
          'imagePath': photoUrl,
          'role': null,
          'joinStatus': null,
          "isGoogle": true,
          "wasLogin": true,

          // ⚡ Changed: save as true immediately
        });
      }

      // ⚡ Changed: save data in parallel for faster execution
      await Future.wait([
        AppStorage.save(key: "email", data: email),
        AppStorage.save(key: "name", data: capitalizeFirst(displayName)),
        AppStorage.save(key: "imagePath", data: photoUrl),
      ]);

      emit(
        state.copyWith(
          status: LoginStatus.googleLoginSuccessful,
          errorMsg: "Google Sign-In successful",
          uid: googleUsers.uid,
        ),
      );

      log("Signed in as: ${googleUsers.displayName}");
    } on FirebaseAuthException catch (exe) {
      final errorMessage = FirebaseAuthErrorHandler.getMessage(exe);
      emit(
        state.copyWith(
          status: LoginStatus.googleLoginFailure,
          errorMsg: errorMessage,
        ),
      );
      log('FirebaseAuthException: ${exe.message}');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    emit(
      state.copyWith(
        status: LoginStatus.forgetting,
        errorMsg: "Sending password reset email",
      ),
    );
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email.trim());
      emit(
        state.copyWith(
          status: LoginStatus.forgetSucessful,
          errorMsg: "Password reset email sent successfully",
        ),
      );
      log('Password reset email sent to $email');
    } on FirebaseAuthException catch (exe) {
      final errorMessage = FirebaseAuthErrorHandler.getMessage(exe);
      emit(
        state.copyWith(
          status: LoginStatus.forgetFailure,
          errorMsg: errorMessage,
        ),
      );

      log('FirebaseAuthException: ${exe.message}');
    }
  }
}
