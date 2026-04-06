import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/fitness/pods/fitness_providers.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:styled_widget/styled_widget.dart';

@RoutePage()
class GoalCreateScreen extends ConsumerStatefulWidget {
  final SnFitnessGoal? goal;

  const GoalCreateScreen({super.key, this.goal});

  @override
  ConsumerState<GoalCreateScreen> createState() => _GoalCreateScreenState();
}

class _GoalCreateScreenState extends ConsumerState<GoalCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _targetController = TextEditingController();
  final _unitController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();

  bool get isEditing => widget.goal != null;

  FitnessGoalType _selectedGoalType = FitnessGoalType.steps;
  WorkoutType? _boundWorkoutType;
  FitnessMetricType? _boundMetricType;
  bool _autoUpdateProgress = true;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _isRepeating = false;
  RepeatType _repeatType = RepeatType.weekly;
  int _repeatInterval = 1;
  int? _repeatCount;
  bool _isLoading = false;
  FitnessVisibility _visibility = FitnessVisibility.private;

  @override
  void initState() {
    super.initState();
    if (widget.goal != null) {
      _populateFromGoal(widget.goal!);
    }
  }

  void _populateFromGoal(SnFitnessGoal goal) {
    _titleController.text = goal.title;
    _targetController.text = goal.targetValue?.toString() ?? '';
    _unitController.text = goal.unit ?? '';
    _descriptionController.text = goal.description ?? '';
    _notesController.text = goal.notes ?? '';
    _selectedGoalType = goal.goalType;
    _boundWorkoutType = goal.boundWorkoutType != null
        ? WorkoutType.values[goal.boundWorkoutType!]
        : null;
    _boundMetricType = goal.boundMetricType != null
        ? FitnessMetricType.values[goal.boundMetricType!]
        : null;
    _autoUpdateProgress = goal.autoUpdateProgress;
    _startDate = goal.startDate;
    _endDate = goal.endDate;
    _visibility = goal.visibility;
    _isRepeating = goal.repeatType != null;
    if (_isRepeating) {
      _repeatType = goal.repeatType!;
      _repeatInterval = goal.repeatInterval ?? 1;
      _repeatCount = goal.repeatCount;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    _unitController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SheetScaffold(
      titleText: isEditing ? 'Edit Goal' : 'Create Goal',
      heightFactor: 0.9,
      actions: [
        TextButton(
          onPressed: _isLoading ? null : _saveGoal,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEditing ? 'Update' : 'Save'),
        ),
      ],
      child: _buildForm(),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTitleField(),
          const SizedBox(height: 16),
          _buildGoalTypeSelector(),
          const SizedBox(height: 16),
          _buildTargetFields(),
          const SizedBox(height: 16),
          _buildBindingSection(),
          const SizedBox(height: 16),
          _buildAutoUpdateToggle(),
          const SizedBox(height: 16),
          _buildDatesSection(),
          const SizedBox(height: 16),
          _buildRepeatToggle(),
          _buildRepeatSection(),
          const SizedBox(height: 16),
          _buildVisibilitySelector(),
          const SizedBox(height: 16),
          _buildDescriptionField(),
          const SizedBox(height: 16),
          _buildNotesField(),
        ],
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(
        labelText: 'Goal Title',
        hintText: 'e.g., Walk 50k steps',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a title';
        }
        return null;
      },
    );
  }

  Widget _buildGoalTypeSelector() {
    return DropdownButtonFormField<FitnessGoalType>(
      value: _selectedGoalType,
      decoration: const InputDecoration(labelText: 'Goal Type'),
      items: FitnessGoalType.values.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(_getGoalTypeName(type)),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedGoalType = value!;
          _unitController.text = _getDefaultUnit(value);
          _boundWorkoutType = _getDefaultBoundWorkout(value);
          _boundMetricType = _getDefaultBoundMetric(value);
        });
      },
    );
  }

  Widget _buildTargetFields() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: _targetController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Target Value',
              hintText: 'e.g., 50000',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Required';
              }
              if (double.tryParse(value) == null) {
                return 'Invalid';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: _unitController,
            decoration: const InputDecoration(
              labelText: 'Unit',
              hintText: 'steps',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBindingSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Auto-Track From',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<WorkoutType?>(
              value: _boundWorkoutType,
              decoration: const InputDecoration(
                labelText: 'Bind to Workout Type',
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('None')),
                ...WorkoutType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getWorkoutTypeName(type)),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _boundWorkoutType = value;
                  if (value != null) _boundMetricType = null;
                });
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<FitnessMetricType?>(
              value: _boundMetricType,
              decoration: const InputDecoration(
                labelText: 'Bind to Metric Type',
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('None')),
                ...FitnessMetricType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getMetricTypeName(type)),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _boundMetricType = value;
                  if (value != null) _boundWorkoutType = null;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAutoUpdateToggle() {
    return SwitchListTile(
      title: const Text('Auto-Update Progress'),
      subtitle: Text(
        _autoUpdateProgress
            ? 'Progress updates automatically'
            : 'Manually update progress',
      ),
      value: _autoUpdateProgress,
      onChanged: (value) {
        setState(() {
          _autoUpdateProgress = value;
        });
      },
    );
  }

  Widget _buildVisibilitySelector() {
    return DropdownButtonFormField<FitnessVisibility>(
      value: _visibility,
      decoration: const InputDecoration(labelText: 'Visibility'),
      items: FitnessVisibility.values.map((v) {
        return DropdownMenuItem(value: v, child: Text(_getVisibilityName(v)));
      }).toList(),
      onChanged: (value) {
        setState(() {
          _visibility = value!;
        });
      },
    );
  }

  Widget _buildDatesSection() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _selectDate(context, true),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Start Date',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(_formatDate(_startDate)),
                ],
              ).padding(horizontal: 16),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => _selectDate(context, false),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'End Date',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(_endDate != null ? _formatDate(_endDate!) : 'None'),
                ],
              ).padding(horizontal: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRepeatToggle() {
    return SwitchListTile(
      title: const Text('Repeat Goal'),
      subtitle: Text(
        _isRepeating
            ? 'Create a repeating goal plan'
            : 'Single goal without repetition',
      ),
      value: _isRepeating,
      onChanged: (value) {
        setState(() {
          _isRepeating = value;
        });
      },
    );
  }

  Widget _buildRepeatSection() {
    if (!_isRepeating) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Repeat Settings',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<RepeatType>(
              value: _repeatType,
              decoration: const InputDecoration(labelText: 'Repeat Type'),
              items: RepeatType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_getRepeatTypeName(type)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _repeatType = value!;
                });
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _repeatInterval.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Interval'),
                    onChanged: (value) {
                      _repeatInterval = int.tryParse(value) ?? 1;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: _repeatCount?.toString() ?? '',
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Count (empty = endless)',
                      hintText: 'e.g., 12',
                    ),
                    onChanged: (value) {
                      _repeatCount = value.isEmpty ? null : int.tryParse(value);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 2,
      decoration: const InputDecoration(labelText: 'Description (optional)'),
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      maxLines: 3,
      decoration: const InputDecoration(labelText: 'Notes (optional)'),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final initial = isStart
        ? _startDate
        : (_endDate ?? DateTime.now().add(const Duration(days: 30)));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _saveGoal() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (isEditing) {
        final request = UpdateGoalRequest(
          title: _titleController.text,
          goalType: _selectedGoalType,
          startDate: _startDate,
          status: widget.goal!.status,
          targetValue: double.tryParse(_targetController.text),
          currentValue: widget.goal!.currentValue,
          unit: _unitController.text.isNotEmpty ? _unitController.text : null,
          boundWorkoutType: _boundWorkoutType?.index,
          boundMetricType: _boundMetricType?.index,
          autoUpdateProgress: _autoUpdateProgress,
          endDate: _endDate,
          description: _descriptionController.text.isNotEmpty
              ? _descriptionController.text
              : null,
          notes: _notesController.text.isNotEmpty
              ? _notesController.text
              : null,
          visibility: _visibility,
        );

        await ref
            .read(goalNotifierProvider.notifier)
            .updateGoal(widget.goal!.id, request);
      } else {
        final request = CreateGoalRequest(
          title: _titleController.text,
          goalType: _selectedGoalType,
          startDate: _startDate,
          targetValue: double.tryParse(_targetController.text),
          unit: _unitController.text.isNotEmpty ? _unitController.text : null,
          boundWorkoutType: _boundWorkoutType?.index,
          boundMetricType: _boundMetricType?.index,
          autoUpdateProgress: _autoUpdateProgress,
          endDate: _endDate,
          description: _descriptionController.text.isNotEmpty
              ? _descriptionController.text
              : null,
          notes: _notesController.text.isNotEmpty
              ? _notesController.text
              : null,
          repeatType: _isRepeating ? _repeatType : null,
          repeatInterval: _isRepeating ? _repeatInterval : null,
          repeatCount: _isRepeating ? _repeatCount : null,
          visibility: _visibility,
        );

        await ref.read(goalNotifierProvider.notifier).createGoal(request);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        showErrorAlert('Error ${isEditing ? 'updating' : 'creating'} goal: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getGoalTypeName(FitnessGoalType type) {
    return switch (type) {
      FitnessGoalType.weightLoss => 'Weight Loss',
      FitnessGoalType.weightGain => 'Weight Gain',
      FitnessGoalType.steps => 'Steps',
      FitnessGoalType.distance => 'Distance',
      FitnessGoalType.duration => 'Duration',
      FitnessGoalType.reps => 'Reps',
      FitnessGoalType.strength => 'Strength',
      FitnessGoalType.cardio => 'Cardio',
      FitnessGoalType.flexibility => 'Flexibility',
      FitnessGoalType.custom => 'Custom',
    };
  }

  String _getWorkoutTypeName(WorkoutType type) {
    return switch (type) {
      WorkoutType.strength => 'Strength',
      WorkoutType.cardio => 'Cardio',
      WorkoutType.hiit => 'HIIT',
      WorkoutType.yoga => 'Yoga',
      WorkoutType.other => 'Other',
    };
  }

  String _getMetricTypeName(FitnessMetricType type) {
    return switch (type) {
      FitnessMetricType.weight => 'Weight',
      FitnessMetricType.bodyFat => 'Body Fat',
      FitnessMetricType.steps => 'Steps',
      FitnessMetricType.heartRate => 'Heart Rate',
      FitnessMetricType.sleep => 'Sleep',
      FitnessMetricType.calories => 'Calories',
      FitnessMetricType.waterIntake => 'Water Intake',
      FitnessMetricType.distance => 'Distance',
      FitnessMetricType.custom => 'Custom',
    };
  }

  String _getRepeatTypeName(RepeatType type) {
    return switch (type) {
      RepeatType.daily => 'Daily',
      RepeatType.weekly => 'Weekly',
      RepeatType.biweekly => 'Bi-weekly',
      RepeatType.monthly => 'Monthly',
      RepeatType.quarterly => 'Quarterly',
      RepeatType.yearly => 'Yearly',
    };
  }

  String _getVisibilityName(FitnessVisibility visibility) {
    return switch (visibility) {
      FitnessVisibility.private => 'Private',
      FitnessVisibility.public => 'Public',
    };
  }

  String _getDefaultUnit(FitnessGoalType type) {
    return switch (type) {
      FitnessGoalType.weightLoss || FitnessGoalType.weightGain => 'kg',
      FitnessGoalType.steps => 'steps',
      FitnessGoalType.distance => 'km',
      FitnessGoalType.duration => 'min',
      FitnessGoalType.reps => 'reps',
      FitnessGoalType.strength || FitnessGoalType.cardio => 'kcal',
      FitnessGoalType.flexibility => 'min',
      FitnessGoalType.custom => '',
    };
  }

  WorkoutType? _getDefaultBoundWorkout(FitnessGoalType type) {
    return switch (type) {
      FitnessGoalType.cardio => WorkoutType.cardio,
      FitnessGoalType.strength => WorkoutType.strength,
      _ => null,
    };
  }

  FitnessMetricType? _getDefaultBoundMetric(FitnessGoalType type) {
    return switch (type) {
      FitnessGoalType.steps => FitnessMetricType.steps,
      FitnessGoalType.distance => FitnessMetricType.distance,
      FitnessGoalType.weightLoss ||
      FitnessGoalType.weightGain => FitnessMetricType.weight,
      _ => null,
    };
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
