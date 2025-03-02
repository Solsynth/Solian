import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification.freezed.dart';
part 'notification.g.dart';

@freezed
abstract class SnNotification with _$SnNotification {
  const factory SnNotification({
    required int id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
    required String topic,
    required String title,
    required String? subtitle,
    required String body,
    @Default({}) Map<String, dynamic> metadata,
    required int priority,
    required int? senderId,
    required int accountId,
    required DateTime? readAt,
  }) = _SnNotification;

  factory SnNotification.fromJson(Map<String, dynamic> json) =>
      _$SnNotificationFromJson(json);
}
