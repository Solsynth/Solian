import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/shared/widgets/app_scaffold.dart' hide PageBackButton;
import 'package:island/shared/widgets/responsive_sidebar.dart';
import 'package:island/shared/widgets/response.dart';
import 'package:island/thoughts/widgets/billing_status_handler.dart';
import 'package:island/thoughts/widgets/free_quota_indicator.dart';
import 'package:island/thoughts/widgets/thought_chat_notifier.dart';
import 'package:island/thoughts/widgets/thought_shared.dart';
import 'package:island/thoughts/widgets/thought_sidebar.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'think.g.dart';

@riverpod
Future<bool> thoughtAvailableStaus(Ref ref) async => true;

@riverpod
Future<Map<String, dynamic>> thoughtQuota(Ref ref) async {
  final client = ref.watch(solarNetworkClientProvider);
  return client.thoughts.getQuota();
}

@riverpod
Future<List<SnThinkingThought>> thoughtSequence(Ref ref, String sequenceId) async {
  final client = ref.watch(solarNetworkClientProvider);
  return client.thoughts.getSequenceMessages(sequenceId);
}

@riverpod
Future<ThoughtServicesResponse> thoughtServices(Ref ref) async {
  final client = ref.watch(solarNetworkClientProvider);
  return client.thoughts.getServices();
}

Future<void> deleteThoughtSequence(
  SolarNetworkClient client,
  String sequenceId,
) async {}

Future<void> updateThoughtSequenceSharing(
  SolarNetworkClient client,
  String sequenceId, {
  required bool isPublic,
}) async {}

Future<void> markThoughtSequenceAsRead(
  SolarNetworkClient client,
  String sequenceId,
) async {}

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

    final initialThoughts = thoughts.value;
    final sequenceIdFromThoughts = initialThoughts?.firstOrNull?.sequenceId;
    final initialTopic = initialThoughts?.firstOrNull?.sequence?.topic ?? 'aiThought'.tr();
    final statusAsync = ref.watch(thoughtAvailableStausProvider);

    final args = ThoughtChatArgs(
      initialSequenceId: sequenceIdFromThoughts,
      initialThoughts: initialThoughts,
      initialTopic: initialTopic,
    );
    final chatNotifier = ref.read(thoughtChatProvider(args).notifier);

    void refreshStatus() => ref.invalidate(thoughtAvailableStausProvider);

    void invalidateThoughtSequence() {
      if (selectedSequenceId.value != null) {
        ref.invalidate(thoughtSequenceProvider(selectedSequenceId.value!));
      }
    }

    void startNewConversation() {
      selectedSequenceId.value = null;
      chatNotifier.clearChat();
      showSidebar.value = false;
    }

    void handleSequenceSelected(String sequenceId) {
      selectedSequenceId.value = sequenceId;
      showSidebar.value = false;
      chatNotifier.loadConversation(sequenceId);
    }

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Symbols.menu),
          onPressed: () => rootScaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(initialTopic),
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
            onPressed: () => showSidebar.value = !showSidebar.value,
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
          onClose: () => showSidebar.value = false,
        ),
        mainContent: _ThoughtMainContent(
          thoughts: thoughts,
          initialTopic: initialTopic,
          sequenceIdFromThoughts: sequenceIdFromThoughts,
          statusAsync: statusAsync,
          onRefreshStatus: refreshStatus,
          onRetry: invalidateThoughtSequence,
        ),
      ),
    );
  }
}

class _ThoughtMainContent extends StatelessWidget {
  const _ThoughtMainContent({
    required this.thoughts,
    required this.initialTopic,
    required this.sequenceIdFromThoughts,
    required this.statusAsync,
    required this.onRefreshStatus,
    required this.onRetry,
  });

  final AsyncValue<List<SnThinkingThought>> thoughts;
  final String initialTopic;
  final String? sequenceIdFromThoughts;
  final AsyncValue<bool> statusAsync;
  final VoidCallback onRefreshStatus;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final content = thoughts.when(
      data: (thoughtList) => ThoughtChatInterface(
        initialThoughts: thoughtList,
        initialSequenceId: sequenceIdFromThoughts,
        initialTopic: initialTopic,
      ),
      loading: () => sequenceIdFromThoughts == null
          ? ThoughtChatInterface(initialTopic: initialTopic)
          : const Center(child: CircularProgressIndicator()),
      error: (error, stack) => ResponseErrorWidget(
        error: error,
        onRetry: onRetry,
      ),
    );

    return BillingStatusHandler(
      statusAsync: statusAsync,
      onRefreshStatus: onRefreshStatus,
      child: content,
    );
  }
}
