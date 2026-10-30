import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/chat/data/message_repository.dart';
import 'package:island/core/network.dart';
import 'package:island/data/database.dart';
import 'package:island/data/message.dart';
import 'package:logging/logging.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Timeline operations the member directory needs to refresh the UI.
///
/// The directory never reaches into the notifier's list or emission internals;
/// it asks the timeline host to re-normalize when the member graph changes.
abstract interface class MessageTimelineHost {
  List<LocalChatMessage> get timelineMessages;

  /// Coalesces an emission into the current frame.
  void scheduleTimelineEmit();

  /// Emits immediately (used after an authoritative repair).
  void emitTimelineNow();
}

/// Owns the room's sender/member graph.
///
/// Messages only carry a sender id. This class keeps the canonical member
/// (with its account and profile) so the timeline can render names and avatars,
/// and repairs members whose account was lost from the local cache.
class MessageMemberDirectory {
  final Ref _ref;
  final String _roomId;
  final AppDatabase _database;
  final MessageRepository _repository;
  final Dio _apiClient;
  final MessageTimelineHost _timeline;
  final _logger = Logger('MessageMemberDirectory');

  final Map<String, SnChatMember> _membersById = {};

  /// Accounts already repaired from the per-account endpoint. Guards against
  /// re-running the repair for ids that resolved; a genuinely deleted account
  /// (unrecoverable) is simply absent from the room-member list.
  final Set<String> _repairedAccountIds = <String>{};
  bool _repairInFlight = false;

  static const int _repairMaxMessages = 100;

  MessageMemberDirectory({
    required Ref ref,
    required String roomId,
    required AppDatabase database,
    required MessageRepository repository,
    required Dio apiClient,
    required MessageTimelineHost timeline,
  }) : _ref = ref,
       _roomId = roomId,
       _database = database,
       _repository = repository,
       _apiClient = apiClient,
       _timeline = timeline;

  SnChatMember? memberFor(String memberId) => _membersById[memberId];

  /// Adds or replaces [member] in the in-memory directory.
  ///
  /// A bare member (empty account) is degraded data from a server fallback or
  /// a pruned cache: it must never replace a member whose account is intact.
  /// The sender repair uses [force] to install the authoritative member.
  bool upsert(SnChatMember? member, {bool force = false}) {
    if (member == null) return false;
    final existing = _membersById[member.id] ?? _membersById[member.accountId];
    if (!force && existing != null && isBare(member) && !isBare(existing)) {
      return false;
    }
    if (!force &&
        existing != null &&
        !member.updatedAt.isAfter(existing.updatedAt) &&
        existing == member) {
      return false;
    }
    if (!force &&
        existing != null &&
        existing.updatedAt.isAfter(member.updatedAt)) {
      return false;
    }
    _membersById[member.id] = member;
    _membersById[member.accountId] = member;
    return true;
  }

  /// True when the member carries a server-fabricated profile shell (random
  /// id, only account_id set) or an empty account name.
  bool isBare(SnChatMember member) {
    final account = member.account;
    return account.id.trim().isEmpty ||
        (account.name.trim().isEmpty &&
            account.nick.trim().isEmpty &&
            account.profile.picture == null);
  }

  /// Replaces each message's embedded sender with the canonical member.
  List<LocalChatMessage> normalizeMessages(
    Iterable<LocalChatMessage> messages,
  ) {
    final list = messages.toList();
    for (final message in list) {
      upsert(message.sender);
    }
    return list.map(normalizeMessage).toList();
  }

  LocalChatMessage normalizeMessage(LocalChatMessage message) {
    final incoming = message.sender;
    if (incoming != null) {
      final existing = _membersById[incoming.id];
      final canonical =
          existing == null || incoming.updatedAt.isAfter(existing.updatedAt)
          ? incoming
          : existing;
      _membersById[incoming.id] = canonical;
      _membersById[incoming.accountId] = canonical;
      if (!identical(message.sender, canonical) ||
          message.data.containsKey('sender')) {
        return _copyWithSender(message, canonical);
      }
      return message;
    }

    final cached = _membersById[message.senderId];
    if (cached != null || message.data.containsKey('sender')) {
      return _copyWithSender(message, cached);
    }
    return message;
  }

  /// Restores the room's member directory before messages are normalized.
  Future<void> hydrate(SnChatRoom room) async {
    for (final member in room.members ?? const <SnChatMember>[]) {
      upsert(member);
    }

    final cachedMembers = await _database.getMembersByRoomId(_roomId);
    for (final member in cachedMembers) {
      upsert(member);
    }
  }

