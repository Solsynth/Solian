import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/poll.dart';
import 'package:island/pods/network.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_paging_utils/riverpod_paging_utils.dart';

part 'poll_list.g.dart';

@riverpod
class PollListNotifier extends _$PollListNotifier
    with CursorPagingNotifierMixin<SnPoll> {
  static const int _pageSize = 20;

  @override
  Future<CursorPagingData<SnPoll>> build(String? pubName) {
    // immediately load first page
    return fetch(cursor: null);
  }

  @override
  Future<CursorPagingData<SnPoll>> fetch({required String? cursor}) async {
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
    final items = data.map((json) => SnPoll.fromJson(json)).toList();

    final hasMore = offset + items.length < total;
    final nextCursor = hasMore ? (offset + items.length).toString() : null;

    return CursorPagingData(
      items: items,
      hasMore: hasMore,
      nextCursor: nextCursor,
    );
  }
}

class CreatorPollListScreen extends HookConsumerWidget {
  const CreatorPollListScreen({super.key, required this.pubName});

  final String pubName;

  Future<void> _createPoll(BuildContext context) async {
    // Use named route defined in router with :name param (creatorPollNew)
    final result = await GoRouter.of(
      context,
    ).pushNamed('creatorPollNew', pathParameters: {'name': pubName});
    // If PollEditorScreen returns a created SnPoll on success, pop back with it
    if (result is SnPoll && context.mounted) {
      Navigator.of(context).maybePop(result);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Polls')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createPoll(context),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
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
                      final poll = data.items[index];
                      return _CreatorPollItem(poll: poll);
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreatorPollItem extends StatelessWidget {
  const _CreatorPollItem({required this.poll});

  final SnPoll poll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ended = poll.endedAt;
    final endedText =
        ended == null
            ? 'No end'
            : MaterialLocalizations.of(context).formatFullDate(ended);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        title: Text(poll.title ?? 'Untitled poll'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (poll.description != null && poll.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  poll.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Questions: ${poll.questions.length} · Ends: $endedText',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (v) {
            switch (v) {
              case 'edit':
                // Use global router helper if desired
                // context.push('/creators/${poll.publisher?.name ?? ''}/polls/${poll.id}/edit');
                Navigator.of(context).pushNamed(
                  'creatorPollEdit',
                  arguments: {
                    'name': poll.publisher?.name ?? '',
                    'id': poll.id,
                  },
                );
                break;
            }
          },
          itemBuilder:
              (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
              ],
        ),
        onTap: () {
          // Open editor for edit
          // Navigator push by path to keep consistency with rest of app:
          // Note: pub name string may be required in route; when absent, route may need query or pick later.
          // For safety, just do nothing if no publisher in list item.
        },
      ),
    );
  }
}
