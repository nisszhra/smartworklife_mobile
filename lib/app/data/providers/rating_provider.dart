import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import '../services/dio_service.dart';

class RatingProvider {
  late final Dio _dio;

  RatingProvider() {
    _dio = Get.find<DioService>().client;
  }

  Future<Response> submitRating({
    required String featureName,
    required int rating,
    String? review,
  }) {
    return _dio.post('/ratings', data: {
      'feature_name': featureName,
      'rating': rating,
      if (review != null && review.isNotEmpty) 'review': review,
    });
  }

  Future<Response> getMyRatings() {
    return _dio.get('/ratings/me');
  }
}
