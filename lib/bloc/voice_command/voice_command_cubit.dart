import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:family_management_app/bloc/fetch%20User/fetch_user_cubit.dart';
import 'package:family_management_app/service/secure_storage.dart';

part 'voice_command_state.dart';

class VoiceCommandCubit extends Cubit<VoiceCommandState> {
  VoiceCommandCubit()
    : super(
        VoiceCommandState(checkingMemberStatus: VoiceCommandStatus.initial),
      );

  Future<bool> checkMemberExists(String memberName) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    emit(state.copyWith(checkingMemberStatus: VoiceCommandStatus.loading));
    try {
      final boardId = await AppStorage.read(key: "boardId") ?? "";
      final normalizedName = memberName.trim().toLowerCase();

      final snapshot = await firestore
          .collection('users')
          .where('boardId', isEqualTo: boardId)
          .where('joinStatus', isNotEqualTo: null)
          .get();

      final allMembers = snapshot.docs.map((doc) {
        final data = doc.data();
        return AllUserInfo(
          uid: data['uid'] ?? '',
          name: data['name'] ?? '',
          email: data['email'] ?? '',
          imagePath: data['imagePath'] ?? '',
          role: data['role'] ?? '',
        );
      }).toList();

      final exists = allMembers.any((user) {
        return user.name.trim().toLowerCase() == normalizedName;
      });

      log("🔍 Member check for '$memberName': $exists");

      emit(
        state.copyWith(
          checkingMemberStatus: exists
              ? VoiceCommandStatus.success
              : VoiceCommandStatus.failure,
        ),
      );
      return exists;
    } catch (e) {
      emit(
        state.copyWith(
          checkingMemberStatus: VoiceCommandStatus.failure,
          errorMessage: "Error checking member: $e",
        ),
      );
      return false;
    }
  }

  Future<void> getAllUserBasedonRole(String name) async {
    final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    final String boardId = await AppStorage.read(key: "boardId") ?? "";
    // final String email = await AppStorage.read(key: "email") ?? "";

    emit(
      state.copyWith(
        fetchUserInfoStatus: VoiceCommandStatus.loading,
        errorMessage: "User Fetching.......",
      ),
    );

    try {
      final snapshot = await firebaseFirestore
          .collection('users')
          .where('joinStatus', isNotEqualTo: null)
          .where('boardId', isEqualTo: boardId)
          .where('name', isEqualTo: name)
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
      log(userList.first.name.toString());
      log(userList.first.name.toString());

      emit(
        state.copyWith(
          fetchUserInfoStatus: VoiceCommandStatus.success,
          userInfo: userList,
          errorMessage: "All User Fetched Successfully",
        ),
      );
    } on FirebaseException catch (exe) {
      emit(
        state.copyWith(
          fetchUserInfoStatus: VoiceCommandStatus.failure,
          errorMessage: exe.toString(),
        ),
      );
    }
  }
}
