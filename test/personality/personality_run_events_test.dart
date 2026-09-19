import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:island/personality/personality_api.dart';

Stream<List<int>> _bytes(List<String> chunks) =>
    Stream.fromIterable(chunks.map(utf8.encode));

void main() {
  test('parses every run event in order', () async {
    final events = await parsePersonalityRunEvents(
      _bytes([
        'event: reasoning.delta\ndata: {"delta":"weighing"}\n\n',
        'event: tool_call.delta\n'
            'data: {"id":"c1","name":"search","arguments":{"q":"x"}}\n\n',
        'event: tool_call.completed\n'
            'data: {"id":"c1","name":"search","arguments":"{\\"q\\":\\"x\\"}","result":"ok"}\n\n',
        'event: message.delta\ndata: {"delta":"Hel"}\n\n',
        'event: message.delta\ndata: {"delta":"lo"}\n\n',
        'event: message.completed\ndata: {"content":"Hello there"}\n\n',
      ]),
    ).toList();

    expect(events, hasLength(6));
    expect((events[0] as PersonalityReasoningDelta).delta, 'weighing');

    final started = events[1] as PersonalityToolCallStarted;
    expect(started.id, 'c1');
    expect(started.name, 'search');
    expect(started.arguments, {'q': 'x'});

    final completed = events[2] as PersonalityToolCallCompleted;
    expect(completed.id, 'c1');
    expect(completed.name, 'search');
    expect(completed.arguments, {'q': 'x'});
    expect(completed.result, 'ok');

    expect(events[3], isA<PersonalityMessageDelta>());
    expect((events[3] as PersonalityMessageDelta).delta, 'Hel');
    expect((events[4] as PersonalityMessageDelta).delta, 'lo');
    expect((events[5] as PersonalityRunCompleted).content, 'Hello there');
  });

  test('tolerates CRLF, chunk splits, and unknown events', () async {
    final events = await parsePersonalityRunEvents(
      _bytes([
        'event: message.delta\r\ndata:{"delta":"a"}\r\n\r\n',
        'event: conversation.updated\ndata: {"delta":"ignored"}\n\n',
        // A frame may be split mid-line by the transport...
        'event: message.delta\ndata: {"del',
        'ta":"b"}\n\n',
        // ...and one payload may span repeated `data:` lines.
        'event: message.delta\ndata: {"delta":\ndata: "c"}\n\n',
        // Malformed JSON is dropped instead of failing the turn.
        'event: message.delta\ndata: not-json\n\n',
        // The stream may close without the trailing blank line.
        'event: message.completed\ndata: {"content":"abc"}',
      ]),
    ).toList();

    expect(
      [
        for (final e in events)
          if (e is PersonalityMessageDelta) e.delta,
      ],
      ['a', 'b', 'c'],
    );
    expect((events.last as PersonalityRunCompleted).content, 'abc');
  });

  test('parses a client tool handoff with its run id', () async {
    final events = await parsePersonalityRunEvents(
      _bytes([
        'event: tool_call.client\n'
            'data: {"run_id":"run-7","id":"c2","name":"web_search_local","arguments":{"query":"duckdb"}}\n\n',
      ]),
    ).toList();

    expect(events, hasLength(1));
    final client = events.single as PersonalityToolCallClient;
    expect(client.runId, 'run-7');
    expect(client.id, 'c2');
    expect(client.name, 'web_search_local');
    expect(client.arguments, {'query': 'duckdb'});
  });

  test('drops a client handoff without a run id', () async {
    final events = await parsePersonalityRunEvents(
      _bytes([
        'event: tool_call.client\n'
            'data: {"id":"c2","name":"web_search_local","arguments":"{}"}\n\n',
      ]),
    ).toList();
    expect(events, isEmpty);
  });

  test('surfaces failures and drops empty deltas', () async {
    final events = await parsePersonalityRunEvents(
      _bytes([
        'event: run.failed\ndata: {"error":"quota exceeded"}\n\n',
        'event: message.delta\ndata: {"delta":""}\n\n',
      ]),
    ).toList();

    expect(events, hasLength(1));
    expect((events.single as PersonalityRunFailed).error, 'quota exceeded');
  });

  test('reads tool arguments from a map, a JSON string, or garbage', () {
    expect(parsePersonalityToolArguments({'q': 'x'}), {'q': 'x'});
    expect(parsePersonalityToolArguments('{"q":"x"}'), {'q': 'x'});
    expect(parsePersonalityToolArguments('{oops'), isEmpty);
    expect(parsePersonalityToolArguments(null), isEmpty);
  });
}
