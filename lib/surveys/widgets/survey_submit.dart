import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/creators/screens/survey/survey_list.dart';
import 'package:island/surveys/widgets/survey_stats_widget.dart';
import 'package:island/core/network.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

enum SurveySubmitVisualStyle { compact, fullPage }

class SurveySubmit extends ConsumerStatefulWidget {
  const SurveySubmit({
    super.key,
    required this.surveyId,
    required this.onSubmit,
    this.initialAnswers,
    this.onCancel,
    this.showProgress = true,
    this.isReadonly = false,
    this.isInitiallyExpanded = false,
    this.disableCollapse = false,
    this.visualStyle = SurveySubmitVisualStyle.compact,
  });

  final String surveyId;

  /// Callback when user submits all answers. Map questionId -> answer.
  final void Function(Map<String, dynamic> answers) onSubmit;

  /// Optional initial answers, keyed by questionId.
  final Map<String, dynamic>? initialAnswers;

  /// Optional cancel callback.
  final VoidCallback? onCancel;

  /// Whether to show a progress indicator (e.g., "2 / N").
  final bool showProgress;

  final bool isReadonly;

  /// Whether the survey should start expanded instead of collapsed.
  final bool isInitiallyExpanded;

  /// When true, the survey cannot be collapsed and always stays expanded.
  final bool disableCollapse;

  final SurveySubmitVisualStyle visualStyle;

  @override
  ConsumerState<SurveySubmit> createState() => _SurveySubmitState();
}

class _SurveySubmitState extends ConsumerState<SurveySubmit> {
  List<SnSurveyQuestion>? _questions;
  int _index = 0;
  bool _submitting = false;
  bool _isModifying = false; // New state to track if user is modifying answers
  bool _isCollapsed = true; // New state to track collapse/expand

  /// Collected answers, keyed by questionId
  late Map<String, dynamic> _answers;

  /// Local controller for free text input
  final TextEditingController _textController = TextEditingController();

  /// Local state holders for inputs to avoid rebuilding whole list
  String? _singleChoiceSelected; // optionId
  final Set<String> _multiChoiceSelected = {};
  bool? _yesNoSelected;
  int? _ratingSelected; // 1..5

  /// Flag to track if user has edited the current question to prevent provider rebuilds from resetting state
  bool _userHasEdited = false;

  /// Listener for text controller to mark as edited when user types
  late final VoidCallback _controllerListener;

  @override
  void initState() {
    super.initState();
    _controllerListener = () {
      _userHasEdited = true;
    };
    _textController.addListener(_controllerListener);
    _answers = Map<String, dynamic>.from(widget.initialAnswers ?? {});
    // Set initial collapse state based on the parameter
    _isCollapsed = widget.disableCollapse ? false : !widget.isInitiallyExpanded;
    if (!widget.isReadonly) {
      // If initial answers are provided, set _isModifying to false initially
      // so the "Modify" button is shown.
      if (widget.initialAnswers != null && widget.initialAnswers!.isNotEmpty) {
        _isModifying = false;
      }
    }
    // Load initial answers into local state
    if (_questions != null) {
      _loadCurrentIntoLocalState();
      _userHasEdited = false;
    }
  }

  void _initializeFromSurveyData(SnSurveyWithStats survey) {
    // Initialize answers from survey data if available
    if (survey.userAnswer != null && survey.userAnswer!.answer.isNotEmpty) {
      _answers = Map<String, dynamic>.from(survey.userAnswer!.answer);
      if (!widget.isReadonly && !_isModifying) {
        _isModifying = false; // Show modify button if user has answered
      }
    }
    _loadCurrentIntoLocalState();
  }

