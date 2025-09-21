import 'package:dio/dio.dart';

import 'package:island/models/file_pool.dart';

class PoolService {
  final Dio _dio;

  PoolService(this._dio);

  Future<List<FilePool>> fetchPools() async {
    final response = await _dio.get('/drive/pools');

    if (response.statusCode == 200) {
      return FilePool.listFromResponse(response.data);
    } else {
      throw Exception('Failed to fetch pools: ${response.statusCode}');
    }
  }
}