  /// Stores sender data separately from messages so account/profile updates
  /// received with a new message survive a timeline or app reload.
  Future<void> upsertIncomingSender(SnChatMember sender) async {
    if (!upsert(sender)) return;

    try {
      await _database.saveAccount(
        sender.account,
        source: 'realtime chat message sender',
      );
      await _database.saveMember(sender);
    } catch (error, stackTrace) {
      // A bare/empty sender profile (server-side fallback) is refused by the
      // cache guard; that must not fail the message pipeline. The in-memory
      // member is already upserted above, so the UI still renders this session.
      final accountDiagnostic = <String, dynamic>{
        'member_id': sender.id,
        ..._accountProfileDiagnostic(sender.account),
      };
      _logger.warning(
        'Failed to persist sender ${sender.accountId} for room $_roomId; '
        'account/profile diagnostic: ${jsonEncode(accountDiagnostic)}',
        error,
        stackTrace,
      );
      return;
    }

    if (_ref.mounted) {
      _timeline.scheduleTimelineEmit();
    }
  }

  /// Scans the active timeline for messages whose sender member/account is
  /// missing or bare and asynchronously repairs the member directory.
  void scheduleRepair() {
    if (!_ref.mounted || _repairInFlight) return;

    final missing = <String>[];
    final bare = <String>[];
    for (final message in _timeline.timelineMessages) {
      final sender = message.sender;
      if (sender == null) {
        if (message.senderId.isEmpty) continue;
        missing.add(message.senderId);
        continue;
      }
      if (sender.accountId == 'system') continue;
      if (isBare(sender)) bare.add(sender.id);
    }
    if (missing.isEmpty && bare.isEmpty) return;
    if (missing.length + bare.length > _repairMaxMessages) return;

    _repairInFlight = true;
    unawaited(
      _repairSenders(
        memberIds: {...bare, ...missing}.toList(),
      ).whenComplete(() => _repairInFlight = false),
    );
  }

  Future<void> _repairSenders({required List<String> memberIds}) async {
    final resolvedByMemberId = <String, SnChatMember>{};

    try {
      // 1. Authoritative per-member endpoint: every active room member comes
      // back with its account hydrated, and leavers are excluded.
      var offset = 0;
      const pageSize = 50;
      final wanted = memberIds.toSet();
      while (wanted.isNotEmpty) {
        final response = await _apiClient.get(
          '/messager/chat/$_roomId/members',
          queryParameters: {'offset': offset, 'take': pageSize},
        );
        final rawMembers = (response.data as List?) ?? const [];
        for (final raw in rawMembers.whereType<Map>()) {
          final member = _tryParseMember(raw);
          if (member == null) continue;
          if (wanted.remove(member.id)) {
            resolvedByMemberId[member.id] = member;
          }
        }
        final totalRaw = response.headers['x-total']?.firstOrNull;
        final total = int.tryParse(totalRaw ?? '') ?? rawMembers.length;
        offset += rawMembers.length;
        if (rawMembers.isEmpty || offset >= total) break;
      }
    } catch (err, stackTrace) {
      _logger.info(
        'Failed to fetch room members for sender repair in room $_roomId',
        err,
        stackTrace,
      );
    }

    // 2. Fall back to the per-account endpoint for ids the member list did not
    // cover (leavers, or members filtered from the page). The member id and
    // account id differ, so resolve the account id from the in-memory
    // directory or the local message row.
    final unresolved = memberIds
        .where((memberId) => !resolvedByMemberId.containsKey(memberId))
        .toList();
    if (unresolved.isNotEmpty) {
      final sdk = _ref.read(solarNetworkClientProvider);
      final accountIds = <String, String>{}; // memberId -> accountId
      final memberForMessage =
          <String, LocalChatMessage>{}; // memberId -> sample
      for (final memberId in unresolved) {
        final existing = _membersById[memberId];
        if (existing != null) {
          accountIds[memberId] = existing.accountId;
          continue;
        }
        final sample = _timeline.timelineMessages
            .where((message) => message.senderId == memberId)
            .firstOrNull;
        if (sample == null) continue;
        memberForMessage[memberId] = sample;
        final local = await _repository.getLocalMessage(sample.id);
        if (local?.sender != null) {
          accountIds[memberId] = local!.sender!.accountId;
        }
      }
      final distinctAccountIds = accountIds.values.toSet();
      for (final accountId in distinctAccountIds) {
        if (_repairedAccountIds.contains(accountId)) continue;
        try {
          final account = await sdk.accounts.getAccountById(accountId);
          await _database.saveAccount(account, source: 'chat sender repair');
          final member = _membersById.entries
              .where((entry) => entry.value.accountId == accountId)
              .firstOrNull
              ?.value;
          if (member != null) {
            final repaired = member.copyWith(account: account);
            upsert(repaired, force: true);
            await _database.saveMember(repaired);
            _repairedAccountIds.add(accountId);
            _emitNow();
          } else {
            // No local member row to attach the account to (deleted member or
            // cache evicted): rebuild the member from the message's own
            // accountId, and let step 3's re-emit pick it up.
            final fallbackMember = SnChatMember(
              id: accountId,
              chatRoomId: _roomId,
              chatRoom: null,
              accountId: accountId,
              createdAt: DateTime.fromMillisecondsSinceEpoch(0),
              updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
              deletedAt: null,
              account: account,
              nick: null,
              notify: 0,
              joinedAt: null,
              breakUntil: null,
              timeoutUntil: null,
              chatGroupId: null,
              chatGroup: null,
              lastReadAt: null,
              status: null,
              realmNick: null,
              realmBio: null,
              realmExperience: null,
              realmLevel: null,
              realmLevelingProgress: null,
              realmLabel: null,
            );
            upsert(fallbackMember, force: true);
            await _database.saveMember(fallbackMember);
            _repairedAccountIds.add(accountId);
            _emitNow();
          }
        } catch (err, stackTrace) {
          _logger.info(
            'Failed to repair sender account $accountId for room $_roomId',
            err,
            stackTrace,
          );
        }
      }

      // Members with no resolvable account id locally (sender row missing
      // entirely): refetch one of their messages; the server hydrates the
      // sender member on that response.
      for (final entry in memberForMessage.entries) {
        if (accountIds.containsKey(entry.key)) continue;
        if (_repairedAccountIds.contains(entry.key)) continue;
        try {
          final remote = await _repository.fetchRemoteMessage(entry.value.id);
          final sender = remote?.sender;
          if (sender == null || sender.accountId == 'system') continue;
          if (isBare(sender)) continue;
          if (!upsert(sender, force: true)) continue;
          await _database.saveAccount(
            sender.account,
            source: 'chat sender repair',
          );
          await _database.saveMember(sender);
          _repairedAccountIds.add(entry.key);
          _emitNow();
        } catch (err, stackTrace) {
          _logger.info(
            'Failed to repair sender member ${entry.key} for room $_roomId',
            err,
            stackTrace,
          );
        }
      }
    }

    // 3. Apply the room-member results and re-emit so the normalized member
    // directory refreshes every message.
    var changed = false;
    for (final member in resolvedByMemberId.values) {
      final existing = _membersById[member.id];
      if (existing != null && !isBare(existing)) {
        if (!upsert(member)) continue;
        changed = true;
      } else {
        upsert(member, force: true);
        changed = true;
      }
      try {
        await _database.saveAccount(
          member.account,
          source: 'chat sender repair',
        );
        await _database.saveMember(member);
      } catch (err, stackTrace) {
        _logger.info(
          'Failed to persist repaired sender ${member.id} for room $_roomId',
          err,
          stackTrace,
        );
      }
    }
    if (changed && _ref.mounted) {
      _emitNow();
    }
  }

