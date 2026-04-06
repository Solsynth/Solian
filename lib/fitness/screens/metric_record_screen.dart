import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/fitness/pods/fitness_providers.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

@RoutePage()
class MetricRecordScreen extends ConsumerStatefulWidget {
  final FitnessMetricType? initialType;

  const MetricRecordScreen({super.key, this.initialType});

  @override
  ConsumerState<MetricRecordScreen> createState() => _MetricRecordScreenState();
}

class _MetricRecordScreenState extends ConsumerState<MetricRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _valueController = TextEditingController();
  final _unitController = TextEditingController();
  final _notesController = TextEditingController();

  FitnessMetricType _selectedType = FitnessMetricType.weight;
  DateTime _recordedAt = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialType != null) {
      _selectedType = widget.initialType!;
      _unitController.text = _getDefaultUnit(_selectedType);
    }
  }

  @override
  void dispose() {
    _valueController.dispose();
    _unitController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SheetScaffold(
      titleText: 'Record Metric',
      heightFactor: 0.7,
      actions: [
        TextButton(
          onPressed: _isLoading ? null : _saveMetric,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
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
          _buildMetricTypeSelector(),
          const SizedBox(height: 16),
          _buildValueFields(),
          const SizedBox(height: 16),
          _buildDateTimePicker(),
          const SizedBox(height: 16),
          _buildNotesField(),
        ],
      ),
    );
  }

  Widget _buildMetricTypeSelector() {
    return DropdownButtonFormField<FitnessMetricType>(
      value: _selectedType,
      decoration: const InputDecoration(labelText: 'Metric Type'),
      items: FitnessMetricType.values.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(_getMetricTypeName(type)),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedType = value!;
          _unitController.text = _getDefaultUnit(value);
        });
      },
    );
  }

  Widget _buildValueFields() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: _valueController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Value',
              hintText: 'e.g., 70',
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
              hintText: 'kg',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimePicker() {
    return GestureDetector(
      onTap: () => _selectDateTime(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recorded At',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(_formatDateTime(_recordedAt)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      maxLines: 3,
      decoration: const InputDecoration(labelText: 'Notes (optional)'),
    );
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _recordedAt,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_recordedAt),
      );
      if (time != null) {
        setState(() {
          _recordedAt = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _saveMetric() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final request = CreateMetricRequest(
        metricType: _selectedType,
        value: double.parse(_valueController.text),
        unit: _unitController.text.isNotEmpty ? _unitController.text : 'count',
        recordedAt: _recordedAt,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        source: 'manual',
      );

      await ref.read(metricNotifierProvider.notifier).createMetric(request);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        showErrorAlert('Error recording metric: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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

  String _getDefaultUnit(FitnessMetricType type) {
    return switch (type) {
      FitnessMetricType.weight => 'kg',
      FitnessMetricType.bodyFat => '%',
      FitnessMetricType.steps => 'steps',
      FitnessMetricType.heartRate => 'bpm',
      FitnessMetricType.sleep => 'hours',
      FitnessMetricType.calories => 'kcal',
      FitnessMetricType.waterIntake => 'L',
      FitnessMetricType.distance => 'km',
      FitnessMetricType.custom => '',
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
