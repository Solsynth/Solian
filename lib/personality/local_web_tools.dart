import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

// ---------------------------------------------------------------------------
// Local web tools
// ---------------------------------------------------------------------------

/// One tool whose body runs in the client rather than on the Personality
/// server.
///
/// The server's own `web_search`/`web_fetch` scrape from shared datacenter
/// egress IPs, which search engines answer with bot challenges; these tools
/// make the same requests from the user's connection instead. Server-owned
/// names cannot be redefined, hence the `_local` suffixes.
class SnLocalTool {
  const SnLocalTool({
    required this.name,
    required this.description,
    required this.parameters,
    required this.execute,
  });

  /// Wire name the model calls; must not collide with a server-owned tool.
  final String name;

  /// Prose the model reads when deciding whether to call this tool.
  final String description;

  /// JSON Schema of the arguments object (`function.parameters`).
  final Map<String, dynamic> parameters;

  /// Runs the tool and returns the text handed back to the model.
  final Future<String> Function(Map<String, dynamic> arguments) execute;

  /// The OpenAI `tools[]` entry the compatibility endpoint accepts verbatim.
  Map<String, dynamic> toOpenAiTool() => {
    'type': 'function',
    'function': {
      'name': name,
      'description': description,
      'parameters': parameters,
    },
  };
}

/// The client-executed web tools, in the order the model sees them.
///
/// [http] must be a bare client: these requests go to third-party engines and
/// must not carry the app's `Authorization` header.
List<SnLocalTool> buildLocalWebTools(Dio http) => [
  SnLocalTool(
    name: 'web_search_local',
    description:
        "Search the web from the user's own connection. Tries credential-free "
        'engines (Bing, DuckDuckGo, Mojeek) in order and returns the first one '
        'that answers with relevant hits, as a numbered title/URL/snippet '
        'list.\n\n'
        "Prefer this over the server-side web_search: it leaves from the user's "
        'IP, which search engines do not challenge with bot checks.\n\n'
        'Understands the operators the engines support (site:, quoted phrases, '
        'exclusions, OR).',
    parameters: const <String, dynamic>{
      'type': 'object',
      'properties': <String, dynamic>{
        'query': <String, dynamic>{'type': 'string', 'description': 'Search query.'},
        'recency': <String, dynamic>{
          'type': 'string',
          'enum': <String>['day', 'week', 'month', 'year'],
          'description': 'Relative time filter: day, week, month, or year.',
        },
        'limit': <String, dynamic>{
          'type': 'integer',
          'minimum': 1,
          'maximum': 20,
          'description': 'Maximum results (1-20, default 10).',
        },
        'num_search_results': <String, dynamic>{
          'type': 'integer',
          'description': 'Alias for limit.',
        },
      },
      'required': <String>['query'],
    },
    execute: (arguments) => _webSearch(http, arguments),
  ),
  SnLocalTool(
    name: 'web_fetch_local',
    description:
        "Fetch one URL from the user's own connection and return its readable "
        'content: HTML becomes markdown with headings, lists and links kept, '
        'JSON is pretty-printed, plain text is returned as-is. Reports the HTTP '
        'status and the final URL after redirects.',
    parameters: const <String, dynamic>{
      'type': 'object',
      'properties': <String, dynamic>{
        'url': <String, dynamic>{
          'type': 'string',
          'description': 'Absolute http(s) URL to fetch.',
        },
        'format': <String, dynamic>{
          'type': 'string',
          'enum': <String>['markdown', 'text', 'html'],
          'description':
              'markdown (default) for readable text, text for raw body '
              'characters, html for the raw source.',
        },
        'max_chars': <String, dynamic>{
          'type': 'integer',
          'minimum': 500,
          'maximum': 200000,
          'description': 'Output character cap (500-200000, default 20000).',
        },
      },
      'required': <String>['url'],
    },
    execute: (arguments) => _webFetch(http, arguments),
  ),
];

// ---------------------------------------------------------------------------
// Shared HTTP plumbing
// ---------------------------------------------------------------------------

/// A real browser user agent: DuckDuckGo and Mojeek answer unknown or absent
/// agents with a challenge page even when the IP is fine.
const _browserUserAgent =
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 '
    '(KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36';

const _htmlAccept =
    'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8';

const _defaultResults = 10;
const _maxResults = 20;
const _engineTimeout = Duration(seconds: 12);
const _searchDeadline = Duration(seconds: 25);
const _fetchTimeout = Duration(seconds: 20);
const _maxBodyBytes = 3 * 1024 * 1024;
const _defaultMaxChars = 20000;
const _minMaxChars = 500;
const _maxMaxChars = 200000;
const _snippetChars = 320;

/// One fetched body, already decoded and capped.
class _LocalHttpResponse {
  const _LocalHttpResponse({
    required this.status,
    required this.statusText,
    required this.url,
    required this.contentType,
    required this.text,
    required this.truncated,
  });

  final int status;
  final String statusText;
  final String url;
  final String contentType;
  final String text;

  /// True when the body hit [_maxBodyBytes] and the rest was discarded.
  final bool truncated;
}

