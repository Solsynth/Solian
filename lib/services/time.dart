import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:relative_time/relative_time.dart';

extension DurationFormatter on Duration {
  String formatDuration() {
    final isNegative = inMicroseconds < 0;
    final positiveDuration = isNegative ? -this : this;

    final hours = positiveDuration.inHours.toString().padLeft(2, '0');
    final minutes = (positiveDuration.inMinutes % 60).toString().padLeft(
      2,
      '0',
    );
    final seconds = (positiveDuration.inSeconds % 60).toString().padLeft(
      2,
      '0',
    );

    return '${isNegative ? '-' : ''}$hours:$minutes:$seconds';
  }
}

extension DateTimeFormatter on DateTime {
  String formatSystem() {
    return DateFormat.yMd().add_jm().format(toLocal());
  }

  String formatCustom(String pattern) {
    return DateFormat(pattern).format(toLocal());
  }

  String formatWithLocale(String locale) {
    return DateFormat.yMd().add_jm().format(toLocal()).toString();
  }

  String formatRelative(BuildContext context) {
    return RelativeTime(context).format(toLocal());
  }
}
