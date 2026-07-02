import 'package:dio/dio.dart';

import 'package:worklife_mobile/app/data/models/hydration_model.dart';
import 'package:worklife_mobile/app/data/providers/hydration_provider.dart';

abstract class HydrationRepository {
  Future<HydrationTodayModel> getTodayHydration(String targetDate);
  Future<HydrationLogModel> addLog(double amountMl, String targetDate);
  Future<void> deleteLog(String logId);
  Future<HydrationSettingModel> getSettings();
  Future<HydrationSettingModel> updateSettings({
    int? reminderIntervalMinutes,
    bool? reminderEnabled,
    String? reminderStartTime,
    String? reminderEndTime,
  });
}

class HydrationRepositoryImpl implements HydrationRepository {
  final HydrationProvider _provider;

  HydrationRepositoryImpl(this._provider);

  @override
  Future<HydrationTodayModel> getTodayHydration(String targetDate) async {
    try {
      final res = await _provider.getTodayHydration(targetDate);
      return HydrationTodayModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<HydrationLogModel> addLog(double amountMl, String targetDate) async {
    try {
      final res = await _provider.addLog(amountMl, targetDate);
      return HydrationLogModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> deleteLog(String logId) async {
    try {
      await _provider.deleteLog(logId);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<HydrationSettingModel> getSettings() async {
    try {
      final res = await _provider.getSettings();
      return HydrationSettingModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<HydrationSettingModel> updateSettings({
    int? reminderIntervalMinutes,
    bool? reminderEnabled,
    String? reminderStartTime,
    String? reminderEndTime,
  }) async {
    try {
      final res = await _provider.updateSettings(
        reminderIntervalMinutes: reminderIntervalMinutes,
        reminderEnabled: reminderEnabled,
        reminderStartTime: reminderStartTime,
        reminderEndTime: reminderEndTime,
      );
      return HydrationSettingModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }


  Exception _handleError(DioException e) {
    print('[HydrationRepo] Error: ${e.type} | ${e.message}');
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return Exception('Tidak dapat terhubung ke server.');
    }
    final data = e.response?.data;
    String message = 'Terjadi kesalahan. Silakan coba lagi.';
    if (data is Map<String, dynamic> && data.containsKey('detail')) {
      message = data['detail'].toString();
    }
    return Exception(message);
  }
}