/// A failed local request, reported as text rather than as an exception: an
/// unreachable host is an answer about the URL, not a defect of the tool.
class _LocalHttpFailure implements Exception {
  const _LocalHttpFailure(this.message, {this.timedOut = false});

  final String message;
  final bool timedOut;

  @override
  String toString() => message;
}

/// One bounded request, never throwing a [DioException].
///
/// The body is streamed and cut off at [_maxBodyBytes] so a huge or endless
/// response cannot exhaust memory. The injected client is bare: only the
/// per-request headers below (and no `Authorization`) reach the network.
Future<_LocalHttpResponse> _request(
  Dio http,
  String url, {
  required Duration timeout,
  String method = 'GET',
  Object? body,
  Map<String, String> headers = const {},
}) async {
  final cancelToken = CancelToken();
  final timeoutMessage = 'Timed out after ${timeout.inMilliseconds} ms';
  try {
    final pending = http.request<ResponseBody>(
      url,
      data: body,
      cancelToken: cancelToken,
      options: Options(
        method: method,
        responseType: ResponseType.stream,
        followRedirects: true,
        validateStatus: (_) => true,
        receiveTimeout: timeout,
        sendTimeout: timeout,
        headers: <String, String>{
          'User-Agent': _browserUserAgent,
          'Accept-Language': 'en-US,en;q=0.9',
          ...headers,
        },
      ),
    );
    final response = await _withTimeout(
      pending,
      timeout,
      () => cancelToken.cancel(timeoutMessage),
      timeoutMessage,
    );

    final stream = response.data?.stream;
    final bytes = BytesBuilder(copy: false);
    var size = 0;
    var truncated = false;
    if (stream != null) {
      await for (final chunk in stream) {
        if (chunk.isEmpty) continue;
        size += chunk.length;
        if (size > _maxBodyBytes) {
          bytes.add(chunk.sublist(0, chunk.length - (size - _maxBodyBytes)));
          truncated = true;
          break;
        }
        bytes.add(chunk);
      }
    }

    return _LocalHttpResponse(
      status: response.statusCode ?? 0,
      statusText: response.statusMessage ?? '',
      url: response.realUri.toString(),
      contentType: response.headers.value(Headers.contentTypeHeader) ?? '',
      text: utf8.decode(bytes.takeBytes(), allowMalformed: true),
      truncated: truncated,
    );
  } on _LocalHttpFailure {
    rethrow;
  } on DioException catch (error) {
    if (_isTimeout(error)) {
      throw _LocalHttpFailure(timeoutMessage, timedOut: true);
    }
    throw _LocalHttpFailure(_dioFailureMessage(error));
  } on Exception catch (error) {
    throw _LocalHttpFailure(error.toString());
  }
}

/// Awaits [future] but gives up after [timeout]; a late result is swallowed so
/// a slow adapter cannot surface an unhandled error once the deadline passed.
Future<T> _withTimeout<T>(
  Future<T> future,
  Duration timeout,
  void Function() onTimeout,
  String timeoutMessage,
) async {
  final completer = Completer<T>();
  final timer = Timer(timeout, () {
    onTimeout();
    if (!completer.isCompleted) {
      completer.completeError(
        _LocalHttpFailure(timeoutMessage, timedOut: true),
      );
    }
  });
  unawaited(
    future.then(
      (value) {
        if (!completer.isCompleted) completer.complete(value);
      },
      onError: (Object error, StackTrace stackTrace) {
        if (!completer.isCompleted) completer.completeError(error, stackTrace);
      },
    ),
  );
  try {
    return await completer.future;
  } finally {
    timer.cancel();
  }
}

bool _isTimeout(DioException error) =>
    error.type == DioExceptionType.cancel ||
    error.type == DioExceptionType.receiveTimeout ||
    error.type == DioExceptionType.sendTimeout ||
    error.type == DioExceptionType.connectionTimeout;

/// The most informative text dio kept for a failure: its message, the wrapped
/// cause (a `HandshakeException`, a `SocketException`, ...), or the type name.
String _dioFailureMessage(DioException error) {
  final message = error.message?.trim() ?? '';
  final cause = error.error?.toString().trim() ?? '';
  if (cause.isEmpty) return message.isEmpty ? error.type.name : message;
  if (message.isEmpty || message.contains(cause)) return cause;
  return '$message $cause';
}

// ---------------------------------------------------------------------------
// Text helpers
// ---------------------------------------------------------------------------

/// Entities seen in search snippets and page bodies; anything absent is left
/// as written rather than silently dropped.
const Map<String, String> _namedEntities = {
  'amp': '&',
  'lt': '<',
  'gt': '>',
  'quot': '"',
  'apos': "'",
  'nbsp': ' ',
  'ndash': '\u2013',
  'mdash': '\u2014',
  'hellip': '\u2026',
  'rsquo': '\u2019',
  'lsquo': '\u2018',
  'ldquo': '\u201c',
  'rdquo': '\u201d',
  'middot': '\u00b7',
  'ensp': ' ',
  'emsp': ' ',
  'thinsp': ' ',
  'copy': '\u00a9',
  'reg': '\u00ae',
  'trade': '\u2122',
  'bull': '\u2022',
  'deg': '\u00b0',
  'plusmn': '\u00b1',
  'frac12': '\u00bd',
  'divide': '\u00f7',
  'ne': '\u2260',
  'le': '\u2264',
  'ge': '\u2265',
  'szlig': '\u00df',
  'uuml': '\u00fc',
  'ouml': '\u00f6',
  'auml': '\u00e4',
  'times': '\u00d7',
  'laquo': '\u00ab',
  'raquo': '\u00bb',
  'eacute': '\u00e9',
  'egrave': '\u00e8',
};

