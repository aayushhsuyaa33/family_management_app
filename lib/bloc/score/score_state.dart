part of 'score_cubit.dart';

enum ScoreStatus { initial, loading, success, failure }

class ScoreState extends Equatable {
  final ScoreStatus status;
  final ScoreStatus overallScoreStatus;
  final ScoreStatus weeklyTrendStatus;
  final List<MyMember>? scoreList;
  final List? loadSplitList;
  final String? errorMessage;
  final double? houseHoldPercent;
  final ScoreStatus loadSplitStatus;
  final double? completedTask;
  final double? pendingTask;

  final int? thisWeekCount;
  final int? lastWeekCount;
  final double? weeklyTrendPercent;
  final bool isUpTrend;

  const ScoreState({
    this.status = ScoreStatus.initial,
    this.overallScoreStatus = ScoreStatus.initial,
    this.loadSplitStatus = ScoreStatus.initial,
    this.weeklyTrendStatus = ScoreStatus.initial,
    this.scoreList,
    this.errorMessage,
    this.houseHoldPercent,
    this.loadSplitList,
    this.completedTask,
    this.pendingTask,
    this.isUpTrend = true,
    this.lastWeekCount,
    this.thisWeekCount,
    this.weeklyTrendPercent,
  });

  ScoreState copyWith({
    ScoreStatus? status,
    ScoreStatus? weeklyTrendStatus,
    List<MyMember>? scoreList,
    String? errorMessage,
    double? houseHoldPercent,
    ScoreStatus? overallScoreStatus,
    ScoreStatus? loadSplitStatus,
    List? loadSplitList,
    double? completedTask,
    double? pendingTask,

    int? thisWeekCount,
    int? lastWeekCount,
    double? weeklyTrendPercent,
    bool? isUpTrend,
  }) {
    return ScoreState(
      status: status ?? this.status,
      scoreList: scoreList ?? this.scoreList,
      errorMessage: errorMessage ?? this.errorMessage,
      houseHoldPercent: houseHoldPercent ?? this.houseHoldPercent,
      overallScoreStatus: overallScoreStatus ?? this.overallScoreStatus,
      loadSplitStatus: loadSplitStatus ?? this.loadSplitStatus,
      loadSplitList: loadSplitList ?? this.loadSplitList,
      completedTask: completedTask ?? this.completedTask,
      pendingTask: pendingTask ?? this.pendingTask,
      weeklyTrendStatus: weeklyTrendStatus ?? this.weeklyTrendStatus,

      isUpTrend: isUpTrend ?? this.isUpTrend,
      weeklyTrendPercent: weeklyTrendPercent ?? this.weeklyTrendPercent,
      lastWeekCount: lastWeekCount ?? this.lastWeekCount,
      thisWeekCount: thisWeekCount ?? this.thisWeekCount,
    );
  }

  @override
  List<Object?> get props => [
    status,
    scoreList,
    errorMessage,
    houseHoldPercent,
    overallScoreStatus,
    loadSplitStatus,
    loadSplitList,
    pendingTask,
    completedTask,
    weeklyTrendStatus,

    isUpTrend,
    thisWeekCount,
    lastWeekCount,
    weeklyTrendPercent,
  ];
}
