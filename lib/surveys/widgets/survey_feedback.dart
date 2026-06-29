import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/widgets/account/account_pfc.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/time.dart';
import 'package:island/creators/screens/survey/survey_list.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/surveys/widgets/survey_stats_widget.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:island/shared/widgets/response.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

final surveyFeedbackNotifierProvider = AsyncNotifierProvider.autoDispose.family(
  SurveyFeedbackNotifier.new,
);

class SurveyFeedbackNotifier
    extends AsyncNotifier<PaginationState<SnSurveyAnswer>>
    with AsyncPaginationController<SnSurveyAnswer> {
  static const int pageSize = 20;

  final String arg;
  SurveyFeedbackNotifier(this.arg);

  @override
  Future<List<SnSurveyAnswer>> fetch() async {
    final client = ref.read(solarNetworkClientProvider).dio;
    final response = await client.get(
      '/sphere/surveys/$arg/feedback',
      queryParameters: {'offset': fetchedCount, 'take': pageSize},
    );
    totalCount = int.parse(response.headers.value('X-Total') ?? '0');
    final List<dynamic> data = response.data;
    return data.map((json) => SnSurveyAnswer.fromJson(json)).toList();
  }
}

@RoutePage()
class SurveyFeedbackPage extends HookConsumerWidget {
  const SurveyFeedbackPage({
    super.key,
    @PathParam('id') required this.surveyId,
    this.title,
  });

  final String surveyId;
  final String? title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final survey = ref.watch(surveyWithStatsProvider(surveyId));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final provider = surveyFeedbackNotifierProvider(surveyId);

    return DefaultTabController(
      length: 2,
      child: AppScaffold(
        appBar: AppBar(
          leading: const AutoLeadingButton(),
          title: Text(title ?? 'surveyFeedback'.tr()),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Summary'),
              Tab(text: 'Participants'),
            ],
          ),
        ),
        body: survey.when(
          loading: () => const ResponseLoadingWidget(),
          error: (err, _) => ResponseErrorWidget(
            error: err,
            onRetry: () => ref.invalidate(surveyWithStatsProvider(surveyId)),
          ),
          data: (data) => DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colorScheme.primaryContainer.withOpacity(0.2),
                  colorScheme.surface,
                ],
              ),
            ),
            child: TabBarView(
              children: [
                _SummaryTab(survey: data),
                PaginationList(
                  footerSkeletonMaxWidth: 880,
                  provider: provider,
                  notifier: provider.notifier,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  itemBuilder: (context, index, answer) {
                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 880),
                        child: _ParticipantCard(answer: answer, survey: data),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryTab extends StatelessWidget {
  const _SummaryTab({required this.survey});

  final SnSurveyWithStats survey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card.filled(
                  color: colorScheme.surfaceContainerLow,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (survey.title != null)
                          Text(
                            survey.title!,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        if (survey.description?.isNotEmpty ?? false) ...[
                          const Gap(12),
                          Text(
                            survey.description!,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.45,
                            ),
                          ),
                        ],
                        const Gap(18),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _InfoChip(
                              icon: Icons.quiz_outlined,
                              label:
                                  '${survey.questions.length} question${survey.questions.length == 1 ? '' : 's'}',
                            ),
                            _InfoChip(
                              icon: Icons.visibility_outlined,
                              label: survey.isAnonymous
                                  ? 'Anonymous responses'
                                  : 'Named responses',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const Gap(20),
                ...([
                  ...survey.questions,
                ]..sort((a, b) => a.order.compareTo(b.order))).map(
                  (question) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        question.title,
                                        style: theme.textTheme.titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      if (question.description?.isNotEmpty ??
                                          false) ...[
                                        const Gap(8),
                                        Text(
                                          question.description!,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                color: colorScheme
                                                    .onSurfaceVariant,
                                                height: 1.35,
                                              ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                if (question.isRequired)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorScheme.errorContainer,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      'required'.tr(),
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(
                                            color: colorScheme.onErrorContainer,
                                          ),
                                    ),
                                  ),
                              ],
                            ),
                            const Gap(18),
                            SurveyStatsWidget(
                              question: question,
                              stats: survey.stats,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ParticipantCard extends StatelessWidget {
  const _ParticipantCard({required this.answer, required this.survey});

  final SnSurveyAnswer answer;
  final SnSurveyWithStats survey;

  String _formatPerQuestionAnswer(
    SnSurveyQuestion question,
    Map<String, dynamic> answerMap,
  ) {
    switch (question.type) {
      case SnSurveyQuestionType.singleChoice:
        final value = answerMap[question.id];
        if (value is String) {
          final option = question.options?.firstWhere(
            (item) => item.id == value,
            orElse: () => SnSurveyOption(id: value, label: '#$value', order: 0),
          );
          return option?.label ?? '#$value';
        }
        return '—';
      case SnSurveyQuestionType.multipleChoice:
        final value = answerMap[question.id];
        if (value is List) {
          final ids = value.whereType<String>().toList();
          if (ids.isEmpty) return '—';
          final labels = ids.map((id) {
            final option = question.options?.firstWhere(
              (item) => item.id == id,
              orElse: () => SnSurveyOption(id: id, label: '#$id', order: 0),
            );
            return option?.label ?? '#$id';
          }).toList();
          return labels.join(', ');
        }
        return '—';
      case SnSurveyQuestionType.yesNo:
        final value = answerMap[question.id];
        if (value is bool) {
          return value ? 'yes'.tr() : 'no'.tr();
        }
        return '—';
      case SnSurveyQuestionType.rating:
        final value = answerMap[question.id];
        if (value is num) return value.toString();
        return '—';
      case SnSurveyQuestionType.freeText:
        final value = answerMap[question.id];
        if (value is String && value.trim().isNotEmpty) return value;
        return '—';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final submitText = answer.account == null
        ? answer.createdAt.formatSystem()
        : '${answer.account!.nick} · ${answer.createdAt.formatSystem()}';
    final questions = [...survey.questions]
      ..sort((a, b) => a.order.compareTo(b.order));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                answer.account == null
                    ? const CircleAvatar(
                        radius: 20,
                        child: Icon(Icons.how_to_vote, size: 18),
                      )
                    : AccountPfcRegion(
                        uname: answer.account!.name,
                        child: ProfilePictureWidget(
                          file: answer.account!.profile.picture,
                        ),
                      ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        submitText,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        answer.account == null
                            ? 'Anonymous participant'
                            : '@${answer.account!.name}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(18),
            ...questions.map(
              (question) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (question.description?.isNotEmpty ?? false) ...[
                        const Gap(6),
                        Text(
                          question.description!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      const Gap(10),
                      Text(
                        _formatPerQuestionAnswer(question, answer.answer),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
          const Gap(8),
          Text(label),
        ],
      ),
    );
  }
}
