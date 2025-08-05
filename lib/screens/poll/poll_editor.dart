import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:gap/gap.dart';
import 'package:island/pods/network.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/post/publishers_modal.dart';
import 'package:island/models/poll.dart';
import 'package:uuid/uuid.dart';

class PollEditorState {
  String? id; // for editing
  String? title;
  String? description;
  DateTime? endedAt;
  List<SnPollQuestion> questions;

  PollEditorState({
    this.id,
    this.title,
    this.description,
    this.endedAt,
    List<SnPollQuestion>? questions,
  }) : questions = questions ?? const [];
}

/// Riverpod Notifier state
class PollEditor extends Notifier<PollEditorState> {
  @override
  PollEditorState build() {
    return PollEditorState();
  }

  void setTitle(String? value) {
    state = PollEditorState(
      id: state.id,
      title: value,
      description: state.description,
      endedAt: state.endedAt,
      questions: [...state.questions],
    );
  }

  void setDescription(String? value) {
    state = PollEditorState(
      id: state.id,
      title: state.title,
      description: value,
      endedAt: state.endedAt,
      questions: [...state.questions],
    );
  }

  void setEndedAt(DateTime? value) {
    state = PollEditorState(
      id: state.id,
      title: state.title,
      description: state.description,
      endedAt: value,
      questions: [...state.questions],
    );
  }

  void setEditingId(String? id) {
    state = PollEditorState(
      id: id,
      title: state.title,
      description: state.description,
      endedAt: state.endedAt,
      questions: [...state.questions],
    );
  }

  void addQuestion(SnPollQuestionType type) {
    final nextOrder = state.questions.length;
    final isOptionsType = _isOptionsType(type);
    final q = SnPollQuestion(
      id: const Uuid().v4(),
      type: type,
      options:
          isOptionsType
              ? [
                SnPollOption(
                  id: const Uuid().v4(),
                  label: 'Option 1',
                  order: 0,
                ),
              ]
              : null,
      title: '',
      description: null,
      order: nextOrder,
      isRequired: false,
    );
    state = PollEditorState(
      id: state.id,
      title: state.title,
      description: state.description,
      endedAt: state.endedAt,
      questions: [...state.questions, q],
    );
  }

  void removeQuestion(int index) {
    if (index < 0 || index >= state.questions.length) return;
    final updated = [...state.questions]..removeAt(index);
    for (var i = 0; i < updated.length; i++) {
      updated[i] = updated[i].copyWith(order: i);
    }
    state = PollEditorState(
      id: state.id,
      title: state.title,
      description: state.description,
      endedAt: state.endedAt,
      questions: updated,
    );
  }

  void moveQuestionUp(int index) {
    if (index <= 0 || index >= state.questions.length) return;
    final updated = [...state.questions];
    final tmp = updated[index - 1];
    updated[index - 1] = updated[index];
    updated[index] = tmp;
    for (var i = 0; i < updated.length; i++) {
      updated[i] = updated[i].copyWith(order: i);
    }
    state = PollEditorState(
      id: state.id,
      title: state.title,
      description: state.description,
      endedAt: state.endedAt,
      questions: updated,
    );
  }

  void moveQuestionDown(int index) {
    if (index < 0 || index >= state.questions.length - 1) return;
    final updated = [...state.questions];
    final tmp = updated[index + 1];
    updated[index + 1] = updated[index];
    updated[index] = tmp;
    for (var i = 0; i < updated.length; i++) {
      updated[i] = updated[i].copyWith(order: i);
    }
    state = PollEditorState(
      id: state.id,
      title: state.title,
      description: state.description,
      endedAt: state.endedAt,
      questions: updated,
    );
  }

  void setQuestionType(int index, SnPollQuestionType type) {
    if (index < 0 || index >= state.questions.length) return;
    final q = state.questions[index];
    final isOptionsType = _isOptionsType(type);
    final newOptions =
        isOptionsType
            ? (q.options?.isNotEmpty == true
                ? q.options
                : [
                  SnPollOption(
                    id: const Uuid().v4(),
                    label: 'Option 1',
                    order: 0,
                  ),
                ])
            : null;
    _updateQuestion(index, q.copyWith(type: type, options: newOptions));
  }

