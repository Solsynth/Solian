import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/file_pool.dart';
import 'package:island/pods/config.dart';
import 'package:island/pods/network.dart';

final poolsProvider = FutureProvider<List<SnFilePool>>((ref) async {
  final dio = ref.watch(apiClientProvider);
  final response = await dio.get('/drive/pools');
  return response.data.map((e) => SnFilePool.fromJson(e)).toList();
});

String? resolveDefaultPoolId(WidgetRef ref, List<SnFilePool> pools) {
  final settings = ref.watch(appSettingsNotifierProvider);

  final configuredId = settings.defaultPoolId;
  if (configuredId != null && pools.any((p) => p.id == configuredId)) {
    return configuredId;
  }

  return pools.firstOrNull?.id;
}
