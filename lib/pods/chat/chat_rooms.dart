import "package:hooks_riverpod/hooks_riverpod.dart";

final isSyncingProvider = StateProvider.autoDispose<bool>((ref) => false);

final flashingMessagesProvider = StateProvider<Set<String>>((ref) => {});
