import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:uuid/uuid.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

const _emptyGuid = '00000000-0000-0000-0000-000000000000';

class CreatorSurveyEditorScreen extends ConsumerStatefulWidget {
  const CreatorSurveyEditorScreen({
    super.key,
    required this.publisherName,
    this.surveyId,
  });

  final String publisherName;
  final String? surveyId;

  @override
  ConsumerState<CreatorSurveyEditorScreen> createState() =>
      _CreatorSurveyEditorScreenState();
}

class _CreatorSurveyEditorScreenState
    extends ConsumerState<CreatorSurveyEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  late SurveyEditorDraft _draft;
  bool _loading = true;
  bool _saving = false;

  bool get _isEditing =>
      widget.surveyId != null && widget.surveyId!.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _draft = SurveyEditorDraft.empty(publisherName: widget.publisherName);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitialData());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    if (!_isEditing) {
      setState(() {
        _loading = false;
      });
      return;
    }

    try {
      final dio = ref.read(solarNetworkClientProvider).dio;
      final res = await dio.get('/sphere/surveys/${widget.surveyId}');
      final json = _extractPayloadMap(res.data);
      final survey = SnSurvey.fromJson(json);
      final draft = SurveyEditorDraft.fromSurvey(
        survey,
        publisherName: widget.publisherName,
        hideResults: json['hide_results'] as bool? ?? false,
      );
      setState(() {
        _draft = draft;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
      showErrorAlert(e);
    }
  }

  Map<String, dynamic> _extractPayloadMap(dynamic payload) {
    if (payload is Map && payload['data'] is Map<String, dynamic>) {
      return Map<String, dynamic>.from(payload['data'] as Map<String, dynamic>);
    }
    return Map<String, dynamic>.from(payload as Map);
  }

  Future<void> _pickEndAt() async {
    final now = DateTime.now();
    final initial = _draft.endedAt ?? now.add(const Duration(days: 1));
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now,
      lastDate: now.add(const Duration(days: 3650)),
    );
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    setState(() {
      _draft = _draft.copyWith(
        endedAt: DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime?.hour ?? 0,
          pickedTime?.minute ?? 0,
        ),
      );
    });
  }

  void _setDraft(SurveyEditorDraft value) {
    setState(() {
      _draft = value;
    });
  }

  void _updateQuestion(int index, SurveyQuestionDraft question) {
    final next = [..._draft.questions];
    next[index] = question.copyWith(order: index);
    _setDraft(_draft.copyWith(questions: _normalizeQuestions(next)));
  }

  void _addQuestion(SnSurveyQuestionType type) {
    final questions = [..._draft.questions];
    questions.add(
      SurveyQuestionDraft.create(type: type, order: questions.length),
    );
    _setDraft(_draft.copyWith(questions: questions));
  }

  void _removeQuestion(int index) {
    final questions = [..._draft.questions]..removeAt(index);
    _setDraft(_draft.copyWith(questions: _normalizeQuestions(questions)));
  }

  void _moveQuestion(int oldIndex, int newIndex) {
    final questions = [..._draft.questions];
    if (newIndex > oldIndex) newIndex -= 1;
    final item = questions.removeAt(oldIndex);
    questions.insert(newIndex, item);
    _setDraft(_draft.copyWith(questions: _normalizeQuestions(questions)));
  }

  List<SurveyQuestionDraft> _normalizeQuestions(
    List<SurveyQuestionDraft> questions,
  ) {
    return [
      for (var i = 0; i < questions.length; i++)
        questions[i].copyWith(order: i),
    ];
  }

  String? _validateDraft() {
    if ((_draft.title ?? '').trim().isEmpty) {
      return 'surveyTitleRequired'.tr();
    }
    if (_draft.questions.isEmpty) {
      return 'Add at least one question.';
    }

    for (var i = 0; i < _draft.questions.length; i++) {
      final q = _draft.questions[i];
      final label = q.title.trim().isEmpty
          ? 'Question ${i + 1}'
          : 'Question ${i + 1}: ${q.title.trim()}';
      if (q.title.trim().isEmpty) {
        return '$label needs a title.';
      }
      if (q.isChoice) {
        if (q.options.length < 2) {
          return '$label needs at least two options.';
        }
        if (q.options.any((option) => option.label.trim().isEmpty)) {
          return '$label has an empty option label.';
        }
        if (q.type == SnSurveyQuestionType.multipleChoice &&
            q.maxSelections != null) {
          if (q.maxSelections! <= 0) {
            return '$label has an invalid max selections value.';
          }
          if (q.maxSelections! > q.options.length) {
            return '$label cannot allow more selections than options.';
          }
        }
      }
      if (q.type == SnSurveyQuestionType.freeText &&
          q.maxLength != null &&
          q.maxLength! <= 0) {
        return '$label has an invalid text limit.';
      }
      if (q.type == SnSurveyQuestionType.rating) {
        if (q.minValue == null || q.maxValue == null) {
          return '$label needs both minimum and maximum rating values.';
        }
        if (q.minValue! >= q.maxValue!) {
          return '$label must have a minimum smaller than the maximum.';
        }
      }
    }

    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final validationError = _validateDraft();
    if (validationError != null) {
      showSnackBar(validationError);
      return;
    }

    setState(() {
      _saving = true;
    });

    final dio = ref.read(solarNetworkClientProvider).dio;
    final body = _draft.toRequestBody(includeClearEndedAt: _isEditing);

    try {
      final Response res = _isEditing
          ? await dio.patch(
              '/sphere/surveys/${_draft.id}',
              queryParameters: {'pub': widget.publisherName},
              data: body,
            )
          : await dio.post(
              '/sphere/surveys',
              queryParameters: {'pub': widget.publisherName},
              data: body,
            );

      if (!mounted) return;
      showSnackBar(_isEditing ? 'surveyUpdated'.tr() : 'surveyCreated'.tr());
      Navigator.of(
        context,
      ).pop(SnSurvey.fromJson(_extractPayloadMap(res.data)));
    } catch (e) {
      if (mounted) {
        showErrorAlert(e);
      }
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppScaffold(
      appBar: AppBar(
        leading: const AutoLeadingButton(),
        title: Text(_isEditing ? 'surveyEdit'.tr() : 'surveyCreate'.tr()),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 920),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _OverviewCard(
                                draft: _draft,
                                onTitleChanged: (value) => _setDraft(
                                  _draft.copyWith(
                                    title: value.trim().isEmpty ? null : value,
                                  ),
                                ),
                                onDescriptionChanged: (value) => _setDraft(
                                  _draft.copyWith(
                                    description: value.trim().isEmpty
                                        ? null
                                        : value,
                                  ),
                                ),
                                onPickEndedAt: _pickEndAt,
                                onClearEndedAt: () =>
                                    _setDraft(_draft.copyWith(endedAt: null)),
                                onNotifySubscribersChanged: (value) =>
                                    _setDraft(
                                      _draft.copyWith(notifySubscribers: value),
                                    ),
                                onAnonymousChanged: (value) => _setDraft(
                                  _draft.copyWith(isAnonymous: value),
                                ),
                                onHideResultsChanged: (value) => _setDraft(
                                  _draft.copyWith(hideResults: value),
                                ),
                              ),
                              const Gap(20),
                              _QuestionToolbar(
                                totalQuestions: _draft.questions.length,
                                onAddQuestion: _addQuestion,
                              ),
                              const Gap(12),
                              if (_draft.questions.isEmpty)
                                _QuestionEmptyState(
                                  onAddFirstQuestion: () => _addQuestion(
                                    SnSurveyQuestionType.singleChoice,
                                  ),
                                )
                              else
                                ReorderableListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  buildDefaultDragHandles: false,
                                  itemCount: _draft.questions.length,
                                  onReorder: _moveQuestion,
                                  itemBuilder: (context, index) {
                                    final question = _draft.questions[index];
                                    return Padding(
                                      key: ValueKey(question.id),
                                      padding: const EdgeInsets.only(
                                        bottom: 12,
                                      ),
                                      child: _QuestionCard(
                                        index: index,
                                        question: question,
                                        onChanged: (next) =>
                                            _updateQuestion(index, next),
                                        onDelete: () => _removeQuestion(index),
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Material(
                  color: theme.colorScheme.surfaceContainerHigh,
                  elevation: 4,
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 920),
                        child: Row(
                          children: [
                            Text(
                              _draft.questions.isEmpty
                                  ? 'No questions yet'
                                  : '${_draft.questions.length} questions ready',
                              style: theme.textTheme.bodyMedium,
                            ),
                            const Spacer(),
                            OutlinedButton(
                              onPressed: _saving
                                  ? null
                                  : () => Navigator.of(context).maybePop(),
                              child: Text('cancel'.tr()),
                            ),
                            const Gap(12),
                            FilledButton.icon(
                              onPressed: _saving ? null : _submit,
                              icon: const Icon(Icons.cloud_upload_outlined),
                              label: Text(
                                _isEditing ? 'update'.tr() : 'create'.tr(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

@immutable
class SurveyEditorDraft {
  const SurveyEditorDraft({
    required this.publisherName,
    this.id,
    this.title,
    this.description,
    this.endedAt,
    required this.notifySubscribers,
    required this.isAnonymous,
    required this.hideResults,
    required this.questions,
  });

  final String publisherName;
  final String? id;
  final String? title;
  final String? description;
  final DateTime? endedAt;
  final bool notifySubscribers;
  final bool isAnonymous;
  final bool hideResults;
  final List<SurveyQuestionDraft> questions;

  factory SurveyEditorDraft.empty({required String publisherName}) {
    return SurveyEditorDraft(
      publisherName: publisherName,
      notifySubscribers: false,
      isAnonymous: false,
      hideResults: false,
      questions: const [],
    );
  }

  factory SurveyEditorDraft.fromSurvey(
    SnSurvey survey, {
    required String publisherName,
    required bool hideResults,
  }) {
    return SurveyEditorDraft(
      publisherName: publisherName,
      id: survey.id,
      title: survey.title,
      description: survey.description,
      endedAt: survey.endedAt,
      notifySubscribers: survey.notifySubscribers,
      isAnonymous: survey.isAnonymous,
      hideResults: hideResults,
      questions: [
        for (final question in survey.questions)
          SurveyQuestionDraft.fromQuestion(question),
      ],
    );
  }

  SurveyEditorDraft copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? endedAt,
    bool clearEndedAt = false,
    bool? notifySubscribers,
    bool? isAnonymous,
    bool? hideResults,
    List<SurveyQuestionDraft>? questions,
  }) {
    return SurveyEditorDraft(
      publisherName: publisherName,
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      endedAt: clearEndedAt ? null : (endedAt ?? this.endedAt),
      notifySubscribers: notifySubscribers ?? this.notifySubscribers,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      hideResults: hideResults ?? this.hideResults,
      questions: questions ?? this.questions,
    );
  }

  Map<String, dynamic> toRequestBody({required bool includeClearEndedAt}) {
    return {
      'title': title,
      'description': description,
      'ended_at': endedAt?.toUtc().toIso8601String(),
      if (includeClearEndedAt && endedAt == null) 'clear_ended_at': true,
      'notify_subscribers': notifySubscribers,
      'is_anonymous': isAnonymous,
      'hide_results': hideResults,
      'questions': [for (final question in questions) question.toRequestBody()],
    };
  }
}

@immutable
class SurveyQuestionDraft {
  const SurveyQuestionDraft({
    required this.id,
    required this.type,
    required this.title,
    this.description,
    required this.order,
    required this.isRequired,
    required this.options,
    this.maxSelections,
    this.maxLength,
    this.minValue,
    this.maxValue,
  });

  final String id;
  final SnSurveyQuestionType type;
  final String title;
  final String? description;
  final int order;
  final bool isRequired;
  final List<SurveyOptionDraft> options;
  final int? maxSelections;
  final int? maxLength;
  final double? minValue;
  final double? maxValue;

  bool get isChoice =>
      type == SnSurveyQuestionType.singleChoice ||
      type == SnSurveyQuestionType.multipleChoice;

  factory SurveyQuestionDraft.create({
    required SnSurveyQuestionType type,
    required int order,
  }) {
    return SurveyQuestionDraft(
      id: const Uuid().v4(),
      type: type,
      title: '',
      order: order,
      isRequired: false,
      options:
          type == SnSurveyQuestionType.singleChoice ||
              type == SnSurveyQuestionType.multipleChoice
          ? [
              SurveyOptionDraft.create(order: 0, label: 'Option 1'),
              SurveyOptionDraft.create(order: 1, label: 'Option 2'),
            ]
          : const [],
      minValue: type == SnSurveyQuestionType.rating ? 1 : null,
      maxValue: type == SnSurveyQuestionType.rating ? 5 : null,
    );
  }

  factory SurveyQuestionDraft.fromQuestion(SnSurveyQuestion question) {
    return SurveyQuestionDraft(
      id: question.id,
      type: question.type,
      title: question.title,
      description: question.description,
      order: question.order,
      isRequired: question.isRequired,
      options: [
        for (final option in question.options ?? const <SnSurveyOption>[])
          SurveyOptionDraft.fromOption(option),
      ],
      maxSelections: question.maxSelections,
      maxLength: question.maxLength,
      minValue: question.minValue,
      maxValue: question.maxValue,
    );
  }

  SurveyQuestionDraft copyWith({
    String? id,
    SnSurveyQuestionType? type,
    String? title,
    String? description,
    bool clearDescription = false,
    int? order,
    bool? isRequired,
    List<SurveyOptionDraft>? options,
    int? maxSelections,
    bool clearMaxSelections = false,
    int? maxLength,
    bool clearMaxLength = false,
    double? minValue,
    bool clearMinValue = false,
    double? maxValue,
    bool clearMaxValue = false,
  }) {
    return SurveyQuestionDraft(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: clearDescription ? null : (description ?? this.description),
      order: order ?? this.order,
      isRequired: isRequired ?? this.isRequired,
      options: options ?? this.options,
      maxSelections: clearMaxSelections
          ? null
          : (maxSelections ?? this.maxSelections),
      maxLength: clearMaxLength ? null : (maxLength ?? this.maxLength),
      minValue: clearMinValue ? null : (minValue ?? this.minValue),
      maxValue: clearMaxValue ? null : (maxValue ?? this.maxValue),
    );
  }

  Map<String, dynamic> toRequestBody() {
    return {
      'id': id.isEmpty ? _emptyGuid : id,
      'type': type.index,
      'options': isChoice
          ? [for (final option in options) option.toRequestBody()]
          : null,
      'title': title.trim(),
      'description': description?.trim().isEmpty == true ? null : description,
      'order': order,
      'is_required': isRequired,
      'max_selections': type == SnSurveyQuestionType.multipleChoice
          ? maxSelections
          : null,
      'max_length': type == SnSurveyQuestionType.freeText ? maxLength : null,
      'min_value': type == SnSurveyQuestionType.rating ? minValue : null,
      'max_value': type == SnSurveyQuestionType.rating ? maxValue : null,
    };
  }
}

@immutable
class SurveyOptionDraft {
  const SurveyOptionDraft({
    required this.id,
    required this.label,
    this.description,
    required this.order,
  });

  final String id;
  final String label;
  final String? description;
  final int order;

  factory SurveyOptionDraft.create({
    required int order,
    required String label,
  }) {
    return SurveyOptionDraft(id: _emptyGuid, label: label, order: order);
  }

  factory SurveyOptionDraft.fromOption(SnSurveyOption option) {
    return SurveyOptionDraft(
      id: option.id,
      label: option.label,
      description: option.description,
      order: option.order,
    );
  }

  SurveyOptionDraft copyWith({
    String? id,
    String? label,
    String? description,
    bool clearDescription = false,
    int? order,
  }) {
    return SurveyOptionDraft(
      id: id ?? this.id,
      label: label ?? this.label,
      description: clearDescription ? null : (description ?? this.description),
      order: order ?? this.order,
    );
  }

  Map<String, dynamic> toRequestBody() {
    return {
      'id': id.isEmpty ? _emptyGuid : id,
      'label': label.trim(),
      'description': description?.trim().isEmpty == true ? null : description,
      'order': order,
    };
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.draft,
    required this.onTitleChanged,
    required this.onDescriptionChanged,
    required this.onPickEndedAt,
    required this.onClearEndedAt,
    required this.onNotifySubscribersChanged,
    required this.onAnonymousChanged,
    required this.onHideResultsChanged,
  });

  final SurveyEditorDraft draft;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onDescriptionChanged;
  final VoidCallback onPickEndedAt;
  final VoidCallback onClearEndedAt;
  final ValueChanged<bool> onNotifySubscribersChanged;
  final ValueChanged<bool> onAnonymousChanged;
  final ValueChanged<bool> onHideResultsChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final endedAtLabel = draft.endedAt == null
        ? 'No end date'
        : '${MaterialLocalizations.of(context).formatFullDate(draft.endedAt!)} ${MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(draft.endedAt!), alwaysUse24HourFormat: true)}';

    return Card.filled(
      color: theme.colorScheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              draft.title?.trim().isNotEmpty == true
                  ? draft.title!.trim()
                  : 'Untitled survey',
              style: theme.textTheme.headlineSmall,
            ),
            const Gap(6),
            Text(
              'Draft a survey that is ready to publish without leaving this screen.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const Gap(20),
            TextFormField(
              initialValue: draft.title ?? '',
              decoration: const InputDecoration(labelText: 'Title'),
              maxLength: 256,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'surveyTitleRequired'.tr();
                }
                return null;
              },
              onChanged: onTitleChanged,
            ),
            const Gap(12),
            TextFormField(
              initialValue: draft.description ?? '',
              decoration: const InputDecoration(
                labelText: 'Description',
                alignLabelWithHint: true,
              ),
              maxLength: 4096,
              maxLines: 4,
              onChanged: onDescriptionChanged,
            ),
            const Gap(16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.tonalIcon(
                  onPressed: onPickEndedAt,
                  icon: const Icon(Icons.event_outlined),
                  label: Text(endedAtLabel),
                ),
                if (draft.endedAt != null)
                  TextButton.icon(
                    onPressed: onClearEndedAt,
                    icon: const Icon(Icons.close),
                    label: Text('clear'.tr()),
                  ),
              ],
            ),
            const Gap(16),
            _SettingTile(
              icon: Icons.notifications_active_outlined,
              title: 'surveyNotifySubscribers'.tr(),
              subtitle: 'surveyNotifySubscribersHint'.tr(),
              value: draft.notifySubscribers,
              onChanged: onNotifySubscribersChanged,
            ),
            const Gap(12),
            _SettingTile(
              icon: Icons.shield_outlined,
              title: 'surveyAnonymousAnswers'.tr(),
              subtitle: 'surveyAnonymousAnswersHint'.tr(),
              value: draft.isAnonymous,
              onChanged: onAnonymousChanged,
            ),
            const Gap(12),
            _SettingTile(
              icon: Icons.bar_chart_outlined,
              title: 'Hide results',
              subtitle: 'Only publisher members can see aggregate statistics.',
              value: draft.hideResults,
              onChanged: onHideResultsChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      child: SwitchListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        secondary: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

class _QuestionToolbar extends StatelessWidget {
  const _QuestionToolbar({
    required this.totalQuestions,
    required this.onAddQuestion,
  });

  final int totalQuestions;
  final ValueChanged<SnSurveyQuestionType> onAddQuestion;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'surveyQuestions'.tr(),
                    style: theme.textTheme.titleMedium,
                  ),
                  const Gap(4),
                  Text(
                    totalQuestions == 0
                        ? 'Add structured questions, limits, and answer rules.'
                        : '$totalQuestions question${totalQuestions == 1 ? '' : 's'} configured',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(12),
            MenuAnchor(
              builder: (context, controller, _) {
                return FilledButton.icon(
                  onPressed: () {
                    if (controller.isOpen) {
                      controller.close();
                    } else {
                      controller.open();
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: Text('surveyAddQuestion'.tr()),
                );
              },
              menuChildren: [
                for (final type in SnSurveyQuestionType.values)
                  MenuItemButton(
                    leadingIcon: Icon(_iconForType(type)),
                    onPressed: () => onAddQuestion(type),
                    child: Text(_labelForType(type)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionEmptyState extends StatelessWidget {
  const _QuestionEmptyState({required this.onAddFirstQuestion});

  final VoidCallback onAddFirstQuestion;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card.filled(
      color: theme.colorScheme.secondaryContainer.withOpacity(0.45),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.quiz_outlined, color: theme.colorScheme.primary),
            const Gap(12),
            Text(
              'surveyNoQuestionsYet'.tr(),
              style: theme.textTheme.titleSmall,
            ),
            const Gap(6),
            Text(
              'surveyNoQuestionsHint'.tr(),
              style: theme.textTheme.bodyMedium,
            ),
            const Gap(16),
            FilledButton.icon(
              onPressed: onAddFirstQuestion,
              icon: const Icon(Icons.add),
              label: const Text('Add first question'),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.index,
    required this.question,
    required this.onChanged,
    required this.onDelete,
  });

  final int index;
  final SurveyQuestionDraft question;
  final ValueChanged<SurveyQuestionDraft> onChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ReorderableDragStartListener(
                  index: index,
                  child: const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Icon(Icons.drag_handle),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question.title.trim().isEmpty
                            ? 'surveyUntitledQuestion'.tr()
                            : question.title.trim(),
                        style: theme.textTheme.titleSmall,
                      ),
                      const Gap(4),
                      Text(
                        _labelForType(question.type),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'delete'.tr(),
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            const Gap(20),
            SizedBox(
              width: 260,
              child: DropdownButtonFormField<SnSurveyQuestionType>(
                value: question.type,
                decoration: const InputDecoration(labelText: 'Type'),
                items: [
                  for (final type in SnSurveyQuestionType.values)
                    DropdownMenuItem(
                      value: type,
                      child: Row(
                        children: [
                          Icon(_iconForType(type), size: 18),
                          const Gap(8),
                          Text(_labelForType(type)),
                        ],
                      ),
                    ),
                ],
                onChanged: (type) {
                  if (type == null) return;
                  onChanged(_switchQuestionType(question, type));
                },
              ),
            ),
            const Gap(12),
            TextFormField(
              initialValue: question.title,
              decoration: InputDecoration(
                labelText: 'surveyQuestionTitle'.tr(),
                helperText: 'Shown to respondents',
              ),
              maxLength: 1024,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'surveyQuestionTitleRequired'.tr();
                }
                return null;
              },
              onChanged: (value) => onChanged(question.copyWith(title: value)),
            ),
            const Gap(12),
            TextFormField(
              initialValue: question.description ?? '',
              decoration: InputDecoration(
                alignLabelWithHint: true,
                labelText: 'surveyQuestionDescriptionOptional'.tr(),
              ),
              maxLines: 3,
              maxLength: 4096,
              onChanged: (value) => onChanged(
                question.copyWith(
                  description: value,
                  clearDescription: value.trim().isEmpty,
                ),
              ),
            ),
            const Gap(16),
            _QuestionCapabilitySection(
              question: question,
              onChanged: onChanged,
            ),
            const Gap(16),
            _SettingTile(
              icon: Icons.check_circle_outlined,
              title: 'required'.tr(),
              subtitle: 'Respondents must answer this question.',
              value: question.isRequired,
              onChanged: (value) => onChanged(question.copyWith(isRequired: value)),
            ),
          ],
        ),
      ),
    );
  }

  SurveyQuestionDraft _switchQuestionType(
    SurveyQuestionDraft question,
    SnSurveyQuestionType type,
  ) {
    if (type == question.type) return question;
    final isChoice =
        type == SnSurveyQuestionType.singleChoice ||
        type == SnSurveyQuestionType.multipleChoice;
    return question.copyWith(
      type: type,
      options: isChoice
          ? (question.options.length >= 2
                ? [
                    for (var i = 0; i < question.options.length; i++)
                      question.options[i].copyWith(order: i),
                  ]
                : [
                    SurveyOptionDraft.create(order: 0, label: 'Option 1'),
                    SurveyOptionDraft.create(order: 1, label: 'Option 2'),
                  ])
          : const [],
      clearMaxSelections: type != SnSurveyQuestionType.multipleChoice,
      clearMaxLength: type != SnSurveyQuestionType.freeText,
      clearMinValue: type != SnSurveyQuestionType.rating,
      clearMaxValue: type != SnSurveyQuestionType.rating,
      minValue: type == SnSurveyQuestionType.rating
          ? (question.minValue ?? 1)
          : null,
      maxValue: type == SnSurveyQuestionType.rating
          ? (question.maxValue ?? 5)
          : null,
    );
  }
}

class _QuestionCapabilitySection extends StatelessWidget {
  const _QuestionCapabilitySection({
    required this.question,
    required this.onChanged,
  });

  final SurveyQuestionDraft question;
  final ValueChanged<SurveyQuestionDraft> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (question.isChoice) ...[
          _OptionsSection(question: question, onChanged: onChanged),
          const Gap(16),
        ],
        if (question.type == SnSurveyQuestionType.multipleChoice) ...[
          const Gap(12),
          _NumericField(
            label: 'Maximum selections',
            helperText: 'Leave empty to allow choosing any number of options.',
            value: question.maxSelections,
            onChanged: (value) => onChanged(
              question.copyWith(
                maxSelections: value,
                clearMaxSelections: value == null,
              ),
            ),
          ),
        ],
        if (question.type == SnSurveyQuestionType.freeText) ...[
          _NumericField(
            label: 'Maximum text length',
            helperText: 'Optional response length limit.',
            value: question.maxLength,
            onChanged: (value) => onChanged(
              question.copyWith(
                maxLength: value,
                clearMaxLength: value == null,
              ),
            ),
          ),
        ],
        if (question.type == SnSurveyQuestionType.rating)
          Row(
            children: [
              Expanded(
                child: _DecimalField(
                  label: 'Minimum rating',
                  value: question.minValue,
                  onChanged: (value) => onChanged(
                    question.copyWith(
                      minValue: value,
                      clearMinValue: value == null,
                    ),
                  ),
                ),
              ),
              const Gap(12),
              Expanded(
                child: _DecimalField(
                  label: 'Maximum rating',
                  value: question.maxValue,
                  onChanged: (value) => onChanged(
                    question.copyWith(
                      maxValue: value,
                      clearMaxValue: value == null,
                    ),
                  ),
                ),
              ),
            ],
          ),
        if (question.type == SnSurveyQuestionType.yesNo)
          const _PreviewTile(
            icon: Icons.toggle_on_outlined,
            title: 'Yes / No response',
            subtitle: 'Respondents will answer with a boolean value.',
          ),
        if (question.type == SnSurveyQuestionType.freeText) ...[
          const Gap(12),
          const _PreviewTile(
            icon: Icons.short_text,
            title: 'Free text response',
            subtitle: 'Supports optional text length constraints.',
          ),
        ],
        if (question.type == SnSurveyQuestionType.rating) ...[
          const Gap(12),
          const _PreviewTile(
            icon: Icons.star_outline,
            title: 'Rating response',
            subtitle:
                'Collected as a numeric value within your configured range.',
          ),
        ],
      ],
    );
  }
}

class _OptionsSection extends StatelessWidget {
  const _OptionsSection({required this.question, required this.onChanged});

  final SurveyQuestionDraft question;
  final ValueChanged<SurveyQuestionDraft> onChanged;

  @override
  Widget build(BuildContext context) {
    final options = question.options;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'options'.tr(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: () {
                final next = [...options];
                next.add(
                  SurveyOptionDraft.create(
                    order: next.length,
                    label: 'Option ${next.length + 1}',
                  ),
                );
                onChanged(question.copyWith(options: _normalizeOptions(next)));
              },
              icon: const Icon(Icons.add),
              label: Text('surveyAddOption'.tr()),
            ),
          ],
        ),
        const Gap(8),
        for (final entry in options.asMap().entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _OptionEditor(
              option: entry.value,
              index: entry.key,
              total: options.length,
              onChanged: (option) {
                final next = [...options];
                next[entry.key] = option.copyWith(order: entry.key);
                onChanged(question.copyWith(options: next));
              },
              onMoveUp: entry.key == 0
                  ? null
                  : () {
                      final next = [...options];
                      final item = next.removeAt(entry.key);
                      next.insert(entry.key - 1, item);
                      onChanged(
                        question.copyWith(options: _normalizeOptions(next)),
                      );
                    },
              onMoveDown: entry.key == options.length - 1
                  ? null
                  : () {
                      final next = [...options];
                      final item = next.removeAt(entry.key);
                      next.insert(entry.key + 1, item);
                      onChanged(
                        question.copyWith(options: _normalizeOptions(next)),
                      );
                    },
              onDelete: options.length <= 2
                  ? null
                  : () {
                      final next = [...options]..removeAt(entry.key);
                      onChanged(
                        question.copyWith(options: _normalizeOptions(next)),
                      );
                    },
            ),
          ),
      ],
    );
  }

  List<SurveyOptionDraft> _normalizeOptions(List<SurveyOptionDraft> options) {
    return [
      for (var i = 0; i < options.length; i++) options[i].copyWith(order: i),
    ];
  }
}

class _OptionEditor extends StatelessWidget {
  const _OptionEditor({
    required this.option,
    required this.index,
    required this.total,
    required this.onChanged,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onDelete,
  });

  final SurveyOptionDraft option;
  final int index;
  final int total;
  final ValueChanged<SurveyOptionDraft> onChanged;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(radius: 14, child: Text('${index + 1}')),
                const Gap(12),
                Expanded(
                  child: Text(
                    'Option ${index + 1}${total > 2 ? '' : ' (minimum set)'}',
                  ),
                ),
                IconButton(
                  onPressed: onMoveUp,
                  icon: const Icon(Icons.arrow_upward),
                ),
                IconButton(
                  onPressed: onMoveDown,
                  icon: const Icon(Icons.arrow_downward),
                ),
                IconButton(onPressed: onDelete, icon: const Icon(Icons.close)),
              ],
            ),
            const Gap(8),
            TextFormField(
              initialValue: option.label,
              decoration: InputDecoration(labelText: 'surveyOptionLabel'.tr()),
              inputFormatters: [LengthLimitingTextInputFormatter(1024)],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Option label is required.';
                }
                return null;
              },
              onChanged: (value) => onChanged(option.copyWith(label: value)),
            ),
            const Gap(10),
            TextFormField(
              initialValue: option.description ?? '',
              decoration: const InputDecoration(
                labelText: 'Option description',
              ),
              maxLines: 2,
              inputFormatters: [LengthLimitingTextInputFormatter(4096)],
              onChanged: (value) => onChanged(
                option.copyWith(
                  description: value,
                  clearDescription: value.trim().isEmpty,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NumericField extends StatelessWidget {
  const _NumericField({
    required this.label,
    required this.helperText,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String helperText;
  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value?.toString() ?? '',
      decoration: InputDecoration(labelText: label, helperText: helperText),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: (value) =>
          onChanged(value.trim().isEmpty ? null : int.tryParse(value.trim())),
    );
  }
}

class _DecimalField extends StatelessWidget {
  const _DecimalField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final double? value;
  final ValueChanged<double?> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value?.toString() ?? '',
      decoration: InputDecoration(labelText: label),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      onChanged: (value) => onChanged(
        value.trim().isEmpty ? null : double.tryParse(value.trim()),
      ),
    );
  }
}

class _PreviewTile extends StatelessWidget {
  const _PreviewTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}

IconData _iconForType(SnSurveyQuestionType type) {
  return switch (type) {
    SnSurveyQuestionType.singleChoice => Icons.radio_button_checked,
    SnSurveyQuestionType.multipleChoice => Icons.check_box_outlined,
    SnSurveyQuestionType.yesNo => Icons.toggle_on_outlined,
    SnSurveyQuestionType.rating => Icons.star_outline,
    SnSurveyQuestionType.freeText => Icons.short_text,
  };
}

String _labelForType(SnSurveyQuestionType type) {
  return switch (type) {
    SnSurveyQuestionType.singleChoice => 'surveyQuestionTypeSingleChoice'.tr(),
    SnSurveyQuestionType.multipleChoice =>
      'surveyQuestionTypeMultipleChoice'.tr(),
    SnSurveyQuestionType.yesNo => 'surveyQuestionTypeYesNo'.tr(),
    SnSurveyQuestionType.rating => 'surveyQuestionTypeRating'.tr(),
    SnSurveyQuestionType.freeText => 'surveyQuestionTypeFreeText'.tr(),
  };
}
