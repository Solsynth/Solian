import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/post.dart';
import 'package:island/pods/network.dart';
import 'package:island/widgets/content/sheet.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_paging_utils/riverpod_paging_utils.dart';

part 'post_award_history_sheet.g.dart';

@riverpod
class PostAwardListNotifier extends _$PostAwardListNotifier
    with CursorPagingNotifierMixin<SnPostAward> {
  static const int _pageSize = 20;

  @override
  Future<CursorPagingData<SnPostAward>> build({required String postId}) {
    return fetch(cursor: null);
  }

  @override
  Future<CursorPagingData<SnPostAward>> fetch({required String? cursor}) async {
    final client = ref.read(apiClientProvider);
    final offset = cursor == null ? 0 : int.parse(cursor);

    final queryParams = {'offset': offset, 'take': _pageSize};

    final response = await client.get(
      '/sphere/posts/$postId/awards',
      queryParameters: queryParams,
    );
    final total = int.parse(response.headers.value('X-Total') ?? '0');
    final List<dynamic> data = response.data;
    final awards = data.map((json) => SnPostAward.fromJson(json)).toList();

    final hasMore = offset + awards.length < total;
    final nextCursor = hasMore ? (offset + awards.length).toString() : null;

    return CursorPagingData(
      items: awards,
      hasMore: hasMore,
      nextCursor: nextCursor,
    );
  }
}

class PostAwardHistorySheet extends HookConsumerWidget {
  final String postId;

  const PostAwardHistorySheet({super.key, required this.postId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = postAwardListNotifierProvider(postId: postId);

    return SheetScaffold(
      titleText: 'Award History',
      child: PagingHelperView(
        provider: provider,
        futureRefreshable: provider.future,
        notifierRefreshable: provider.notifier,
        contentBuilder:
            (data, widgetCount, endItemView) => ListView.builder(
              itemCount: widgetCount,
              itemBuilder: (context, index) {
                if (index == widgetCount - 1) {
                  return endItemView;
                }

                final award = data.items[index];
                return Column(
                  children: [
                    PostAwardItem(award: award),
                    const Divider(height: 1),
                  ],
                );
              },
            ),
      ),
    );
  }
}

class PostAwardItem extends StatelessWidget {
  final SnPostAward award;

  const PostAwardItem({super.key, required this.award});

  String _getAttitudeText(int attitude) {
    switch (attitude) {
      case 0:
        return 'Positive';
      case 2:
        return 'Negative';
      default:
        return 'Neutral';
    }
  }

  Color _getAttitudeColor(int attitude, BuildContext context) {
    switch (attitude) {
      case 0:
        return Colors.green;
      case 2:
        return Colors.red;
      default:
        return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getAttitudeColor(
          award.attitude,
          context,
        ).withOpacity(0.1),
        child: Icon(
          award.attitude == 0
              ? Icons.thumb_up
              : award.attitude == 2
              ? Icons.thumb_down
              : Icons.thumbs_up_down,
          color: _getAttitudeColor(award.attitude, context),
        ),
      ),
      title: Text(
        '${award.amount} pts',
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getAttitudeText(award.attitude),
            style: TextStyle(
              color: _getAttitudeColor(award.attitude, context),
              fontWeight: FontWeight.w500,
            ),
          ),
          if (award.message != null && award.message!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(award.message!, style: Theme.of(context).textTheme.bodyMedium),
          ],
          const SizedBox(height: 2),
          if (award.createdAt != null) ...[
            const SizedBox(height: 2),
            Text(
              award.createdAt!.toLocal().toString().split('.')[0],
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
      isThreeLine: award.message != null && award.message!.isNotEmpty,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}
