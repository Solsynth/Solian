import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/models/poll.dart';
import 'package:island/pods/network.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/poll/poll_stats_widget.dart';

class PollSubmit extends ConsumerStatefulWidget {
  const PollSubmit({
    super.key,
    required this.poll,
    required this.onSubmit,
    required this.stats,
    this.initialAnswers,
    this.onCancel,
    this.showProgress = true,
    this.isReadonly = false,
    this.isInitiallyExpanded = false,
  });

  final SnPollWithStats poll;

  /// Callback when user submits all answers. Map questionId -> answer.
  final void Function(Map<String, dynamic> answers) onSubmit;

  /// Optional initial answers, keyed by questionId.
  final Map<String, dynamic>? initialAnswers;
  final Map<String, dynamic>? stats;

  /// Optional cancel callback.
  final VoidCallback? onCancel;

  /// Whether to show a progress indicator (e.g., "2 / N").
  final bool showProgress;

  final bool isReadonly;

  /// Whether the poll should start expanded instead of collapsed.
  final bool isInitiallyExpanded;

  @override
  ConsumerState<PollSubmit> createState() => _PollSubmitState();
}

class _PollSubmitState extends ConsumerState<PollSubmit> {
  late final List<SnPollQuestion> _questions;
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

  @override
  void initState() {
    super.initState();
    // Ensure questions are ordered by `order`
    _questions = [...widget.poll.questions]
      ..sort((a, b) => a.order.compareTo(b.order));
    _answers = Map<String, dynamic>.from(widget.initialAnswers ?? {});
    // Set initial collapse state based on the parameter
    _isCollapsed = !widget.isInitiallyExpanded;
    if (!widget.isReadonly) {
      _loadCurrentIntoLocalState();
      // If initial answers are provided, set _isModifying to false initially
      // so the "Modify" button is shown.
      if (widget.initialAnswers != null && widget.initialAnswers!.isNotEmpty) {
        _isModifying = false;
      }
    }
  }

