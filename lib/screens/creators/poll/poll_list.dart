import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/poll.dart';
import 'package:island/pods/network.dart';
import 'package:island/screens/poll/poll_editor.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/poll/poll_feedback.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_paging_utils/riverpod_paging_utils.dart';
import 'package:island/widgets/extended_refresh_indicator.dart';
import 'package:styled_widget/styled_widget.dart';

part 'poll_list.g.dart';

@riverpod
class PollListNotifier extends _$PollListNotifier
    with CursorPagingNotifierMixin<SnPollWithStats> {
  static const int _pageSize = 20;

  @override
  Future<CursorPagingData<SnPollWithStats>> build(String? pubName) {
    // immediately load first page
    return fetch(cursor: null);
  }

  @override
  Future<CursorPagingData<SnPollWithStats>> fetch({
    required String? cursor,
  }) async {
    final client = ref.read(apiClientProvider);
    final offset = cursor == null ? 0 : int.parse(cursor);

    // read the current family argument passed to provider
    final currentPub = pubName;
    final queryParams = {
      'offset': offset,
      'take': _pageSize,
      if (currentPub != null) 'pub': currentPub,
    };

    final response = await client.get(
      '/sphere/polls/me',
      queryParameters: queryParams,
    );
    final total = int.parse(response.headers.value('X-Total') ?? '0');
    final List<dynamic> data = response.data;
    final items = data.map((json) => SnPollWithStats.fromJson(json)).toList();

    final hasMore = offset + items.length < total;
    final nextCursor = hasMore ? (offset + items.length).toString() : null;

    return CursorPagingData(
      items: items,
      hasMore: hasMore,
      nextCursor: nextCursor,
    );
  }
}

@riverpod
Future<SnPollWithStats> pollWithStats(Ref ref, String id) async {
  final apiClient = ref.watch(apiClientProvider);
  final resp = await apiClient.get('/sphere/polls/$id');
  return SnPollWithStats.fromJson(resp.data);
}

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
      appBar: AppBar(title: const Text('Polls')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createPoll(context),
        child: const Icon(Icons.add),
      ),
      body: ExtendedRefreshIndicator(
        onRefresh: () => ref.refresh(pollListNotifierProvider(pubName).future),
        child: CustomScrollView(
          slivers: [
            PagingHelperSliverView(
              provider: pollListNotifierProvider(pubName),
              futureRefreshable: pollListNotifierProvider(pubName).future,
              notifierRefreshable: pollListNotifierProvider(pubName).notifier,
              contentBuilder:
                  (data, widgetCount, endItemView) => SliverList.builder(
                    itemCount: widgetCount,
                    itemBuilder: (context, index) {
                      if (index == widgetCount - 1) {
                        return endItemView;
                      }
                      final pollWithStats = data.items[index];
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
          ],
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
    final endedText =
        ended == null
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
          itemBuilder:
              (context) => [
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
                      builder:
                          (context) => PollEditorScreen(
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
                      builder:
                          (context) => AlertDialog(
                            title: Text('Delete Poll'),
                            content: Text(
                              'Are you sure you want to delete this poll?',
                            ),
                            actions: [
                              TextButton(
                                onPressed:
                                    () => Navigator.of(context).pop(false),
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed:
                                    () => Navigator.of(context).pop(true),
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                    );
                    if (confirmed == true) {
                      try {
                        final client = ref.read(apiClientProvider);
                        await client.delete(
                          '/sphere/polls/${pollWithStats.id}',
                        );
                        ref.invalidate(pollListNotifierProvider(pubName));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Poll deleted successfully'),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to delete poll')),
                          );
                        }
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
