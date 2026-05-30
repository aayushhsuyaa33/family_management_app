part of 'google_calendar_cubit.dart';

enum GoogleCalendarStatus { initial, loading, success, failure }

class GoogleCalendarState extends Equatable {
  final GoogleCalendarStatus addStatus;
  final GoogleCalendarStatus deleteStatus;
  final String? error;

  const GoogleCalendarState({
    this.addStatus = GoogleCalendarStatus.initial,
    this.deleteStatus = GoogleCalendarStatus.initial,
    this.error,
  });

  GoogleCalendarState copyWith({
    GoogleCalendarStatus? addStatus,
    GoogleCalendarStatus? deleteStatus,

    String? error,
  }) {
    return GoogleCalendarState(
      addStatus: addStatus ?? this.addStatus,
      deleteStatus: deleteStatus ?? this.deleteStatus,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [error, addStatus, deleteStatus];
}
