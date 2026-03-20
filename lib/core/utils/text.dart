import 'dart:ui';

extension StringExtension on String {
  String capitalizeEachWord() {
    if (isEmpty) return this;

    return split(' ')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
              : '',
        )
        .join(' ');
  }

  String toCamelCase() {
    if (isEmpty) return this;
    return split('-')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
              : '',
        )
        .join();
  }

  Color? parseHexColor() {
    if (isEmpty) return null;
    final normalized = replaceFirst('#', '');
    if (normalized.length != 6 && normalized.length != 8) return null;
    final buffer = StringBuffer();
    if (normalized.length == 6) buffer.write('ff');
    buffer.write(normalized);
    return Color(int.tryParse(buffer.toString(), radix: 16) ?? 0);
  }
}
