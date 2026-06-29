import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:worklife_mobile/app/data/models/berita_model.dart';
import 'package:worklife_mobile/app/data/services/dio_service.dart';

class BeritaService extends GetxService {
  final Dio client = Get.find<DioService>().client;

  Future<List<BeritaModel>> getBerita({int limit = 100}) async {
    try {
      final response = await client.get('/berita', queryParameters: {
        'limit': limit,
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((e) => BeritaModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('[BeritaService] Error getBerita: $e');
      rethrow;
    }
  }

  Future<List<BeritaModel>> searchBerita(String keyword, {int limit = 100}) async {
    try {
      final response = await client.get('/berita/$keyword', queryParameters: {
        'limit': limit,
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((e) => BeritaModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('[BeritaService] Error searchBerita: $e');
      rethrow;
    }
  }
}