final _numericEntityRe = RegExp(r'&#(x[0-9a-f]+|\d+);', caseSensitive: false);
final _namedEntityRe = RegExp(r'&([a-z]+);', caseSensitive: false);
final _tagRe = RegExp(r'<[^>]+>');
final _brTagRe = RegExp(r'<br\s*/?>', caseSensitive: false);
final _whitespaceRe = RegExp(r'\s+');
final _blankLinesRe = RegExp(r'\n{3,}');
final _trailingSpaceRe = RegExp(r'[ \t]+\n');
final _httpSchemeRe = RegExp(r'^https?$', caseSensitive: false);

String _decodeEntities(String? value) {
  final text = value ?? '';
  if (text.isEmpty) return '';
  return text
      .replaceAllMapped(_numericEntityRe, (match) {
        final digits = match.group(1)!;
        final hex = digits[0].toLowerCase() == 'x';
        final code = int.tryParse(
          hex ? digits.substring(1) : digits,
          radix: hex ? 16 : 10,
        );
        if (code == null || code < 0 || code > 0x10ffff) return '';
        return String.fromCharCode(code);
      })
      .replaceAllMapped(
        _namedEntityRe,
        (match) => _namedEntities[match.group(1)!.toLowerCase()] ?? match.group(0)!,
      )
      .replaceAll('&nbsp;', ' ');
}

/// Tags out, entities decoded, whitespace collapsed.
String _stripTags(String? html) {
  final text = html ?? '';
  if (text.isEmpty) return '';
  return _decodeEntities(text.replaceAll(_brTagRe, ' ').replaceAll(_tagRe, ' '))
      .replaceAll(_whitespaceRe, ' ')
      .trim();
}

/// Reads an attribute out of a raw tag body, tolerating unquoted values.
String? _attrOf(String tag, String name) {
  final match = RegExp(
    '(?:^|\\s)$name\\s*=\\s*("([^"]*)"|\'([^\']*)\'|([^\\s>]+))',
    caseSensitive: false,
  ).firstMatch(tag);
  if (match == null) return null;
  return _decodeEntities(
    match.group(2) ?? match.group(3) ?? match.group(4) ?? '',
  );
}

/// DuckDuckGo wraps result links in `//duckduckgo.com/l/?uddg=<target>`.
String? _unwrapRedirect(String? href) {
  if (href == null || href.isEmpty) return null;
  final match = RegExp(r'[?&]uddg=([^&]+)').firstMatch(href);
  if (match == null) return href;
  try {
    return Uri.decodeComponent(match.group(1)!);
  } on ArgumentError {
    return href;
  } on FormatException {
    return href;
  }
}

/// Resolves [href] against [base], rejecting anything that is not http(s).
String? _absoluteUrl(String? href, String base) {
  if (href == null || href.isEmpty) return null;
  try {
    final resolved = Uri.parse(base).resolve(href);
    if (!_httpSchemeRe.hasMatch(resolved.scheme)) return null;
    return resolved.toString();
  } on FormatException {
    return null;
  }
}

String _clip(String? value, int max) {
  final text = (value ?? '').replaceAll(_whitespaceRe, ' ').trim();
  return text.length > max ? '${text.substring(0, max - 1)}\u2026' : text;
}

String _firstMatch(String source, RegExp pattern) {
  final match = pattern.firstMatch(source);
  return match == null ? '' : (match.group(1) ?? '');
}

// ---------------------------------------------------------------------------
// Search engines (credential-free HTML/RSS frontends)
// ---------------------------------------------------------------------------

/// One search hit; [snippet] is already decoded and clipped.
class _SearchResult {
  const _SearchResult({
    required this.title,
    required this.url,
    required this.snippet,
  });

  final String title;
  final String url;
  final String snippet;
}

/// What every engine needs for one query.
class _SearchRequest {
  const _SearchRequest({
    required this.query,
    required this.limit,
    required this.recency,
    required this.timeout,
  });

  final String query;
  final int limit;

  /// One of `day`, `week`, `month`, `year`, or null.
  final String? recency;

  /// Wall clock left for this engine (already bounded by the chain deadline).
  final Duration timeout;
}

typedef _EngineRun = Future<List<_SearchResult>> Function(
  Dio http,
  _SearchRequest request,
);

/// One entry of the engine chain.
class _SearchEngine {
  const _SearchEngine({required this.label, required this.run});

  final String label;
  final _EngineRun run;
}

/// The query a chain run was launched for, plus what it found.
class _SearchOutcome {
  const _SearchOutcome({
    required this.provider,
    required this.results,
    required this.failures,
  });

  final String? provider;
  final List<_SearchResult> results;

