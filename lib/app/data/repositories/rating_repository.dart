import '../providers/rating_provider.dart';

class RatingRepository {
  final RatingProvider _provider;

  RatingRepository(this._provider);

  Future<bool> submitRating({
    required String featureName,
    required int rating,
    String? review,
  }) async {
    try {
      final response = await _provider.submitRating(
        featureName: featureName,
        rating: rating,
        review: review,
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('[RatingRepo] submitRating error: $e');
      return false;
    }
  }

  Future<List<dynamic>> getMyRatings() async {
    try {
      final response = await _provider.getMyRatings();
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      }
      return [];
    } catch (e) {
      print('[RatingRepo] getMyRatings error: $e');
      return [];
    }
  }
}
