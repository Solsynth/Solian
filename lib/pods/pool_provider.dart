import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/file_pool.dart';
import 'package:island/pods/config.dart';
import 'package:island/pods/network.dart';

final poolsProvider = FutureProvider<List<SnFilePool>>((ref) async {
  final dio = ref.watch(apiClientProvider);
  final response = await dio.get('/drive/pools');
  final pools = SnFilePoolList.listFromResponse(response.data);
  return pools.filterValid();
});

String resolveDefaultPoolId(WidgetRef ref, List<SnFilePool> pools) {
  final settings = ref.watch(appSettingsNotifierProvider);
  final validPools = pools.filterValid();

  final configuredId = settings.defaultPoolId;
  if (configuredId != null && validPools.any((p) => p.id == configuredId)) {
    return configuredId;
  }

  if (validPools.isNotEmpty) {
    return validPools.first.id;
  }

  // DEFAULT: Solar Network Driver
  return '500e5ed8-bd44-4359-bc0a-ec85e2adf447'; }