  /// `"<Engine>: <reason>"` for every engine that did not win.
  final List<String> failures;
}

/// `day`/`week`/`month`/`year`, the only recency values the tools accept.
const List<String> _recencyValues = ['day', 'week', 'month', 'year'];

/// Frontend-specific `df` codes for the relative time filter.
const Map<String, String> _recencyCodes = {
  'day': 'd',
  'week': 'w',
  'month': 'm',
  'year': 'y',
};

/// Anchors of the given class, paired with whatever follows them up to the
/// next result anchor.
List<({String attrs, String inner, String rest})> _scanResults(
  String html,
  String classPattern,
) {
  final pattern = RegExp(
    '<a\\s([^>]*class\\s*=\\s*["\'][^"\']*$classPattern[^"\']*["\'][^>]*)>'
    '([\\s\\S]*?)</a>([\\s\\S]*?)(?=<a\\s[^>]*class\\s*=\\s*["\'][^"\']*$classPattern|\$)',
    caseSensitive: false,
  );
  return [
    for (final match in pattern.allMatches(html))
      (attrs: match.group(1)!, inner: match.group(2)!, rest: match.group(3)!),
  ];
}

final _challengeRe = RegExp(
  r'anomaly-modal|anomaly\.js|challenge-form|altcha|unusual traffic|are you a robot|cf-challenge',
  caseSensitive: false,
);

bool _looksChallenged(String html) => _challengeRe.hasMatch(html);

final _ddgSnippetRe = RegExp(
  r"""<a\s[^>]*class\s*=\s*["'][^"']*result__snippet[^"']*["'][^>]*>([\s\S]*?)</a>""",
  caseSensitive: false,
);
final _ddgLiteSnippetRe = RegExp(
  r"""<td[^>]*class\s*=\s*["'][^"']*result-snippet[^"']*["'][^>]*>([\s\S]*?)</td>""",
  caseSensitive: false,
);
final _ddgResultRe = RegExp(r'result__a', caseSensitive: false);

/// `html.duckduckgo.com` and `lite.duckduckgo.com` share a result shape.
List<_SearchResult> _parseDuckDuckGo(String html) {
  final results = <_SearchResult>[];
  for (final anchor in _scanResults(html, '(?:result__a|result-link)')) {
    final url = _absoluteUrl(
      _unwrapRedirect(_attrOf(anchor.attrs, 'href')),
      'https://duckduckgo.com',
    );
    final title = _stripTags(anchor.inner);
    if (url == null || title.isEmpty) continue;
    final snippet = _firstMatch(anchor.rest, _ddgSnippetRe);
    final text = snippet.isNotEmpty
        ? snippet
        : _firstMatch(anchor.rest, _ddgLiteSnippetRe);
    results.add(
      _SearchResult(title: title, url: url, snippet: _clip(_stripTags(text), _snippetChars)),
    );
  }
  return results;
}

final _bingBlockRe = RegExp(
  r'<li class="b_algo"[\s\S]*?(?=<li class="b_algo"|</ol>|$)',
  caseSensitive: false,
);
final _bingAnchorRe = RegExp(
  r'<h2[^>]*>\s*<a\s([^>]*)>([\s\S]*?)</a>',
  caseSensitive: false,
);
final _bingParagraphRe = RegExp(r'<p[^>]*>([\s\S]*?)</p>', caseSensitive: false);
final _bingMarkupRe = RegExp(r'class="b_algo"');
final _bingChallengeRe = RegExp(
  r'captcha|unusual traffic|verify you are human',
  caseSensitive: false,
);

List<_SearchResult> _parseBingHtml(String html) {
  final results = <_SearchResult>[];
  for (final block in _bingBlockRe.allMatches(html)) {
    final anchor = _bingAnchorRe.firstMatch(block.group(0)!);
    if (anchor == null) continue;
    final url = _absoluteUrl(_attrOf(anchor.group(1)!, 'href'), 'https://www.bing.com');
    final title = _stripTags(anchor.group(2));
    if (url == null || title.isEmpty) continue;
    final snippet = _firstMatch(block.group(0)!, _bingParagraphRe);
    results.add(
      _SearchResult(title: title, url: url, snippet: _clip(_stripTags(snippet), _snippetChars)),
    );
  }
  return results;
}

final _rssItemRe = RegExp(r'<item>[\s\S]*?</item>', caseSensitive: false);
final _rssLinkRe = RegExp(r'<link>([\s\S]*?)</link>', caseSensitive: false);
final _rssTitleRe = RegExp(r'<title>([\s\S]*?)</title>', caseSensitive: false);
final _rssDescriptionRe = RegExp(r'<description>([\s\S]*?)</description>', caseSensitive: false);
final _rssRootRe = RegExp(r'<rss', caseSensitive: false);

List<_SearchResult> _parseBingRss(String xml) {
  final results = <_SearchResult>[];
  for (final item in _rssItemRe.allMatches(xml)) {
    final block = item.group(0)!;
    final url = _stripTags(_firstMatch(block, _rssLinkRe));
    final title = _stripTags(_firstMatch(block, _rssTitleRe));
    final snippet = _stripTags(_firstMatch(block, _rssDescriptionRe));
    if (url.isEmpty || !_isHttpUrl(url) || title.isEmpty) continue;
    results.add(
      _SearchResult(title: title, url: url, snippet: _clip(snippet, _snippetChars)),
    );
  }
  return results;
}

