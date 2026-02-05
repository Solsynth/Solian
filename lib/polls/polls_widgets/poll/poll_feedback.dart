import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/accounts_widgets/account/account_pfc.dart';
import 'package:island/creators/creators/poll/poll_list.dart';
import 'package:island/pagination/pagination.dart';
import 'package:island/polls/polls_widgets/poll/poll_stats_widget.dart';
import 'package:island/posts/posts_models/poll.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/time.dart';
import 'package:island/drive/drive_widgets/cloud_files.dart';
import 'package:island/core/widgets/content/sheet.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:island/shared/widgets/response.dart';
import 'package:styled_widget/styled_widget.dart';

final pollFeedbackNotifierProvider = AsyncNotifierProvider.autoDispose.family(
  PollFeedbackNotifier.new,
);

class PollFeedbackNotifier extends AsyncNotifier<PaginationState<SnPollAnswer>>
    with AsyncPaginationController<SnPollAnswer> {
  static const int pageSize = 20;

  final String arg;
  PollFeedbackNotifier(this.arg);

  @override
  Future<List<SnPollAnswer>> fetch() async {
    final client = ref.read(apiClientProvider);

    final queryParams = {'offset': fetchedCount, 'take': pageSize};

    final response = await client.get(
      '/sphere/polls/$arg/feedback',
      queryParameters: queryParams,
    );
    totalCount = int.parse(response.headers.value('X-Total') ?? '0');
    final List<dynamic> data = response.data;
    return data.map((json) => SnPollAnswer.fromJson(json)).toList();
  }
}

class PollFeedbackSheet extends HookConsumerWidget {
  final String pollId;
  final String? title;
  const PollFeedbackSheet({super.key, required this.pollId, this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final poll = ref.watch(pollWithStatsProvider(pollId));
    final provider = pollFeedbackNotifierProvider(pollId);

    return SheetScaffold(
      titleText: title ?? 'Poll feedback',
      child: poll.when(
        data: (data) => CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _PollHeader(poll: data)),
            SliverToBoxAdapter(child: const Divider(height: 1)),
            SliverGap(4),
            PaginationList(
              provider: provider,
              notifier: provider.notifier,
              isSliver: true,
              isRefreshable: false,
              itemBuilder: (context, index, answer) {
                return Column(
                  children: [
                    _PollAnswerTile(answer: answer, poll: data),
                    if (index <
                        (ref.read(provider).value?.items.length ?? 0) - 1)
                      const Divider(height: 1).padding(vertical: 4),
                  ],
                );
              },
            ),
            SliverGap(4 + MediaQuery.of(context).padding.bottom),
          ],
        ),
        error: (err, _) => ResponseErrorWidget(
          error: err,
          onRetry: () => ref.invalidate(pollWithStatsProvider(pollId)),
        ),
        loading: () => ResponseLoadingWidget(),
      ),
    );
  }
}

class _PollHeader extends StatelessWidget {
  const _PollHeader({required this.poll});
  final SnPollWithStats poll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        if (poll.title != null || (poll.description?.isNotEmpty ?? false))
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (poll.title != null)
                Text(poll.title!, style: theme.textTheme.titleLarge),
              if (poll.description?.isNotEmpty ?? false)
                Text(
                  poll.description!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
            ],
          ).padding(horizontal: 20, top: 16),
        ExpansionTile(
          title: Text('pollQuestions').tr().fontSize(17).bold(),
          tilePadding: EdgeInsets.symmetric(horizontal: 20),
          children: poll.questions
              .map(
                (q) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (q.title.isNotEmpty) Text(q.title).bold(),
                    if (q.description?.isNotEmpty ?? false)
                      Text(q.description!),
                    PollStatsWidget(question: q, stats: poll.stats),
                  ],
                ).padding(horizontal: 20, top: 8, bottom: 16),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _PollAnswerTile extends StatelessWidget {
  final SnPollAnswer answer;
  final SnPollWithStats poll;
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
          final labels = ids.map((id) {
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
    final submitText = answer.account == null
        ? answer.createdAt.formatSystem()
        : '${answer.account!.nick} · ${answer.createdAt.formatSystem()}';

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
      leading: answer.account == null
          ? const CircleAvatar(
              radius: 16,
              child: Icon(Icons.how_to_vote, size: 16),
            )
          : AccountPfcRegion(
              uname: answer.account!.name,
              child: ProfilePictureWidget(
                file: answer.account!.profile.picture,
              ),
            ),
      title: Text(submitText),
      subtitle: Text(content),
      trailing: null,
    );
  }
}
