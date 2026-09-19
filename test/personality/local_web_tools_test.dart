import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island/personality/local_web_tools.dart';

/// One canned HTTP response.
class _StubResponse {
  const _StubResponse(
    this.body, {
    this.status = 200,
    this.statusMessage = 'OK',
    this.contentType = 'text/html; charset=utf-8',
  });

  final String body;
  final int status;
  final String statusMessage;
  final String contentType;
}

/// Serves canned responses and records every request the tools made, so the
/// tests can assert on the wire (URL, method, body, headers) as well as on the
/// text handed back to the model.
class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.respond);

  final _StubResponse Function(RequestOptions options) respond;
  final List<RequestOptions> requests = [];

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final response = respond(options);
    return ResponseBody.fromString(
      response.body,
      response.status,
      statusMessage: response.statusMessage,
      headers: {
        Headers.contentTypeHeader: [response.contentType],
      },
    );
  }
}

/// A transport that always fails, standing in for a dead host or a TLS
/// handshake the machine refuses.
class _ThrowingAdapter implements HttpClientAdapter {
  _ThrowingAdapter(this.error);

  final Object error;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => throw error;
}

SnLocalTool _tool(List<SnLocalTool> tools, String name) =>
    tools.firstWhere((tool) => tool.name == name);

const _bingChallengeHtml =
    '<html><body>We detected unusual traffic from your network. '
    'Please verify you are human.<form id="challenge-form"></form></body></html>';

const _duckDuckGoResultHtml =
    '<div class="result results_links">'
    '<a rel="nofollow" class="result__a" '
    'href="//duckduckgo.com/l/?uddg=https%3A%2F%2Fexample.org%2Fsolian-pets">'
    'Solian pets guide</a>'
    '<a class="result__snippet" href="https://example.org/solian-pets">'
    'Everything about Solian pets.</a>'
    '</div>';