final _mojeekSnippetRe = RegExp(
  r"""<p[^>]*class\s*=\s*["'][^"']*\bs\b[^"']*["'][^>]*>([\s\S]*?)</p>""",
  caseSensitive: false,
);

List<_SearchResult> _parseMojeek(String html) {
  final results = <_SearchResult>[];
  for (final anchor in _scanResults(html, r'\bob\b')) {
    final url = _absoluteUrl(_attrOf(anchor.attrs, 'href'), 'https://www.mojeek.com');
    final title = _stripTags(anchor.inner);
    if (url == null || title.isEmpty) continue;
    final snippet = _firstMatch(anchor.rest, _mojeekSnippetRe);
    results.add(
      _SearchResult(title: title, url: url, snippet: _clip(_stripTags(snippet), _snippetChars)),
    );
  }
  return results;
}

/// Guards the engines' `title`/`url` extraction: a parsed URL must be http(s).
bool _isHttpUrl(String url) {
  try {
    return _httpSchemeRe.hasMatch(Uri.parse(url).scheme);
  } on FormatException {
    return false;
  }
}

Future<List<_SearchResult>> _runBingHtml(Dio http, _SearchRequest request) async {
  final url =
      'https://www.bing.com/search?q=${Uri.encodeComponent(request.query)}'
      '&count=${request.limit}&setlang=en';
  final response = await _request(
    http,
    url,
    timeout: request.timeout,
    headers: {'Accept': _htmlAccept},
  );
  if (response.status >= 400) {
    throw _LocalHttpFailure(_httpStatusLine(response));
  }
  final parsed = _parseBingHtml(response.text).take(request.limit).toList();
  if (parsed.isEmpty && !_bingMarkupRe.hasMatch(response.text)) {
    throw _LocalHttpFailure(
      _bingChallengeRe.hasMatch(response.text) ? 'bot challenge' : 'no results markup',
    );
  }
  return parsed;
}

Future<List<_SearchResult>> _runDuckDuckGo(Dio http, _SearchRequest request) async {
  final response = await _request(
    http,
    'https://html.duckduckgo.com/html/',
    method: 'POST',
    body: _formBody({'q': request.query, 'kl': 'us-en'}, _recencyCodes[request.recency]),
    timeout: request.timeout,
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Accept': _htmlAccept,
    },
  );
  if (response.status >= 400) {
    throw _LocalHttpFailure(_httpStatusLine(response));
  }
  if (_looksChallenged(response.text) && !_ddgResultRe.hasMatch(response.text)) {
    throw _LocalHttpFailure('bot challenge');
  }
  return _parseDuckDuckGo(response.text).take(request.limit).toList();
}

Future<List<_SearchResult>> _runDuckDuckGoLite(Dio http, _SearchRequest request) async {
  final response = await _request(
    http,
    'https://lite.duckduckgo.com/lite/',
    method: 'POST',
    body: _formBody({'q': request.query}, _recencyCodes[request.recency]),
    timeout: request.timeout,
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Accept': _htmlAccept,
    },
  );
  if (response.status >= 400) {
    throw _LocalHttpFailure(_httpStatusLine(response));
  }
  final parsed = _parseDuckDuckGo(response.text).take(request.limit).toList();
  if (parsed.isEmpty && _looksChallenged(response.text)) {
    throw _LocalHttpFailure('bot challenge');
  }
  return parsed;
}

Future<List<_SearchResult>> _runBingRss(Dio http, _SearchRequest request) async {
  final url =
      'https://www.bing.com/search?q=${Uri.encodeComponent(request.query)}'
      '&format=rss&count=${request.limit}';
  final response = await _request(
    http,
    url,
    timeout: request.timeout,
    headers: {'Accept': 'application/rss+xml,application/xml,text/xml,*/*'},
  );
  if (response.status >= 400) {
    throw _LocalHttpFailure(_httpStatusLine(response));
  }
  final parsed = _parseBingRss(response.text).take(request.limit).toList();
  if (parsed.isEmpty && !_rssRootRe.hasMatch(response.text)) {
    throw _LocalHttpFailure('bot challenge');
  }
  return parsed;
}

Future<List<_SearchResult>> _runMojeek(Dio http, _SearchRequest request) async {
  final since = request.recency != null && _recencyValues.contains(request.recency)
      ? request.recency
      : null;
  final url =
      'https://www.mojeek.com/search?q=${Uri.encodeComponent(request.query)}'
      '${since == null ? '' : '&since=$since'}';
  final response = await _request(
    http,
    url,
    timeout: request.timeout,
    headers: {'Accept': _htmlAccept},
  );
  if (response.status >= 400) {
    throw _LocalHttpFailure(_httpStatusLine(response));
  }
  final parsed = _parseMojeek(response.text).take(request.limit).toList();
  if (parsed.isEmpty && _looksChallenged(response.text)) {
    throw _LocalHttpFailure('bot challenge');
  }
  return parsed;
}

