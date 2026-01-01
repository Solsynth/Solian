import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/thought.dart';
import 'package:island/pods/network.dart';
import 'package:island/pods/paging.dart';
import 'package:island/services/time.dart';
import 'package:island/widgets/content/sheet.dart';
import 'package:island/widgets/paging/pagination_list.dart';

final thoughtSequenceListNotifierProvider = AsyncNotifierProvider.autoDispose(
  ThoughtSequenceListNotifier.new,
);

class ThoughtSequenceListNotifier
    extends AsyncNotifier<PaginationState<SnThinkingSequence>>
    with AsyncPaginationController<SnThinkingSequence> {
  static const int pageSize = 20;

  @override
  Future<List<SnThinkingSequence>> fetch() async {
    final client = ref.read(apiClientProvider);

    final queryParams = {'offset': fetchedCount, 'take': pageSize};

    final response = await client.get(
      '/insight/thought/sequences',
      queryParameters: queryParams,
    );
    totalCount = int.parse(response.headers.value('X-Total') ?? '0');
    final List<dynamic> data = response.data;
    return data.map((json) => SnThinkingSequence.fromJson(json)).toList();
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
      child: PaginationList(
        provider: provider,
        notifier: provider.notifier,
        itemBuilder: (context, index, sequence) {
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
    );
  }
}
