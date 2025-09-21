import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/services/pool_service.dart';
import 'package:island/models/file_pool.dart';
import 'package:island/pods/network.dart';

final poolServiceProvider = Provider<PoolService>((ref) {
  final dio = ref.watch(apiClientProvider);
  return PoolService(dio);
});

final poolsProvider = FutureProvider<List<SnFilePool>>((ref) async {
  final service = ref.watch(poolServiceProvider);
  return service.fetchPools();
});
