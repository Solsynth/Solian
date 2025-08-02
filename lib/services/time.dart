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

  String formatShortDuration() {
    final isNegative = inMicroseconds < 0;
    final positiveDuration = isNegative ? -this : this;

    final hours = positiveDuration.inHours;
    final minutes = (positiveDuration.inMinutes % 60).toString().padLeft(
      2,
      '0',
    );
    final seconds = (positiveDuration.inSeconds % 60).toString().padLeft(
      2,
      '0',
    );
    final milliseconds = (positiveDuration.inMilliseconds % 1000)
        .toString()
        .padLeft(3, '0');

    String result;
    if (hours > 0) {
      result =
          '${isNegative ? '-' : ''}${hours.toString().padLeft(2, '0')}:$minutes:$seconds.$milliseconds';
    } else {
      result = '${isNegative ? '-' : ''}$minutes:$seconds.$milliseconds';
    }
    return result;
  }

  String formatOffset() {
    final isNegative = inMicroseconds < 0;
    final positiveDuration = isNegative ? -this : this;

    final hours = positiveDuration.inHours.toString().padLeft(2, '0');
    final minutes = (positiveDuration.inMinutes % 60).toString().padLeft(
      2,
      '0',
    );

    return '${isNegative ? '-' : '+'}$hours:$minutes';
  }

  String formatOffsetLocal() {
    // Get the local timezone offset
    final localOffset = DateTime.now().timeZoneOffset;

    // Add the local offset to the input duration
    final totalOffset = this - localOffset;

    final isNegative = totalOffset.inMicroseconds < 0;
    final positiveDuration = isNegative ? -totalOffset : totalOffset;

    final hours = positiveDuration.inHours.toString().padLeft(2, '0');
    final minutes = (positiveDuration.inMinutes % 60).toString().padLeft(
      2,
      '0',
    );

    return '${isNegative ? '-' : '+'}$hours:$minutes';
  }
}

extension DateTimeFormatter on DateTime {
  String formatSystem() {
    return DateFormat.yMd().add_jm().format(toLocal());
  }

  String formatCustom(String pattern) {
    return DateFormat(pattern).format(toLocal());
  }

  String formatCustomGlobal(String pattern) {
    return DateFormat(pattern).format(this);
  }

  String formatWithLocale(String locale) {
    return DateFormat.yMd().add_jm().format(toLocal()).toString();
  }

  String formatRelative(BuildContext context) {
    return RelativeTime(context).format(toLocal());
  }
}
