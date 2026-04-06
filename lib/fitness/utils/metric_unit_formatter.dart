String formatMetricUnit(double value, String rawUnit) {
  final normalized = rawUnit.toUpperCase().trim();

  if (value == 0) {
    return _formatZeroValue(normalized);
  }

  return switch (normalized) {
    'COUNT' || 'COUNT/DAY' => '',
    'METER' => _formatMeters(value),
    'KILOCALORIE' || 'KCAL' => 'kcal',
    'BEATS_PER_MINUTE' || 'BPM' => 'bpm',
    'MINUTE' => _formatMinutes(value.toInt()),
    'HOUR' => _formatHours(value),
    'LITER' || 'ML' => _formatMilliliters(value),
    'PERCENT' || '%' => '%',
    'KG' || 'KILOGRAM' => 'kg',
    'CM' || 'METER_CM' => 'cm',
    _ => rawUnit,
  };
}

String formatMetricValue(double value, String rawUnit) {
  final normalized = rawUnit.toUpperCase().trim();
  final formattedUnit = formatMetricUnit(value, rawUnit);

  if (formattedUnit.isEmpty) {
    return value.toStringAsFixed(0);
  }

  return switch (normalized) {
    'MINUTE' => _formatMinutes(value.toInt()),
    'HOUR' => _formatHours(value),
    'METER' => _formatMeters(value),
    'LITER' || 'ML' => _formatMilliliters(value),
    'PERCENT' || '%' => '${value.toStringAsFixed(1)}%',
    _ => '${value.toStringAsFixed(1)} $formattedUnit',
  };
}

String _formatMinutes(int minutes) {
  if (minutes < 60) {
    return '${minutes}m';
  }
  final hours = minutes ~/ 60;
  final mins = minutes % 60;
  if (mins == 0) {
    return '${hours}h';
  }
  return '${hours}h ${mins}m';
}

String _formatHours(double hours) {
  final totalMinutes = (hours * 60).toInt();
  final h = totalMinutes ~/ 60;
  final m = totalMinutes % 60;
  if (m == 0) {
    return '${h}h';
  }
  return '${h}h ${m}m';
}

String _formatMeters(double meters) {
  if (meters >= 1000) {
    return '${(meters / 1000).toStringAsFixed(2)} km';
  }
  return '${meters.toStringAsFixed(0)} m';
}

String _formatMilliliters(double ml) {
  if (ml >= 1000) {
    return '${(ml / 1000).toStringAsFixed(1)} L';
  }
  return '${ml.toStringAsFixed(0)} ml';
}

String _formatZeroValue(String normalized) {
  return switch (normalized) {
    'COUNT' || 'COUNT/DAY' => '0',
    'METER' => '0 m',
    'KILOCALORIE' || 'KCAL' => '0 kcal',
    'BEATS_PER_MINUTE' || 'BPM' => '0 bpm',
    'MINUTE' => '0m',
    'HOUR' => '0h',
    'LITER' || 'ML' => '0 ml',
    'PERCENT' || '%' => '0%',
    'KG' || 'KILOGRAM' => '0 kg',
    'CM' || 'METER_CM' => '0 cm',
    _ => '0',
  };
}

String getDisplayUnit(String rawUnit) {
  final normalized = rawUnit.toUpperCase().trim();
  return switch (normalized) {
    'COUNT' || 'COUNT/DAY' => '',
    'METER' => 'km',
    'KILOCALORIE' || 'KCAL' => 'kcal',
    'BEATS_PER_MINUTE' || 'BPM' => 'bpm',
    'MINUTE' => 'time',
    'HOUR' => 'time',
    'LITER' || 'ML' => 'L',
    'PERCENT' || '%' => '%',
    'KG' || 'KILOGRAM' => 'kg',
    'CM' || 'METER_CM' => 'cm',
    _ => rawUnit,
  };
}

String formatSource(String? source) {
  if (source == null || source.isEmpty) return 'Unknown';

  final normalized = source.toLowerCase();

  if (normalized.contains('healthkit') || normalized.contains('health')) {
    return 'Apple Health';
  }
  if (normalized.contains('googlefit') ||
      normalized.contains('google') ||
      normalized.contains('fit')) {
    return 'Google Fit';
  }
  if (normalized.contains('samsung')) {
    return 'Samsung Health';
  }
  if (normalized.contains('garmin')) {
    return 'Garmin';
  }
  if (normalized.contains('fitbit')) {
    return 'Fitbit';
  }
  if (normalized.contains('mi') || normalized.contains('xiaomi')) {
    return 'Xiaomi';
  }
  if (normalized.contains('huawei')) {
    return 'Huawei Health';
  }

  return source;
}
