/// The user's Solar Network task boards, as tools.
///
/// Reads the user's boards and the tasks and comments on them, and writes by
/// creating and updating tasks and adding comments. It runs on demand: the
/// grant is reading the user's own boards, and the companion only needs the
/// tools when the user asks about their work.
///
/// ## The path the service serves
///
/// The boards endpoint is `/ideask/broads` — the service's own spelling — and
/// the tasks and comments hang off it. That is the path these tools call;
/// `/ideask/boards` is not a route.
library;

import 'package:easy_localization/easy_localization.dart';
import 'package:island/thoughts/plugins/local_tool.dart';
import 'package:island/thoughts/plugins/plugin.dart';
import 'package:island/thoughts/plugins/solar_support.dart';

/// How much of a task's content the model is given.
///
/// A task body can run long; enough to act on plus a marker that it was cut.
const int _contentChars = 4000;

/// The only statuses a task may carry, spelled exactly as the service does.
const Set<String> _statuses = {'open', 'completed', 'skipped', 'duplicated'};

class BoardsPlugin extends SnPlugin {
  const BoardsPlugin();

  @override
  String get id => 'boards';

  @override
  String get label => 'thoughtsSkillBoardsLabel'.tr();

  @override
  String get description => 'thoughtsSkillBoardsDescription'.tr();

  @override
  String get summary => 'Read and manage the user\'s task boards';

  @override
  bool get onDemand => true;

