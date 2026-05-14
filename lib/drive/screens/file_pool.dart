import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

final poolsProvider = FutureProvider<List<SnFilePool>>((ref) async {
  final driveApi = ref.watch(solarNetworkClientProvider).drive;
  return driveApi.listPools();
});

String? resolveDefaultPoolId(AppSettings settings, List<SnFilePool> pools) {
  final configuredId = settings.defaultPoolId;
  if (configuredId != null && pools.any((p) => p.id == configuredId)) {
    return configuredId;
  }

  return pools.firstOrNull?.id;
}