  void _emitNow() {
    if (!_ref.mounted) return;
    _timeline.emitTimelineNow();
  }

  SnChatMember? _tryParseMember(dynamic data) {
    if (data is! Map<String, dynamic>) return null;
    try {
      return SnChatMember.fromJson(data);
    } catch (err, stackTrace) {
      _logger.warning(
        'Skipping invalid chat member during sender repair; '
        'diagnostic: ${jsonEncode({'member_id': data['id'], 'account_id': data['account_id'], 'account_keys': _mapKeys(data['account'])})}',
        err,
        stackTrace,
      );
      return null;
    }
  }

  LocalChatMessage _copyWithSender(
    LocalChatMessage message,
    SnChatMember? sender,
  ) {
    final data = Map<String, dynamic>.from(message.data)..remove('sender');
    return LocalChatMessage(
      id: message.id,
      roomId: message.roomId,
      senderId: message.senderId,
      sender: sender,
      data: data,
      createdAt: message.createdAt,
      clientMessageId: message.clientMessageId,
      nonce: message.nonce,
      status: message.status,
      content: message.content,
      isDeleted: message.isDeleted,
      updatedAt: message.updatedAt,
      deletedAt: message.deletedAt,
      type: message.type,
      meta: message.meta,
      membersMentioned: message.membersMentioned,
      editedAt: message.editedAt,
      attachments: message.attachments,
      reactions: message.reactions,
      repliedMessageId: message.repliedMessageId,
      forwardedMessageId: message.forwardedMessageId,
      localAttachments: message.localAttachments,
    );
  }

  List<String> _mapKeys(dynamic value) {
    if (value is! Map) return const [];
    final keys = value.keys.map((key) => key.toString()).toList()..sort();
    return keys;
  }

  Map<String, dynamic> _accountProfileDiagnostic(SnAccount account) {
    final profile = account.profile;
    return {
      'account_id': account.id,
      'profile_id': profile.id,
      'profile_id_empty': profile.id.trim().isEmpty,
      'profile_has_first_name': profile.firstName.trim().isNotEmpty,
      'profile_has_last_name': profile.lastName.trim().isNotEmpty,
      'profile_has_bio': profile.bio.trim().isNotEmpty,
      'profile_has_picture': profile.picture != null,
      'profile_is_bare': profile.id.trim().isEmpty,
    };
  }
}