  @override
  List<SnLocalTool> buildTools(SnPluginContext context) {
    final dio = context.api;
    return [
      SnLocalTool(
        name: 'list_boards',
        description:
            'The user\'s Solar Network task boards, with their task prefixes. '
            'Use it to find which board the user means before listing or '
            'creating tasks.',
        parameters: {'type': 'object', 'properties': <String, dynamic>{}},
        execute: (arguments) => solarToolResult(() async {
          final body = await solarGet(dio, '/ideask/broads');
          return {
            'boards': [for (final broad in solarPage(body)) _broad(broad)],
          };
        }),
      ),
      SnLocalTool(
        name: 'list_tasks',
        description:
            'The tasks on one Solar Network task board, optionally filtered '
            'by status, search text, priority, tag, group or assignee. Task '
            'statuses are exactly open, completed, skipped or duplicated. '
            'Takes a broad id from local_list_boards.',
        parameters: {
          'type': 'object',
          'properties': {
            'broad_id': {
              'type': 'string',
              'description': 'The board id, from local_list_boards.',
            },
            'status': {
              'type': 'string',
              'description': 'Filter by status: open, completed, skipped or '
                  'duplicated.',
            },
            'search': {
              'type': 'string',
              'description': 'Filter by search text.',
            },
            'priority': {
              'type': 'integer',
              'description': 'Filter by priority number.',
            },
            'tag': {'type': 'string', 'description': 'Filter by tag.'},
            'group_id': {
              'type': 'string',
              'description': 'Filter by group id.',
            },
            'assignee_account_id': {
              'type': 'string',
              'description': 'Filter by the assigning account id.',
            },
          },
          'required': ['broad_id'],
        },
        execute: (arguments) => solarToolResult(() async {
          final broadId = solarText(arguments, 'broad_id');
          if (broadId == null) return solarMissing('broad_id');
          final body = await solarGet(
            dio,
            '/ideask/broads/${Uri.encodeComponent(broadId)}/tasks',
            // Only the filters the caller named go out; a null entry is
            // dropped by solarGet rather than sent empty.
            query: {
              'status': solarText(arguments, 'status'),
              'search': solarText(arguments, 'search'),
              'priority': solarInt(arguments, 'priority'),
              'tag': solarText(arguments, 'tag'),
              'group_id': solarText(arguments, 'group_id'),
              'assignee_account_id': solarText(arguments, 'assignee_account_id'),
            },
          );
          return {
            'tasks': [for (final task in _tasks(body)) _taskSummary(task)],
          };
        }),
      ),
      SnLocalTool(
        name: 'read_task',
        description:
            'One Solar Network task in full, including its description and '
            'content. Takes a task id from local_list_tasks.',
        parameters: {
          'type': 'object',
          'properties': {
            'task_id': {
              'type': 'string',
              'description': 'The task id, from local_list_tasks.',
            },
          },
          'required': ['task_id'],
        },
        execute: (arguments) => solarToolResult(() async {
          final taskId = solarText(arguments, 'task_id');
          if (taskId == null) return solarMissing('task_id');
          return _task(
            await solarGet(dio, '/ideask/tasks/${Uri.encodeComponent(taskId)}'),
          );
        }),
      ),
      SnLocalTool(
        name: 'create_task',
        description:
            'Creates a task on the user\'s Solar Network board. It is a real '
            'work item on their boards, visible to whoever shares the board, '
            'so create only what the user asked for. Takes a broad id from '
            'local_list_boards.',
        parameters: {
          'type': 'object',
          'properties': {
            'broad_id': {
              'type': 'string',
              'description': 'The board id, from local_list_boards.',
            },
            'name': {'type': 'string', 'description': 'The task title.'},
            'description': {
              'type': 'string',
              'description': 'Optional longer description.',
            },
            'content': {
              'type': 'string',
              'description': 'Optional task body.',
            },
            'priority': {
              'type': 'integer',
              'description': 'Optional priority number.',
            },
            'deadline_at': {
              'type': 'string',
              'description': 'Optional deadline, ISO-8601 UTC, e.g. '
                  '2026-10-01T09:00:00Z.',
            },
            'assignee_account_ids': {
              'type': 'array',
              'items': {'type': 'string'},
              'description': 'Optional account ids to assign.',
            },
            'tags': {
              'type': 'array',
              'items': {'type': 'string'},
              'description': 'Optional tags.',
            },
          },
          'required': ['broad_id', 'name'],
        },
        execute: (arguments) => solarToolResult(() async {
          final broadId = solarText(arguments, 'broad_id');
          if (broadId == null) return solarMissing('broad_id');
          final name = solarText(arguments, 'name');
          if (name == null) return solarMissing('name');
          final created = await solarPost(
            dio,
            '/ideask/broads/${Uri.encodeComponent(broadId)}/tasks',
            // Only the fields the caller named go out, like the PATCH below.
            body: _nonNull({
              'name': name,
              'description': solarText(arguments, 'description'),
              'content': solarText(arguments, 'content'),
              'priority': solarInt(arguments, 'priority'),
              'deadline_at': solarText(arguments, 'deadline_at'),
              'assignee_account_ids': arguments['assignee_account_ids'],
              'tags': arguments['tags'],
            }),
          );
          return _task(created);
        }),
      ),
      SnLocalTool(
        name: 'update_task',
        description:
            'Updates one Solar Network task: its name, status, priority, '
            'deadline or text. The status must be exactly open, completed, '
            'skipped or duplicated. Takes a task id from local_list_tasks.',
        parameters: {
          'type': 'object',
          'properties': {
            'task_id': {
              'type': 'string',
              'description': 'The task id, from local_list_tasks.',
            },
            'name': {'type': 'string', 'description': 'The new title.'},
            'status': {
              'type': 'string',
              'description': 'One of open, completed, skipped or duplicated.',
            },
            'priority': {
              'type': 'integer',
              'description': 'The new priority number.',
            },
            'deadline_at': {
              'type': 'string',
              'description': 'The new deadline, ISO-8601 UTC.',
            },
            'description': {
              'type': 'string',
              'description': 'The new description.',
            },
            'content': {
              'type': 'string',
              'description': 'The new task body.',
            },
          },
          'required': ['task_id'],
        },
        execute: (arguments) => solarToolResult(() async {
          final taskId = solarText(arguments, 'task_id');
          if (taskId == null) return solarMissing('task_id');
          final status = solarText(arguments, 'status');
          if (status != null && !_statuses.contains(status)) {
            return {
              'error': 'The "status" argument must be one of open, completed, '
                  'skipped or duplicated.',
            };
          }
          final updated = await solarPatch(
            dio,
            '/ideask/tasks/${Uri.encodeComponent(taskId)}',
            body: _nonNull({
              'name': solarText(arguments, 'name'),
              'description': solarText(arguments, 'description'),
              'content': solarText(arguments, 'content'),
              'priority': solarInt(arguments, 'priority'),
              'deadline_at': solarText(arguments, 'deadline_at'),
              'status': status,
            }),
          );
          return _task(updated);
        }),
      ),
      SnLocalTool(
        name: 'list_task_comments',
        description:
            'The comments on one Solar Network task. Takes a task id from '
            'local_list_tasks.',
        parameters: {
          'type': 'object',
          'properties': {
            'task_id': {
              'type': 'string',
              'description': 'The task id, from local_list_tasks.',
            },
          },
          'required': ['task_id'],
        },
        execute: (arguments) => solarToolResult(() async {
          final taskId = solarText(arguments, 'task_id');
          if (taskId == null) return solarMissing('task_id');
          final body = await solarGet(
            dio,
            '/ideask/tasks/${Uri.encodeComponent(taskId)}/comments',
          );
          return {
            'comments': [for (final comment in _comments(body)) _comment(comment)],
          };
        }),
      ),
      SnLocalTool(
        name: 'add_task_comment',
        description:
            'Adds a comment to one Solar Network task, in the user\'s own '
            'words. Takes a task id from local_list_tasks.',
        parameters: {
          'type': 'object',
          'properties': {
            'task_id': {
              'type': 'string',
              'description': 'The task id, from local_list_tasks.',
            },
            'content': {
              'type': 'string',
              'description': 'The comment body, in the user\'s own words.',
            },
          },
          'required': ['task_id', 'content'],
        },
        execute: (arguments) => solarToolResult(() async {
          final taskId = solarText(arguments, 'task_id');
          if (taskId == null) return solarMissing('task_id');
          final content = solarText(arguments, 'content');
          if (content == null) return solarMissing('content');
          return _comment(
            await solarPost(
              dio,
              '/ideask/tasks/${Uri.encodeComponent(taskId)}/comments',
              body: {'content': content},
            ),
          );
        }),
      ),
    ];
  }

