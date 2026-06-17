import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:worklife_mobile/app/data/services/dio_service.dart';

class NotulenProvider {
  dio.Dio get _dio => Get.find<DioService>().client;

  Future<dio.Response> getList() {
    return _dio.get('/notulens');
  }

  Future<dio.Response> getDetail(String id) {
    return _dio.get('/notulens/$id');
  }

  Future<dio.Response> uploadAudio(String filePath) async {
    final formData = dio.FormData.fromMap({
      'file': await dio.MultipartFile.fromFile(filePath),
    });

    return _dio.post('/notulens/upload', data: formData);
  }

  Future<dio.Response> createFromText(
    String transcript, {
    int? durationSeconds,
  }) {
    return _dio.post(
      '/notulens/from-text',
      data: {
        'transcript': transcript,
        if (durationSeconds != null) 'duration_seconds': durationSeconds,
      },
    );
  }

  Future<dio.Response> generateSummary(String id) {
    return _dio.post('/notulens/$id/generate-summary');
  }

  Future<dio.Response> save(String id, Map<String, dynamic> data) {
    return _dio.post('/notulens/$id/save', data: data);
  }

  Future<dio.Response> delete(String id) {
    return _dio.delete('/notulens/$id');
  }

  Future<dio.Response> bulkDelete({List<String>? ids, bool deleteAll = false}) {
    return _dio.post('/notulens/bulk-delete', data: deleteAll
        ? {'delete_all': true}
        : {'ids': ids ?? []});
  }

  Future<dio.Response> refine(String text) {
    return _dio.post(
      '/notulens/refine',
      data: {'text': text},
    );
  }
}

