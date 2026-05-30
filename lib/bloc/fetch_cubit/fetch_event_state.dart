part of 'fetch_event_cubit.dart';

enum FetchKidsStatus { fetching, fetched, fetchingError, initialFetching }

class FetchEventState extends Equatable {
  final FetchKidsStatus status;
  final String? errorMsg;
  final List<KidsInfo>? kidsInfo;
  final List<Map<String, dynamic>>? globalUpcomingEvents;

  const FetchEventState({
    this.errorMsg,
    required this.status,
    this.kidsInfo,
    this.globalUpcomingEvents,
  });

  FetchEventState copyWith({
    FetchKidsStatus? status,
    String? errorMsg,
    List<KidsInfo>? kidsInfo,
    List<Map<String, dynamic>>? globalUpcomingEvents,
  }) {
    return FetchEventState(
      status: status ?? this.status,
      errorMsg: errorMsg ?? this.errorMsg,
      kidsInfo: kidsInfo ?? this.kidsInfo,
      globalUpcomingEvents: globalUpcomingEvents ?? this.globalUpcomingEvents,
    );
  }

  @override
  List<Object?> get props => [status, errorMsg, kidsInfo, globalUpcomingEvents];
}

class KidsInfo {
  final String? kidRecentEvent;
  final String? kidName;
  final String? kidAge;
  final String? kidNextEvent;
  final String? uid;

  const KidsInfo({
    this.kidName,
    this.uid,
    this.kidAge,
    this.kidNextEvent,
    this.kidRecentEvent,
  });
  KidsInfo copyWith({String? kidNextEvent, String? kidRecentEvent}) {
    return KidsInfo(
      uid: uid,
      kidName: kidName,
      kidAge: kidAge,
      kidNextEvent: kidNextEvent ?? this.kidNextEvent,
      kidRecentEvent: kidRecentEvent ?? this.kidRecentEvent,
    );
  }
}
