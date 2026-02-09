import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:gap/gap.dart";
import "package:island/thought/thought_widgets/thought/thought_sequence_list.dart";
import "package:island/thought/thought_widgets/thought/thought_shared.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:island/thought/thought.dart";
import "package:island/core/network.dart";
import "package:island/shared/widgets/alert.dart";
import "package:island/shared/widgets/app_scaffold.dart";
import "package:island/shared/widgets/response.dart";
import "package:material_symbols_icons/material_symbols_icons.dart";

part 'think.g.dart';

@riverpod
Future<bool> thoughtAvailableStaus(Ref ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.get('/insight/billing/status');
  return response.data['status'] == 'ok';
}

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

@riverpod
Future<ThoughtServicesResponse> thoughtServices(Ref ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.get('/insight/thought/services');
  return ThoughtServicesResponse.fromJson(response.data);
}

class ThoughtScreen extends HookConsumerWidget {
  const ThoughtScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSequenceId = useState<String?>(null);
    final thoughts = selectedSequenceId.value != null
        ? ref.watch(thoughtSequenceProvider(selectedSequenceId.value!))
        : const AsyncValue<List<SnThinkingThought>>.data([]);

    // Extract sequence ID from loaded thoughts for the chat interface
    final sequenceIdFromThoughts = thoughts.maybeWhen(
      data: (thoughts) {
        if (thoughts.isNotEmpty && thoughts.first.sequenceId.isNotEmpty) {
          return thoughts.first.sequenceId;
        }
        return null;
      },
      orElse: () => null,
    );

    // Get initial thoughts and topic from provider
    final initialThoughts = thoughts.value;
    final initialTopic =
        (initialThoughts?.isNotEmpty ?? false) &&
            initialThoughts!.first.sequence?.topic != null
        ? initialThoughts.first.sequence!.topic
        : 'aiThought'.tr();

    final statusAsync = ref.watch(thoughtAvailableStausProvider);

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(
        title: Text(initialTopic ?? 'aiThought'.tr()),
        leading: const PageBackButton(),
        actions: [
          IconButton(
            icon: const Icon(Symbols.history),
            onPressed: () {
              // Show sequence selector
              showModalBottomSheet(
                context: context,
                builder: (context) => ThoughtSequenceSelector(
                  onSequenceSelected: (sequenceId) {
                    selectedSequenceId.value = sequenceId;
                  },
                ),
              );
            },
          ),
          const Gap(8),
        ],
      ),
      body: statusAsync.maybeWhen(
        data: (status) {
          final retry = useMemoized(
            () => () async {
              showLoadingModal(context);
              try {
                await ref
                    .read(apiClientProvider)
                    .post('/insight/billing/retry');
                showSnackBar('Retried billing process');
                ref.invalidate(thoughtAvailableStausProvider);
              } catch (e) {
                showSnackBar('Failed to retry billing');
              }
              if (context.mounted) hideLoadingModal(context);
            },
            [context, ref],
          );

          final thoughtsBody = thoughts.when(
            data: (thoughtList) => ThoughtChatInterface(
              initialThoughts: thoughtList,
              initialSequenceId: sequenceIdFromThoughts,
              initialTopic: initialTopic,
              isDisabled: !status,
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => ResponseErrorWidget(
              error: error,
              onRetry: () => selectedSequenceId.value != null
                  ? ref.invalidate(
                      thoughtSequenceProvider(selectedSequenceId.value!),
                    )
                  : null,
            ),
          );
          return status
              ? thoughtsBody
              : Column(
                  children: [
                    MaterialBanner(
                      leading: const Icon(Symbols.error),
                      content: const Text(
                        'You have unpaid orders. Please settle your payment to continue using the service.',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            retry();
                          },
                          child: Text('retry'.tr()),
                        ),
                      ],
                    ),
                    Expanded(child: thoughtsBody),
                  ],
                );
        },
        orElse: () => thoughts.when(
          data: (thoughtList) => ThoughtChatInterface(
            initialThoughts: thoughtList,
            initialTopic: initialTopic,
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ResponseErrorWidget(
            error: error,
            onRetry: () => selectedSequenceId.value != null
                ? ref.invalidate(
                    thoughtSequenceProvider(selectedSequenceId.value!),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