String _httpStatusLine(_LocalHttpResponse response) => response.statusText.isEmpty
    ? 'HTTP ${response.status}'
    : 'HTTP ${response.status} ${response.statusText}';

/// `application/x-www-form-urlencoded` body for the DuckDuckGo POSTs.
String _formBody(Map<String, String> fields, String? recencyCode) {
  final form = <String, String>{
    ...fields,
    'df': ?recencyCode,
  };
  return form.entries
      .map(
        (entry) =>
            '${Uri.encodeQueryComponent(entry.key)}=${Uri.encodeQueryComponent(entry.value)}',
      )
      .join('&');
}

/// Drop repeats, normalizing away the fragment and a trailing slash so the
/// same page reached through two engines appears once.
List<_SearchResult> _dedupe(List<_SearchResult> results) {
  final seen = <String>{};
  final out = <_SearchResult>[];
  for (final result in results) {
    var key = result.url;
    try {
      key = Uri.parse(result.url).toString();
    } on FormatException {
      // Unparseable URL: dedupe on the raw string.
    }
    final fragment = key.indexOf('#');
    if (fragment >= 0) key = key.substring(0, fragment);
    if (key.endsWith('/')) key = key.substring(0, key.length - 1);
    if (!seen.add(key)) continue;
    out.add(result);
  }
  return out;
}

final _operatorRe = RegExp(
  r'\b(site|filetype|inurl|intitle|after|before):\S+',
  caseSensitive: false,
);
final _termSplitRe = RegExp(r'[^0-9A-Za-z\u00c0-\u024f\u4e00-\u9fff]+');

/// Terms a result must mention to count as a match. Engines (Bing especially)
/// answer a query with no matches by returning pages about its most popular
/// token, so a strict query like `zzzqxxq nosuchterm` would otherwise look
/// successful. Operator operands are dropped first; CJK stays one token.
List<String> _significantTerms(String query) {
  final stripped = query.replaceAll(_operatorRe, ' ');
  final terms = <String>{};
  for (final term in stripped.split(_termSplitRe)) {
    final lowered = term.toLowerCase();
    if (lowered.length >= 3) terms.add(lowered);
  }
  final sorted = terms.toList()..sort((left, right) => right.length.compareTo(left.length));
  return sorted.take(4).toList();
}

List<_SearchResult> _filterRelevant(List<_SearchResult> results, String query) {
  final terms = _significantTerms(query);
  if (terms.isEmpty) return results;
  return [
    for (final result in results)
      if (terms.any(
        (term) => '${result.title} ${result.snippet}'.toLowerCase().contains(term),
      ))
        result,
  ];
}

/// Runs the engine chain under one overall deadline, returning the first
/// engine that yields results. An engine whose hits are all irrelevant counts
/// as a failure, so the chain keeps going instead of trusting a junk page.
Future<_SearchOutcome> _localSearch(
  Dio http,
  String query, {
  required int limit,
  String? recency,
}) async {
  final stopwatch = Stopwatch()..start();
  final failures = <String>[];
  for (final engine in _engines) {
    final remaining = _searchDeadline - stopwatch.elapsed;
    if (remaining <= Duration.zero) break;
    final timeout = remaining < _engineTimeout ? remaining : _engineTimeout;
    try {
      final request = _SearchRequest(
        query: query,
        limit: limit,
        recency: recency,
        timeout: timeout,
      );
      final results = _filterRelevant(
        _dedupe(await engine.run(http, request)),
        query,
      );
      if (results.isNotEmpty) {
        return _SearchOutcome(
          provider: engine.label,
          results: results,
          failures: failures,
        );
      }
      failures.add('${engine.label}: no results');
    } catch (error) {
      failures.add('${engine.label}: $error');
    }
  }
  return _SearchOutcome(provider: null, results: const [], failures: failures);
}

/// The chain, in the order engines are tried.
final List<_SearchEngine> _engines = [
  const _SearchEngine(label: 'Bing', run: _runBingHtml),
  const _SearchEngine(label: 'DuckDuckGo', run: _runDuckDuckGo),
  const _SearchEngine(label: 'DuckDuckGo Lite', run: _runDuckDuckGoLite),
  const _SearchEngine(label: 'Bing RSS', run: _runBingRss),
  const _SearchEngine(label: 'Mojeek', run: _runMojeek),
];

String _formatResults(String provider, List<_SearchResult> results) {
  final lines = <String>[
    'Local search via $provider \u2014 ${results.length} result(s)',
    '',
  ];
  for (var index = 0; index < results.length; index++) {
    final result = results[index];
    lines.add('[${index + 1}] ${result.title}');
    lines.add('    ${result.url}');
    if (result.snippet.isNotEmpty) lines.add('    ${result.snippet}');
    lines.add('');
  }
  return lines.join('\n').trimRight();
}

// ---------------------------------------------------------------------------
// HTML -> markdown (for web_fetch)
// ---------------------------------------------------------------------------

