/// Model untuk satu entri log minum air
class HydrationLogModel {
  final String id;
  final double amountMl;
  final String logDate;
  final DateTime loggedAt;

  HydrationLogModel({
    required this.id,
    required this.amountMl,
    required this.logDate,
    required this.loggedAt,
  });

  factory HydrationLogModel.fromJson(Map<String, dynamic> json) {
    return HydrationLogModel(
      id: json['id'].toString(),
      amountMl: (json['amount_ml'] as num).toDouble(),
      logDate: json['log_date'] as String,
      loggedAt: DateTime.parse(json['logged_at']),
    );
  }
}

/// Model untuk data hidrasi hari ini (GET /health/hydration/today)
class HydrationTodayModel {
  final double consumedMl;
  final double targetMl;
  final double progressPercent;
  final List<HydrationLogModel> logs;

  HydrationTodayModel({
    required this.consumedMl,
    required this.targetMl,
    required this.progressPercent,
    required this.logs,
  });

  double get consumedLiters => consumedMl / 1000;
  double get targetLiters => targetMl / 1000;

  factory HydrationTodayModel.fromJson(Map<String, dynamic> json) {
    final logsList = (json['logs'] as List<dynamic>? ?? [])
        .map((l) => HydrationLogModel.fromJson(l as Map<String, dynamic>))
        .toList();

    return HydrationTodayModel(
      consumedMl: (json['consumed_ml'] as num).toDouble(),
      targetMl: (json['target_ml'] as num).toDouble(),
      progressPercent: (json['progress_percent'] as num).toDouble(),
      logs: logsList,
    );
  }
}

/// Model untuk pengaturan hidrasi (GET /health/hydration/settings)
class HydrationSettingModel {
  final String id;
  final double dailyTargetMl;
  final int reminderIntervalMinutes;
  final bool reminderEnabled;
  final String reminderStartTime;
  final String reminderEndTime;

  HydrationSettingModel({
    required this.id,
    required this.dailyTargetMl,
    required this.reminderIntervalMinutes,
    required this.reminderEnabled,
    required this.reminderStartTime,
    required this.reminderEndTime,
  });

  factory HydrationSettingModel.fromJson(Map<String, dynamic> json) {
    return HydrationSettingModel(
      id: json['id'].toString(),
      dailyTargetMl: (json['daily_target_ml'] as num).toDouble(),
      reminderIntervalMinutes: json['reminder_interval_minutes'] as int,
      reminderEnabled: json['reminder_enabled'] as bool,
      reminderStartTime: json['reminder_start_time'] as String,
      reminderEndTime: json['reminder_end_time'] as String,
    );
  }
}
