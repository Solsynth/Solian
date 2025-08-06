import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/poll.dart';
import 'package:island/pods/network.dart';
import 'package:island/services/time.dart';
import 'package:island/widgets/content/sheet.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_paging_utils/riverpod_paging_utils.dart';
import 'package:styled_widget/styled_widget.dart';

part 'poll_feedback.g.dart';

@riverpod
class PollFeedbackNotifier extends _$PollFeedbackNotifier
    with CursorPagingNotifierMixin<SnPollAnswer> {
  static const int _pageSize = 20;

  @override
  Future<CursorPagingData<SnPollAnswer>> build(String id) {
    // immediately load first page
    return fetch(cursor: null);
  }

  @override
  Future<CursorPagingData<SnPollAnswer>> fetch({
    required String? cursor,
  }) async {
    final client = ref.read(apiClientProvider);
    final offset = cursor == null ? 0 : int.parse(cursor);

    final queryParams = {'offset': offset, 'take': _pageSize};

    final response = await client.get(
      '/sphere/polls/$id/feedback',
      queryParameters: queryParams,
    );
    final total = int.parse(response.headers.value('X-Total') ?? '0');
    final List<dynamic> data = response.data;
    final items = data.map((json) => SnPollAnswer.fromJson(json)).toList();

    final hasMore = offset + items.length < total;
    final nextCursor = hasMore ? (offset + items.length).toString() : null;

    return CursorPagingData(
      items: items,
      hasMore: hasMore,
      nextCursor: nextCursor,
    );
  }
}

class PollFeedbackSheet extends HookConsumerWidget {
  final String pollId;
  final String? title;
  final SnPoll poll;
  final Map<String, dynamic>? stats; // stats object similar to PollSubmit
  const PollFeedbackSheet({
    super.key,
    required this.pollId,
    required this.poll,
    this.title,
    this.stats,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SheetScaffold(
      titleText: title ?? 'Poll feedback',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PollHeader(poll: poll, stats: stats),
          const Divider(height: 1),
          Expanded(
            child: PagingHelperView(
              provider: pollFeedbackNotifierProvider(pollId),
              futureRefreshable: pollFeedbackNotifierProvider(pollId).future,
              notifierRefreshable:
                  pollFeedbackNotifierProvider(pollId).notifier,
              contentBuilder:
                  (data, widgetCount, endItemView) => ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: widgetCount,
                    itemBuilder: (context, index) {
                      if (index == widgetCount - 1) {
                        // Provided by PagingHelperView to indicate end/loading
                        return endItemView;
                      }
                      final answer = data.items[index];
                      return _PollAnswerTile(answer: answer, poll: poll);
                    },
                    separatorBuilder:
                        (context, index) =>
                            const Divider(height: 1).padding(vertical: 4),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PollHeader extends StatelessWidget {
  const _PollHeader({required this.poll, this.stats});
  final SnPoll poll;
  final Map<String, dynamic>? stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (poll.title != null)
          Text(poll.title!, style: theme.textTheme.titleLarge),
        if (poll.description != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              poll.description!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
          ),
      ],
    ).padding(horizontal: 20, vertical: 16);
  }
}

class _PollAnswerTile extends StatelessWidget {
  final SnPollAnswer answer;
  final SnPoll poll;
  const _PollAnswerTile({required this.answer, required this.poll});

  String _formatPerQuestionAnswer(
    SnPollQuestion q,
    Map<String, dynamic> ansMap,
  ) {
    switch (q.type) {
      case SnPollQuestionType.singleChoice:
        final val = ansMap[q.id];
        if (val is String) {
          final opt = q.options?.firstWhere(
            (o) => o.id == val,
            orElse: () => SnPollOption(id: val, label: '#$val', order: 0),
          );
          return opt?.label ?? '#$val';
        }
        return '—';
      case SnPollQuestionType.multipleChoice:
        final val = ansMap[q.id];
        if (val is List) {
          final ids = val.whereType<String>().toList();
          if (ids.isEmpty) return '—';
          final labels =
              ids.map((id) {
                final opt = q.options?.firstWhere(
                  (o) => o.id == id,
                  orElse: () => SnPollOption(id: id, label: '#$id', order: 0),
                );
                return opt?.label ?? '#$id';
              }).toList();
          return labels.join(', ');
        }
        return '—';
      case SnPollQuestionType.yesNo:
        final val = ansMap[q.id];
        if (val is bool) {
          return val ? 'Yes' : 'No';
        }
        return '—';
      case SnPollQuestionType.rating:
        final val = ansMap[q.id];
        if (val is int) return val.toString();
        if (val is num) return val.toString();
        return '—';
      case SnPollQuestionType.freeText:
        final val = ansMap[q.id];
        if (val is String && val.trim().isNotEmpty) return val;
        return '—';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Submit date/time (title)
    final submitText = answer.createdAt.formatSystem();

    // Compose content from poll questions if provided, otherwise fallback to joined key-values
    String content;
    if (poll.questions.isNotEmpty) {
      final questions = [...poll.questions]
        ..sort((a, b) => a.order.compareTo(b.order));
      final buffer = StringBuffer();
      for (final q in questions) {
        final formatted = _formatPerQuestionAnswer(q, answer.answer);
        buffer.writeln('${q.title}: $formatted');
      }
      content = buffer.toString().trimRight();
    } else {
      // Fallback formatting without poll context. We still want to show the question title
      // instead of the raw question id key if we can derive it from the answer map itself.
      // Since we don't have poll metadata here, we cannot resolve the title; therefore we
      // will show only values line-by-line without exposing the raw id.
      if (answer.answer.isEmpty) {
        content = '—';
      } else {
        final parts = <String>[];
        answer.answer.forEach((key, value) {
          var question = poll.questions.firstWhere((q) => q.id == key);
          if (value is List) {
            parts.add('${question.title}: ${value.join(', ')}');
          } else {
            parts.add('${question.title}: $value');
          }
        });
        content = parts.join('\n');
      }
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      isThreeLine: true,
      leading: const CircleAvatar(
        radius: 16,
        child: Icon(Icons.how_to_vote, size: 16),
      ),
      title: Text(submitText),
      subtitle: Text(content),
      trailing: null,
    );
  }
}