  void setQuestionTitle(int index, String title) {
    if (index < 0 || index >= state.questions.length) return;
    final q = state.questions[index];
    _updateQuestion(index, q.copyWith(title: title));
  }

  void setQuestionDescription(int index, String? description) {
    if (index < 0 || index >= state.questions.length) return;
    final q = state.questions[index];
    _updateQuestion(index, q.copyWith(description: description));
  }

  void setQuestionRequired(int index, bool value) {
    if (index < 0 || index >= state.questions.length) return;
    final q = state.questions[index];
    _updateQuestion(index, q.copyWith(isRequired: value));
  }

  void addOption(int qIndex) {
    if (qIndex < 0 || qIndex >= state.questions.length) return;
    final q = state.questions[qIndex];
    if (!_isOptionsType(q.type)) return;
    final opts = <SnPollOption>[...(q.options ?? [])];
    final nextOrder = opts.length;
    opts.add(
      SnPollOption(
        id: const Uuid().v4(),
        label: 'Option ${nextOrder + 1}',
        order: nextOrder,
      ),
    );
    _updateQuestion(qIndex, q.copyWith(options: opts));
  }

  void removeOption(int qIndex, int optIndex) {
    if (qIndex < 0 || qIndex >= state.questions.length) return;
    final q = state.questions[qIndex];
    if (!_isOptionsType(q.type)) return;
    final opts = <SnPollOption>[...(q.options ?? [])];
    if (optIndex < 0 || optIndex >= opts.length) return;
    opts.removeAt(optIndex);
    for (var i = 0; i < opts.length; i++) {
      opts[i] = opts[i].copyWith(order: i);
    }
    _updateQuestion(qIndex, q.copyWith(options: opts));
  }

  List<SnPollOption> _moveOptionByDelta(
    List<SnPollOption> original,
    int idx,
    int delta,
  ) {
    if (idx + delta < 0 || idx + delta >= original.length) {
      return original;
    }
    final clone = List<SnPollOption>.from(original);
    clone.insert(idx + delta, clone.removeAt(idx));
    for (var i = 0; i < clone.length; i++) {
      clone[i] = clone[i].copyWith(order: i);
    }
    return clone;
  }

  void moveOptionUp(int qIndex, int optIndex) {
    if (qIndex < 0 || qIndex >= state.questions.length) return;
    final q = state.questions[qIndex];
    if (!_isOptionsType(q.type)) return;
    final original = q.options ?? const <SnPollOption>[];
    if (optIndex <= 0 || optIndex >= original.length) return;

    final reordered = _moveOptionByDelta(original, optIndex, -1);
    if (!identical(reordered, original)) {
      _updateQuestion(qIndex, q.copyWith(options: reordered));
    }
  }

  void moveOptionDown(int qIndex, int optIndex) {
    if (qIndex < 0 || qIndex >= state.questions.length) return;
    final q = state.questions[qIndex];
    if (!_isOptionsType(q.type)) return;
    final original = q.options ?? const <SnPollOption>[];
    if (optIndex < 0 || optIndex >= original.length - 1) return;

    final reordered = _moveOptionByDelta(original, optIndex, 1);
    if (!identical(reordered, original)) {
      _updateQuestion(qIndex, q.copyWith(options: reordered));
    }
  }

  void setOptionLabel(int qIndex, int optIndex, String label) {
    final q = state.questions[qIndex];
    if (!_isOptionsType(q.type)) return;
    final opts = <SnPollOption>[...(q.options ?? [])];
    if (optIndex < 0 || optIndex >= opts.length) return;
    opts[optIndex] = opts[optIndex].copyWith(label: label);
    _updateQuestion(qIndex, q.copyWith(options: opts));
  }

  void setOptionDescription(int qIndex, int optIndex, String? description) {
    final q = state.questions[qIndex];
    if (!_isOptionsType(q.type)) return;
    final opts = <SnPollOption>[...(q.options ?? [])];
    if (optIndex < 0 || optIndex >= opts.length) return;
    opts[optIndex] = opts[optIndex].copyWith(description: description);
    _updateQuestion(qIndex, q.copyWith(options: opts));
  }

