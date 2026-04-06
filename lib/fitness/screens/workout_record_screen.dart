import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:island/fitness/pods/fitness_providers.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

@RoutePage()
class WorkoutRecordScreen extends ConsumerStatefulWidget {
  const WorkoutRecordScreen({super.key});

  @override
  ConsumerState<WorkoutRecordScreen> createState() =>
      _WorkoutRecordScreenState();
}

class _WorkoutRecordScreenState extends ConsumerState<WorkoutRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _durationController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();

  WorkoutType _selectedType = WorkoutType.cardio;
  DateTime _startTime = DateTime.now();
  DateTime? _endTime;
  bool _isLoading = false;
  FitnessVisibility _visibility = FitnessVisibility.private;

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    _caloriesController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SheetScaffold(
      titleText: 'recordWorkout'.tr(),
      heightFactor: 0.8,
      actions: [
        TextButton(
          onPressed: _isLoading ? null : _saveWorkout,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text('save'.tr()),
        ),
        const Gap(8),
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
          _buildNameField(),
          const SizedBox(height: 16),
          _buildWorkoutTypeSelector(),
          const SizedBox(height: 16),
          _buildDateTimeSection(),
          const SizedBox(height: 16),
          _buildDurationField(),
          const SizedBox(height: 16),
          _buildCaloriesField(),
          const SizedBox(height: 16),
          _buildDescriptionField(),
          const SizedBox(height: 16),
          _buildNotesField(),
          const SizedBox(height: 16),
          _buildVisibilitySelector(),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'workoutName'.tr(),
        hintText: 'workoutNameHint'.tr(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'fieldCannotBeEmpty'.tr();
        }
        return null;
      },
    );
  }

  Widget _buildWorkoutTypeSelector() {
    return DropdownButtonFormField<WorkoutType>(
      value: _selectedType,
      decoration: InputDecoration(labelText: 'workoutType'.tr()),
      items: WorkoutType.values.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(_getWorkoutTypeName(type)),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedType = value!;
          if (_nameController.text.isEmpty) {
            _nameController.text = _getDefaultName(value);
          }
        });
      },
    );
  }

  Widget _buildDateTimeSection() {
    return Row(
      children: [
        Expanded(
          child: _buildDateTimePicker('startTime'.tr(), _startTime, true),
        ),
        const SizedBox(width: 12),
        Expanded(child: _buildDateTimePicker('endTime'.tr(), _endTime, false)),
      ],
    );
  }

  Widget _buildDateTimePicker(String label, DateTime? dateTime, bool isStart) {
    return GestureDetector(
      onTap: () => _selectDateTime(context, isStart),
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
              label,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).hintColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(dateTime != null ? _formatDateTime(dateTime) : 'notSet'.tr()),
          ],
        ).padding(horizontal: 16),
      ),
    );
  }

  Widget _buildDurationField() {
    return TextFormField(
      controller: _durationController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'durationMinutes'.tr(),
        hintText: 'durationMinutesHint'.tr(),
      ),
    );
  }

  Widget _buildCaloriesField() {
    return TextFormField(
      controller: _caloriesController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'caloriesBurned'.tr(),
        hintText: 'caloriesBurnedHint'.tr(),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 2,
      decoration: InputDecoration(labelText: 'descriptionOptional'.tr()),
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      maxLines: 3,
      decoration: InputDecoration(labelText: 'notesOptional'.tr()),
    );
  }

  Widget _buildVisibilitySelector() {
    return DropdownButtonFormField<FitnessVisibility>(
      value: _visibility,
      decoration: InputDecoration(labelText: 'visibility'.tr()),
      items: FitnessVisibility.values.map((v) {
        return DropdownMenuItem(
          value: v,
          child: Text(
            v == FitnessVisibility.private
                ? 'visibilityPrivate'.tr()
                : 'visibilityPublic'.tr(),
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _visibility = value!;
        });
      },
    );
  }

  Future<void> _selectDateTime(BuildContext context, bool isStart) async {
    final initial = isStart ? _startTime : (_endTime ?? DateTime.now());
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (date != null && context.mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initial),
      );
      if (time != null) {
        setState(() {
          final dateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
          if (isStart) {
            _startTime = dateTime;
          } else {
            _endTime = dateTime;
          }
        });
      }
    }
  }

  Future<void> _saveWorkout() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final request = CreateWorkoutRequest(
        name: _nameController.text,
        type: _selectedType,
        startTime: _startTime,
        endTime: _endTime,
        caloriesBurned: int.tryParse(_caloriesController.text),
        description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        visibility: _visibility,
      );

      await ref.read(workoutNotifierProvider.notifier).createWorkout(request);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        showErrorAlert('operationFailed'.tr(args: [e.toString()]));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getWorkoutTypeName(WorkoutType type) {
    return switch (type) {
      WorkoutType.strength => 'workoutTypeStrength'.tr(),
      WorkoutType.cardio => 'workoutTypeCardio'.tr(),
      WorkoutType.hiit => 'workoutTypeHiit'.tr(),
      WorkoutType.yoga => 'workoutTypeYoga'.tr(),
      WorkoutType.other => 'workoutTypeOther'.tr(),
    };
  }

  String _getDefaultName(WorkoutType type) {
    return switch (type) {
      WorkoutType.strength => 'Strength Workout',
      WorkoutType.cardio => 'Cardio Session',
      WorkoutType.hiit => 'HIIT Workout',
      WorkoutType.yoga => 'Yoga Session',
      WorkoutType.other => 'Workout',
    };
  }

  String _formatDateTime(DateTime date) {
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
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${months[date.month - 1]} ${date.day}, ${date.year} $hour:$minute';
  }
}
