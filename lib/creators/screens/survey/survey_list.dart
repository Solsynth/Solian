import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/creators/screens/survey/survey_editor.dart';
import 'package:island/polls/polls_widgets/poll/poll_feedback.dart';
import 'package:island/core/network.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart' hide PageBackButton;
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:island/shared/widgets/extended_refresh_indicator.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'survey_list.g.dart';

final surveyListNotifierProvider = AsyncNotifierProvider.family.autoDispose(
  SurveyListNotifier.new,
);

class SurveyListNotifier
    extends AsyncNotifier<PaginationState<SnSurveyWithStats>>
    with AsyncPaginationController<SnSurveyWithStats> {
  static const int pageSize = 20;

  final String? arg;
  SurveyListNotifier(this.arg);

  @override
  Future<List<SnSurveyWithStats>> fetch() async {
    final client = ref.read(solarNetworkClientProvider).dio;

    final queryParams = {
      'offset': fetchedCount.toString(),
      'take': pageSize,
      if (arg != null) 'pub': arg,
    };

    final response = await client.get(
      '/sphere/surveys/me',
      queryParameters: queryParams,
    );
    totalCount = int.parse(response.headers.value('X-Total') ?? '0');
    final items = response.data
        .map((json) => SnSurveyWithStats.fromJson(json))
        .cast<SnSurveyWithStats>()
        .toList();

    return items;
  }
}

@riverpod
Future<SnSurveyWithStats> surveyWithStats(Ref ref, String id) async {
  final apiClient = ref.watch(solarNetworkClientProvider).dio;
  final resp = await apiClient.get('/sphere/surveys/$id');
  return SnSurveyWithStats.fromJson(resp.data);
}

@RoutePage()
class CreatorSurveyListScreen extends HookConsumerWidget {
  const CreatorSurveyListScreen({
    super.key,
    @PathParam("pubName") required this.pubName,
  });

  final String pubName;

  Future<void> _createSurvey(BuildContext context, WidgetRef ref) async {
    final result = await Navigator.of(context).push<SnSurvey>(
      MaterialPageRoute(
        builder: (context) => CreatorSurveyEditorScreen(publisherName: pubName),
      ),
    );
    if (result != null && context.mounted) {
      ref.invalidate(surveyListNotifierProvider(pubName));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      appBar: AppBar(
        leading: const AutoLeadingButton(),
        title: const Text('Surveys'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createSurvey(context, ref),
        child: const Icon(Icons.add),
      ),
      body: ExtendedRefreshIndicator(
        onRefresh: () =>
            ref.refresh(surveyListNotifierProvider(pubName).future),
        child: PaginationList(
          footerSkeletonMaxWidth: 640,
          provider: surveyListNotifierProvider(pubName),
          notifier: surveyListNotifierProvider(pubName).notifier,
          padding: const EdgeInsets.only(top: 12),
          itemBuilder: (context, index, surveyWithStats) {
            return ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 640),
              child: _CreatorSurveyItem(
                surveyWithStats: surveyWithStats,
                pubName: pubName,
              ),
            ).center();
          },
        ),
      ),
    );
  }
}

class _CreatorSurveyItem extends HookConsumerWidget {
  final String pubName;
  const _CreatorSurveyItem({
    required this.surveyWithStats,
    required this.pubName,
  });

  final SnSurveyWithStats surveyWithStats;

  String _statusLabel(SnSurveyStatus status) {
    return switch (status) {
      SnSurveyStatus.draft => 'surveyDraft'.tr(),
      SnSurveyStatus.published => 'surveyPublished'.tr(),
      SnSurveyStatus.archived => 'surveyArchived'.tr(),
    };
  }

  Color _statusColor(SnSurveyStatus status, ThemeData theme) {
    return switch (status) {
      SnSurveyStatus.draft => theme.colorScheme.outline,
      SnSurveyStatus.published => Colors.green,
      SnSurveyStatus.archived => theme.colorScheme.tertiary,
    };
  }

  Future<void> _publish(BuildContext context, WidgetRef ref) async {
    try {
      final client = ref.read(solarNetworkClientProvider).dio;
      await client.post('/sphere/surveys/${surveyWithStats.id}/publish');
      ref.invalidate(surveyListNotifierProvider(pubName));
      showSnackBar('surveyPublishedSnackbar'.tr());
    } catch (e) {
      showErrorAlert(e);
    }
  }