  bool _isOptionsType(SnPollQuestionType type) {
    return type == SnPollQuestionType.singleChoice ||
        type == SnPollQuestionType.multipleChoice;
  }

  void _updateQuestion(int index, SnPollQuestion newQ) {
    final list = <SnPollQuestion>[...state.questions];
    list[index] = newQ;
    state = PollEditorState(
      id: state.id,
      title: state.title,
      description: state.description,
      endedAt: state.endedAt,
      questions: list,
    );
  }
}

/// The poll editor screen.
/// Note: This is UI only; wire API later. Requires riverpod_generator and build_runner to generate .g.dart.
final pollEditorProvider = NotifierProvider<PollEditor, PollEditorState>(
  PollEditor.new,
);

class PollEditorScreen extends ConsumerWidget {
  const PollEditorScreen({
    super.key,
    this.initialPollId,
    this.initialPublisher,
  });

  // Submit helpers declared before build to avoid forward reference issues

  static Future<void> _submitPoll(BuildContext context, WidgetRef ref) async {
    final model = ref.watch(pollEditorProvider);
    final dio = ref.read(apiClientProvider);

    // Pick publisher (required)
    final pickedPublisher = await showModalBottomSheet<dynamic>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (_) => const PublisherModal(),
    );

    if (pickedPublisher == null) {
      showSnackBar('Publisher is required');
      return;
    }

