/// Shared plumbing for plugins whose tools call Solar Network.
///
/// Three jobs, all of them about what the model ends up reading: make the
/// request, project the answer down to the fields a reader needs, and turn a
/// failure into something the model can act on.
///
/// ## Why these tools call paths rather than the SDK's methods
///
/// `solar_network_sdk` offers a typed method per endpoint, and it is wrong in
/// two ways that only show up at runtime. Its routes lag the services they
/// describe — the home feed, post search, a publisher's posts, the daily
/// fortune, every room-scoped chat call and both notification writes answer
/// 404 — and its response models lag further, so parsing a field the server
/// stopped sending throws mid-call. One method even swallows a 404 into
/// `null`, which reads to the model as "there is nothing" rather than "that
/// endpoint is gone".
///
/// So the tools name their paths, and read the few fields they report out of
/// the decoded JSON. A path here is checked against the service that serves
/// it, and a field that disappears is a missing value rather than an
/// exception. That is the whole trade: less type safety against a schema that
/// is already stale, in exchange for a tool that answers.
library;

import 'dart:convert';

import 'package:dio/dio.dart';

/// Runs one Solar Network call and returns what the model should read.
///
/// The answer is JSON either way: the payload on success, or an object with an
/// `error`. A failure — not signed in, nothing there, refused, offline — is a
/// fact about the request rather than a defect of the tool, so it is reported
/// as an answer. The model can then correct itself, which is the whole
/// difference between a dead end and a second attempt.
Future<String> solarToolResult(Future<Object?> Function() call) async {
  try {
    return jsonEncode(await call());
  } on DioException catch (error) {
    return jsonEncode({'error': solarFailureText(error)});
  } catch (error) {
    return jsonEncode({'error': 'The request failed: $error'});
  }
}

/// One GET against the gateway, over the app's authenticated connection.
///
/// [query] entries that are null are left out rather than sent empty, which is
/// what keeps an optional filter optional.
Future<Object?> solarGet(
  Dio dio,
  String path, {
  Map<String, dynamic>? query,
}) async {
  final response = await dio.get<Object?>(
    path,
    queryParameters: _withoutBlanks(query),
  );
  return response.data;
}

/// One GET that keeps the response, for the listing endpoints that count
/// their pages in the `X-Total` header rather than the payload.
Future<Response<Object?>> solarGetResponse(
  Dio dio,
  String path, {
  Map<String, dynamic>? query,
}) =>
    dio.get<Object?>(
      path,
      queryParameters: _withoutBlanks(query),
    );

/// The page count a listing carries in its `X-Total` header, if any.
///
/// A service that pages by header tells a reader how many items there are in
/// all; without it the last page would read like the whole mailbox.
int solarTotal(Response<Object?> response) =>
    int.tryParse(response.headers.value('x-total') ?? '') ?? 0;

/// One POST against the gateway, over the app's authenticated connection.
Future<Object?> solarPost(
  Dio dio,
  String path, {
  Map<String, dynamic>? query,
  Object? body,
}) async {
  final response = await dio.post<Object?>(
    path,
    queryParameters: _withoutBlanks(query),
    data: body,
  );
  return response.data;
}

/// One PATCH against the gateway, over the app's authenticated connection.
///
/// A partial update sends only the fields the caller named; the accessors are
/// what keep a field the model left out out of the body.
Future<Object?> solarPatch(
  Dio dio,
  String path, {
  Map<String, dynamic>? query,
  Object? body,
}) async {
  final response = await dio.patch<Object?>(
    path,
    queryParameters: _withoutBlanks(query),
    data: body,
  );
  return response.data;
}


Map<String, dynamic>? _withoutBlanks(Map<String, dynamic>? query) {
  if (query == null || query.isEmpty) return null;
  final sent = <String, dynamic>{};
  for (final entry in query.entries) {
    if (entry.value != null) sent[entry.key] = entry.value;
  }
  return sent.isEmpty ? null : sent;
}

