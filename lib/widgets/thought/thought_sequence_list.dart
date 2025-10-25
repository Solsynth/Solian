import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/thought.dart';
import 'package:island/pods/network.dart';
import 'package:island/services/time.dart';
import 'package:island/widgets/content/sheet.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_paging_utils/riverpod_paging_utils.dart';

part 'thought_sequence_list.g.dart';

@riverpod
class ThoughtSequenceListNotifier extends _$ThoughtSequenceListNotifier
    with CursorPagingNotifierMixin<SnThinkingSequence> {
  static const int _pageSize = 20;

  @override
  Future<CursorPagingData<SnThinkingSequence>> build() {
    return fetch(cursor: null);
  }

  @override
  Future<CursorPagingData<SnThinkingSequence>> fetch({
    required String? cursor,
  }) async {
    final client = ref.read(apiClientProvider);
    final offset = cursor == null ? 0 : int.parse(cursor);

    final queryParams = {'offset': offset, 'take': _pageSize};

    final response = await client.get(
      '/insight/thought/sequences',
      queryParameters: queryParams,
    );
    final total = int.parse(response.headers.value('X-Total') ?? '0');
    final List<dynamic> data = response.data;
    final sequences =
        data.map((json) => SnThinkingSequence.fromJson(json)).toList();

    final hasMore = offset + sequences.length < total;
    final nextCursor = hasMore ? (offset + sequences.length).toString() : null;

    return CursorPagingData(
      items: sequences,
      hasMore: hasMore,
      nextCursor: nextCursor,
    );
  }
}

class ThoughtSequenceSelector extends HookConsumerWidget {
  final Function(String) onSequenceSelected;

  const ThoughtSequenceSelector({super.key, required this.onSequenceSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = thoughtSequenceListNotifierProvider;
    return SheetScaffold(
      titleText: 'Select Conversation',
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

                final sequence = data.items[index];
                return ListTile(
                  title: Text(sequence.topic ?? 'Untitled Conversation'),
                  subtitle: Text(sequence.createdAt.formatSystem()),
                  onTap: () {
                    onSequenceSelected(sequence.id);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
      ),
    );
  }
}
