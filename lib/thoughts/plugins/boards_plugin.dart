/// The user's Ideask workspace, as tools.
///
/// Reads the user's workspace folders, pages and tasks, and writes by
/// creating pages and tasks, updating tasks and adding comments. It runs on
/// demand: the grant is reading the user's own workspace, and the companion
/// only needs the tools when the user asks about their work.
///
/// ## The model the service serves
///
/// Folders group pages and tasks inside a workspace; a task may instead sit
/// unfiled in the workspace. A task has no status of its own: the wire carries
/// `complete_reason`, and `open`, `completed`, `skipped` and `duplicated` are
/// derived from it.
library;

import 'package:easy_localization/easy_localization.dart';
import 'package:island/thoughts/plugins/local_tool.dart';
import 'package:island/thoughts/plugins/plugin.dart';
import 'package:island/thoughts/plugins/solar_support.dart';

/// How much of a task's or page's content the model is given.
///
/// A body can run long; enough to act on plus a marker that it was cut.
const int _contentChars = 4000;

/// The statuses a task may carry, spelled for the model.
const Set<String> _statuses = {'open', 'completed', 'skipped', 'duplicated'};

/// The wire's `status` filter value for each derived status.
const Map<String, int> _statusFilters = {
  'open': 0,
  'completed': 1,
  'skipped': 2,
  'duplicated': 3,
};

/// The wire's `complete_reason` value for each derived status.
const Map<String, int?> _completeReasons = {
  'open': null,
  'completed': 0,
  'skipped': 1,
  'duplicated': 2,
};

class BoardsPlugin extends SnPlugin {
  const BoardsPlugin();

  @override
  String get id => 'boards';

  @override
  String get label => 'thoughtsSkillBoardsLabel'.tr();

  @override
  String get description => 'thoughtsSkillBoardsDescription'.tr();

  @override
  String get summary =>
      'Read and manage the user\'s workspace folders, pages and tasks';

  @override
  bool get onDemand => true;