/// A string field, or null when it is absent, null, or blank.
///
/// The wire fills an unused text field with an empty string as often as it
/// omits it, and neither says anything a reader can use.
String? solarString(Object? json, String key) {
  final value = _field(json, key);
  if (value == null) return null;
  if (value is Map || value is Iterable) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

/// A number field, or null when it is absent or not a number.
///
/// Never throws: a count the server stopped sending is a count the answer does
/// not have, not a broken tool.
num? solarNumber(Object? json, String key) {
  final value = _field(json, key);
  if (value is num) return value;
  if (value is String) return num.tryParse(value);
  return null;
}

/// A whole number field, as an `int` for the model's benefit.
int? solarInt(Object? json, String key) => solarNumber(json, key)?.toInt();

/// A list field, or an empty list when it is absent or is not a list.
List<Object?> solarList(Object? json, String key) {
  final value = _field(json, key);
  return value is List ? value : const [];
}

/// A nested object field, or null when it is absent or is not an object.
Map<String, dynamic>? solarMap(Object? json, String key) {
  final value = _field(json, key);
  return value is Map<String, dynamic> ? value : null;
}

/// The raw field, for the rare read the typed accessors do not cover.
Object? solarField(Object? json, String key) => _field(json, key);

Object? _field(Object? json, String key) {
  if (json is Map) return json[key];
  return null;
}

/// A timestamp field, or a timestamp, as the model should read it.
///
/// The wire carries sub-second precision the model never needs, and a bare
/// local-time string would be ambiguous the moment the user travels.
String? solarTime(Object? value) {
  final DateTime? parsed = switch (value) {
    DateTime time => time,
    String text when text.isNotEmpty => DateTime.tryParse(text),
    _ => null,
  };
  if (parsed == null) return null;
  final utc = parsed.toUtc().toIso8601String();
  final dot = utc.indexOf('.');
  return dot < 0 ? utc : '${utc.substring(0, dot)}Z';
}

/// A timestamp held under [key].
String? solarTimeField(Object? json, String key) => solarTime(_field(json, key));

/// The items of a listing, whichever of the two shapes the endpoint uses.
///
/// Some listings answer with a bare array and some with an envelope carrying
/// one under `items` — the timeline is the second kind — and a tool should not
/// have to know which it is talking to in order to count them.
List<Object?> solarPage(Object? json) {
  if (json is List) return json;
  if (json is Map) {
    for (final key in const ['items', 'rooms', 'groups']) {
      final value = json[key];
      if (value is List) return value;
    }
  }
  return const [];
}

/// Drops the fields that say nothing, so a projection stays worth reading.
///
/// Absent, blank, and empty collections go: a model reading a list of forty
/// items pays for every `"reactions": {}` it will never use.
///
/// A **number is kept, zero included**. Zero is an answer — a post with no
/// replies is not the same as one whose reply count was not sent — and a
/// helper that quietly deleted it would make the two indistinguishable to the
/// reader. A projection that genuinely wants a zero left out says so itself.
Map<String, dynamic> solarCompact(Map<String, dynamic> fields) =>
    fields..removeWhere(
      (_, value) =>
          value == null ||
          (value is String && value.isEmpty) ||
          (value is Iterable && value.isEmpty) ||
          (value is Map && value.isEmpty),
    );

/// A `take` argument clamped to what one call may ask for.
///
/// Models routinely pass a number as a string, or ask for more than fits in a
/// context window; neither should end the call.
int solarTake(
  Map<String, dynamic> arguments, {
  int fallback = 10,
  int max = 30,
}) {
  final raw = arguments['take'];
  final asked = raw is int ? raw : int.tryParse('${raw ?? ''}');
  return asked == null ? fallback : asked.clamp(1, max);
}

/// A required string argument, or null when the model left it out or blank.
String? solarText(Map<String, dynamic> arguments, String key) {
  final value = arguments[key];
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

/// A required argument that is missing or blank, reported so the model retries.
///
/// Returning this rather than throwing keeps a malformed call a turn the model
/// can fix, instead of a tool that appears broken.
Map<String, dynamic> solarMissing(String argument) => {
  'error': 'The "$argument" argument is required.',
};

/// Trims [text] to [limit] characters, marking that it was cut.
///
/// A post body can be arbitrarily long; the model needs enough of it to act,
/// and needs to know when there was more.
String? solarClip(String? text, {int limit = 600}) {
  if (text == null) return null;
  if (text.length <= limit) return text;
  return '${text.substring(0, limit)}… [truncated]';
}

/// What to tell the model about a failed Solar Network call.
///
/// Says what the status means for the user, not just what it was: `401` is a
/// session that needs signing in again, and telling the model `HTTP 401` alone
/// invites it to retry a request that cannot succeed.
String solarFailureText(DioException error) {
  final said = _serverSaid(error.response?.data);
  final suffix = said.isEmpty ? '' : ': $said';
  final status = error.response?.statusCode;
  if (status == null) {
    return 'Could not reach Solar Network (${error.type.name})$suffix.';
  }
  final reason = switch (status) {
    400 => 'Solar Network rejected the request',
    401 => 'the user is not signed in to Solar Network, or the session expired',
    403 => 'the account is not allowed to do that',
    404 => 'there is no such item',
    405 => 'that is not something Solar Network allows here',
    409 => 'that conflicts with an existing item',
    429 => 'too many requests right now',
    >= 500 => 'Solar Network hit an internal error',
    _ => 'Solar Network refused the request',
  };
  return '$reason (HTTP $status)$suffix.';
}

/// The message a Solar Network error body carries, if any.
///
/// The gateway answers a failure with `{"message": ...}`; some services wrap a
/// lower layer's error instead, which may be prose rather than an object.
String _serverSaid(Object? data) {
  if (data is Map) {
    for (final key in const ['message', 'error', 'detail']) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
  }
  if (data is String && data.trim().isNotEmpty && data.length <= 200) {
    return data.trim();
  }
  return '';
}
