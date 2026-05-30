import 'dart:async';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:family_management_app/app/api/api_routes.dart';
import 'package:family_management_app/screens/functionality/child_screen.dart';
import 'package:family_management_app/service/secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
part 'fetch_user_state.dart';

class FetchUserCubit extends Cubit<FetchUserState> {
  FetchUserCubit()
    : super(
        FetchUserState(
          logoutStatus: FetchRequestStatus.initial,
          fetchAllUserStatus: FetchRequestStatus.initial,
          fetchJoinRequestForHomePageStatus: FetchRequestStatus.initial,
          fetchJoinRequestsNotificationStatus: FetchRequestStatus.initial,
          checkWaitingStatus: FetchRequestStatus.initial,
          fetchCommandCenterInfoStatus: FetchRequestStatus.initial,
          fetchProfileInfoStatus: FetchRequestStatus.initial,
          fetchProfileInfoChildStatus: FetchRequestStatus.initial,
        ),
      );

  StreamSubscription? _userSubscription;

  Future<void> logOut() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    emit(
      state.copyWith(
        logoutStatus: FetchRequestStatus.loading,
        errorMsg: "Logging Out.... Please Wait",
      ),
    );
    try {
      await GoogleSignIn().signOut();
      await auth.signOut();
      emit(
        state.copyWith(
          logoutStatus: FetchRequestStatus.sucess,
          errorMsg: "log Out Successfully",
        ),
      );
    } on FirebaseAuthException catch (exe) {
      emit(
        state.copyWith(
          logoutStatus: FetchRequestStatus.failed,
          errorMsg: exe.toString(),
        ),
      );
    }
  }

  Future<void> getAllUserBasedonRole() async {
    final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    final String boardId = await AppStorage.read(key: "boardId") ?? "";
    // final String email = await AppStorage.read(key: "email") ?? "";

    emit(
      state.copyWith(
        fetchAllUserStatus: FetchRequestStatus.loading,
        errorMsg: "User Fetching.......",
      ),
    );

    try {
      final snapshot = await firebaseFirestore
          .collection('board')
          .doc(boardId)
          .collection('joinRequests')
          .where('joinStatus', isEqualTo: 'accepted')
          .get();

      final userList = snapshot.docs.map((doc) {
        final data = doc.data();
        return AllUserInfo(
          uid: data['uid'] ?? '',
          name: data['name'] ?? '',
          email: data['email'] ?? '',
          imagePath: data['imagePath'] ?? "",
          role: data['role'] ?? '',
        );
      }).toList();

      emit(
        state.copyWith(
          fetchAllUserStatus: FetchRequestStatus.sucess,
          userInfo: userList,
          errorMsg: "All User Fetched Successfully",
        ),
      );
    } on FirebaseException catch (exe) {
      emit(
        state.copyWith(
          fetchAllUserStatus: FetchRequestStatus.failed,
          errorMsg: exe.toString(),
        ),
      );
    }
  }

  Future<void> fetchJoinRequestsForHomePage() async {
    final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    final String boardId = await AppStorage.read(key: "boardId") ?? "";
    final String role = await AppStorage.read(key: "savedRole") ?? "";

    emit(
      state.copyWith(
        fetchJoinRequestForHomePageStatus: FetchRequestStatus.loading,
      ),
    );
    try {
      await _userSubscription?.cancel();

      if (role == "Chief") {
        _userSubscription = firebaseFirestore
            .collection('board')
            .doc(boardId)
            .collection("joinRequests")
            .where('joinStatus', isEqualTo: 'pending')
            .snapshots()
            .listen((snapShot) {
              emit(
                state.copyWith(
                  fetchJoinRequestForHomePageStatus: FetchRequestStatus.sucess,
                  pendingUserCount: snapShot.docs.length,
                ),
              );
            });
      } else {
        emit(
          state.copyWith(
            fetchJoinRequestForHomePageStatus: FetchRequestStatus.sucess,
            pendingUserCount: 0,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          fetchJoinRequestForHomePageStatus: FetchRequestStatus.failed,
          errorMsg: e.toString(),
        ),
      );
    }
  }

  Future<void> fetchJoinRequestsNotification() async {
    final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    final String boardId = await AppStorage.read(key: "boardId") ?? "";

    emit(
      state.copyWith(
        fetchJoinRequestsNotificationStatus: FetchRequestStatus.loading,
      ),
    );

    try {
      firebaseFirestore
          .collection('board')
          .doc(boardId)
          .collection('joinRequests')
          .orderBy('createdAt', descending: true)
          .where('joinStatus', isEqualTo: 'pending')
          .snapshots()
          .listen((snapshot) {
            final list = snapshot.docs
                .map(
                  (doc) => {
                    'email': doc['email'] ?? '',
                    'name': doc['name'] ?? '',
                    'imagePath': doc['imagePath'] ?? '',
                    'uid': doc['uid'] ?? '',
                    'joinStatus': doc['joinStatus'] ?? '',
                    'createdAt': doc['createdAt'] ?? "",
                  },
                )
                .toList();

            emit(
              state.copyWith(
                joinRequestList: list,
                fetchJoinRequestsNotificationStatus: FetchRequestStatus.sucess,
              ),
            );
          });
    } catch (e) {
      emit(
        state.copyWith(
          fetchJoinRequestsNotificationStatus: FetchRequestStatus.failed,
          errorMsg: e.toString(),
        ),
      );
    }
  }

  Future<void> rejectJoinRequest(String docId, String name) async {
    final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    final String boardId = await AppStorage.read(key: "boardId") ?? "";
    emit(state.copyWith(rejectStatus: FetchRequestStatus.loading));
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      await notifyUserRejection(userUid: docId, boardId: boardId);
      await firebaseFirestore
          .collection('board')
          .doc(boardId)
          .collection("joinRequests")
          .doc(docId)
          .delete();
      await firebaseFirestore.collection('users').doc(docId).delete();
      emit(
        state.copyWith(
          rejectStatus: FetchRequestStatus.sucess,
          errorMsg: "❌ $name has been rejected.",
        ),
      );
      notifyUserRejection(userUid: docId, boardId: boardId);
    } catch (e) {
      emit(
        state.copyWith(
          rejectStatus: FetchRequestStatus.failed,
          errorMsg: e.toString(),
        ),
      );
    }
  }

  Future<void> acceptJoinRequest(
    String email,
    String docId,
    String role,
    String name,
  ) async {
    final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    final String boardId = await AppStorage.read(key: "boardId") ?? "";
    final String chiefImagePath = await AppStorage.read(key: "imagePath") ?? "";
    final String chiefName = await AppStorage.read(key: "name") ?? "";
    final String chiefEmail = await AppStorage.read(key: "email") ?? "";

    emit(state.copyWith(approveStatus: FetchRequestStatus.loading));
    try {
      await Future.delayed(const Duration(seconds: 1));
      await firebaseFirestore
          .collection('board')
          .doc(boardId)
          .collection("joinRequests")
          .doc(docId)
          .update({'role': role, "joinStatus": 'accepted'});

      await firebaseFirestore.collection('users').doc(docId).update({
        'role': role,
        "joinStatus": 'accepted',
      });

      emit(
        state.copyWith(
          approveStatus: FetchRequestStatus.sucess,
          errorMsg: "✅ $name has been approved as $role.",
        ),
      );
      sendUserWelcomeEMail(
        chiefEmail: chiefEmail,
        role: role,
        userEmail: email,
        userName: name,
        userUid: docId,
        boardId: boardId,
      );
      notifyUserAcceptance(userUid: docId, boardId: boardId, role: role);
    } catch (e) {
      emit(
        state.copyWith(
          approveStatus: FetchRequestStatus.failed,
          errorMsg: e.toString(),
        ),
      );
    }
  }

  Future<void> checkWaiting({required String boardId}) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final FirebaseAuth auth = FirebaseAuth.instance;
    final uid = auth.currentUser?.uid;

    emit(
      state.copyWith(
        checkWaitingStatus: FetchRequestStatus.loading,
        itemCount: state.joinRequestList?.length ?? 5,
      ),
    );
    try {
      final singleSnapShot = await firestore.collection("users").doc(uid).get();
      final roleStatus = singleSnapShot.data()?['joinStatus'] as String?;

      log("RoleStatus: $roleStatus");

      emit(
        state.copyWith(
          checkWaitingStatus: FetchRequestStatus.sucess,
          roleStatus: roleStatus,
        ),
      );
    } catch (e) {
      // handle error
      emit(state.copyWith(checkWaitingStatus: FetchRequestStatus.failed));
    }
  }

  void resetNotificationCount() {
    emit(state.copyWith(itemCount: 0));
  }

  Future<void> fetchCommandCenterInfo() async {
    final FirebaseFirestore firebaseFireStore = FirebaseFirestore.instance;

    emit(
      state.copyWith(
        fetchCommandCenterInfoStatus: FetchRequestStatus.loading,
        errorMsg: "Data Fetching",
      ),
    );

    try {
      final String? boardId = await AppStorage.read(key: "boardId");

      await _userSubscription?.cancel();

      _userSubscription = firebaseFireStore
          .collection("users")
          .where('boardId', isEqualTo: boardId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen((snapshot) {
            final userList = snapshot.docs.map((doc) {
              final data = doc.data();
              return AllUserInfo(
                uid: data['uid'] ?? '',
                email: data['email'] ?? '',
                name: data['name'] ?? '',
                imagePath: data['imagePath'] ?? '',
                role: data['role'] ?? '',
                joinStatus: data['joinStatus'] ?? "",
              );
            }).toList();
            userList.sort((a, b) {
              int rolePriority(String role) {
                switch (role) {
                  case 'Chief':
                    return 1;
                  case 'Co-Chief':
                    return 2;
                  case 'Unit Lead':
                    return 3;
                  default: // Stakeholders / Kids
                    return 4;
                }
              }

              return rolePriority(a.role!).compareTo(rolePriority(b.role!));
            });

            emit(
              state.copyWith(
                fetchCommandCenterInfoStatus: FetchRequestStatus.sucess,
                userInfo: userList,
                errorMsg: "All Users Fetched Successfully",
                itemCount: userList.length,
              ),
            );
          });
    } on FirebaseException catch (exe) {
      emit(
        state.copyWith(
          fetchCommandCenterInfoStatus: FetchRequestStatus.failed,
          errorMsg: exe.message,
        ),
      );
    }
  }

  Future<void> fetchProfileInfo({required String uid}) async {
    final FirebaseFirestore firebaseFireStore = FirebaseFirestore.instance;

    emit(
      state.copyWith(
        fetchProfileInfoStatus: FetchRequestStatus.loading,
        errorMsg: "Data Fetching",
      ),
    );

    try {
      final String? boardId = await AppStorage.read(key: "boardId");
      final snapshot = await firebaseFireStore
          .collection("board")
          .doc(boardId)
          .collection("joinRequests")
          .doc(uid)
          .get();

      final userInfo = snapshot.data();

      final userEmail = userInfo?['email'] as String? ?? "";
      final userName = userInfo?['name'] as String? ?? "";
      final userRole = userInfo?['role'] as String? ?? "";
      final userImage = userInfo?['imagePath'] as String? ?? "";

      emit(
        state.copyWith(
          fetchProfileInfoStatus: FetchRequestStatus.sucess,
          email: userEmail,
          name: userName,
          imagePath: userImage,
          role: userRole,

          errorMsg: "All User Fetched Sucessfully",
        ),
      );
    } on FirebaseException catch (exe) {
      emit(
        state.copyWith(
          fetchProfileInfoStatus: FetchRequestStatus.failed,
          errorMsg: exe.message,
        ),
      );
    }
  }

  Future<void> fetchProfileInfoChild({required String uid}) async {
    log("fetchig");
    emit(
      state.copyWith(
        fetchProfileInfoChildStatus: FetchRequestStatus.loading,
        errorMsg: "Data Fetching",
      ),
    );

    try {
      final String? boardId = await AppStorage.read(key: "boardId");

      FirebaseFirestore.instance
          .collection("children")
          .doc(boardId)
          .collection('child')
          .doc(uid)
          .snapshots()
          .listen((snapshot) {
            if (snapshot.exists) {
              final data = snapshot.data()!;
              final childProfile = ChildProfile(
                name: data['name'] ?? '',
                age: data['age'] ?? '',
                dob: data['date'] ?? "",
                photo: null,
                imagePath: data['imagePath'] ?? '',
                gender: data['gender'] ?? "",
                schoolAddress: data["schoolAddress"],
                schoolName: data['schoolName'],
                grade: data['grade'],
                classScheduleDate: data['classDate'] ?? "",
                classScheduleTime: data['classTime'] ?? "",
                allergies: data['allergies'] ?? "",
                medicalInformation: data['medicalInfo'],
                generalNotes: data['generalNotes'],
                optionalEnhancements: data['optionalInfo'],
              );
              emit(
                state.copyWith(
                  fetchProfileInfoChildStatus: FetchRequestStatus.sucess,
                  childInfo: childProfile,
                ),
              );
            }
          });
    } on FirebaseException catch (exe) {
      emit(
        state.copyWith(
          fetchProfileInfoChildStatus: FetchRequestStatus.failed,
          errorMsg: exe.message,
        ),
      );
    }
  }

  Future<void> deleteUserFromFirestore(List<String> uid) async {
    try {
      final String boardId = await AppStorage.read(key: "boardId") ?? "";
      await Future.delayed(Duration(seconds: 1));
      final updatedUsers = List<AllUserInfo>.from(state.userInfo!)
        ..removeWhere((user) => uid.contains(user.uid));
      emit(state.copyWith(userInfo: updatedUsers));

      for (var ids in uid) {
        await FirebaseFirestore.instance.collection('users').doc(ids).delete();
        await FirebaseFirestore.instance
            .collection('children')
            .doc(boardId)
            .collection('child')
            .doc(ids)
            .delete();
      }

      log("User document deleted successfully.");
    } catch (e) {
      log("Error deleting user document: $e");
    }
  }

  Future<void> deleteUserLeadFromFirestore(List<String> uid) async {
    try {
      final String boardId = await AppStorage.read(key: "boardId") ?? "";
      await Future.delayed(Duration(seconds: 1));
      final updatedUsers = List<AllUserInfo>.from(state.userInfo!)
        ..removeWhere((user) => uid.contains(user.uid));
      emit(state.copyWith(userInfo: updatedUsers));

      for (var ids in uid) {
        await FirebaseFirestore.instance.collection('users').doc(ids).delete();
        await FirebaseFirestore.instance
            .collection('board')
            .doc(boardId)
            .collection('joinRequests')
            .doc(ids)
            .delete();
      }
      log("User document deleted successfully.");
    } catch (e) {
      log("Error deleting user document: $e");
    }
  }

  void resetState() {
    emit(
      state.copyWith(fetchProfileInfoChildStatus: FetchRequestStatus.initial),
    );
  }

  void inviteUser() {
    const String message = '''
Hey 👋, join me on this awesome app!
Download it here: https://play.google.com/store/apps/details?id=com.example.app
Or on iOS: https://apps.apple.com/app/idXXXXXXXX
''';
    Share.share(message, subject: "You're invited!");
  }

  Future<void> notifyUserAcceptance({
    required String userUid,
    required String boardId,
    required String role,
  }) async {
    final Dio dio = Dio();
    try {
      await dio.post(
        ApiRoutes.notifyUserAcceptance,
        data: {'userUid': userUid, 'boardId': boardId, "role": role},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
    } catch (exe) {
      throw Exception(exe.toString());
    }
  }

  Future<void> notifyUserRejection({
    required String userUid,
    required String boardId,
  }) async {
    final Dio dio = Dio();
    try {
      await dio.post(
        ApiRoutes.notifyUserRejection,
        data: {'userUid': userUid, 'boardId': boardId},
        options: Options(headers: {'Content-Type': "application/json"}),
      );
    } catch (exe) {
      throw Exception(exe.toString());
    }
  }

  Future<void> sendUserWelcomeEMail({
    required String chiefEmail,
    required String userName,
    required String userEmail,
    required String role,
    required String boardId,
    String? userUid,
  }) async {
    final Dio dio = Dio();
    try {
      await dio.post(
        ApiRoutes.sendUserAcceptedWelcomeEmail,
        data: {
          "chiefEmail": chiefEmail,
          "userName": userName,
          "userEmail": userEmail,
          'role': role,
          'userUid': userUid,
          'boardId': boardId,
        },
        options: Options(headers: {'Content-Type': "application/json"}),
      );
    } catch (exe) {
      throw Exception(exe);
    }
  }
}