  @override
  void didUpdateWidget(covariant PollSubmit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.poll.id != widget.poll.id) {
      _index = 0;
      _answers = Map<String, dynamic>.from(widget.initialAnswers ?? {});
      _questions
        ..clear()
        ..addAll(
          [...widget.poll.questions]
            ..sort((a, b) => a.order.compareTo(b.order)),
        );
      if (!widget.isReadonly) {
        _loadCurrentIntoLocalState();
        // If poll ID changes, reset modification state
        _isModifying = false;
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  SnPollQuestion get _current => _questions[_index];

  void _loadCurrentIntoLocalState() {
    final q = _current;
    final saved = _answers[q.id];

    _singleChoiceSelected = null;
    _multiChoiceSelected.clear();
    _yesNoSelected = null;
    _ratingSelected = null;
    _textController.text = '';

    switch (q.type) {
      case SnPollQuestionType.singleChoice:
        if (saved is String) _singleChoiceSelected = saved;
        break;
      case SnPollQuestionType.multipleChoice:
        if (saved is List) {
          _multiChoiceSelected.addAll(saved.whereType<String>());
        }
        break;
      case SnPollQuestionType.yesNo:
        if (saved is bool) _yesNoSelected = saved;
        break;
      case SnPollQuestionType.rating:
        if (saved is int) _ratingSelected = saved;
        break;
      case SnPollQuestionType.freeText:
        if (saved is String) _textController.text = saved;
        break;
    }
  }

  bool _isCurrentAnswered() {
    final q = _current;
    if (!q.isRequired) return true;

    switch (q.type) {
      case SnPollQuestionType.singleChoice:
        return _singleChoiceSelected != null;
      case SnPollQuestionType.multipleChoice:
        return _multiChoiceSelected.isNotEmpty;
      case SnPollQuestionType.yesNo:
        return _yesNoSelected != null;
      case SnPollQuestionType.rating:
        return (_ratingSelected ?? 0) > 0;
      case SnPollQuestionType.freeText:
        return _textController.text.trim().isNotEmpty;
    }
  }

  void _persistCurrentAnswer() {
    final q = _current;
    switch (q.type) {
      case SnPollQuestionType.singleChoice:
        if (_singleChoiceSelected == null) {
          _answers.remove(q.id);
        } else {
          _answers[q.id] = _singleChoiceSelected!;
        }
        break;
      case SnPollQuestionType.multipleChoice:
        if (_multiChoiceSelected.isEmpty) {
          _answers.remove(q.id);
        } else {
          _answers[q.id] = _multiChoiceSelected.toList(growable: false);
        }
        break;
      case SnPollQuestionType.yesNo:
        if (_yesNoSelected == null) {
          _answers.remove(q.id);
        } else {
          _answers[q.id] = _yesNoSelected!;
        }
        break;
      case SnPollQuestionType.rating:
        if (_ratingSelected == null) {
          _answers.remove(q.id);
        } else {
          _answers[q.id] = _ratingSelected!;
        }
        break;
      case SnPollQuestionType.freeText:
        final text = _textController.text.trim();
        if (text.isEmpty) {
          _answers.remove(q.id);
        } else {
          _answers[q.id] = text;
        }
        break;
    }
  }

  Future<void> _submitToServer() async {
    // Persist current question before final submit
    _persistCurrentAnswer();

    setState(() {
      _submitting = true;
    });

    try {
      final dio = ref.read(apiClientProvider);

      await dio.post(
        '/sphere/polls/${widget.poll.id}/answer',
        data: {'answer': _answers},
      );

      // Only call onSubmit after server accepts
      widget.onSubmit(Map<String, dynamic>.unmodifiable(_answers));

      showSnackBar('pollAnswerSubmitted'.tr());
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

  void _next() {
    if (_submitting) return;
    _persistCurrentAnswer();
    if (_index < _questions.length - 1) {
      setState(() {
        _index++;
        _loadCurrentIntoLocalState();
      });
    } else {
      // Final submit to API
      _submitToServer();
    }
  }

  void _back() {
    if (_submitting) return;
    _persistCurrentAnswer();
    if (_index > 0) {
      setState(() {
        _index--;
        _loadCurrentIntoLocalState();
      });
    } else {
      // at the first question; allow cancel if provided
      widget.onCancel?.call();
    }
  }

  Widget _buildHeader(BuildContext context) {
    final q = _current;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.poll.title != null || widget.poll.description != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.poll.title != null)
                  Text(
                    widget.poll.title!,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                if (widget.poll.description != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      widget.poll.description!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        if (widget.showProgress &&
            _isModifying) // Only show progress when modifying
          Text(
            '${_index + 1} / ${_questions.length}',
            style: Theme.of(context).textTheme.labelMedium,
          ),
        Row(
          children: [
            Expanded(
              child: Text(
                q.title,
                style: Theme.of(context).textTheme.titleMedium,
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
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              q.description!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStats(BuildContext context, SnPollQuestion q) {
    return PollStatsWidget(question: q, stats: widget.stats);
  }

  Widget _buildBody(BuildContext context) {
    if (widget.initialAnswers != null && !widget.isReadonly && !_isModifying) {
      return const SizedBox.shrink(); // Collapse input fields if already submitted and not modifying
    }
    final q = _current;
    switch (q.type) {
      case SnPollQuestionType.singleChoice:
        return _buildSingleChoice(context, q);
      case SnPollQuestionType.multipleChoice:
        return _buildMultipleChoice(context, q);
      case SnPollQuestionType.yesNo:
        return _buildYesNo(context, q);
      case SnPollQuestionType.rating:
        return _buildRating(context, q);
      case SnPollQuestionType.freeText:
        return _buildFreeText(context, q);
    }
  }

  Widget _buildSingleChoice(BuildContext context, SnPollQuestion q) {
    final options = [...?q.options]..sort((a, b) => a.order.compareTo(b.order));
    return Column(
      children: [
        for (final opt in options)
          RadioListTile<String>(
            value: opt.id,
            groupValue: _singleChoiceSelected,
            onChanged: (val) => setState(() => _singleChoiceSelected = val),
            title: Text(opt.label),
            subtitle: opt.description != null ? Text(opt.description!) : null,
          ),
      ],
    );
  }

  Widget _buildMultipleChoice(BuildContext context, SnPollQuestion q) {
    final options = [...?q.options]..sort((a, b) => a.order.compareTo(b.order));
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
              });
            },
            title: Text(opt.label),
            subtitle: opt.description != null ? Text(opt.description!) : null,
          ),
      ],
    );
  }

  Widget _buildYesNo(BuildContext context, SnPollQuestion q) {
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
              });
            },
            multiSelectionEnabled: false,
            emptySelectionAllowed: true,
          ),
        ),
      ],
    );
  }

  Widget _buildRating(BuildContext context, SnPollQuestion q) {
    const max = 5;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(max, (i) {
        final value = i + 1;
        final selected = (_ratingSelected ?? 0) >= value;
        return IconButton(
          icon: Icon(
            selected ? Icons.star : Icons.star_border,
            color: selected ? Colors.amber : null,
          ),
          onPressed: () {
            setState(() {
              _ratingSelected = value;
            });
          },
        );
      }),
    );
  }

  Widget _buildFreeText(BuildContext context, SnPollQuestion q) {
    return TextField(
      controller: _textController,
      maxLines: 6,
      decoration: const InputDecoration(border: OutlineInputBorder()),
    );
  }

  Widget _buildNavBar(BuildContext context) {
    final isLast = _index == _questions.length - 1;
    final canProceed = _isCurrentAnswered() && !_submitting;

    if (widget.initialAnswers != null && !_isModifying && !widget.isReadonly) {
      // If poll is submitted and not in modification mode, show "Modify" button
      return FilledButton.icon(
        icon: const Icon(Icons.edit),
        label: Text('modifyAnswers'.tr()),
        onPressed: () {
          setState(() {
            _isModifying = true;
            _index = 0; // Reset to first question for modification
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
          onPressed:
              _submitting
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
          icon:
              _submitting
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : Icon(isLast ? Icons.check : Icons.arrow_forward),
          label: Text(isLast ? 'submit'.tr() : 'next'.tr()),
          onPressed: canProceed ? _next : null,
        ),
      ],
    );
  }

  Widget _buildSubmittedView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.poll.title != null || widget.poll.description != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.poll.title?.isNotEmpty ?? false)
                  Text(
                    widget.poll.title!,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                if (widget.poll.description?.isNotEmpty ?? false)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      widget.poll.description!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        for (final q in _questions)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        q.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    if (q.isRequired)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          '*',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                  ],
                ),
                if (q.description != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      q.description!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                  ),
                _buildStats(context, q),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildReadonlyView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.poll.title != null || widget.poll.description != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.poll.title != null)
                  Text(
                    widget.poll.title!,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                if (widget.poll.description != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      widget.poll.description!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        for (final q in _questions)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        q.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    if (q.isRequired)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          '*',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                  ],
                ),
                if (q.description != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      q.description!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                  ),
                _buildStats(context, q),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCollapsedView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.poll.title != null)
                    Text(
                      widget.poll.title!,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (widget.poll.description != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        widget.poll.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).textTheme.bodySmall?.color?.withOpacity(0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        '${_questions.length} question${_questions.length == 1 ? '' : 's'}',
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
              tooltip: _isCollapsed ? 'expandPoll'.tr() : 'collapsePoll'.tr(),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return const SizedBox.shrink();
    }

    // If collapsed, show collapsed view for all states
    if (_isCollapsed) {
      return _buildCollapsedView(context);
    }

    // If poll is already submitted and not in readonly mode, and not in modification mode, show submitted view
    if (widget.initialAnswers != null && !widget.isReadonly && !_isModifying) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCollapsedView(context),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) {
              final offset = Tween<Offset>(
                begin: const Offset(0, -0.1),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut));
              final fade = CurvedAnimation(parent: anim, curve: Curves.easeOut);
              return FadeTransition(
                opacity: fade,
                child: SlideTransition(position: offset, child: child),
              );
            },
            child: Column(
              key: const ValueKey('submitted_expanded'),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [_buildSubmittedView(context), _buildNavBar(context)],
            ),
          ),
        ],
      );
    }

    // If poll is in readonly mode, show readonly view
    if (widget.isReadonly) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCollapsedView(context),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) {
              final offset = Tween<Offset>(
                begin: const Offset(0, -0.1),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut));
              final fade = CurvedAnimation(parent: anim, curve: Curves.easeOut);
              return FadeTransition(
                opacity: fade,
                child: SlideTransition(position: offset, child: child),
              );
            },
            child: _buildReadonlyView(context),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildCollapsedView(context),
        const SizedBox(height: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, anim) {
            final offset = Tween<Offset>(
              begin: const Offset(0, -0.1),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut));
            final fade = CurvedAnimation(parent: anim, curve: Curves.easeOut);
            return FadeTransition(
              opacity: fade,
              child: SlideTransition(position: offset, child: child),
            );
          },
          child: Column(
            key: const ValueKey('normal_expanded'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              const SizedBox(height: 12),
              _AnimatedStep(
                key: ValueKey(_current.id),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildBody(context),
                    _buildStats(context, _current),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildNavBar(context),
            ],
          ),
        ),
      ],
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
