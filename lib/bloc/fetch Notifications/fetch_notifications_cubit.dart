import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:family_management_app/service/secure_storage.dart';

part 'fetch_notifications_state.dart';

class FetchNotificationsCubit extends Cubit<FetchNotificationsState> {
  FetchNotificationsCubit()
    : super(
        FetchNotificationsState(
          notifiactionStatus: FetchNotificationStatus.initial,
          notifiactionStatusMember: FetchNotificationStatus.initial,
        ),
      );

  List<DocumentSnapshot> _docs = [];
  DocumentSnapshot? _lastDoc;
  bool _hasMore = true;

  bool get hasMore => _hasMore;

  Future<void> fetchFirstNotificationsForChief() async {
    final String boardId = await AppStorage.read(key: 'boardId') ?? "";
    final firebaseDoc = FirebaseFirestore.instance;

    emit(state.copyWith(notifiactionStatus: FetchNotificationStatus.loading));

    try {
      final snapshot = await firebaseDoc
          .collection('notifications')
          .doc(boardId)
          .collection('chief')
          .orderBy('timestamp', descending: true)
          .limit(9)
          .get();

      _docs = snapshot.docs;
      _lastDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
      _hasMore = snapshot.docs.length == 9;

      final notificationList = _docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        return {
          'title': data['title'] ?? "",
          'body': data['body'] ?? "",
          'type': data['type'] ?? "",
          "recipientUid": data["recipientUid"],
          'createdAt': data['timestamp'],
          'name': data['name'] ?? "",
          'imagePath': data['imagePath'],
        };
      }).toList();
      emit(
        state.copyWith(
          notifiactionStatus: FetchNotificationStatus.success,
          notificationList: notificationList,
          errorMsg: "Notification Fetched Success",
        ),
      );
    } catch (exe) {
      emit(
        state.copyWith(
          notifiactionStatus: FetchNotificationStatus.failed,
          errorMsg: exe.toString(),
        ),
      );
    }
  }

  Future<void> fetchNextNotificationsChief() async {
    if (!_hasMore || _lastDoc == null) return;
    final String boardId = await AppStorage.read(key: 'boardId') ?? "";
    final firebaseDoc = FirebaseFirestore.instance;
    try {
      final snapshot = await firebaseDoc
          .collection('notifications')
          .doc(boardId)
          .collection('chief')
          .orderBy('timestamp', descending: true)
          .startAfterDocument(_lastDoc!)
          .limit(9)
          .get();

      _docs.addAll(snapshot.docs);
      _lastDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : _lastDoc!;
      _hasMore = snapshot.docs.length == 9;

      final notificationList = _docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        return {
          'title': data['title'] ?? "",
          'body': data['body'] ?? "",
          'type': data['type'] ?? "",
          "recipientUid": data["recipientUid"],
          'createdAt': data['timestamp'],
          'name': data['name'] ?? "",
          'imagePath': data['imagePath'],
        };
      }).toList();
      emit(
        state.copyWith(
          notifiactionStatus: FetchNotificationStatus.success,
          notificationList: notificationList,
          errorMsg: "Notification Fetched Success",
        ),
      );
    } catch (exe) {
      emit(
        state.copyWith(
          notifiactionStatus: FetchNotificationStatus.failed,
          errorMsg: exe.toString(),
        ),
      );
    }
  }

  Future<void> fetchFirstNotificationMember() async {
    final String boardId = await AppStorage.read(key: 'boardId') ?? "";
    final String savedUid = await AppStorage.read(key: 'uid') ?? "";
    final firebaseDoc = FirebaseFirestore.instance;

    emit(
      state.copyWith(notifiactionStatusMember: FetchNotificationStatus.loading),
    );
    try {
      final snapshot = await firebaseDoc
          .collection('notifications')
          .doc(boardId)
          .collection('members')
          .where('recipientUid', isEqualTo: savedUid)
          .orderBy('timestamp', descending: true)
          .limit(9)
          .get();

      _docs = snapshot.docs;
      _lastDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
      _hasMore = snapshot.docs.length == 9;

      final notificationList = _docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        return {
          'title': data['title'] ?? "",
          'body': data['body'] ?? "",
          'type': data['type'] ?? "",
          'recipientUid': data['recipientUid'] ?? "",
          'createdAt': data['timestamp'],
          'name': data['name'] ?? "",
          'imagePath': data['imagePath'],
        };
      }).toList();

      emit(
        state.copyWith(
          notifiactionStatusMember: FetchNotificationStatus.success,
          notificationListMember: notificationList,
        ),
      );
    } catch (exe) {
      emit(
        state.copyWith(
          notifiactionStatusMember: FetchNotificationStatus.failed,
          errorMsg: exe.toString(),
        ),
      );
    }
  }

  Future<void> fetchNextNotificationsMember() async {
    if (!_hasMore || _lastDoc == null) return;

    final String boardId = await AppStorage.read(key: 'boardId') ?? "";
    final String savedUid = await AppStorage.read(key: 'uid') ?? "";
    final firebaseDoc = FirebaseFirestore.instance;

    try {
      final snapshot = await firebaseDoc
          .collection('notifications')
          .doc(boardId)
          .collection('members')
          .where('recipientUid', isEqualTo: savedUid)
          .orderBy('timestamp', descending: true)
          .startAfterDocument(_lastDoc!)
          .limit(9)
          .get();

      _docs.addAll(snapshot.docs);
      _lastDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : _lastDoc;
      _hasMore = snapshot.docs.length == 9;

      final notificationList = _docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        return {
          'title': data['title'] ?? "",
          'body': data['body'] ?? "",
          'type': data['type'] ?? "",
          'recipientUid': data['recipientUid'] ?? "",
          'createdAt': data['timestamp'],
          'name': data['name'] ?? "",
          'imagePath': data['imagePath'],
        };
      }).toList();

      emit(
        state.copyWith(
          notifiactionStatusMember: FetchNotificationStatus.success,
          notificationListMember: notificationList,
        ),
      );
    } catch (exe) {
      emit(
        state.copyWith(
          notifiactionStatusMember: FetchNotificationStatus.failed,
          errorMsg: exe.toString(),
        ),
      );
    }
  }
}
