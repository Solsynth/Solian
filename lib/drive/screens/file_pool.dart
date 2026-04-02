import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

final poolsProvider = FutureProvider<List<SnFilePool>>((ref) async {
  final dio = ref.watch(solarNetworkClientProvider).dio;
  final response = await dio.get('/drive/pools');
  return response.data
      .map((e) => SnFilePool.fromJson(e))
      .cast<SnFilePool>()
      .toList();
});

String? resolveDefaultPoolId(AppSettings settings, List<SnFilePool> pools) {
  final configuredId = settings.defaultPoolId;
  if (configuredId != null && pools.any((p) => p.id == configuredId)) {
    return configuredId;
  }

  return pools.firstOrNull?.id;
}