    final String publisherName =
        pickedPublisher.name ?? pickedPublisher['name'] ?? '';
    if (publisherName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid publisher selected')),
      );
      return;
    }

    // Build payload
    final body = {
      'title': model.title,
      'description': model.description,
      'endedAt': model.endedAt?.toUtc().toIso8601String(),
      'questions':
          model.questions
              .map(
                (q) => {
                  'type': q.type.index,
                  'options':
                      q.options
                          ?.map(
                            (o) => {
                              'label': o.label,
                              'description': o.description,
                              'order': o.order,
                            },
                          )
                          .toList(),
                  'title': q.title,
                  'description': q.description,
                  'order': q.order,
                  'isRequired': q.isRequired,
                },
              )
              .toList(),
    };

    try {
      final isUpdate = model.id != null && model.id!.isNotEmpty;
      final String path =
          isUpdate ? '/sphere/polls/${model.id}' : '/sphere/polls';
      final Response res =
          await (isUpdate
              ? dio.patch(
                path,
                queryParameters: {'pub': publisherName},
                data: body,
              )
              : dio.post(
                path,
                queryParameters: {'pub': publisherName},
                data: body,
              ));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isUpdate ? 'Poll updated.' : 'Poll created.')),
      );

      if (!context.mounted) return;
      Navigator.of(context).maybePop(res.data);
    } on DioException catch (e) {
      final msg =
          e.response?.data is Map && (e.response!.data['message'] != null)
              ? e.response!.data['message'].toString()
              : e.message ?? 'Network error';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed: $msg')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unexpected error: $e')));
    }
  }

  // If editing, provide existing poll id and preselected publisher name (optional)
  final String? initialPollId;
  final String? initialPublisher;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = ref.watch(pollEditorProvider);
    final notifier = ref.watch(pollEditorProvider.notifier);

    // initialize editing state if provided
    if (initialPollId != null && model.id != initialPollId) {
      notifier.setEditingId(initialPollId);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(model.id == null ? 'Create Poll' : 'Edit Poll'),
        actions: [
          if (kDebugMode)
            IconButton(
              tooltip: 'Preview JSON (debug)',
              onPressed: () {
                _showDebugPreview(context, model);
              },
              icon: const Icon(Icons.visibility_outlined),
            ),
          const Gap(8),
        ],
      ),
      body: SafeArea(
        child: Form(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                initialValue: model.title ?? '',
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                ),
                textInputAction: TextInputAction.next,
                maxLength: 256,
                onChanged: notifier.setTitle,
                onTapOutside:
                    (_) => FocusManager.instance.primaryFocus?.unfocus(),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),
              const Gap(12),
              TextFormField(
                initialValue: model.description ?? '',
                decoration: const InputDecoration(
                  labelText: 'Description',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                ),
                maxLines: 3,
                maxLength: 4096,
                onChanged: notifier.setDescription,
                onTapOutside:
                    (_) => FocusManager.instance.primaryFocus?.unfocus(),
              ),
              const Gap(12),
              _EndDatePicker(
                value: model.endedAt,
                onChanged: notifier.setEndedAt,
              ),
              const Gap(24),
              Row(
                children: [
                  Text(
                    'Questions',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  MenuAnchor(
                    builder: (context, controller, child) {
                      return FilledButton.icon(
                        onPressed: () {
                          controller.isOpen
                              ? controller.close()
                              : controller.open();
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add question'),
                      );
                    },
                    menuChildren:
                        SnPollQuestionType.values
                            .map(
                              (t) => MenuItemButton(
                                leadingIcon: Icon(_iconForType(t)),
                                onPressed: () => notifier.addQuestion(t),
                                child: Text(_labelForType(t)),
                              ),
                            )
                            .toList(),
                  ),
                ],
              ),
              const Gap(8),
              if (model.questions.isEmpty)
                _EmptyState(
                  title: 'No questions yet',
                  subtitle: 'Use "Add question" to start building your poll.',
                )
              else
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: model.questions.length,
                  onReorder: (oldIndex, newIndex) {
                    // Convert to stepwise moves using provided functions
                    if (newIndex > oldIndex) newIndex -= 1;
                    final steps = newIndex - oldIndex;
                    if (steps == 0) return;
                    if (steps > 0) {
                      for (int i = 0; i < steps; i++) {
                        notifier.moveQuestionDown(oldIndex + i);
                      }
                    } else {
                      for (int i = 0; i > steps; i--) {
                        notifier.moveQuestionUp(oldIndex + i);
                      }
                    }
                  },
                  buildDefaultDragHandles: false,
                  itemBuilder: (context, index) {
                    final q = model.questions[index];
                    return Card(
                      key: ValueKey('q_$index'),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          _QuestionHeader(
                            index: index,
                            question: q,
                            onMoveUp:
                                index > 0
                                    ? () => notifier.moveQuestionUp(index)
                                    : null,
                            onMoveDown:
                                index < model.questions.length - 1
                                    ? () => notifier.moveQuestionDown(index)
                                    : null,
                            onDelete: () => notifier.removeQuestion(index),
                          ),
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: _QuestionEditor(index: index, question: q),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              const Gap(96),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          16 + MediaQuery.of(context).padding.bottom,
        ),
        child: Row(
          children: [
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).maybePop();
              },
              icon: const Icon(Icons.close),
              label: const Text('Cancel'),
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: () {
                _submitPoll(context, ref);
              },
              icon: const Icon(Icons.cloud_upload_outlined),
              label: Text(model.id == null ? 'Create' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDebugPreview(BuildContext context, PollEditorState model) {
    final buf = StringBuffer();
    buf.writeln('{');
    buf.writeln('  "title": ${_jsonStr(model.title)},');
    buf.writeln('  "description": ${_jsonStr(model.description)},');
    buf.writeln('  "endedAt": ${_jsonStr(model.endedAt?.toIso8601String())},');
    buf.writeln('  "questions": [');
    for (var i = 0; i < model.questions.length; i++) {
      final q = model.questions[i];
      buf.writeln('    {');
      buf.writeln('      "type": "${q.type.name}",');
      buf.writeln('      "title": ${_jsonStr(q.title)},');
      buf.writeln('      "description": ${_jsonStr(q.description)},');
      buf.writeln('      "order": ${q.order},');
      buf.writeln('      "isRequired": ${q.isRequired},');
      if (q.options != null) {
        buf.writeln('      "options": [');
        for (var j = 0; j < q.options!.length; j++) {
          final o = q.options![j];
          buf.writeln(
            '        { "label": ${_jsonStr(o.label)}, "description": ${_jsonStr(o.description)}, "order": ${o.order} }${j == q.options!.length - 1 ? '' : ','}',
          );
        }
        buf.writeln('      ]');
      } else {
        buf.writeln('      "options": null');
      }
      buf.writeln('    }${i == model.questions.length - 1 ? '' : ','}');
    }
    buf.writeln('  ]');
    buf.writeln('}');
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Debug Preview'),
            content: SingleChildScrollView(
              child: SelectableText(buf.toString()),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }
}

String _jsonStr(String? v) =>
    v == null ? 'null' : '"${v.replaceAll('"', '\\"')}"';

IconData _iconForType(SnPollQuestionType t) {
  switch (t) {
    case SnPollQuestionType.singleChoice:
      return Icons.radio_button_checked;
    case SnPollQuestionType.multipleChoice:
      return Icons.check_box;
    case SnPollQuestionType.freeText:
      return Icons.short_text;
    case SnPollQuestionType.yesNo:
      return Icons.toggle_on;
    case SnPollQuestionType.rating:
      return Icons.star_rate;
  }
}

String _labelForType(SnPollQuestionType t) {
  switch (t) {
    case SnPollQuestionType.singleChoice:
      return 'Single choice';
    case SnPollQuestionType.multipleChoice:
      return 'Multiple choice';
    case SnPollQuestionType.freeText:
      return 'Free text';
    case SnPollQuestionType.yesNo:
      return 'Yes / No';
    case SnPollQuestionType.rating:
      return 'Rating';
  }
}

/// End date and time picker row
class _EndDatePicker extends StatelessWidget {
  const _EndDatePicker({required this.value, required this.onChanged});

  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'End date & time (optional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ),
            child: Wrap(
              spacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Icon(Icons.event, color: Theme.of(context).colorScheme.primary),
                Text(
                  value == null
                      ? 'Not set'
                      : MaterialLocalizations.of(
                        context,
                      ).formatFullDate(value!),
                ),
                if (value != null) ...[
                  const Text('—'),
                  Text(
                    MaterialLocalizations.of(context).formatTimeOfDay(
                      TimeOfDay.fromDateTime(value!),
                      alwaysUse24HourFormat: true,
                    ),
                  ),
                ],
                const Gap(8),
                TextButton(
                  onPressed: () async {
                    final now = DateTime.now();
                    final initial = value ?? now.add(const Duration(days: 1));
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: initial,
                      firstDate: now,
                      lastDate: now.add(const Duration(days: 3650)),
                    );
                    if (pickedDate == null) return;
                    if (!context.mounted) return;
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(initial),
                      builder: (ctx, child) {
                        return MediaQuery(
                          data: MediaQuery.of(
                            ctx,
                          ).copyWith(alwaysUse24HourFormat: true),
                          child: child!,
                        );
                      },
                    );
                    final dt = DateTime(
                      pickedDate.year,
                      pickedDate.month,
                      pickedDate.day,
                      pickedTime?.hour ?? 0,
                      pickedTime?.minute ?? 0,
                    );
                    onChanged(dt);
                  },
                  child: const Text('Pick'),
                ),
                if (value != null)
                  TextButton(
                    onPressed: () => onChanged(null),
                    child: const Text('Clear'),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Question card header with actions
class _QuestionHeader extends StatelessWidget {
  const _QuestionHeader({
    required this.index,
    required this.question,
    this.onMoveUp,
    this.onMoveDown,
    this.onDelete,
  });

  final int index;
  final SnPollQuestion question;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ReorderableDragStartListener(
        index: index,
        child: const Icon(Icons.drag_handle),
      ),
      title: Text(
        question.title.isEmpty ? 'Untitled question' : question.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(_labelForType(question.type)),
      trailing: Wrap(
        spacing: 4,
        children: [
          IconButton(
            tooltip: 'Move up',
            onPressed: onMoveUp,
            icon: const Icon(Icons.arrow_upward),
          ),
          IconButton(
            tooltip: 'Move down',
            onPressed: onMoveDown,
            icon: const Icon(Icons.arrow_downward),
          ),
          IconButton(
            tooltip: 'Delete',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
            color: Theme.of(context).colorScheme.error,
          ),
        ],
      ),
    );
  }
}

/// Question details editor
class _QuestionEditor extends ConsumerWidget {
  const _QuestionEditor({required this.index, required this.question});

  final int index;
  final SnPollQuestion question;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(pollEditorProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _QuestionTypePicker(
              value: question.type,
              onChanged: (t) => notifier.setQuestionType(index, t),
            ),
            FilterChip(
              label: const Text('Required'),
              selected: question.isRequired,
              onSelected: (v) => notifier.setQuestionRequired(index, v),
              avatar: Icon(
                question.isRequired
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
              ),
            ),
          ],
        ),
        const Gap(12),
        TextFormField(
          initialValue: question.title,
          decoration: const InputDecoration(
            labelText: 'Question title',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
          textInputAction: TextInputAction.next,
          maxLength: 1024,
          onChanged: (v) => notifier.setQuestionTitle(index, v),
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return 'Question title is required';
            }
            return null;
          },
        ),
        const Gap(12),
        TextFormField(
          initialValue: question.description ?? '',
          decoration: const InputDecoration(
            labelText: 'Question description (optional)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
          maxLines: 2,
          maxLength: 4096,
          onChanged:
              (v) =>
                  notifier.setQuestionDescription(index, v.isEmpty ? null : v),
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        ),
        if (question.options != null) ...[
          const Gap(16),
          Text('Options', style: Theme.of(context).textTheme.titleMedium),
          const Gap(8),
          _OptionsEditor(index: index, options: question.options!),
          const Gap(4),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () => notifier.addOption(index),
              icon: const Icon(Icons.add),
              label: const Text('Add option'),
            ),
          ),
        ],
        if (question.options == null &&
            (question.type == SnPollQuestionType.freeText ||
                question.type == SnPollQuestionType.rating ||
                question.type == SnPollQuestionType.yesNo)) ...[
          const Gap(16),
          _TextAnswerPreview(long: false),
        ],
      ],
    );
  }
}