final _anchorRe = RegExp(r'<a\s([^>]*)>([\s\S]*?)</a>', caseSensitive: false);
final _boldRe = RegExp(r'<(strong|b)\b[^>]*>([\s\S]*?)</\1>', caseSensitive: false);
final _italicRe = RegExp(r'<(em|i)\b[^>]*>([\s\S]*?)</\1>', caseSensitive: false);
final _inlineCodeRe = RegExp(r'<code\b[^>]*>([\s\S]*?)</code>', caseSensitive: false);

String _inlineMarkdown(String html, String base) {
  if (html.isEmpty) return '';
  final replaced = html
      .replaceAllMapped(_anchorRe, (match) {
        final text = _stripTags(match.group(2));
        final href = _absoluteUrl(_attrOf(match.group(1)!, 'href'), base);
        if (href == null || text.isEmpty) return text;
        return '[$text]($href)';
      })
      .replaceAllMapped(_boldRe, (match) => '**${_stripTags(match.group(2))}**')
      .replaceAllMapped(_italicRe, (match) => '*${_stripTags(match.group(2))}*')
      .replaceAllMapped(_inlineCodeRe, (match) => '`${_stripTags(match.group(1))}`')
      .replaceAll(_tagRe, ' ');
  return _decodeEntities(replaced).replaceAll(_whitespaceRe, ' ').trim();
}

final _titleRe = RegExp(r'<title[^>]*>([\s\S]*?)</title>', caseSensitive: false);
final _metaDescriptionRe = RegExp(
  r'''<meta[^>]+name\s*=\s*["']description["'][^>]*content\s*=\s*["']([^"']*)["']''',
  caseSensitive: false,
);
final _metaOgDescriptionRe = RegExp(
  r'''<meta[^>]+property\s*=\s*["']og:description["'][^>]*content\s*=\s*["']([^"']*)["']''',
  caseSensitive: false,
);
final _commentRe = RegExp(r'<!--[\s\S]*?-->');
final _droppedElementRe = RegExp(
  r'<(script|style|noscript|template|svg|canvas|iframe|head|form|select)[^>]*>[\s\S]*?</\1>',
  caseSensitive: false,
);
final _preRe = RegExp(r'<pre[^>]*>([\s\S]*?)</pre>', caseSensitive: false);
final _headingRe = RegExp(r'<h([1-6])[^>]*>([\s\S]*?)</h\1>', caseSensitive: false);
final _listItemRe = RegExp(r'<li[^>]*>([\s\S]*?)</li>', caseSensitive: false);
final _blockquoteRe = RegExp(
  r'<blockquote[^>]*>([\s\S]*?)</blockquote>',
  caseSensitive: false,
);
final _blockEndRe = RegExp(
  r'</(p|div|section|article|main|header|tr|ul|ol|table|dl|dd|dt|h[1-6])>',
  caseSensitive: false,
);
final _cellRe = RegExp(r'<(td|th)[^>]*>', caseSensitive: false);
final _inlineTagRe = RegExp(r'<(a|strong|b|em|i|code)\b', caseSensitive: false);

/// Readable markdown from a page: headings, lists, links, and code kept.
({String title, String description, String markdown}) _htmlToMarkdown(
  String html,
  String base,
) {
  final title = _stripTags(_titleRe.firstMatch(html)?.group(1));
  final description = _decodeEntities(
    (_metaDescriptionRe.firstMatch(html) ?? _metaOgDescriptionRe.firstMatch(html))
        ?.group(1),
  ).trim();

  var body = html
      .replaceAll(_commentRe, ' ')
      .replaceAll(_droppedElementRe, ' ')
      .replaceAllMapped(_preRe, (match) {
        final text = _decodeEntities(match.group(1)!.replaceAll(_tagRe, ''))
            .replaceAll(_blankLinesRe, '\n\n')
            .trim();
        return '\n\n```\n$text\n```\n\n';
      })
      .replaceAllMapped(
        _headingRe,
        (match) =>
            '\n\n${'#' * int.parse(match.group(1)!)} ${_inlineMarkdown(match.group(2)!, base)}\n\n',
      )
      .replaceAllMapped(
        _listItemRe,
        (match) => '\n- ${_inlineMarkdown(match.group(1)!, base)}',
      )
      .replaceAllMapped(
        _blockquoteRe,
        (match) => '\n\n> ${_inlineMarkdown(match.group(1)!, base)}\n\n',
      )
      .replaceAll(_brTagRe, '\n')
      .replaceAll(_blockEndRe, '\n\n')
      .replaceAll(_cellRe, ' | ');

  final inlined = _inlineTagRe.hasMatch(body)
      ? body
            .split('\n')
            .map(
              (line) => line.contains('<')
                  ? _inlineMarkdown(line, base)
                  : _decodeEntities(line),
            )
            .join('\n')
      : _decodeEntities(body.replaceAll(_tagRe, ''));
  body = inlined
      .replaceAll(_trailingSpaceRe, '\n')
      .replaceAll(_blankLinesRe, '\n\n')
      .trim();

  return (title: title, description: description, markdown: body);
}

// ---------------------------------------------------------------------------
// Tool bodies
// ---------------------------------------------------------------------------

