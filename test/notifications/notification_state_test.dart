import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/widgets/friend_status_toast.dart';
import 'package:island/core/notification.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

SnAccount _account(String id) {
  return SnAccount(
    id: id,
    name: id,
    nick: id,
    language: 'en',
    isSuperuser: false,
    automatedId: null,
    profile: SnAccountProfile(
      id: 'profile-$id',
      experience: 0,
      level: 1,
      levelingProgress: 0.0,
      picture: null,
      background: null,
      verification: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      deletedAt: null,
    ),
    perkSubscription: null,
    badges: [],
    contacts: [],
    activatedAt: DateTime.now(),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    deletedAt: null,
  );
}

SnAccountStatus _status(String accountId, {required bool isOnline}) {
  return SnAccountStatus(
    id: 'status-$accountId',
    attitude: 0,
    isOnline: isOnline,
    isCustomized: false,
    meta: null,
    clearedAt: null,
    accountId: accountId,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    deletedAt: null,
  );
}

FriendStatusChangeEvent _event(
  SnAccount account, {
  required bool isOnline,
}) {
  return FriendStatusChangeEvent(
    account: account,
    status: _status(account.id, isOnline: isOnline),
    changeType: isOnline
        ? FriendStatusChangeType.online
        : FriendStatusChangeType.offline,
  );
}

void main() {
  late ProviderContainer container;
  late ProviderSubscription<List<NotificationItem>> keepAlive;

  setUp(() {
    container = ProviderContainer();
    // `notificationStateProvider` is auto-dispose; a listener keeps it alive
    // across the test body.
    keepAlive = container.listen(notificationStateProvider, (_, _) {});
  });

  tearDown(() {
    keepAlive.close();
    container.dispose();
  });

  test('refreshes the live toast of the same account instead of stacking', () {
    final notifier = container.read(notificationStateProvider.notifier);
    final alice = _account('alice');
    final bob = _account('bob');

    notifier.addFriendStatus(_event(alice, isOnline: true));
    notifier.addFriendStatus(_event(bob, isOnline: true));

    var items = container.read(notificationStateProvider);
    expect(items, hasLength(2));

    final aliceItem = items.singleWhere(
      (item) => item.friendStatusEvent!.account.id == 'alice',
    );
    final aliceId = aliceItem.id;

    // Alice changes status again: the existing toast is updated in place.
    notifier.addFriendStatus(_event(alice, isOnline: false));

    items = container.read(notificationStateProvider);
    expect(items, hasLength(2));

    final refreshed = items.singleWhere(
      (item) => item.friendStatusEvent!.account.id == 'alice',
    );
    expect(refreshed.id, aliceId);
    expect(
      refreshed.friendStatusEvent!.changeType,
      FriendStatusChangeType.offline,
    );
  });

  test('refresh resets the auto-dismiss duration to the base window', () {
    final notifier = container.read(notificationStateProvider.notifier);
    final alice = _account('alice');
    final bob = _account('bob');

    notifier.addFriendStatus(_event(alice, isOnline: true));
    notifier.addFriendStatus(_event(bob, isOnline: true));

    // Bob was stacked second, so his toast carries the stagger bonus.
    notifier.addFriendStatus(_event(alice, isOnline: false));

    final items = container.read(notificationStateProvider);
    final aliceItem = items.singleWhere(
      (item) => item.friendStatusEvent!.account.id == 'alice',
    );
    final bobItem = items.singleWhere(
      (item) => item.friendStatusEvent!.account.id == 'bob',
    );
    expect(aliceItem.duration, kNotificationBaseDuration);
    expect(
      bobItem.duration,
      kNotificationBaseDuration + const Duration(seconds: 1),
    );
  });

  test('a dismissed toast no longer absorbs a new event for that account', () {
    final notifier = container.read(notificationStateProvider.notifier);
    final alice = _account('alice');
    final bob = _account('bob');

    notifier.addFriendStatus(_event(alice, isOnline: true));
    notifier.addFriendStatus(_event(bob, isOnline: true));

    final aliceItem = container.read(notificationStateProvider).singleWhere(
      (item) => item.friendStatusEvent!.account.id == 'alice',
    );
    notifier.dismiss(aliceItem.id);
    notifier.addFriendStatus(_event(alice, isOnline: false));

    final items = container.read(notificationStateProvider);
    // Dismissed Alice toast + Bob toast + fresh Alice toast.
    expect(items, hasLength(3));
    expect(
      items
          .where((item) => item.friendStatusEvent?.account.id == 'alice')
          .length,
      2,
    );
  });
}
