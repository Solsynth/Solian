import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/creators/screens/survey/survey_list.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/surveys/widgets/survey_submit.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

@RoutePage()
class SurveySubmitPage extends ConsumerWidget {
  final String surveyId;
  final bool isReadonly;
  final bool isInitiallyExpanded;

  const SurveySubmitPage({
    super.key,
    @PathParam("id") required this.surveyId,
    this.isReadonly = false,
    this.isInitiallyExpanded = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surveyAsync = ref.watch(surveyWithStatsProvider(surveyId));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppScaffold(
      appBar: AppBar(
        title: surveyAsync.whenOrNull(
          data: (survey) => survey.title != null ? Text(survey.title!) : null,
        ),
        actions: [
          if (surveyAsync case AsyncData(
            :final value,
          ) when value.publisher != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: _PublisherChip(publisher: value.publisher!),
            ),
        ],
      ),
      body: surveyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Failed to load survey: $error'),
          ),
        ),
        data: (survey) => Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
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
                            if (survey.description != null &&
                                survey.description!.isNotEmpty) ...[
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
                                  label: isReadonly
                                      ? 'Read-only'
                                      : 'Interactive',
                                ),
                                if (survey.endedAt != null)
                                  _InfoChip(
                                    icon: Icons.schedule_outlined,
                                    label: MaterialLocalizations.of(
                                      context,
                                    ).formatFullDate(survey.endedAt!),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Gap(20),
                    Card(
                      elevation: 0,
                      color: colorScheme.surface.withOpacity(0.86),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: SurveySubmit(
                          surveyId: surveyId,
                          disableCollapse: true,
                          visualStyle: SurveySubmitVisualStyle.fullPage,
                          onSubmit: (_) {
                            context.maybePop();
                          },
                          isReadonly: isReadonly,
                          isInitiallyExpanded: isInitiallyExpanded,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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

class _PublisherChip extends StatelessWidget {
  final SnPublisher publisher;

  const _PublisherChip({required this.publisher});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: publisher.picture != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CloudImageWidget(
                  file: publisher.picture!,
                  fit: BoxFit.cover,
                  noBlurhash: true,
                ),
              ),
            )
          : Icon(
              Icons.account_circle,
              size: 20,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      label: Text(
        publisher.nick,
        style: Theme.of(context).textTheme.labelLarge,
      ),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      side: BorderSide.none,
      onPressed: () {
        context.router.push(PublisherProfileRoute(name: publisher.name));
      },
    );
  }
}
