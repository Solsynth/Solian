/// The user's Solar Network notifications, as tools.
///
/// Reads what arrived, reports the unread count, and clears the inbox. This is
/// the set the companion is asked for constantly — "anything new?" is the most
/// common thing a user asks a companion that can see their account — so unlike
/// the social set it rides on every run rather than waiting to be activated.
///
/// The paths are the gateway's, under `/metoer`. The list route is the one
/// read here with a side effect: fetching a page marks it viewed unless the
/// caller says otherwise, so `read_notifications` sends `unmark=true` and a
/// question about the inbox leaves it exactly as it was found. The service has
/// no per-notification read — the SDK's method for one answers 404 — so the
/// set offers the two reads and the one write that exist.
///
/// Reads and the write live in one plugin because they are one grant: the same
/// switch that lets the companion see the inbox is what lets it clear it, and
/// a second switch would only invite the user to believe the first one cannot
/// touch anything.
library;

import 'package:easy_localization/easy_localization.dart';
import 'package:island/thoughts/plugins/local_tool.dart';
import 'package:island/thoughts/plugins/plugin.dart';
import 'package:island/thoughts/plugins/solar_support.dart';

class NotificationsPlugin extends SnPlugin {
  const NotificationsPlugin();

  @override
  String get id => 'notifications';

  @override
  String get label => 'thoughtsSkillNotificationsLabel'.tr();

  @override
  String get description => 'thoughtsSkillNotificationsDescription'.tr();

  @override
  String get summary => 'Check unread notifications and clear the inbox';

  /// The server's three notification tools, each under the local name that
  /// does the same job. There is no per-notification read to claim because the
  /// service does not have one.
  @override
  Map<String, String> get overrides => const {
    'list_notifications': 'read_notifications',
    'get_unread_notification_count': 'unread_notifications',
    'mark_all_notifications_read': 'mark_all_notifications_read',
  };

  @override
  List<SnLocalTool> buildTools(SnPluginContext context) {
    final dio = context.api;
    return [
      SnLocalTool(
        name: 'read_notifications',
        description:
            'The user\'s Solar Network notifications, newest first: replies, '
            'mentions, reactions, wallet and subscription events. Each one '
            'says whether it has already been read. Reading this list does not '
            'mark anything read.',
        parameters: {
          'type': 'object',
          'properties': {
            'take': {
              'type': 'integer',
              'description':
                  'How many notifications to return (1-30, default 10).',
            },
          },
        },
        execute: (arguments) => solarToolResult(() async {
          final page = await solarGet(
            dio,
            '/metoer/notifications',
            // Without `unmark` this route marks the page it returns viewed, so
            // answering "what arrived?" would consume the unread count the
            // companion is asked about moments later.
            query: {
              'offset': 0,
              'take': solarTake(arguments),
              'unmark': true,
            },
          );
          return {
            'notifications': [
              for (final item in solarPage(page)) _notification(item),
            ],
          };
        }),
      ),
      SnLocalTool(
        name: 'unread_notifications',
        description:
            'How many Solar Network notifications the user has not read yet. '
            'The cheapest answer to "anything new?" — the count alone, without '
            'the notifications themselves, so prefer it when the user has not '
            'asked for the details.',
        parameters: {'type': 'object', 'properties': <String, dynamic>{}},
        execute: (arguments) => solarToolResult(() async {
          final count = await solarGet(dio, '/metoer/notifications/count');
          return {'unread': _count(count)};
        }),
      ),
      SnLocalTool(
        name: 'mark_all_notifications_read',
        description:
            'Marks every Solar Network notification read, clearing the user\'s '
            'whole inbox and the unread count with it. There is no undo and no '
            'per-notification version of this, so call it only when the user '
            'has asked for the inbox to be cleared.',
        parameters: {'type': 'object', 'properties': <String, dynamic>{}},
        execute: (arguments) => solarToolResult(() async {
          await solarPost(dio, '/metoer/notifications/all/read');
          return {'ok': true};
        }),
      ),
    ];
  }

  @override
  List<String> systemPrompt(SnPluginContext context) => const [
    'The user\'s Solar Network notification tools are loaded: '
    'local_read_notifications, local_unread_notifications and '
    'local_mark_all_notifications_read. They run as the signed-in user on '
    'their own connection, and the notifications they return are the user\'s '
    'real ones.',
    'When the user asks whether anything is new, the unread count is the '
    'answer — report the number rather than paraphrasing the list. Reading '
    'does not mark anything read: the inbox is left as it was found, and the '
    'one write, local_mark_all_notifications_read, clears every unread '
    'notification at once, so do it when the user asks for that rather than as '
    'a tidy-up after reading one out.',
  ];
}

/// One notification projected to the fields that carry meaning.
///
/// A notification carries its subtitle, its metadata blob, its push type and
/// the account it belongs to; the metadata is an application-specific payload
/// the model cannot act on and the account is the one the tools already run
/// as. What a reader needs is what arrived, when, and whether it has been
/// seen — and a field the wire stops sending is a missing value here, not a
/// failure.
Map<String, dynamic> _notification(Object? json) => solarCompact({
  'id': solarString(json, 'id'),
  'topic': solarString(json, 'topic'),
  'title': solarString(json, 'title'),
  'body': solarClip(solarString(json, 'content')),
  'created_at': solarTimeField(json, 'created_at'),
  'read': solarTimeField(json, 'viewed_at') != null,
});

/// The unread count, however the body spells it.
///
/// This route answers with the number alone rather than an object wrapping it,
/// and a number that reached the wire as text is still a number. A body that
/// carries neither is a count the answer does not have.
int? _count(Object? json) {
  if (json is num) return json.toInt();
  if (json is String) return int.tryParse(json.trim());
  return solarInt(json, 'count');
}
