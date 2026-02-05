import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/drive/drive_models/file_pool.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';

final poolsProvider = FutureProvider<List<SnFilePool>>((ref) async {
  final dio = ref.watch(apiClientProvider);
  final response = await dio.get('/drive/pools');
  return response.data
      .map((e) => SnFilePool.fromJson(e))
      .cast<SnFilePool>()
      .toList();
});

String? resolveDefaultPoolId(WidgetRef ref, List<SnFilePool> pools) {
  final settings = ref.watch(appSettingsProvider);

  final configuredId = settings.defaultPoolId;
  if (configuredId != null && pools.any((p) => p.id == configuredId)) {
    return configuredId;
  }

  return pools.firstOrNull?.id;
}