class _QuestionTypePicker extends StatelessWidget {
  const _QuestionTypePicker({required this.value, required this.onChanged});

  final SnPollQuestionType value;
  final ValueChanged<SnPollQuestionType> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<SnPollQuestionType>(
      value: value,
      decoration: const InputDecoration(
        labelText: 'Type',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      items:
          SnPollQuestionType.values
              .map(
                (t) => DropdownMenuItem(
                  value: t,
                  child: Row(
                    children: [
                      Icon(_iconForType(t)),
                      const Gap(8),
                      Text(_labelForType(t)),
                    ],
                  ),
                ),
              )
              .toList(),
      onChanged: (t) {
        if (t != null) onChanged(t);
      },
    );
  }
}

class _OptionsEditor extends ConsumerWidget {
  const _OptionsEditor({required this.index, required this.options});

  final int index;
  final List<SnPollOption> options;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(pollEditorProvider.notifier);

    return Column(
      children: [
        for (var i = 0; i < options.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    key: ValueKey(options[i].id),
                    initialValue: options[i].label,
                    decoration: const InputDecoration(
                      labelText: 'Option label',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                    ),
                    onChanged: (v) => notifier.setOptionLabel(index, i, v),
                    onTapOutside:
                        (_) => FocusManager.instance.primaryFocus?.unfocus(),
                    inputFormatters: [LengthLimitingTextInputFormatter(1024)],
                  ),
                ),
                const Gap(8),
                SizedBox(
                  width: 40,
                  child: IconButton(
                    tooltip: 'Move up',
                    onPressed:
                        i > 0 ? () => notifier.moveOptionUp(index, i) : null,
                    icon: const Icon(Icons.arrow_upward),
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: IconButton(
                    tooltip: 'Move down',
                    onPressed:
                        i < options.length - 1
                            ? () => notifier.moveOptionDown(index, i)
                            : null,
                    icon: const Icon(Icons.arrow_downward),
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: IconButton(
                    tooltip: 'Delete',
                    onPressed: () => notifier.removeOption(index, i),
                    icon: const Icon(Icons.close),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _TextAnswerPreview extends StatelessWidget {
  const _TextAnswerPreview({required this.long});

  final bool long;

  @override
  Widget build(BuildContext context) {
    return TextField(
      enabled: false,
      maxLines: long ? 4 : 1,
      decoration: InputDecoration(
        labelText:
            long ? 'Long text answer (preview)' : 'Short text answer (preview)',
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.help_outline,
            color: Theme.of(context).colorScheme.primary,
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const Gap(4),
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
