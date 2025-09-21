import 'package:island/models/file_pool.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/pods/config.dart';

List<SnFilePool> filterValidPools(List<SnFilePool> pools) {
  return pools.where((p) {
    final accept = p.policyConfig?['accept_types'];

    if (accept is List) {
      final acceptsOnlyMedia = accept.every((t) =>
          t is String &&
          (t.startsWith('image/') ||
              t.startsWith('video/') ||
              t.startsWith('audio/')));
      if (acceptsOnlyMedia) return false;
    }

    return true;
  }).toList();
}

String resolveDefaultPoolId(WidgetRef ref, List<SnFilePool> pools) {
  final settings = ref.watch(appSettingsNotifierProvider);
  final validPools = filterValidPools(pools);

  final configuredId = settings.defaultPoolId;
  if (configuredId != null &&
      validPools.any((p) => p.id == configuredId)) {
    return configuredId;
  }

  if (validPools.isNotEmpty) {
    return validPools.first.id;
  }

  return '500e5ed8-bd44-4359-bc0a-ec85e2adf447'; // Solar Network Driver
}
