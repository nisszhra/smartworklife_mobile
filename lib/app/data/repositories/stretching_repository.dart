import '../providers/stretching_provider.dart';

class StretchingRepository {
  final StretchingProvider _provider;

  StretchingRepository(this._provider);

  /// Mulai sesi stretching di backend, kembalikan session_id
  Future<String?> startSession({required String exerciseId}) async {
    try {
      final response = await _provider.startSession(exerciseId: exerciseId);
      if (response.statusCode == 201 && response.data != null) {
        return response.data['id'] as String?;
      }
    } catch (e) {
      print('[StretchingRepo] startSession error: $e');
    }
    return null;
  }

  /// Tandai sesi selesai di backend
  Future<bool> completeSession({required String sessionId}) async {
    try {
      final response = await _provider.completeSession(sessionId: sessionId);
      return response.statusCode == 200;
    } catch (e) {
      print('[StretchingRepo] completeSession error: $e');
      return false;
    }
  }
}