  @override
  List<String> systemPrompt(SnPluginContext context) => const [
    'The user\'s Solar Network task boards are loaded: local_list_boards, '
    'local_list_tasks, local_read_task, local_create_task, local_update_task, '
    'local_list_task_comments and local_add_task_comment. They read and write '
    'the user\'s own boards on their own connection.',
    'Reading the boards is the grant: the tools answer from the user\'s own '
    'account, so use them only for work the user asked about.',
    'Create, update and comment change real work items that other people may '
    'see. Only call them when the user asks, and put the user\'s own words in '
    'the content.',
    'Task statuses are exactly open, completed, skipped or duplicated, and '
    'broad and task ids always come from the read tools — never invent one.',
  ];
}

/// The items of a task listing, whichever shape the endpoint uses.
///
/// The service answers a bare array, a `{'tasks': [...]}` object, or an
/// envelope; a tool should not have to know which in order to count them.
List<Object?> _tasks(Object? body) {
  if (body is List) return body;
  final listed = solarList(body, 'tasks');
  return listed.isNotEmpty ? listed : solarPage(body);
}

/// The items of a comment listing, whichever shape the endpoint uses.
List<Object?> _comments(Object? body) {
  if (body is List) return body;
  final listed = solarList(body, 'comments');
  return listed.isNotEmpty ? listed : solarPage(body);
}

/// A body with the fields the caller never named taken out.
///
/// A create or update sends only what the caller named: a blank description
/// and a missing deadline are the same "not given", and neither goes out.
Map<String, dynamic> _nonNull(Map<String, dynamic> fields) =>
    fields..removeWhere((_, value) => value == null);

/// One board as the model reads it.
Map<String, dynamic> _broad(Object? json) => solarCompact({
  'id': solarString(json, 'id'),
  // The service fills either name or title; the second is the fallback.
  'name': solarString(json, 'name') ?? solarString(json, 'title'),
  'workspace_id': solarString(json, 'workspace_id'),
  'task_prefix': solarString(json, 'task_prefix'),
  'description': solarString(json, 'description'),
});

/// One task as the listing carries it: enough to pick and to filter.
Map<String, dynamic> _taskSummary(Object? json) => solarCompact({
  'id': solarString(json, 'id'),
  'name': solarString(json, 'name'),
  'task_key': solarString(json, 'task_key'),
  'status': solarString(json, 'status'),
  'priority': solarInt(json, 'priority'),
  'deadline_at': solarTimeField(json, 'deadline_at'),
  'completed_at': solarTimeField(json, 'completed_at'),
  'assignees': _assigneeNames(json),
  'tags': _tagNames(json),
});

/// One task in full, as the model reads it before acting on it.
Map<String, dynamic> _task(Object? json) => solarCompact({
  'id': solarString(json, 'id'),
  'name': solarString(json, 'name'),
  'task_key': solarString(json, 'task_key'),
  'description': solarString(json, 'description'),
  'content': solarClip(solarString(json, 'content'), limit: _contentChars),
  'status': solarString(json, 'status'),
  'priority': solarInt(json, 'priority'),
  'deadline_at': solarTimeField(json, 'deadline_at'),
  'completed_at': solarTimeField(json, 'completed_at'),
  'broad_id': solarString(json, 'broad_id'),
  'group_id': solarString(json, 'group_id'),
  'parent_task_id': solarString(json, 'parent_task_id'),
  'assignees': _assigneeNames(json),
  'tags': _tagNames(json),
});

/// The assignees' names, as the service spells each one.
///
/// The wire fills several spellings of a name; the first one present wins,
/// and an assignee with none is dropped rather than reported blank.
List<String> _assigneeNames(Object? json) {
  final names = <String>[];
  for (final assignee in solarList(json, 'assignees')) {
    final account = solarMap(assignee, 'account');
    final name = solarString(assignee, 'account_nick') ??
        solarString(assignee, 'account_name') ??
        solarString(account, 'nick') ??
        solarString(account, 'name');
    if (name != null) names.add(name);
  }
  return names;
}

/// The task's tags, as plain words.
List<String> _tagNames(Object? json) => [
  for (final tag in solarList(json, 'tags'))
    if (tag is String && tag.trim().isNotEmpty) tag.trim(),
];

/// One comment projected defensively — the service has not documented the
/// comment shape, so every field has a fallback and none may throw.
Map<String, dynamic> _comment(Object? json) {
  final account = solarMap(json, 'account');
  return solarCompact({
    'id': solarString(json, 'id'),
    'content': solarString(json, 'content') ?? solarString(json, 'body'),
    'created_at': solarTimeField(json, 'created_at'),
    'author': solarString(json, 'author_name') ??
        solarString(account, 'nick') ??
        solarString(json, 'nick') ??
        solarString(json, 'name'),
  });
}
