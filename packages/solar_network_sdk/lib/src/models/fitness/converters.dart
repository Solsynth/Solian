import 'package:freezed_annotation/freezed_annotation.dart';

class DateTimeConverter implements JsonConverter<DateTime, String> {
  const DateTimeConverter();

  @override
  DateTime fromJson(String json) => DateTime.parse(json);

  @override
  String toJson(DateTime dateTime) =>
      dateTime.toUtc().toIso8601String().replaceAll('+00:00', 'Z');
}

class NullableDateTimeConverter implements JsonConverter<DateTime?, String?> {
  const NullableDateTimeConverter();

  @override
  DateTime? fromJson(String? json) =>
      json != null ? DateTime.parse(json) : null;

  @override
  String? toJson(DateTime? dateTime) =>
      dateTime?.toUtc().toIso8601String().replaceAll('+00:00', 'Z');
}
