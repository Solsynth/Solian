import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:island/models/user.dart';

part 'abuse_report.freezed.dart';
part 'abuse_report.g.dart';

@freezed
sealed class SnAbuseReport with _$SnAbuseReport {
  const factory SnAbuseReport({
    required String id,
    required String resourceIdentifier,
    required int type,
    required String reason,
    required DateTime? resolvedAt,
    required String? resolution,
    required String accountId,
    required SnAccount? account,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
  }) = _SnAbuseReport;

  factory SnAbuseReport.fromJson(Map<String, dynamic> json) =>
      _$SnAbuseReportFromJson(json);
}
