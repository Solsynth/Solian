import 'package:freezed_annotation/freezed_annotation.dart';

part 'ticket_models.freezed.dart';
part 'ticket_models.g.dart';

@freezed
sealed class SnTicket with _$SnTicket {
  const factory SnTicket({
    required String id,
    required String title,
    String? description,
    required int type,
    required int status,
    required int priority,
    required String creatorId,
    String? assigneeId,
    DateTime? resolvedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
    @Default([]) List<SnTicketMessage> messages,
    @Default([]) List<SnTicketFile> files,
  }) = _SnTicket;

  factory SnTicket.fromJson(Map<String, dynamic> json) =>
      _$SnTicketFromJson(json);
}

@freezed
sealed class SnTicketMessage with _$SnTicketMessage {
  const factory SnTicketMessage({
    required String id,
    required String ticketId,
    required String senderId,
    required String content,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _SnTicketMessage;

  factory SnTicketMessage.fromJson(Map<String, dynamic> json) =>
      _$SnTicketMessageFromJson(json);
}

@freezed
sealed class SnTicketFile with _$SnTicketFile {
  const factory SnTicketFile({
    required String id,
    required String ticketId,
    required String fileId,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _SnTicketFile;

  factory SnTicketFile.fromJson(Map<String, dynamic> json) =>
      _$SnTicketFileFromJson(json);
}

@freezed
sealed class TicketType with _$TicketType {
  const factory TicketType(int value, String displayName) = _TicketType;

  const TicketType._();

  static const support = TicketType(0, 'Support');
  static const bugReport = TicketType(1, 'Bug Report');
  static const featureRequest = TicketType(2, 'Feature Request');
  static const billing = TicketType(3, 'Billing');
  static const other = TicketType(4, 'Other');

  static const supportStr = TicketType(0, 'support');
  static const bugReportStr = TicketType(1, 'bug_report');
  static const featureRequestStr = TicketType(2, 'feature_request');
  static const billingStr = TicketType(3, 'billing');
  static const otherStr = TicketType(4, 'other');

  static List<TicketType> get values => [
    support,
    bugReport,
    featureRequest,
    billing,
    other,
  ];

  static TicketType fromValue(int value) {
    return values.firstWhere((e) => e.value == value, orElse: () => other);
  }

  static TicketType fromString(String value) {
    switch (value) {
      case 'support':
        return support;
      case 'bug_report':
        return bugReport;
      case 'feature_request':
        return featureRequest;
      case 'billing':
        return billing;
      default:
        return other;
    }
  }
}

@freezed
sealed class TicketStatus with _$TicketStatus {
  const factory TicketStatus(String value, String displayName) = _TicketStatus;

  const TicketStatus._();

  static const open = TicketStatus('open', 'Open');
  static const inProgress = TicketStatus('in_progress', 'In Progress');
  static const resolved = TicketStatus('resolved', 'Resolved');
  static const closed = TicketStatus('closed', 'Closed');

  static List<TicketStatus> get values => [open, inProgress, resolved, closed];

  static TicketStatus fromValue(String value) {
    return values.firstWhere((e) => e.value == value, orElse: () => open);
  }
}

@freezed
sealed class TicketPriority with _$TicketPriority {
  const factory TicketPriority(int value, String displayName) = _TicketPriority;

  const TicketPriority._();

  static const low = TicketPriority(0, 'Low');
  static const medium = TicketPriority(1, 'Medium');
  static const high = TicketPriority(2, 'High');
  static const critical = TicketPriority(3, 'Critical');

  static List<TicketPriority> get values => [low, medium, high, critical];

  static TicketPriority fromValue(int value) {
    return values.firstWhere((e) => e.value == value, orElse: () => medium);
  }

  static TicketPriority fromString(String value) {
    switch (value) {
      case 'low':
        return low;
      case 'high':
        return high;
      case 'critical':
        return critical;
      default:
        return medium;
    }
  }
}
