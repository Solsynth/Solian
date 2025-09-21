
import '../models/file_pool.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../pods/config.dart';

List<FilePool> filterValidPools(List<FilePool> pools) {
  return pools.where((p) {
    final accept = p.policyConfig['accept_types'];
    if (accept != null) {
      final acceptsOnlyMedia = accept.every((t) =>
          t.startsWith('image/') ||
          t.startsWith('video/') ||
          t.startsWith('audio/'));
      if (acceptsOnlyMedia) return false;
    }
    return true;
  }).toList();
}

String resolveDefaultPoolId(WidgetRef ref, List<FilePool> pools) {
  final settings = ref.watch(appSettingsNotifierProvider);
  final validPools = filterValidPools(pools);

  if (settings.defaultPoolId != null &&
      validPools.any((p) => p.id == settings.defaultPoolId)) {
    return settings.defaultPoolId!;
  }

  if (validPools.isNotEmpty) {
    return validPools.first.id;
  }
  // DEFAULT: Solar Network Driver
  return '500e5ed8-bd44-4359-bc0a-ec85e2adf447';
}