/// Reads an integer argument clamped into `[min, max]`, falling back to
/// [fallback] when absent or unusable.
int _boundedInt(Object? value, int fallback, int min, int max) {
  final requested = value is num && value.isFinite ? value.truncate() : fallback;
  if (requested < min) return min;
  if (requested > max) return max;
  return requested;
}

Future<String> _webSearch(Dio http, Map<String, dynamic> arguments) async {
  final rawQuery = arguments['query'];
  final query = rawQuery is String ? rawQuery.trim() : '';
  if (query.isEmpty) return 'Error: `query` is required.';

  final requested = arguments['num_search_results'] ?? arguments['limit'];
  final limit = requested is num && requested.isFinite && requested > 0
      ? _boundedInt(requested, _defaultResults, 1, _maxResults)
      : _defaultResults;
  final rawRecency = arguments['recency'];
  final recencyText = rawRecency is String ? rawRecency.trim().toLowerCase() : '';
  final recency = _recencyValues.contains(recencyText) ? recencyText : null;

  final outcome = await _localSearch(http, query, limit: limit, recency: recency);
  if (outcome.results.isNotEmpty) {
    return _formatResults(outcome.provider!, outcome.results);
  }
  final detail = outcome.failures.map((failure) => '- $failure').join('\n');
  return 'Error: no local search engine returned results for "$query".\n$detail';
}

final _certificateRe = RegExp(r'certificate', caseSensitive: false);
final _fetchFormats = const <String>['markdown', 'text', 'html'];

Future<String> _webFetch(Dio http, Map<String, dynamic> arguments) async {
  final rawUrl = arguments['url'];
  final target = rawUrl is String ? rawUrl.trim() : '';
  final parsed = Uri.tryParse(target);
  if (parsed == null ||
      !_httpSchemeRe.hasMatch(parsed.scheme) ||
      parsed.host.isEmpty) {
    return 'Error: `url` must be an absolute http(s) URL.';
  }

  final rawFormat = arguments['format'];
  final requestedFormat = rawFormat is String
      ? rawFormat.trim().toLowerCase()
      : 'markdown';
  final format = _fetchFormats.contains(requestedFormat)
      ? requestedFormat
      : 'markdown';
  final maxChars = _boundedInt(
    arguments['max_chars'],
    _defaultMaxChars,
    _minMaxChars,
    _maxMaxChars,
  );

  final _LocalHttpResponse response;
  try {
    response = await _request(
      http,
      parsed.toString(),
      timeout: _fetchTimeout,
      headers: {
        'Accept': 'text/html,application/json,text/plain,application/xml,*/*',
      },
    );
  } on _LocalHttpFailure catch (failure) {
    final message = failure.message;
    final hint = _certificateRe.hasMatch(message)
        ? " The site's TLS certificate is not trusted by this machine."
        : failure.timedOut
        ? ' No response within ${_fetchTimeout.inSeconds}s.'
        : '';
    return 'Error: could not fetch ${parsed.toString()} \u2014 $message.$hint';
  }

  final contentType = response.contentType.split(';').first.trim().toLowerCase();
  final isHtml =
      contentType.contains('html') ||
      contentType.contains('xml') ||
      contentType.isEmpty;
  final isJson = contentType.contains('json');
  final isText =
      contentType.startsWith('text/') ||
      contentType.contains('javascript') ||
      contentType.contains('yaml') ||
      contentType.contains('csv');

  var body = '';
  var note = '';

  if (format == 'html') {
    body = response.text;
  } else if (isJson) {
    try {
      body = const JsonEncoder.withIndent('  ').convert(jsonDecode(response.text));
    } on FormatException {
      body = response.text;
      note = ' (unparsed JSON)';
    }
  } else if (isHtml && format == 'markdown') {
    final converted = _htmlToMarkdown(response.text, response.url);
    // Pages usually render their own <h1> from the same <title>: only prepend
    // a heading the body does not already carry.
    final alreadyTitled =
        converted.title.isNotEmpty &&
        converted.markdown.toLowerCase().contains(
          converted.title.toLowerCase(),
        );
    final header = [
      if (converted.title.isNotEmpty && !alreadyTitled) '# ${converted.title}',
      if (converted.description.isNotEmpty) converted.description,
    ].join('\n\n');
    body = [if (header.isNotEmpty) header, if (converted.markdown.isNotEmpty) converted.markdown].join('\n\n');
  } else if (isHtml || isText) {
    body = isHtml ? _stripTags(response.text) : response.text;
  } else {
    return 'Fetched ${response.url} '
        '(HTTP ${response.status} ${response.statusText}).\n'
        'Content-Type ${contentType.isEmpty ? 'unknown' : contentType} is not '
        'readable text; ${response.text.length} character(s) received and '
        'discarded.';
  }

  final truncated = body.length > maxChars;
  final text = truncated ? body.substring(0, maxChars) : body;
  final header = [
    'URL: ${response.url}',
    'HTTP ${response.status}${response.statusText.isEmpty ? '' : ' ${response.statusText}'}',
    if (contentType.isNotEmpty) 'Content-Type: $contentType$note',
    if (truncated) 'Truncated to $maxChars characters.',
    if (response.truncated) 'Response body was cut off at the size limit.',
  ];
  return '${header.join('\n')}\n\n$text'.trimRight();
}
