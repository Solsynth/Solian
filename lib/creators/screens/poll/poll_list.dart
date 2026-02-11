import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/polls/screens/poll_editor.dart';
import 'package:island/polls/polls_widgets/poll/poll_feedback.dart';
import 'package:island/core/network.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:island/shared/widgets/extended_refresh_indicator.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'poll_list.g.dart';

final pollListNotifierProvider = AsyncNotifierProvider.family.autoDispose(
  PollListNotifier.new,
);

class PollListNotifier extends AsyncNotifier<PaginationState<SnPollWithStats>>
    with AsyncPaginationController<SnPollWithStats> {
  static const int pageSize = 20;

  final String? arg;
  PollListNotifier(this.arg);

  @override
  Future<List<SnPollWithStats>> fetch() async {
    final client = ref.read(apiClientProvider);

    // read the current family argument passed to provider
    final queryParams = {
      'offset': fetchedCount.toString(),
      'take': pageSize,
      if (arg != null) 'pub': arg,
    };

    final response = await client.get(
      '/sphere/polls/me',
      queryParameters: queryParams,
    );
    totalCount = int.parse(response.headers.value('X-Total') ?? '0');
    final items = response.data
        .map((json) => SnPollWithStats.fromJson(json))
        .cast<SnPollWithStats>()
        .toList();

    return items;
  }
}

@riverpod
Future<SnPollWithStats> pollWithStats(Ref ref, String id) async {
  final apiClient = ref.watch(apiClientProvider);
  final resp = await apiClient.get('/sphere/polls/$id');
  return SnPollWithStats.fromJson(resp.data);
}

@RoutePage()
class CreatorPollListScreen extends HookConsumerWidget {
  const CreatorPollListScreen({super.key, required this.pubName});

  final String pubName;

  Future<void> _createPoll(BuildContext context) async {
    final result = await showModalBottomSheet<SnPollWithStats>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => PollEditorScreen(initialPublisher: pubName),
    );
    if (result != null && context.mounted) {
      Navigator.of(context).maybePop(result);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(
        leading: const PageBackButton(backTo: '/creators'),
        title: const Text('Polls'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createPoll(context),
        child: const Icon(Icons.add),
      ),
      body: ExtendedRefreshIndicator(
        onRefresh: () => ref.refresh(pollListNotifierProvider(pubName).future),
        child: PaginationList(
          footerSkeletonMaxWidth: 640,
          provider: pollListNotifierProvider(pubName),
          notifier: pollListNotifierProvider(pubName).notifier,
          padding: const EdgeInsets.only(top: 12),
          itemBuilder: (context, index, pollWithStats) {
            return ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 640),
              child: _CreatorPollItem(
                pollWithStats: pollWithStats,
                pubName: pubName,
              ),
            ).center();
          },
        ),
      ),
    );
  }
}

class _CreatorPollItem extends HookConsumerWidget {
  final String pubName;
  const _CreatorPollItem({required this.pollWithStats, required this.pubName});

  final SnPollWithStats pollWithStats;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final ended = pollWithStats.endedAt;
    final endedText = ended == null
        ? 'No end'
        : MaterialLocalizations.of(context).formatFullDate(ended);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        title: Text(pollWithStats.title ?? 'Untitled poll'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (pollWithStats.description != null &&
                pollWithStats.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  pollWithStats.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Questions: ${pollWithStats.questions.length} · Ends: $endedText',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: Row(
                children: [
                  const Icon(Symbols.edit),
                  const Gap(16),
                  Text('edit').tr(),
                ],
              ),
              onTap: () async {
                final result = await showModalBottomSheet<SnPoll>(
                  context: context,
                  isScrollControlled: true,
                  isDismissible: false,
                  builder: (context) => PollEditorScreen(
                    initialPublisher: pubName,
                    initialPollId: pollWithStats.id,
                  ),
                );
                if (result != null && context.mounted) {
                  ref.invalidate(pollListNotifierProvider(pubName));
                }
              },
            ),
            PopupMenuItem(
              child: Row(
                children: [
                  const Icon(Symbols.delete, color: Colors.red),
                  const Gap(16),
                  Text('delete').tr().textColor(Colors.red),
                ],
              ),
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Delete Poll'),
                    content: Text('Are you sure you want to delete this poll?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  try {
                    final client = ref.read(apiClientProvider);
                    await client.delete('/sphere/polls/${pollWithStats.id}');
                    ref.invalidate(pollListNotifierProvider(pubName));
                    showSnackBar('Poll deleted successfully');
                  } catch (e) {
                    showErrorAlert(e);
                  }
                }
              },
            ),
          ],
        ),
        onTap: () {
          showModalBottomSheet(
            context: context,
            useRootNavigator: true,
            isScrollControlled: true,
            builder: (context) => PollFeedbackSheet(pollId: pollWithStats.id),
          );
        },
      ),
    );
  }
}
