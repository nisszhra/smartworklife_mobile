import '../models/dashboard_summary_model.dart';
import '../providers/dashboard_provider.dart';

class DashboardRepository {
  final DashboardProvider _provider;

  DashboardRepository(this._provider);

  Future<DashboardSummaryModel> getDashboardSummary(String targetDate) async {
    final response = await _provider.getDashboardSummary(targetDate);
    if (response.statusCode == 200) {
      return DashboardSummaryModel.fromJson(response.data);
    } else {
      throw Exception('Gagal mengambil data dashboard');
    }
  }
}
