import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/post.dart';
import 'package:island/pods/network.dart';
import 'package:island/pods/paging.dart';
import 'package:island/widgets/content/sheet.dart';
import 'package:island/widgets/paging/pagination_list.dart';

final postAwardListNotifierProvider = AsyncNotifierProvider.autoDispose
    .family<PostAwardListNotifier, List<SnPostAward>, String>(
      PostAwardListNotifier.new,
    );

class PostAwardListNotifier
    extends AutoDisposeFamilyAsyncNotifier<List<SnPostAward>, String>
    with FamilyAsyncPaginationController<SnPostAward, String> {
  static const int _pageSize = 20;

  @override
  Future<List<SnPostAward>> fetch() async {
    final client = ref.read(apiClientProvider);

    final queryParams = {'offset': fetchedCount, 'take': _pageSize};

    final response = await client.get(
      '/sphere/posts/$arg/awards',
      queryParameters: queryParams,
    );
    totalCount = int.parse(response.headers.value('X-Total') ?? '0');
    final List<dynamic> data = response.data;
    return data.map((json) => SnPostAward.fromJson(json)).toList();
  }
}

class PostAwardHistorySheet extends HookConsumerWidget {
  final String postId;

  const PostAwardHistorySheet({super.key, required this.postId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = postAwardListNotifierProvider(postId);

    return SheetScaffold(
      titleText: 'Award History',
      child: PaginationList(
        provider: provider,
        notifier: provider.notifier,
        itemBuilder: (context, index, award) {
          return Column(
            children: [
              PostAwardItem(award: award),
              if (index < (ref.read(provider).valueOrNull?.length ?? 0) - 1)
                const Divider(height: 1),
            ],
          );
        },
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
