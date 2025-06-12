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
