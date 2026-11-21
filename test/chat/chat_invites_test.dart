import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/chat/pods/chat_room.dart';
import 'package:island/core/network.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Answers the invites request with one row shaped like LightHouse's
/// `GET /messager/chat/invites`: the member carries its room, and a DM room
/// carries its peer under `members`.
class _InviteAdapter implements HttpClientAdapter {
  _InviteAdapter(this.body);

  final String body;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    expect(options.path, '/messager/chat/invites');
    return ResponseBody.fromString(
      body,
      200,
      headers: {
        Headers.contentTypeHeader: const ['application/json'],
      },
    );
  }
}

Map<String, dynamic> _account(String id, String nick) => {
  'id': id,
  'name': id,
  'nick': nick,
  'language': 'en',
  'is_superuser': false,
  'automated_id': null,
  'profile': {
    'id': id,
    'experience': 0,
    'level': 1,
    'leveling_progress': 0,
    'picture': null,
    'background': null,
    'verification': null,
    'created_at': '2026-01-01T00:00:00Z',
    'updated_at': '2026-01-01T00:00:00Z',
    'deleted_at': null,
  },
  'perk_subscription': null,
  'activated_at': null,
  'created_at': '2026-01-01T00:00:00Z',
  'updated_at': '2026-01-01T00:00:00Z',
  'deleted_at': null,
};

Map<String, dynamic> _member({
  required String id,
  required String roomId,
  required String accountId,
  Map<String, dynamic>? chatRoom,
}) => {
  'id': id,
  'chat_room_id': roomId,
  'chat_room': chatRoom,
  'account_id': accountId,
  'account': _account(accountId, 'Invitee'),
  'nick': null,
  'notify': 0,
  'joined_at': null,
  'leave_at': null,
  'confirmed_at': null,
  'break_until': null,
  'timeout_until': null,
  'last_read_at': null,
  'status': null,
  'realm_nick': null,
  'realm_bio': null,
  'realm_experience': null,
  'realm_level': null,
  'realm_leveling_progress': null,
  'realm_label': null,
  'created_at': '2026-01-01T00:00:00Z',
  'updated_at': '2026-01-01T00:00:00Z',
  'deleted_at': null,
};

Map<String, dynamic> _dmRoom(String id, String peerId) => {
  'id': id,
  'name': null,
  'description': null,
  'slug': null,
  'type': 1,
  'is_community': false,
  'is_public': false,
  'is_read_receipts_public': false,
  'encryption_mode': 0,
  'mls_group_id': null,
  'picture': null,
  'background': null,
  'account_id': null,
  'realm_id': null,
  'realm': null,
  'members': [
    _member(id: 'peer-member', roomId: id, accountId: peerId),
  ],
  'created_at': '2026-01-01T00:00:00Z',
  'updated_at': '2026-01-01T00:00:00Z',
  'deleted_at': null,
};

Future<List<dynamic>> invitesFor(String body) async {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
    ..httpClientAdapter = _InviteAdapter(body);
  final container = ProviderContainer(
    overrides: [apiClientProvider.overrideWithValue(dio)],
  );
  addTearDown(container.dispose);
  return container.read(chatroomInvitesProvider.future);
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await EasyLocalization.ensureInitialized();
  });

  test('keeps an invite that carries its room', () async {
    final payload = [
      _member(
        id: 'invite-1',
        roomId: 'room-1',
        accountId: 'me',
        chatRoom: _dmRoom('room-1', 'peer'),
      ),
    ];

    final invites = await invitesFor(jsonEncode(payload));

    expect(invites, hasLength(1));
    final invite = invites.single;
    expect(invite.id, 'invite-1');
    expect(invite.chatRoom?.id, 'room-1');
    expect(invite.chatRoom?.type, 1);
    expect(invite.chatRoom?.members, hasLength(1));
    expect(invite.chatRoom?.members?.single.accountId, 'peer');
  });

  test('drops an invite whose room the server did not send', () async {
    final payload = [
      _member(id: 'invite-1', roomId: 'room-1', accountId: 'me'),
      _member(
        id: 'invite-2',
        roomId: 'room-2',
        accountId: 'me',
        chatRoom: _dmRoom('room-2', 'peer'),
      ),
    ];

    final invites = await invitesFor(jsonEncode(payload));

    expect(invites.map((invite) => invite.id), ['invite-2']);
  });
}
