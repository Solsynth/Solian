import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
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
  FitnessVisibility _visibility = FitnessVisibility.private;

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
      titleText: 'recordMetric'.tr(),
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
              : Text('save'.tr()),
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
          const SizedBox(height: 16),
          _buildVisibilitySelector(),
        ],
      ),
    );
  }

  Widget _buildMetricTypeSelector() {
    return DropdownButtonFormField<FitnessMetricType>(
      value: _selectedType,
      decoration: InputDecoration(labelText: 'metricType'.tr()),
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
            decoration: InputDecoration(
              labelText: 'metricValue'.tr(),
              hintText: 'metricValueHint'.tr(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'required'.tr();
              }
              if (double.tryParse(value) == null) {
                return 'fieldCannotBeEmpty'.tr();
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: _unitController,
            decoration: InputDecoration(
              labelText: 'unit'.tr(),
              hintText: 'e.g., kg',
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
                    'recordedAt'.tr(),
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

  Future<void> _selectDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _recordedAt,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null && context.mounted) {
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
        visibility: _visibility,
      );

      await ref.read(metricNotifierProvider.notifier).createMetric(request);

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

  String _getMetricTypeName(FitnessMetricType type) {
    return switch (type) {
      FitnessMetricType.weight => 'metricTypeWeight'.tr(),
      FitnessMetricType.bodyFat => 'metricTypeBodyFat'.tr(),
      FitnessMetricType.steps => 'metricTypeSteps'.tr(),
      FitnessMetricType.heartRate => 'metricTypeHeartRate'.tr(),
      FitnessMetricType.sleep => 'metricTypeSleep'.tr(),
      FitnessMetricType.calories => 'metricTypeCalories'.tr(),
      FitnessMetricType.waterIntake => 'metricTypeWaterIntake'.tr(),
      FitnessMetricType.distance => 'metricTypeDistance'.tr(),
      FitnessMetricType.custom => 'metricTypeCustom'.tr(),
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