void main() {
  group('web_search_local', () {
    test('parses Bing HTML into the documented result list', () async {
      final adapter = _StubAdapter(
        (_) => const _StubResponse(
          '<html><body><ol>'
          '<li class="b_algo"><h2><a href="https://example.com/pets">'
          'Solian pets &amp; friends</a></h2>'
          '<p>Solian is the home for pets &hellip; and more.</p></li>'
          '<li class="b_algo"><h2><a href="https://example.com/other#top">'
          'Another pets page</a></h2><p>All pets, everywhere.</p></li>'
          '<li class="b_algo"><h2><a href="https://example.com/third">'
          'Third pets item</a></h2><p>Third snippet.</p></li>'
          '<li class="b_algo"><h2><a href="https://example.com/fourth">'
          'Fourth pets item</a></h2><p>Fourth snippet.</p></li>'
          '</ol></body></html>',
        ),
      );
      final dio = Dio()..httpClientAdapter = adapter;
      final search = _tool(buildLocalWebTools(dio), 'web_search_local');

      final text = await search.execute({'query': 'solian pets', 'limit': 3});

      expect(
        text,
        'Local search via Bing — 3 result(s)\n'
        '\n'
        '[1] Solian pets & friends\n'
        '    https://example.com/pets\n'
        '    Solian is the home for pets … and more.\n'
        '\n'
        '[2] Another pets page\n'
        '    https://example.com/other#top\n'
        '    All pets, everywhere.\n'
        '\n'
        '[3] Third pets item\n'
        '    https://example.com/third\n'
        '    Third snippet.',
      );

      // The request is a browser-shaped, credential-free GET of the engine URL.
      final request = adapter.requests.single;
      expect(request.method, 'GET');
      expect(request.uri.host, 'www.bing.com');
      expect(request.uri.queryParameters['q'], 'solian pets');
      expect(request.uri.queryParameters['count'], '3');
      expect(request.uri.queryParameters['setlang'], 'en');
      expect(request.headers['User-Agent'], startsWith('Mozilla/5.0'));
      expect(request.headers['Accept-Language'], 'en-US,en;q=0.9');
      expect(request.headers.containsKey('Authorization'), isFalse);
    });

    test('falls through a challenge page to the next engine', () async {
      final adapter = _StubAdapter((options) {
        if (options.uri.host == 'www.bing.com') {
          return const _StubResponse(_bingChallengeHtml);
        }
        if (options.uri.host == 'html.duckduckgo.com') {
          return const _StubResponse(_duckDuckGoResultHtml);
        }
        return const _StubResponse('', status: 404, statusMessage: 'Not Found');
      });
      final dio = Dio()..httpClientAdapter = adapter;
      final search = _tool(buildLocalWebTools(dio), 'web_search_local');

      final text = await search.execute({
        'query': 'solian pets',
        'recency': 'week',
      });

      expect(
        text,
        'Local search via DuckDuckGo — 1 result(s)\n'
        '\n'
        '[1] Solian pets guide\n'
        '    https://example.org/solian-pets\n'
        '    Everything about Solian pets.',
      );

      expect(adapter.requests.length, 2);
      final post = adapter.requests[1];
      expect(post.method, 'POST');
      expect(post.uri.host, 'html.duckduckgo.com');
      expect(post.data, 'q=solian+pets&kl=us-en&df=w');
    });

    test('rejects results that mention none of the query terms', () async {
      final adapter = _StubAdapter((options) {
        final uri = options.uri;
        if (uri.host == 'www.bing.com' && uri.queryParameters.containsKey('format')) {
          return const _StubResponse(
            '<rss version="2.0"><channel><item><title>Weather today</title>'
            '<link>https://example.com/weather</link>'
            '<description>Sunny spells.</description></item></channel></rss>',
            contentType: 'application/xml',
          );
        }
        if (uri.host == 'www.bing.com') {
          return const _StubResponse(
            '<ol><li class="b_algo"><h2>'
            '<a href="https://example.com/w">Weather today</a></h2>'
            '<p>Sunny spells.</p></li></ol>',
          );
        }
        if (uri.host == 'www.mojeek.com') {
          return const _StubResponse(
            '<ul><li><a class="ob" href="https://example.com/m">Weather today</a>'
            '</li><p class="s">Sunny spells.</p></ul>',
          );
        }
        return const _StubResponse(
          '<div><a class="result__a" href="https://example.com/d">Weather today'
          '</a><a class="result__snippet">Sunny spells.</a></div>',
        );
      });
      final dio = Dio()..httpClientAdapter = adapter;
      final search = _tool(buildLocalWebTools(dio), 'web_search_local');

      final text = await search.execute({
        'query': 'zzzqxxq nosuchterm',
        'num_search_results': 2,
      });

      // Every engine answered, every answer was off-topic, so the chain
      // reports each one instead of returning junk as a hit.
      expect(
        text,
        'Error: no local search engine returned results for "zzzqxxq nosuchterm".\n'
        '- Bing: no results\n'
        '- DuckDuckGo: no results\n'
        '- DuckDuckGo Lite: no results\n'
        '- Bing RSS: no results\n'
        '- Mojeek: no results',
      );
      expect(adapter.requests.length, 5);
      expect(adapter.requests.first.uri.queryParameters['count'], '2');
    });

    test('decodes entities and clips long snippets', () async {
      final adapter = _StubAdapter(
        (_) => _StubResponse(
          '<ol><li class="b_algo"><h2>'
          '<a href="https://example.com/cafe">Solian&nbsp;pets &amp; more</a>'
          '</h2><p>solian caf&#233; &amp; bar ${'y' * 400}</p></li></ol>',
        ),
      );
      final dio = Dio()..httpClientAdapter = adapter;
      final search = _tool(buildLocalWebTools(dio), 'web_search_local');

      final text = await search.execute({'query': 'solian'});

      final snippet = 'solian café & bar ${'y' * 301}\u2026';
      expect(snippet.length, 320);
      expect(text, contains('[1] Solian pets & more\n'));
      expect(text, contains('    $snippet'));
    });

    test('requires a query', () async {
      final dio = Dio()..httpClientAdapter = _StubAdapter((_) => const _StubResponse(''));
      final search = _tool(buildLocalWebTools(dio), 'web_search_local');

      expect(await search.execute({}), 'Error: `query` is required.');
      expect(await search.execute({'query': '   '}), 'Error: `query` is required.');
    });
  });

  group('web_fetch_local', () {
    test('converts HTML to markdown with absolute links', () async {
      const html =
          '<html><head><title>Solian Pets</title>'
          '<meta name="description" content="All about Solian pets"></head>'
          '<body><h1>Solian Pets</h1>'
          '<p>Read the <a href="/guide">guide</a> and <strong>enjoy</strong> '
          '<code>pets</code>.</p>'
          '<ul><li>One</li><li>Two</li></ul>'
          '<pre>code line</pre></body></html>';
      final adapter = _StubAdapter((_) => const _StubResponse(html));
      final dio = Dio()..httpClientAdapter = adapter;
      final fetch = _tool(buildLocalWebTools(dio), 'web_fetch_local');

      final text = await fetch.execute({
        'url': 'https://example.com/docs/page.html',
      });

      expect(text.split('\n').take(3).toList(), [
        'URL: https://example.com/docs/page.html',
        'HTTP 200 OK',
        'Content-Type: text/html',
      ]);
      expect(text, contains('All about Solian pets\n\n# Solian Pets\n\n'));
      expect(
        text,
        contains('Read the [guide](https://example.com/guide) and '
            '**enjoy** `pets`.'),
      );
      expect(text, contains('\n- One\n- Two\n'));
      expect(text, contains('```\ncode line\n```'));
      expect(text.contains('<'), isFalse);
    });

    test('pretty-prints JSON', () async {
      final adapter = _StubAdapter(
        (_) => const _StubResponse(
          '{"a":1,"b":[true,null]}',
          contentType: 'application/json; charset=utf-8',
        ),
      );
      final dio = Dio()..httpClientAdapter = adapter;
      final fetch = _tool(buildLocalWebTools(dio), 'web_fetch_local');

      final text = await fetch.execute({'url': 'https://api.example.com/data'});

      expect(text, contains('Content-Type: application/json'));
      expect(
        text,
        endsWith('{\n  "a": 1,\n  "b": [\n    true,\n    null\n  ]\n}'),
      );
    });

    test('returns the raw source for format html', () async {
      final adapter = _StubAdapter(
        (_) => const _StubResponse('<html><body>hi</body></html>'),
      );
      final dio = Dio()..httpClientAdapter = adapter;
      final fetch = _tool(buildLocalWebTools(dio), 'web_fetch_local');

      final text = await fetch.execute({
        'url': 'https://example.com/',
        'format': 'html',
      });

      expect(text, endsWith('<html><body>hi</body></html>'));
    });

    test('describes non-text content instead of dumping it', () async {
      final adapter = _StubAdapter(
        (_) => const _StubResponse('PNGBYTES', contentType: 'image/png'),
      );
      final dio = Dio()..httpClientAdapter = adapter;
      final fetch = _tool(buildLocalWebTools(dio), 'web_fetch_local');

      final text = await fetch.execute({'url': 'https://example.com/i.png'});

      expect(text, contains('Content-Type image/png is not readable text;'));
      expect(text, contains('8 character(s) received and discarded.'));
    });

    test('refuses non-http(s) and relative URLs', () async {
      final adapter = _StubAdapter((_) => const _StubResponse(''));
      final dio = Dio()..httpClientAdapter = adapter;
      final fetch = _tool(buildLocalWebTools(dio), 'web_fetch_local');

      const error = 'Error: `url` must be an absolute http(s) URL.';
      expect(await fetch.execute({'url': 'file:///etc/passwd'}), error);
      expect(await fetch.execute({'url': '/relative/path'}), error);
      expect(await fetch.execute({'url': 'ftp://example.com/x'}), error);
      expect(await fetch.execute({}), error);
      expect(adapter.requests, isEmpty);
    });

    test('truncates the body to max_chars, clamped to 500', () async {
      final adapter = _StubAdapter(
        (_) => _StubResponse('<p>${'a' * 2000}</p>'),
      );
      final dio = Dio()..httpClientAdapter = adapter;
      final fetch = _tool(buildLocalWebTools(dio), 'web_fetch_local');

      final text = await fetch.execute({
        'url': 'https://example.com/long',
        'max_chars': 10,
      });

      expect(text, contains('Truncated to 500 characters.'));
      expect(text.split('\n\n').last, 'a' * 500);
    });

    test('reports a TLS failure as a readable error instead of throwing', () async {
      final dio = Dio()
        ..httpClientAdapter = _ThrowingAdapter(
          const HandshakeException('CERTIFICATE_VERIFY_FAILED: self signed certificate'),
        );
      final fetch = _tool(buildLocalWebTools(dio), 'web_fetch_local');

      final text = await fetch.execute({'url': 'https://certs.example.com/page'});

      expect(
        text,
        startsWith('Error: could not fetch https://certs.example.com/page — '),
      );
      expect(
        text,
        contains(
          "The site's TLS certificate is not trusted by this machine.",
        ),
      );
    });

    test('reports an unreachable host as a readable error', () async {
      final dio = Dio()
        ..httpClientAdapter = _ThrowingAdapter(
          const SocketException('Connection refused'),
        );
      final fetch = _tool(buildLocalWebTools(dio), 'web_fetch_local');

      final text = await fetch.execute({'url': 'https://down.example.com/'});

      expect(text, startsWith('Error: could not fetch https://down.example.com/ — '));
      expect(text, contains('Connection refused'));
      expect(text, isNot(contains('TLS certificate')));
    });
  });

  test('tools serialize to OpenAI function entries', () {
    final tools = buildLocalWebTools(Dio());

    expect(tools.map((tool) => tool.name).toList(), [
      'web_search_local',
      'web_fetch_local',
    ]);
    for (final tool in tools) {
      final entry = tool.toOpenAiTool();
      expect(entry['type'], 'function');
      final function = entry['function'] as Map<String, dynamic>;
      expect(function['name'], tool.name);
      expect(function['description'], tool.description);
      expect(function['parameters'], same(tool.parameters));
    }
    final searchParams =
        tools.first.toOpenAiTool()['function']['parameters'] as Map<String, dynamic>;
    expect(searchParams['required'], ['query']);
  });
}
