String _upperCamelToLowerSnake(String input) {
  final regex = RegExp(r'(?<=[a-z0-9])([A-Z])');
  return input
      .replaceAllMapped(regex, (match) => '_${match.group(0)}')
      .toLowerCase();
}

Map<String, dynamic> convertMapKeysToSnakeCase(Map<String, dynamic> input) {
  final result = <String, dynamic>{};

  input.forEach((key, value) {
    final newKey = _upperCamelToLowerSnake(key);

    if (value is Map<String, dynamic>) {
      result[newKey] = convertMapKeysToSnakeCase(value);
    } else if (value is List) {
      result[newKey] =
          value.map((item) {
            if (item is Map<String, dynamic>) {
              return convertMapKeysToSnakeCase(item);
            }
            return item;
          }).toList();
    } else {
      result[newKey] = value;
    }
  });

  return result;
}