  @override
  List<SnLocalTool> buildTools(SnPluginContext context) {
    final dio = context.api;
    return [
      SnLocalTool(
        name: 'list_folders',
        description:
            'The root folders of one Solar Network Ideask workspace, with '
            'their descriptions. Use it to find the folder the user means '
            'before listing pages or tasks.',
        parameters: {
          'type': 'object',
          'properties': {
            'workspace_id': {
              'type': 'string',
              'description': 'The workspace id.',
            },
          },
          'required': ['workspace_id'],
        },
        execute: (arguments) => solarToolResult(() async {
          final workspaceId = solarText(arguments, 'workspace_id');
          if (workspaceId == null) return solarMissing('workspace_id');
          final body = await solarGet(
            dio,
            '/ideask/folders',
            query: {'workspace_id': workspaceId, 'root': 'true'},
          );
          return {
            'folders': [for (final folder in solarPage(body)) _folder(folder)],
          };
        }),
      ),
      SnLocalTool(
        name: 'list_pages',
        description:
            'The pages of one Solar Network Ideask workspace, optionally '
            'narrowed to one folder. Each row carries the page title and '
            'tags, not its body — read one page for that.',
        parameters: {
          'type': 'object',
          'properties': {
            'workspace_id': {
              'type': 'string',
              'description': 'The workspace id.',
            },
            'folder_id': {
              'type': 'string',
              'description': 'Optional folder id, from local_list_folders.',
            },
          },
          'required': ['workspace_id'],
        },
        execute: (arguments) => solarToolResult(() async {
          final workspaceId = solarText(arguments, 'workspace_id');
          if (workspaceId == null) return solarMissing('workspace_id');
          final body = await solarGet(
            dio,
            '/ideask/pages',
            query: {
              'workspace_id': workspaceId,
              'folder_id': solarText(arguments, 'folder_id'),
            },
          );
          return {
            'pages': [for (final page in solarPage(body)) _pageSummary(page)],
          };
        }),
      ),
      SnLocalTool(
        name: 'create_page',
        description:
            'Creates a page in one Solar Network Ideask workspace. It is a '
            'real document the user and anyone sharing the workspace may '
            'read, so create only what the user asked for. Takes a folder id '
            'from local_list_folders.',
        parameters: {
          'type': 'object',
          'properties': {
            'workspace_id': {
              'type': 'string',
              'description': 'The workspace id.',
            },
            'title': {'type': 'string', 'description': 'The page title.'},
            'folder_id': {
              'type': 'string',
              'description': 'Optional folder id, from local_list_folders.',
            },
            'content_md': {
              'type': 'string',
              'description': 'Optional page body, as Markdown.',
            },
          },
          'required': ['workspace_id', 'title'],
        },
        execute: (arguments) => solarToolResult(() async {
          final workspaceId = solarText(arguments, 'workspace_id');
          if (workspaceId == null) return solarMissing('workspace_id');
          final title = solarText(arguments, 'title');
          if (title == null) return solarMissing('title');
          final created = await solarPost(
            dio,
            '/ideask/pages',
            body: _nonNull({
              'workspace_id': workspaceId,
              'title': title,
              'folder_id': solarText(arguments, 'folder_id'),
              'content_md': solarText(arguments, 'content_md'),
            }),
          );
          return _pageSummary(created);
        }),
      ),
      SnLocalTool(
        name: 'read_page',
        description:
            'One Solar Network Ideask page in full, with its description and '
            'Markdown body. Takes a page id from local_list_pages.',
        parameters: {
          'type': 'object',
          'properties': {
            'page_id': {
              'type': 'string',
              'description': 'The page id, from local_list_pages.',
            },
          },
          'required': ['page_id'],
        },
        execute: (arguments) => solarToolResult(() async {
          final pageId = solarText(arguments, 'page_id');
          if (pageId == null) return solarMissing('page_id');
          final page = await solarGet(
            dio,
            '/ideask/pages/${Uri.encodeComponent(pageId)}',
          );
          final body = await solarGet(
            dio,
            '/ideask/pages/${Uri.encodeComponent(pageId)}/body',
          );
          return _page(page, body);
        }),
      ),
      SnLocalTool(
        name: 'list_tasks',
        description:
            'The tasks of one Solar Network Ideask workspace, optionally '
            'narrowed to one folder and filtered by status, search text, '
            'priority, tag or assignee. Task statuses are exactly open, '
            'completed, skipped or duplicated. Takes a workspace id and, '
            'optionally, a folder id from local_list_folders.',
        parameters: {
          'type': 'object',
          'properties': {
            'workspace_id': {
              'type': 'string',
              'description': 'The workspace id.',
            },
            'folder_id': {
              'type': 'string',
              'description': 'Optional folder id, from local_list_folders.',
            },
            'status': {
              'type': 'string',
              'description':
                  'Filter by status: open, completed, skipped or '
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
            'assignee_account_id': {
              'type': 'string',
              'description': 'Filter by the assigning account id.',
            },
          },
          'required': ['workspace_id'],
        },
        execute: (arguments) => solarToolResult(() async {
          final workspaceId = solarText(arguments, 'workspace_id');
          if (workspaceId == null) return solarMissing('workspace_id');
          final status = solarText(arguments, 'status');
          if (status != null && !_statuses.contains(status)) {
            return {
              'error':
                  'The "status" argument must be one of open, completed, '
                  'skipped or duplicated.',
            };
          }
          final body = await solarGet(
            dio,
            '/ideask/workspaces/${Uri.encodeComponent(workspaceId)}/tasks',
            // Only the filters the caller named go out; a null entry is
            // dropped by solarGet rather than sent empty.
            query: {
              'folder_id': solarText(arguments, 'folder_id'),
              'status': status == null ? null : _statusFilters[status],
              'search': solarText(arguments, 'search'),
              'priority': solarInt(arguments, 'priority'),
              'tag': solarText(arguments, 'tag'),
              'assigneeAccountId': solarText(arguments, 'assignee_account_id'),
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
            'One Solar Network Ideask task in full, including its description '
            'and content. Takes a task id from local_list_tasks.',
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
            'Creates a task in one Solar Network Ideask workspace, filed in a '
            'folder or left unfiled. It is a real work item the user and '
            'anyone sharing the workspace may see, so create only what the '
            'user asked for. Takes a folder id from local_list_folders.',
        parameters: {
          'type': 'object',
          'properties': {
            'workspace_id': {
              'type': 'string',
              'description': 'The workspace id.',
            },
            'name': {'type': 'string', 'description': 'The task title.'},
            'folder_id': {
              'type': 'string',
              'description': 'Optional folder id, from local_list_folders.',
            },
            'description': {
              'type': 'string',
              'description': 'Optional longer description.',
            },
            'content': {'type': 'string', 'description': 'Optional task body.'},
            'priority': {
              'type': 'integer',
              'description': 'Optional priority number.',
            },
            'deadline_at': {
              'type': 'string',
              'description':
                  'Optional deadline, ISO-8601 UTC, e.g. '
                  '2026-10-01T09:00:00Z.',
            },
            'tags': {
              'type': 'array',
              'items': {'type': 'string'},
              'description': 'Optional tags.',
            },
          },
          'required': ['workspace_id', 'name'],
        },
        execute: (arguments) => solarToolResult(() async {
          final workspaceId = solarText(arguments, 'workspace_id');
          if (workspaceId == null) return solarMissing('workspace_id');
          final name = solarText(arguments, 'name');
          if (name == null) return solarMissing('name');
          final created = await solarPost(
            dio,
            '/ideask/workspaces/${Uri.encodeComponent(workspaceId)}/tasks',
            // Only the fields the caller named go out, like the PATCH below.
            body: _nonNull({
              'name': name,
              'folder_id': solarText(arguments, 'folder_id'),
              'description': solarText(arguments, 'description'),
              'content': solarText(arguments, 'content'),
              'priority': solarInt(arguments, 'priority'),
              'deadline_at': solarText(arguments, 'deadline_at'),
              'tags': arguments['tags'],
            }),
          );
          return _task(created);
        }),
      ),
      SnLocalTool(
        name: 'update_task',
        description:
            'Updates one Solar Network Ideask task: its name, status, '
            'priority, deadline or text. The status must be exactly open, '
            'completed, skipped or duplicated. Takes a task id from '
            'local_list_tasks.',
        parameters: {
          'type': 'object',
          'properties': {
            'task_id': {
              'type': 'string',
              'description': 'The task id, from local_list_tasks.',
            },
            'name': {'type': 'string', 'description': 'The task title.'},
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
            'content': {'type': 'string', 'description': 'The new task body.'},
            'tags': {
              'type': 'array',
              'items': {'type': 'string'},
              'description': 'The new tags.',
            },
          },
          'required': ['task_id', 'name'],
        },
        execute: (arguments) => solarToolResult(() async {
          final taskId = solarText(arguments, 'task_id');
          if (taskId == null) return solarMissing('task_id');
          final name = solarText(arguments, 'name');
          if (name == null) return solarMissing('name');
          final status = solarText(arguments, 'status');
          if (status != null && !_statuses.contains(status)) {
            return {
              'error':
                  'The "status" argument must be one of open, completed, '
                  'skipped or duplicated.',
            };
          }
          // The PATCH reads an omitted complete_reason as null, which would
          // reopen a completed task. So echo the task's current reason —
          // or the one the requested status names — on every update.
          final current = await solarGet(
            dio,
            '/ideask/tasks/${Uri.encodeComponent(taskId)}',
          );
          final reason = status == null
              ? solarInt(current, 'complete_reason')
              : _completeReasons[status];
          final updated = await solarPatch(
            dio,
            '/ideask/tasks/${Uri.encodeComponent(taskId)}',
            body: {
              ..._nonNull({
                'name': name,
                'description': solarText(arguments, 'description'),
                'content': solarText(arguments, 'content'),
                'priority': solarInt(arguments, 'priority'),
                'deadline_at': solarText(arguments, 'deadline_at'),
                'tags': arguments['tags'],
              }),
              // Sent even when null: null is "open", not "unchanged".
              'complete_reason': reason,
            },
          );
          return _task(updated);
        }),
      ),
      SnLocalTool(
        name: 'list_task_comments',
        description:
            'The comments on one Solar Network Ideask task. Takes a task id '
            'from local_list_tasks.',
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
            'comments': [
              for (final comment in _comments(body)) _comment(comment),
            ],
          };
        }),
      ),
      SnLocalTool(
        name: 'add_task_comment',
        description:
            'Adds a comment to one Solar Network Ideask task, in the user\'s '
            'own words. Takes a task id from local_list_tasks.',
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
    'The user\'s Solar Network Ideask workspace is loaded: local_list_folders, '
        'local_list_pages, local_create_page, local_read_page, local_list_tasks, '
        'local_read_task, local_create_task, local_update_task, '
        'local_list_task_comments and local_add_task_comment. They read and write '
        'the user\'s own workspace on their own connection.',
    'Reading the workspace is the grant: the tools answer from the user\'s own '
        'account, so use them only for work the user asked about.',
    'Folders group pages and tasks inside a workspace; a task may instead sit '
        'unfiled in the workspace. Task status is derived from complete_reason, '
        'and is one of open, completed, skipped or duplicated.',
    'Create, update and comment change real work items that other people may '
        'see. Only call them when the user asks, and put the user\'s own words in '
        'the content.',
    'Workspace, folder, page and task ids always come from the read tools — '
        'never invent one.',
  ];
}

/// The items of a task listing, whichever shape the endpoint uses.
///
/// The service answers a bare array or an envelope; a tool should not have to
/// know which in order to count them.
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

/// One folder as the model reads it.
Map<String, dynamic> _folder(Object? json) => solarCompact({
  'id': solarString(json, 'id'),
  'name': solarString(json, 'name'),
  'parent_id': solarString(json, 'parent_id'),
  'workspace_id': solarString(json, 'workspace_id'),
  'description': solarString(json, 'description'),
});

/// One page as the listing carries it: enough to pick, not its body.
Map<String, dynamic> _pageSummary(Object? json) => solarCompact({
  'id': solarString(json, 'id'),
  'title': solarString(json, 'title'),
  'workspace_id': solarString(json, 'workspace_id'),
  'folder_id': solarString(json, 'folder_id'),
  'collection_id': solarString(json, 'collection_id'),
  'tags': _tagNames(json),
  'updated_at': solarTimeField(json, 'updated_at'),
});

/// One page in full: its description, tags and Markdown body.
///
/// The body is read from the page's own body endpoint and [body] is that
/// answer; a page with no body is a page with nothing written in it.
Map<String, dynamic> _page(Object? json, Object? body) => solarCompact({
  'id': solarString(json, 'id'),
  'title': solarString(json, 'title'),
  'description': solarString(json, 'description'),
  'tags': _tagNames(json),
  'folder_id': solarString(json, 'folder_id'),
  'workspace_id': solarString(json, 'workspace_id'),
  'updated_at': solarTimeField(json, 'updated_at'),
  'content_md': solarClip(
    solarString(body, 'content_md'),
    limit: _contentChars,
  ),
});

/// One task as the listing carries it: enough to pick and to filter.
Map<String, dynamic> _taskSummary(Object? json) => solarCompact({
  'id': solarString(json, 'id'),
  'name': solarString(json, 'name'),
  'task_key': solarString(json, 'task_key'),
  'status': _status(json),
  'priority': solarInt(json, 'priority'),
  'deadline_at': solarTimeField(json, 'deadline_at'),
  'completed_at': solarTimeField(json, 'completed_at'),
  'tags': _tagNames(json),
});

/// One task in full, as the model reads it before acting on it.
Map<String, dynamic> _task(Object? json) => solarCompact({
  'id': solarString(json, 'id'),
  'name': solarString(json, 'name'),
  'task_key': solarString(json, 'task_key'),
  'description': solarString(json, 'description'),
  'content': solarClip(solarString(json, 'content'), limit: _contentChars),
  'status': _status(json),
  'priority': solarInt(json, 'priority'),
  'deadline_at': solarTimeField(json, 'deadline_at'),
  'completed_at': solarTimeField(json, 'completed_at'),
  'workspace_id': solarString(json, 'workspace_id'),
  'folder_id': solarString(json, 'folder_id'),
  'parent_task_id': solarString(json, 'parent_task_id'),
  'tags': _tagNames(json),
});

/// The task's status, derived from the wire's `complete_reason`.
///
/// The wire carries 0 completed, 1 skipped, 2 duplicated and null open; a
/// status the tool reports must be one of exactly those four words.
String _status(Object? json) {
  final reason = solarInt(json, 'complete_reason');
  return switch (reason) {
    0 => 'completed',
    1 => 'skipped',
    2 => 'duplicated',
    _ => 'open',
  };
}

/// The tags, as plain words.
List<String> _tagNames(Object? json) => [
  for (final tag in solarList(json, 'tags'))
    if (tag is String && tag.trim().isNotEmpty) tag.trim(),
];

/// One comment projected defensively — every field has a fallback and none
/// may throw.
Map<String, dynamic> _comment(Object? json) => solarCompact({
  'id': solarString(json, 'id'),
  'task_id': solarString(json, 'task_id'),
  'author_account_id': solarString(json, 'author_account_id'),
  'content': solarString(json, 'content') ?? solarString(json, 'body'),
  'created_at': solarTimeField(json, 'created_at'),
  'updated_at': solarTimeField(json, 'updated_at'),
});
