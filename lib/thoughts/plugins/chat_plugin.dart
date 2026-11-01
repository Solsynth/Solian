/// The user's Solar Network messages, as tools.
///
/// Reads the conversation list, one conversation's messages and the unread
/// tally; writes by sending a message to a room or to a person by username.
/// It is a second plugin rather than more tools on the social one because the
/// grant is different: posting is public and the user can edit it afterwards,
/// while a message is delivered privately and immediately to people who are
/// waiting for it.
///
/// On demand: five definitions cost context on every request, and the
/// companion only needs them when the user asks about their messages. The
/// prompt fragment below is only sent once the model has loaded the set.
///
/// ## The room in the path
///
/// Every route here addresses a room directly — `/messager/chat/{roomId}/…` —
/// and the client used to call a `/messager/chat/rooms/{roomId}/…` family that
/// no version of the service has ever served. Reading a conversation and
/// sending into one both answered 404 for that reason alone.
library;

import 'package:dio/dio.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:island/thoughts/plugins/local_tool.dart';
import 'package:island/thoughts/plugins/plugin.dart';
import 'package:island/thoughts/plugins/solar_support.dart';

/// How many characters of a message body the model is given.
///
/// Enough for a chat message in full — the common case — and a clipped opening
/// plus a marker for a pasted wall of text.
const int _messageChars = 600;

/// The most conversations one answer carries.
///
/// The endpoint returns every room the account is in and takes no page size,
/// so the cap is applied here: a companion answering "what is new" needs the
/// recent ones, not all of them.
const int _maxRooms = 50;

class ChatPlugin extends SnPlugin {
  const ChatPlugin();

  @override
  String get id => 'chat';

  @override
  String get label => 'thoughtsSkillChatLabel'.tr();

  @override
  String get description => 'thoughtsSkillChatDescription'.tr();

  @override
  String get summary => 'Read conversations and send messages as the user';

  @override
  bool get onDemand => true;

  /// Sending is the server's `send_chat_message` under a local tool.
  ///
  /// Not claimed: `get_chat_message`, which reads one message by id where
  /// these tools read a room's recent messages, and `send_chat_message_batch`,
  /// which sends several in one call. Neither is answered here, so overriding
  /// them would remove the capability instead of moving it.
  @override
  Map<String, String> get overrides => const {
    'send_chat_message': 'send_message',
  };

  @override
  List<SnLocalTool> buildTools(SnPluginContext context) {
    final dio = context.api;
    return [
      SnLocalTool(
        name: 'read_conversations',
        description:
            'The user\'s Solar Network conversations: everyone they have a '
            'direct conversation with and every room they are in. Use it to '
            'find which conversation the user means before reading one.',
        parameters: {'type': 'object', 'properties': <String, dynamic>{}},
        execute: (arguments) => solarToolResult(() async {
          final body = await solarGet(dio, '/messager/chat');
          final rooms = solarPage(body).take(_maxRooms);
          return {
            'conversations': [for (final room in rooms) _room(room)],
          };
        }),
      ),
      SnLocalTool(
        name: 'read_conversation',
        description:
            'The recent messages in one Solar Network conversation, oldest '
            'first as the service returns them. Takes a room id from '
            'local_read_conversations.',
        parameters: {
          'type': 'object',
          'properties': {
            'room_id': {
              'type': 'string',
              'description': 'The conversation id, from read_conversations.',
            },
            'take': {
              'type': 'integer',
              'description': 'How many messages to return (1-50, default 20).',
            },
          },
          'required': ['room_id'],
        },
        execute: (arguments) => solarToolResult(() async {
          final roomId = solarText(arguments, 'room_id');
          if (roomId == null) return solarMissing('room_id');
          final messages = await solarGet(
            dio,
            '/messager/chat/${Uri.encodeComponent(roomId)}/messages',
            // `offset` has no server-side default: leaving it out is a 400.
            query: {
              'offset': 0,
              'take': solarTake(arguments, fallback: 20, max: 50),
            },
          );
          return {
            'messages': [for (final message in solarPage(messages)) _message(message)],
          };
        }),
      ),
      SnLocalTool(
        name: 'send_message',
        description:
            'Sends a message into one Solar Network conversation as the user. '
            'It is delivered to the other people in the room immediately and '
            'cannot be unsent, so send only wording the user gave you. Returns '
            'the sent message.',
        parameters: {
          'type': 'object',
          'properties': {
            'room_id': {
              'type': 'string',
              'description': 'The conversation id, from read_conversations.',
            },
            'content': {
              'type': 'string',
              'description': 'The message body, in the user\'s own words.',
            },
          },
          'required': ['room_id', 'content'],
        },
        execute: (arguments) => solarToolResult(() async {
          final roomId = solarText(arguments, 'room_id');
          final content = solarText(arguments, 'content');
          if (roomId == null) return solarMissing('room_id');
          if (content == null) return solarMissing('content');
          return _message(await _send(dio, roomId, content));
        }),
      ),
      SnLocalTool(
        name: 'message_someone',
        description:
            'Sends a direct message to a Solar Network user by username, '
            'opening the conversation with them if there is not one already. '
            'This is the tool to use when the user says to tell a particular '
            'person something.',
        parameters: {
          'type': 'object',
          'properties': {
            'username': {
              'type': 'string',
              'description': 'The account username, without the leading @.',
            },
            'content': {
              'type': 'string',
              'description': 'The message body, in the user\'s own words.',
            },
          },
          'required': ['username', 'content'],
        },
        execute: (arguments) => solarToolResult(() async {
          final username = solarText(arguments, 'username');
          final content = solarText(arguments, 'content');
          if (username == null) return solarMissing('username');
          if (content == null) return solarMissing('content');

          final account = await solarGet(
            dio,
            '/stargate/accounts/${Uri.encodeComponent(username)}',
          );
          final accountId = solarString(account, 'id');
          if (accountId == null) {
            return {'error': 'There is no account "$username".'};
          }
          // The direct room is created by the request that names the person,
          // and the response is the room either way.
          final room = await solarPost(
            dio,
            '/messager/chat/direct',
            body: {'related_user_id': accountId},
          );
          final roomId = solarString(room, 'id');
          if (roomId == null) {
            return {'error': 'Could not open a conversation with "$username".'};
          }
          return {
            'ok': true,
            'username': username,
            'room_id': roomId,
            'message': _message(await _send(dio, roomId, content)),
          };
        }),
      ),
      SnLocalTool(
        name: 'unread_messages',
        description:
            'How many Solar Network messages are waiting, in total and per '
            'conversation, with the last message in each. Answers "anything '
            'new?" without reading whole conversations.',
        parameters: {'type': 'object', 'properties': <String, dynamic>{}},
        execute: (arguments) => solarToolResult(() async {
          final total = await solarGet(dio, '/messager/chat/unread');
          final summary = await solarGet(dio, '/messager/chat/summary');
          // Both keys are always present: nothing waiting is the answer to
          // "anything new?", and an omitted key would read as unknown.
          return {
            'unread': total is num ? total.toInt() : solarInt(total, 'count'),
            'conversations': _unreadRooms(summary),
          };
        }),
      ),
    ];
  }

