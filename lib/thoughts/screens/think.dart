import "package:auto_route/auto_route.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:gap/gap.dart";
import "package:island/thoughts/widgets/thought_chat_notifier.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:island/thoughts/widgets/billing_status_handler.dart";
import "package:island/thoughts/widgets/thought_shared.dart";
import "package:island/thoughts/widgets/thought_sidebar.dart";
import "package:island/thoughts/widgets/free_quota_indicator.dart";
import "package:island/core/network.dart";
import "package:solar_network_sdk/solar_network_sdk.dart";
import "package:island/shared/widgets/app_scaffold.dart" hide PageBackButton;
import "package:island/shared/widgets/responsive_sidebar.dart";
import "package:island/shared/widgets/response.dart";
import "package:material_symbols_icons/material_symbols_icons.dart";

part 'think.g.dart';

@riverpod
Future<bool> thoughtAvailableStaus(Ref ref) async {
  final client = ref.watch(solarNetworkClientProvider);
  try {
    final status = await client.thoughts.getBillingStatus();
    return status['status'] == 'ok';
  } catch (_) {
    return false;
  }
}

@riverpod
Future<Map<String, dynamic>> thoughtQuota(Ref ref) async {
  final client = ref.watch(solarNetworkClientProvider);
  return await client.thoughts.getQuota();
}

@riverpod
Future<List<SnThinkingThought>> thoughtSequence(
  Ref ref,
  String sequenceId,
) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.get(
    '/insight/thought/sequences/$sequenceId',
    queryParameters: {'offset': 0, 'take': 50},
  );
  return (response.data as List)
      .map((e) => SnThinkingThought.fromJson(e))
      .toList();
}

@riverpod
Future<ThoughtServicesResponse> thoughtServices(Ref ref) async {
  final client = ref.watch(solarNetworkClientProvider);
  return await client.thoughts.getServices();
}

/// Deletes a thought sequence by ID.
Future<void> deleteThoughtSequence(
  SolarNetworkClient client,
  String sequenceId,
) async {
  await client.thoughts.deleteSequence(sequenceId);
}

/// Updates the sharing status of a thought sequence.
Future<void> updateThoughtSequenceSharing(
  SolarNetworkClient client,
  String sequenceId, {
  required bool isPublic,
}) async {
  await client.thoughts.updateSequence(
    sequenceId: sequenceId,
    data: {'is_public': isPublic},
  );
}

/// Marks a thought sequence as read.
Future<void> markThoughtSequenceAsRead(
  SolarNetworkClient client,
  String sequenceId,
) async {
  await client.thoughts.markSequenceAsRead(sequenceId);
}

@RoutePage()
class ThoughtScreen extends HookConsumerWidget {
  const ThoughtScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSequenceId = useState<String?>(null);
    final showSidebar = useState(false);

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

    // Create args for the chat notifier
    final args = ThoughtChatArgs(
      initialSequenceId: sequenceIdFromThoughts,
      initialThoughts: initialThoughts,
      initialTopic: initialTopic,
    );

    // Get chat state for service selector from the notifier
    final chatState = ref.watch(thoughtChatProvider(args));
    final chatNotifier = ref.read(thoughtChatProvider(args).notifier);

    void refreshStatus() => ref.invalidate(thoughtAvailableStausProvider);

    void invalidateThoughtSequence() {
      if (selectedSequenceId.value != null) {
        ref.invalidate(thoughtSequenceProvider(selectedSequenceId.value!));
      }
    }

    void startNewConversation() {
      if (selectedSequenceId.value != null) {
        ref.invalidate(thoughtSequenceProvider(selectedSequenceId.value!));
      }
      selectedSequenceId.value = null;
      chatNotifier.clearChat();
      showSidebar.value = false;
    }

    void toggleSidebar() => showSidebar.value = !showSidebar.value;

    void closeSidebar() => showSidebar.value = false;

    void handleSequenceSelected(String sequenceId) {
      selectedSequenceId.value = sequenceId;
      // Mark the conversation as read
      markThoughtSequenceAsRead(
        ref.read(solarNetworkClientProvider),
        sequenceId,
      );
      // The service will be updated when thoughts are loaded (see effect below)
    }

    // Effect to update selected service when sequence changes
    if (selectedSequenceId.value != null) {
      ref.listen(thoughtSequenceProvider(selectedSequenceId.value!), (
        previous,
        next,
      ) {
        next.whenData((thoughts) {
          if (thoughts.isNotEmpty) {
            final botName =
                thoughts.first.botName ?? thoughts.first.sequence?.botName;
            if (botName != null && botName.isNotEmpty) {
              chatNotifier.syncServiceId(botName);
            }
          }
        });
      });
    }

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Symbols.menu),
          onPressed: () {
            rootScaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Text(initialTopic ?? 'aiThought'.tr()),
        actions: [
          FreeQuotaIndicator(
            forcegroundColor: Theme.of(context).appBarTheme.foregroundColor,
          ),
          const Gap(6),
          IconButton(
            icon: const Icon(Symbols.add_circle),
            onPressed: startNewConversation,
            tooltip: 'newConversation'.tr(),
          ),
          IconButton(
            icon: const Icon(Symbols.history),
            onPressed: toggleSidebar,
            tooltip: 'conversations'.tr(),
          ),
          const Gap(8),
        ],
      ),
      body: ResponsiveSidebar(
        showSidebar: showSidebar,
        sidebarWidth: 360,
        sidebarContent: ThoughtSidebar(
          selectedSequenceId: selectedSequenceId.value,
          onSequenceSelected: handleSequenceSelected,
          onClose: closeSidebar,
        ),
        mainContent: _ThoughtMainContent(
          thoughts: thoughts,
          initialTopic: initialTopic,
          sequenceIdFromThoughts: sequenceIdFromThoughts,
          statusAsync: statusAsync,
          onRefreshStatus: refreshStatus,
          onRetry: invalidateThoughtSequence,
          hasSelectedSequence: selectedSequenceId.value != null,
        ),
      ),
    );
  }
}

/// The main content area for the thought screen.
///
/// Handles displaying the chat interface with billing status wrapper,
/// loading states, and error handling.
class _ThoughtMainContent extends StatelessWidget {
  final AsyncValue<List<SnThinkingThought>> thoughts;
  final String? initialTopic;
  final String? sequenceIdFromThoughts;
  final AsyncValue<bool> statusAsync;
  final VoidCallback onRefreshStatus;
  final VoidCallback onRetry;
  final bool hasSelectedSequence;

  const _ThoughtMainContent({
    required this.thoughts,
    required this.initialTopic,
    required this.sequenceIdFromThoughts,
    required this.statusAsync,
    required this.onRefreshStatus,
    required this.onRetry,
    required this.hasSelectedSequence,
  });

  @override
  Widget build(BuildContext context) {
    return BillingStatusHandler(
      statusAsync: statusAsync,
      onRefreshStatus: onRefreshStatus,
      child: thoughts.when(
        data: (thoughtList) => ThoughtChatInterface(
          initialThoughts: thoughtList,
          initialSequenceId: sequenceIdFromThoughts,
          initialTopic: initialTopic,
          isDisabled: statusAsync.value == false,
        ),
        loading: () => hasSelectedSequence
            ? const Center(child: CircularProgressIndicator())
            : ThoughtChatInterface(
                initialTopic: initialTopic,
                isDisabled: statusAsync.value == false,
              ),
        error: (error, _) => ResponseErrorWidget(
          error: error,
          onRetry: hasSelectedSequence ? onRetry : () {},
        ),
      ),
    );
  }
}