  @override
  void didUpdateWidget(covariant SurveySubmit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.surveyId != widget.surveyId) {
      _index = 0;
      _answers = Map<String, dynamic>.from(widget.initialAnswers ?? {});
      // Reset modification state when survey changes
      _isModifying = false;
    }
  }

  @override
  void dispose() {
    _textController.removeListener(_controllerListener);
    _textController.dispose();
    super.dispose();
  }

  SnSurveyQuestion get _current => _questions![_index];

  bool get _isFullPage =>
      widget.visualStyle == SurveySubmitVisualStyle.fullPage;

  bool _isExpired(SnSurveyWithStats survey) {
    final endedAt = survey.endedAt;
    if (endedAt == null) return false;
    return endedAt.toUtc().isBefore(DateTime.now().toUtc());
  }

  void _loadCurrentIntoLocalState() {
    final q = _current;
    final saved = _answers[q.id];

    if (!_userHasEdited) {
      _singleChoiceSelected = null;
      _multiChoiceSelected.clear();
      _yesNoSelected = null;
      _ratingSelected = null;

      switch (q.type) {
        case SnSurveyQuestionType.singleChoice:
          if (saved is String) _singleChoiceSelected = saved;
          break;
        case SnSurveyQuestionType.multipleChoice:
          if (saved is List) {
            _multiChoiceSelected.addAll(saved.whereType<String>());
          }
          break;
        case SnSurveyQuestionType.yesNo:
          if (saved is bool) _yesNoSelected = saved;
          break;
        case SnSurveyQuestionType.rating:
          if (saved is int) _ratingSelected = saved;
          break;
        case SnSurveyQuestionType.freeText:
          _textController.removeListener(_controllerListener);
          _textController.text = saved is String ? saved : '';
          _textController.addListener(_controllerListener);
          break;
      }
    }
  }

  bool _isCurrentAnswered() {
    final q = _current;
    if (!q.isRequired) return true;

    switch (q.type) {
      case SnSurveyQuestionType.singleChoice:
        return _singleChoiceSelected != null;
      case SnSurveyQuestionType.multipleChoice:
        return _multiChoiceSelected.isNotEmpty;
      case SnSurveyQuestionType.yesNo:
        return _yesNoSelected != null;
      case SnSurveyQuestionType.rating:
        return (_ratingSelected ?? 0) > 0;
      case SnSurveyQuestionType.freeText:
        return _textController.text.trim().isNotEmpty;
    }
  }

  void _persistCurrentAnswer() {
    final q = _current;
    switch (q.type) {
      case SnSurveyQuestionType.singleChoice:
        if (_singleChoiceSelected == null) {
          _answers.remove(q.id);
        } else {
          _answers[q.id] = _singleChoiceSelected!;
        }
        break;
      case SnSurveyQuestionType.multipleChoice:
        if (_multiChoiceSelected.isEmpty) {
          _answers.remove(q.id);
        } else {
          _answers[q.id] = _multiChoiceSelected.toList(growable: false);
        }
        break;
      case SnSurveyQuestionType.yesNo:
        if (_yesNoSelected == null) {
          _answers.remove(q.id);
        } else {
          _answers[q.id] = _yesNoSelected!;
        }
        break;
      case SnSurveyQuestionType.rating:
        if (_ratingSelected == null) {
          _answers.remove(q.id);
        } else {
          _answers[q.id] = _ratingSelected!;
        }
        break;
      case SnSurveyQuestionType.freeText:
        final text = _textController.text.trim();
        if (text.isEmpty) {
          _answers.remove(q.id);
        } else {
          _answers[q.id] = text;
        }
        break;
    }
  }

  Future<void> _submitToServer(SnSurveyWithStats survey) async {
    // Persist current question before final submit
    _persistCurrentAnswer();

    setState(() {
      _submitting = true;
    });

    try {
      final dio = ref.read(solarNetworkClientProvider).dio;

      await dio.post(
        '/sphere/surveys/${survey.id}/answer',
        data: {'answer': _answers},
      );

      // Refresh survey data to show submitted answer
      ref.invalidate(surveyWithStatsProvider(widget.surveyId));

      // Only call onSubmit after server accepts
      widget.onSubmit(Map<String, dynamic>.unmodifiable(_answers));

      showSnackBar('surveyAnswerSubmitted'.tr());
      HapticFeedback.heavyImpact();
    } catch (e) {
      showErrorAlert(e);
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  void _next(SnSurveyWithStats survey) {
    if (_submitting) return;
    if (!_isCurrentAnswered()) {
      showSnackBar('${'required'.tr()}: ${_current.title}');
      return;
    }
    _persistCurrentAnswer();
    if (_index < _questions!.length - 1) {
      setState(() {
        _index++;
        _userHasEdited = false;
        _loadCurrentIntoLocalState();
      });
    } else {
      // Final submit to API
      _submitToServer(survey);
    }
  }

  void _back() {
    if (_submitting) return;
    _persistCurrentAnswer();
    if (_index > 0) {
      setState(() {
        _index--;
        _userHasEdited = false;
        _loadCurrentIntoLocalState();
      });
    } else {
      // at the first question; allow cancel if provided
      widget.onCancel?.call();
    }
  }

  Widget _buildHeader(BuildContext context, SnSurveyWithStats survey) {
    final q = _current;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showProgress && _isModifying)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '${_index + 1} / ${_questions!.length}',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        if (widget.showProgress && _isModifying)
          SizedBox(height: _isFullPage ? 16 : 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                q.title,
                style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
              ),
            ),
            if (q.isRequired)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  '*',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
          ],
        ),
        if (q.description != null)
          Padding(
            padding: EdgeInsets.only(top: _isFullPage ? 10 : 4),
            child: Text(
              q.description!,
              style:
                  (_isFullPage
                          ? theme.textTheme.titleSmall
                          : theme.textTheme.bodySmall)
                      ?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.45,
                      ),
            ),
          ),
      ],
    );
  }

  Widget _buildStats(
    BuildContext context,
    SnSurveyQuestion q,
    Map<String, dynamic>? stats,
  ) {
    return SurveyStatsWidget(question: q, stats: stats);
  }

  Widget _buildBody(BuildContext context, SnSurveyWithStats survey) {
    final hasUserAnswer =
        survey.userAnswer != null && survey.userAnswer!.answer.isNotEmpty;
    if (hasUserAnswer && !widget.isReadonly && !_isModifying) {
      return const SizedBox.shrink(); // Collapse input fields if already submitted and not modifying
    }
    final q = _current;
    switch (q.type) {
      case SnSurveyQuestionType.singleChoice:
        return _buildSingleChoice(context, q);
      case SnSurveyQuestionType.multipleChoice:
        return _buildMultipleChoice(context, q);
      case SnSurveyQuestionType.yesNo:
        return _buildYesNo(context, q);
      case SnSurveyQuestionType.rating:
        return _buildRating(context, q);
      case SnSurveyQuestionType.freeText:
        return _buildFreeText(context, q);
    }
  }

  Widget _buildSingleChoice(BuildContext context, SnSurveyQuestion q) {
    final options = [...?q.options]..sort((a, b) => a.order.compareTo(b.order));
    if (!_isFullPage) {
      return Column(
        children: [
          for (final opt in options)
            RadioListTile<String>(
              value: opt.id,
              groupValue: _singleChoiceSelected,
              onChanged: (val) => setState(() {
                _singleChoiceSelected = val;
                _userHasEdited = true;
              }),
              title: Text(opt.label),
              subtitle: opt.description != null ? Text(opt.description!) : null,
            ),
        ],
      );
    }

    return Column(
      children: [
        for (final opt in options)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _AnswerCard(
              selected: _singleChoiceSelected == opt.id,
              onTap: () => setState(() {
                _singleChoiceSelected = opt.id;
                _userHasEdited = true;
              }),
              leading: Icon(
                _singleChoiceSelected == opt.id
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
              ),
              title: opt.label,
              subtitle: opt.description,
            ),
          ),
      ],
    );
  }

  Widget _buildMultipleChoice(BuildContext context, SnSurveyQuestion q) {
    final options = [...?q.options]..sort((a, b) => a.order.compareTo(b.order));
    if (!_isFullPage) {
      return Column(
        children: [
          for (final opt in options)
            CheckboxListTile(
              value: _multiChoiceSelected.contains(opt.id),
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    _multiChoiceSelected.add(opt.id);
                  } else {
                    _multiChoiceSelected.remove(opt.id);
                  }
                  _userHasEdited = true;
                });
              },
              title: Text(opt.label),
              subtitle: opt.description != null ? Text(opt.description!) : null,
            ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (q.maxSelections != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Choose up to ${q.maxSelections} option${q.maxSelections == 1 ? '' : 's'}.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        for (final opt in options)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _AnswerCard(
              selected: _multiChoiceSelected.contains(opt.id),
              onTap: () {
                setState(() {
                  final selected = _multiChoiceSelected.contains(opt.id);
                  if (selected) {
                    _multiChoiceSelected.remove(opt.id);
                  } else {
                    final maxSelections = q.maxSelections;
                    if (maxSelections == null ||
                        _multiChoiceSelected.length < maxSelections) {
                      _multiChoiceSelected.add(opt.id);
                    }
                  }
                  _userHasEdited = true;
                });
              },
              leading: Icon(
                _multiChoiceSelected.contains(opt.id)
                    ? Icons.check_box
                    : Icons.check_box_outline_blank,
              ),
              title: opt.label,
              subtitle: opt.description,
            ),
          ),
      ],
    );
  }

  Widget _buildYesNo(BuildContext context, SnSurveyQuestion q) {
    if (!_isFullPage) {
      return Row(
        children: [
          Expanded(
            child: SegmentedButton<bool>(
              segments: [
                ButtonSegment(value: true, label: Text('yes'.tr())),
                ButtonSegment(value: false, label: Text('no'.tr())),
              ],
              selected: _yesNoSelected == null ? {} : {_yesNoSelected!},
              onSelectionChanged: (sel) {
                setState(() {
                  _yesNoSelected = sel.isEmpty ? null : sel.first;
                  _userHasEdited = true;
                });
              },
              multiSelectionEnabled: false,
              emptySelectionAllowed: true,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: _AnswerCard(
            selected: _yesNoSelected == true,
            onTap: () => setState(() {
              _yesNoSelected = true;
              _userHasEdited = true;
            }),
            leading: const Icon(Icons.thumb_up_alt_outlined),
            title: 'yes'.tr(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _AnswerCard(
            selected: _yesNoSelected == false,
            onTap: () => setState(() {
              _yesNoSelected = false;
              _userHasEdited = true;
            }),
            leading: const Icon(Icons.thumb_down_alt_outlined),
            title: 'no'.tr(),
          ),
        ),
      ],
    );
  }

  Widget _buildRating(BuildContext context, SnSurveyQuestion q) {
    final min = (q.minValue ?? 1).round();
    final max = (q.maxValue ?? 5).round();
    final buttons = [
      for (var value = min; value <= max; value++)
        IconButton(
          tooltip: '$value',
          style: IconButton.styleFrom(
            shape: const CircleBorder(),
            backgroundColor: Colors.transparent,
          ),
          icon: Icon(
            (_ratingSelected ?? 0) >= value ? Icons.star : Icons.star_border,
            color: (_ratingSelected ?? 0) >= value ? Colors.amber : null,
          ),
          onPressed: () {
            setState(() {
              _ratingSelected = value;
              _userHasEdited = true;
            });
          },
        ),
    ];

    if (!_isFullPage) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: buttons,
      );
    }

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: buttons,
    );
  }

  Widget _buildFreeText(BuildContext context, SnSurveyQuestion q) {
    return TextField(
      controller: _textController,
      maxLines: _isFullPage ? 10 : 6,
      maxLength: q.maxLength,
      style: _isFullPage ? Theme.of(context).textTheme.titleMedium : null,
    );
  }

  Widget _buildNavBar(BuildContext context, SnSurveyWithStats survey) {
    final isLast = _index == _questions!.length - 1;
    final canProceed = _isCurrentAnswered() && !_submitting;
    final hasUserAnswer =
        survey.userAnswer != null && survey.userAnswer!.answer.isNotEmpty;

    if (hasUserAnswer && !_isModifying && !widget.isReadonly) {
      // If survey is submitted and not in modification mode, show "Modify" button
      return FilledButton.icon(
        icon: const Icon(Icons.edit),
        label: Text('modifyAnswers'.tr()),
        onPressed: () {
          setState(() {
            _isModifying = true;
            _index = 0; // Reset to first question for modification
            _userHasEdited = false;
            _loadCurrentIntoLocalState();
          });
        },
      );
    }

    return Row(
      children: [
        OutlinedButton.icon(
          icon: const Icon(Icons.arrow_back),
          label: Text(_index == 0 ? 'cancel'.tr() : 'back'.tr()),
          onPressed: _submitting
              ? null
              : () {
                  if (_index == 0 && _isModifying) {
                    // If at first question and in modification mode, go back to submitted view
                    setState(() {
                      _isModifying = false;
                    });
                  } else {
                    _back();
                  }
                },
        ),
        const Spacer(),
        FilledButton.icon(
          style: _isFullPage
              ? FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                )
              : null,
          icon: _submitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(isLast ? Icons.check : Icons.arrow_forward),
          label: Text(isLast ? 'submit'.tr() : 'next'.tr()),
          onPressed: canProceed ? () => _next(survey) : null,
        ),
      ],
    );
  }

  Widget _buildStatsStepper(
    BuildContext context,
    SnSurveyWithStats survey, {
    required bool canModify,
  }) {
    final isLast = _index == _questions!.length - 1;
    final expired = _isExpired(survey);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(context, survey),
        const SizedBox(height: 12),
        _AnimatedStep(
          key: ValueKey('stats_${_current.id}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [_buildStats(context, _current, survey.stats)],
          ),
        ),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (canModify && !expired)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: Text('modifyAnswers'.tr()),
                  onPressed: () {
                    setState(() {
                      _isModifying = true;
                      _index = 0;
                      _userHasEdited = false;
                      _loadCurrentIntoLocalState();
                    });
                  },
                ),
              ),
            Row(
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.arrow_back),
                  label: Text(_index == 0 ? 'close'.tr() : 'back'.tr()),
                  onPressed: () {
                    if (_index == 0) {
                      widget.onCancel?.call();
                      return;
                    }
                    setState(() {
                      _index--;
                      _userHasEdited = false;
                      _loadCurrentIntoLocalState();
                    });
                  },
                ),
                const Spacer(),
                FilledButton.icon(
                  icon: Icon(isLast ? Icons.check : Icons.arrow_forward),
                  label: Text(isLast ? 'done'.tr() : 'next'.tr()),
                  onPressed: () {
                    if (isLast) {
                      if (canModify && !expired) {
                        setState(() {
                          _isModifying = false;
                        });
                      }
                      return;
                    }
                    setState(() {
                      _index++;
                      _userHasEdited = false;
                      _loadCurrentIntoLocalState();
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReadonlyView(BuildContext context, SnSurveyWithStats survey) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (survey.title != null || survey.description != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (survey.title != null)
                  Text(
                    survey.title!,
                    style: _isFullPage
                        ? Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          )
                        : Theme.of(context).textTheme.titleLarge,
                  ),
                if (survey.description != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      survey.description!,
                      style:
                          (_isFullPage
                                  ? Theme.of(context).textTheme.titleMedium
                                  : Theme.of(context).textTheme.bodyMedium)
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                    ),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 4),
        _buildStatsStepper(context, survey, canModify: false),
      ],
    );
  }

  Widget _buildCollapsedView(BuildContext context, SnSurveyWithStats survey) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (survey.title != null && !_isFullPage)
                    Text(
                      survey.title!,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (survey.description != null && !_isFullPage)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        survey.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).textTheme.bodySmall?.color?.withOpacity(0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  else if (!_isFullPage)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        '${_questions!.length} question${_questions!.length == 1 ? '' : 's'}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).textTheme.bodySmall?.color?.withOpacity(0.7),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (!widget.disableCollapse)
              IconButton(
                icon: Icon(
                  _isCollapsed ? Icons.expand_more : Icons.expand_less,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _isCollapsed = !_isCollapsed;
                  });
                },
                visualDensity: VisualDensity.compact,
                tooltip: _isCollapsed
                    ? 'expandSurvey'.tr()
                    : 'collapseSurvey'.tr(),
              ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final surveyAsync = ref.watch(surveyWithStatsProvider(widget.surveyId));

    return surveyAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Failed to load survey: $error'),
        ),
      ),
      data: (survey) {
        final expired = _isExpired(survey);
        // Initialize questions when data is available
        _questions = [...survey.questions]
          ..sort((a, b) => a.order.compareTo(b.order));

        // Initialize answers from survey data
        _initializeFromSurveyData(survey);

        if (_questions!.isEmpty) {
          return const SizedBox.shrink();
        }

        // If collapsed, show collapsed view for all states
        if (_isCollapsed) {
          return _buildCollapsedView(context, survey);
        }

        // If survey is already submitted and not in readonly mode, and not in modification mode, show submitted view
        final hasUserAnswer =
            survey.userAnswer != null && survey.userAnswer!.answer.isNotEmpty;
        if (hasUserAnswer && !widget.isReadonly && !_isModifying) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCollapsedView(context, survey),
              const SizedBox(height: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) {
                  final offset =
                      Tween<Offset>(
                        begin: const Offset(0, -0.1),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(parent: anim, curve: Curves.easeOut),
                      );
                  final fade = CurvedAnimation(
                    parent: anim,
                    curve: Curves.easeOut,
                  );
                  return FadeTransition(
                    opacity: fade,
                    child: SlideTransition(position: offset, child: child),
                  );
                },
                child: Column(
                  key: const ValueKey('submitted_expanded'),
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildStatsStepper(context, survey, canModify: true),
                  ],
                ),
              ),
            ],
          );
        }

        // If survey is in readonly mode or expired, show readonly view
        if (widget.isReadonly || expired) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCollapsedView(context, survey),
              const SizedBox(height: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) {
                  final offset =
                      Tween<Offset>(
                        begin: const Offset(0, -0.1),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(parent: anim, curve: Curves.easeOut),
                      );
                  final fade = CurvedAnimation(
                    parent: anim,
                    curve: Curves.easeOut,
                  );
                  return FadeTransition(
                    opacity: fade,
                    child: SlideTransition(position: offset, child: child),
                  );
                },
                child: _buildReadonlyView(context, survey),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCollapsedView(context, survey),
            const SizedBox(height: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) {
                final offset = Tween<Offset>(
                  begin: const Offset(0, -0.1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut));
                final fade = CurvedAnimation(
                  parent: anim,
                  curve: Curves.easeOut,
                );
                return FadeTransition(
                  opacity: fade,
                  child: SlideTransition(position: offset, child: child),
                );
              },
              child: Column(
                key: const ValueKey('normal_expanded'),
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context, survey),
                  const SizedBox(height: 12),
                  _AnimatedStep(
                    key: ValueKey(_current.id),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [_buildBody(context, survey)],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildNavBar(context, survey),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AnswerCard extends StatelessWidget {
  const _AnswerCard({
    required this.selected,
    required this.onTap,
    required this.leading,
    required this.title,
    this.subtitle,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget leading;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Material(
      color: selected
          ? colorScheme.primaryContainer
          : colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: selected
                  ? colorScheme.primary
                  : colorScheme.outlineVariant,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: IconTheme(
                  data: IconThemeData(
                    color: selected
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                  child: leading,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: selected
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurface,
                      ),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: selected
                              ? colorScheme.onPrimaryContainer.withOpacity(0.82)
                              : colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Simple fade/slide transition between questions.
class _AnimatedStep extends StatelessWidget {
  const _AnimatedStep({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, anim) {
        final offset = Tween<Offset>(
          begin: const Offset(0.1, 0),
          end: Offset.zero,
        ).animate(anim);
        final fade = CurvedAnimation(parent: anim, curve: Curves.easeInOut);
        return FadeTransition(
          opacity: fade,
          child: SlideTransition(position: offset, child: child),
        );
      },
      child: child,
    );
  }
}
