import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/pool_service.dart';
import '../models/file_pool.dart';
import 'package:island/pods/network.dart';

final poolServiceProvider = Provider<PoolService>((ref) {
  final dio = ref.watch(apiClientProvider);
  return PoolService(dio);
});

final poolsProvider = FutureProvider<List<FilePool>>((ref) async {
  final service = ref.watch(poolServiceProvider);
  return service.fetchPools();
});
