import 'package:dio/dio.dart';

/// Standardized error payload returned by the API.
///
/// Mirrors `DysonNetwork.Shared.Networking.ApiError` on the server side
/// (an RFC 7807-inspired problem+json envelope):
/// `{ code, message, status, detail, traceId, errors, meta }`.
class ApiError {
  const ApiError({
    this.code = 'UNKNOWN_ERROR',
    this.message = 'An unexpected error occurred.',
    this.status,
    this.detail,
    this.traceId,
    this.errors,
    this.meta,
  });

  /// Application-specific error code (e.g. "VALIDATION_ERROR", "NOT_FOUND",
  /// "SERVER_ERROR"). Convention: `{RESOURCE}_{REASON}_{VARIANT}`, ALL_CAPS.
  final String code;

  /// Short, human-readable message for the error.
  final String message;

  /// HTTP status code of the error, when known.
  final int? status;

  /// More detailed description of the error.
  final String? detail;

  /// Server trace identifier (e.g. `HttpContext.TraceIdentifier`) to help
  /// debugging.
  final String? traceId;

  /// Field-level validation errors: field name -> list of messages.
  final Map<String, List<String>>? errors;

  /// Arbitrary additional metadata for clients.
  final Map<String, dynamic>? meta;

  /// Whether the payload carries a meaningful app-specific code rather than
  /// the generic [code] default `UNKNOWN_ERROR`.
  bool get hasCode => code.isNotEmpty && code != 'UNKNOWN_ERROR';

  /// User-facing text: message, then detail, then field errors, joined.
  String get displayMessage {
    final parts = <String>[
      if (message.trim().isNotEmpty) message.trim(),
      if (detail != null && detail!.trim().isNotEmpty) detail!.trim(),
      ...?errors?.values
          .expand((messages) => messages)
          .map((m) => m.trim())
          .where((m) => m.isNotEmpty),
    ];
    if (parts.isNotEmpty) return parts.join('\n');
    return hasCode ? code : message;
  }

  /// Extracts an [ApiError] from the response body of a failed [DioException].
  ///
  /// Returns null when the response carries no recognizable error payload
  /// (so callers can fall back to transport-level messages).
  static ApiError? tryParse(DioException err) {
    final data = err.response?.data;
    if (data is Map) {
      const knownKeys = {
        'code',
        'message',
        'error',
        'detail',
        'status',
        'traceId',
        'errors',
        'meta',
      };
      final map = Map<String, dynamic>.from(data);
      if (map.keys.any(knownKeys.contains)) {
        return ApiError.fromJson(map);
      }
    } else if (data is String && data.trim().isNotEmpty) {
      // Plain-text error body.
      return ApiError(
        message: data.trim(),
        status: err.response?.statusCode,
      );
    }
    return null;
  }

  factory ApiError.fromJson(Map<String, dynamic> json) {
    Map<String, List<String>>? errors;
    final rawErrors = json['errors'];
    if (rawErrors is Map) {
      errors = {
        for (final entry in rawErrors.entries)
          entry.key.toString(): _stringList(entry.value),
      };
    }

    final rawMeta = json['meta'];
    final rawStatus = json['status'];
    final rawCode = json['code']?.toString().trim() ?? '';

    return ApiError(
      code: rawCode.isNotEmpty ? rawCode : 'UNKNOWN_ERROR',
      message:
          json['message']?.toString() ??
          json['error']?.toString() ??
          'An unexpected error occurred.',
      status:
          rawStatus is num
              ? rawStatus.toInt()
              : int.tryParse(rawStatus?.toString() ?? ''),
      detail: json['detail']?.toString(),
      traceId: json['traceId']?.toString(),
      errors: errors,
      meta: rawMeta is Map ? Map<String, dynamic>.from(rawMeta) : null,
    );
  }

  static List<String> _stringList(dynamic value) {
    return switch (value) {
      List list => list.map((e) => e.toString()).toList(),
      _ => [value.toString()],
    };
  }

  @override
  String toString() =>
      'ApiError(code: $code, message: $message, status: $status, '
      'traceId: $traceId)';
}