  Future<void> _archive(BuildContext context, WidgetRef ref) async {
    try {
      final client = ref.read(solarNetworkClientProvider).dio;
      await client.post('/sphere/surveys/${surveyWithStats.id}/archive');
      ref.invalidate(surveyListNotifierProvider(pubName));
      showSnackBar('surveyArchivedSnackbar'.tr());
    } catch (e) {
      showErrorAlert(e);
    }
  }

  Future<void> _clone(BuildContext context, WidgetRef ref) async {
    try {
      final client = ref.read(solarNetworkClientProvider).dio;
      await client.post('/sphere/surveys/${surveyWithStats.id}/clone');
      ref.invalidate(surveyListNotifierProvider(pubName));
      showSnackBar('surveyClonedSnackbar'.tr());
    } catch (e) {
      showErrorAlert(e);
    }
  }

  Future<void> _editSurvey(BuildContext context, WidgetRef ref) async {
    final result = await Navigator.of(context).push<SnSurvey>(
      MaterialPageRoute(
        builder: (context) => CreatorSurveyEditorScreen(
          publisherName: pubName,
          surveyId: surveyWithStats.id,
        ),
      ),
    );
    if (result != null && context.mounted) {
      ref.invalidate(surveyListNotifierProvider(pubName));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final ended = surveyWithStats.endedAt;
    final endedText = ended == null
        ? 'No end'
        : MaterialLocalizations.of(context).formatFullDate(ended);
    final status = surveyWithStats.status;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        title: Text(surveyWithStats.title ?? 'Untitled survey'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (surveyWithStats.description != null &&
                surveyWithStats.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  surveyWithStats.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor(status, theme).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _statusLabel(status),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _statusColor(status, theme),
                      ),
                    ),
                  ),
                  const Gap(8),
                  Expanded(
                    child: Text(
                      '${surveyWithStats.questions.length} questions · Ends: $endedText',
                      style: theme.textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          itemBuilder: (context) => [
            if (status == SnSurveyStatus.draft)
              PopupMenuItem(
                child: Row(
                  children: [
                    const Icon(Symbols.edit),
                    const Gap(16),
                    Text('edit').tr(),
                  ],
                ),
                onTap: () => _editSurvey(context, ref),
              ),
            if (status == SnSurveyStatus.draft)
              PopupMenuItem(
                child: Row(
                  children: [
                    const Icon(Symbols.publish),
                    const Gap(16),
                    Text('surveyPublish'.tr()).textColor(Colors.green),
                  ],
                ),
                onTap: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('surveyPublishConfirmTitle'.tr()),
                      content: Text('surveyPublishConfirmContent'.tr()),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text('cancel'.tr()),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text('surveyPublish'.tr()),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    await _publish(context, ref);
                  }
                },
              ),
            if (status == SnSurveyStatus.published)
              PopupMenuItem(
                child: Row(
                  children: [
                    const Icon(Symbols.archive),
                    const Gap(16),
                    Text('surveyArchive'.tr()).textColor(Colors.orange),
                  ],
                ),
                onTap: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('surveyArchiveConfirmTitle'.tr()),
                      content: Text('surveyArchiveConfirmContent'.tr()),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text('cancel'.tr()),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text('surveyArchive'.tr()),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    await _archive(context, ref);
                  }
                },
              ),
            if (status != SnSurveyStatus.draft)
              PopupMenuItem(
                child: Row(
                  children: [
                    const Icon(Symbols.content_copy),
                    const Gap(16),
                    Text('surveyClone'.tr()),
                  ],
                ),
                onTap: () => _clone(context, ref),
              ),
            PopupMenuItem(
              child: Row(
                children: [
                  const Icon(Symbols.delete),
                  const Gap(16),
                  const Text('Delete Survey'),
                ],
              ),
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Survey'),
                    content: const Text(
                      'Are you sure you want to delete this survey?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text('cancel'.tr()),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text('delete'.tr()),
                      ),
                    ],
                  ),
                );
                if (confirmed != true) return;
                try {
                  final client = ref.read(solarNetworkClientProvider).dio;
                  await client.delete('/sphere/surveys/${surveyWithStats.id}');
                  ref.invalidate(surveyListNotifierProvider(pubName));
                  showSnackBar('Survey deleted successfully');
                } catch (e) {
                  showErrorAlert(e);
                }
              },
            ),
          ],
        ),
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => PollFeedbackSheet(pollId: surveyWithStats.id),
        ),
      ),
    );
  }
}
