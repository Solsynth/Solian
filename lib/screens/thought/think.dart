import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:gap/gap.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:island/models/thought.dart";
import "package:island/pods/network.dart";
import "package:island/widgets/app_scaffold.dart";
import "package:island/widgets/response.dart";
import "package:island/widgets/thought/thought_sequence_list.dart";
import "package:island/widgets/thought/thought_shared.dart";
import "package:material_symbols_icons/material_symbols_icons.dart";

part 'think.g.dart';

@riverpod
Future<List<SnThinkingThought>> thoughtSequence(
  Ref ref,
  String sequenceId,
) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.get(
    '/insight/thought/sequences/$sequenceId',
  );
  return (response.data as List)
      .map((e) => SnThinkingThought.fromJson(e))
      .toList();
}

class ThoughtScreen extends HookConsumerWidget {
  const ThoughtScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSequenceId = useState<String?>(null);
    final thoughts =
        selectedSequenceId.value != null
            ? ref.watch(thoughtSequenceProvider(selectedSequenceId.value!))
            : const AsyncValue<List<SnThinkingThought>>.data([]);

    // Get initial thoughts and topic from provider
    final initialThoughts = thoughts.valueOrNull;
    final initialTopic =
        (initialThoughts?.isNotEmpty ?? false) &&
                initialThoughts!.first.sequence?.topic != null
            ? initialThoughts.first.sequence!.topic
            : 'aiThought'.tr();

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(
        title: Text(initialTopic ?? 'aiThought'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Symbols.history),
            onPressed: () {
              // Show sequence selector
              showModalBottomSheet(
                context: context,
                builder:
                    (context) => ThoughtSequenceSelector(
                      onSequenceSelected: (sequenceId) {
                        selectedSequenceId.value = sequenceId;
                      },
                    ),
              );
            },
          ),
          // TODO: Need to access chat state for actions
          const Gap(8),
        ],
      ),
      body: thoughts.when(
        data:
            (thoughtList) => ThoughtChatInterface(
              initialThoughts: thoughtList,
              initialTopic: initialTopic,
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, _) => ResponseErrorWidget(
              error: error,
              onRetry:
                  () =>
                      selectedSequenceId.value != null
                          ? ref.invalidate(
                            thoughtSequenceProvider(selectedSequenceId.value!),
                          )
                          : null,
            ),
      ),
    );
  }
}
