class DashboardSummaryModel {
  final int focusTime;
  final int breakTime;
  final double tasksDoneRate;
  final double workPercentage;
  final double restPercentage;
  final double exercisePercentage;
  final double hydrationProgress;
  final int points;

  DashboardSummaryModel({
    required this.focusTime,
    required this.breakTime,
    required this.tasksDoneRate,
    required this.workPercentage,
    required this.restPercentage,
    required this.exercisePercentage,
    required this.hydrationProgress,
    required this.points,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryModel(
      focusTime: json['focus_time_seconds'] ?? 0,
      breakTime: json['break_time_seconds'] ?? 0,
      tasksDoneRate: ((json['tasks']?['completion_rate'] ?? 0.0) as num).toDouble(),
      workPercentage: ((json['balance']?['work_percent'] ?? 0.0) as num).toDouble(),
      restPercentage: ((json['balance']?['rest_percent'] ?? 0.0) as num).toDouble(),
      exercisePercentage: ((json['balance']?['exercise_percent'] ?? 0.0) as num).toDouble(),
      hydrationProgress: ((json['hydration']?['progress_percent'] ?? 0.0) as num).toDouble(),
      points: json['points'] ?? 0,
    );
  }
}