  @override
  List<String> systemPrompt(SnPluginContext context) => const [
    'The user\'s Solar Network message tools are loaded: '
    'local_read_conversations, local_read_conversation, local_send_message, '
    'local_message_someone and local_unread_messages. They read and send as '
    'the signed-in user on their own connection.',
    'A message is delivered privately and immediately to real people and '
    'cannot be unsent. Send only wording the user gave you — never compose a '
    'message yourself, and ask for the wording when they have not given it. '
    'Prefer local_message_someone when the user names a person, and '
    'local_read_conversations first when they name a conversation you cannot '
    'identify.',
  ];
}

/// Sends one message into a room.
///
/// `isThreadRoot` is sent explicitly because the request expects it: a reply
/// that starts a thread and one that does not are different requests, and
/// these tools only ever send the second.
Future<Object?> _send(Dio dio, String roomId, String content) => solarPost(
  dio,
  '/messager/chat/${Uri.encodeComponent(roomId)}/messages',
  body: {'content': content, 'is_thread_root': false},
);

/// One conversation as the model reads it.
///
/// A room carries its realm, its encryption mode and its settings; only what
/// identifies it and its people answers what the user asked.
Map<String, dynamic> _room(Object? json) {
  final members = solarList(json, 'members');
  return solarCompact({
    'room_id': solarString(json, 'id'),
    'name': solarString(json, 'name'),
    // The wire sends an int for the kind; a word is what a model can act on.
    'kind': switch (solarInt(json, 'type')) {
      1 => 'direct',
      null => null,
      _ => 'group',
    },
    'members': [
      for (final member in members) ?_memberName(member),
    ],
    'member_count': members.isEmpty ? null : members.length,
    'updated_at': solarTimeField(json, 'updated_at'),
  });
}

/// A member's name as the other members see it: the nickname they set for this
/// room first, then the username.
String? _memberName(Object? member) =>
    solarString(member, 'nick') ?? solarString(member, 'username');

/// One message projected to the fields that carry meaning.
///
/// A message embeds its sender, that sender's whole account, its attachments,
/// its reactions and its thread; serializing one whole would spend the context
/// window on a single line of chat.
Map<String, dynamic> _message(Object? json) {
  final sender = solarMap(json, 'sender');
  return solarCompact({
    'id': solarString(json, 'id'),
    'sent_at':
        solarTimeField(json, 'created_at') ?? solarTimeField(json, 'updated_at'),
    'sender': _memberName(sender) ?? solarString(json, 'sender_id'),
    'sender_id': solarString(json, 'sender_id'),
    'content': solarClip(solarString(json, 'content'), limit: _messageChars),
    'replied_to': solarString(json, 'replied_message_id'),
  });
}

/// When a summarized room's last message was sent, for ordering.
String? _lastSentAt(Map<String, dynamic> room) {
  final message = room['last_message'];
  return message is Map ? message['sent_at'] as String? : null;
}

/// The rooms with something unread, newest last message first.
///
/// The summary is keyed by room id and carries no name, so a room is reported
/// by its id: naming it would cost a second request for every answer, and the
/// model can read the names once from `read_conversations`.
List<Map<String, dynamic>> _unreadRooms(Object? summary) {
  if (summary is! Map) return const [];
  final rooms = <Map<String, dynamic>>[];
  for (final entry in summary.entries) {
    final room = entry.value;
    final unread = solarInt(room, 'unread_count') ?? 0;
    // A room with nothing waiting is not news, whether the summary says so
    // with a zero or with the flag.
    if (unread <= 0 && solarField(room, 'has_unread') != true) continue;
    rooms.add(
      solarCompact({
        'room_id': '${entry.key}',
        'unread': solarInt(room, 'unread_count'),
        'last_message': _message(solarField(room, 'last_message')),
      }),
    );
  }
  // Newest last message first, so the model reads the live conversation
  // rather than whichever room the service happened to key first.
  rooms.sort((a, b) {
    final left = '${_lastSentAt(a)}';
    final right = '${_lastSentAt(b)}';
    return right.compareTo(left);
  });
  return rooms;
}
