import 'package:solar_network_sdk/solar_network_sdk.dart';

String? getDirectChatCounterpartAccountName(
  SnChatRoom room,
  String? currentUserId,
) {
  if (room.type != 1) return null;
  final members = room.members ?? const <SnChatMember>[];
  final others = members.where((member) => member.accountId != currentUserId);
  for (final member in others) {
    final accountName = member.account.name.trim();
    if (accountName.isNotEmpty) return accountName;
  }
  return null;
}

String? getDirectChatCounterpartNick(SnChatRoom room, String? currentUserId) {
  if (room.type != 1) return null;
  final members = room.members ?? const <SnChatMember>[];
  final others = members.where((member) => member.accountId != currentUserId);
  for (final member in others) {
    final nick = member.account.nick.trim();
    if (nick.isNotEmpty) return nick;
  }
  return null;
}

String? getDirectChatCounterpartFirstName(
  SnChatRoom room,
  String? currentUserId,
) {
  if (room.type != 1) return null;
  final members = room.members ?? const <SnChatMember>[];
  final others = members.where((member) => member.accountId != currentUserId);
  for (final member in others) {
    final firstName = member.account.profile.firstName.trim();
    if (firstName.isNotEmpty) return firstName;
  }
  return null;
}

String? getDirectChatCounterpartAccountId(
  SnChatRoom room,
  String? currentUserId,
) {
  if (room.type != 1) return null;
  final members = room.members ?? const <SnChatMember>[];
  final others = members.where((member) => member.accountId != currentUserId);
  for (final member in others) {
    final accountId = member.accountId;
    if (accountId.isNotEmpty) return accountId;
  }
  return null;
}

String? getDirectChatCounterpartPictureUrl(
  SnChatRoom room,
  String? currentUserId,
  String serverUrl,
) {
  if (room.type != 1) return null;
  final members = room.members ?? const <SnChatMember>[];
  final others = members.where((member) => member.accountId != currentUserId);
  for (final member in others) {
    final picture = member.account.profile.picture;
    if (picture == null) continue;
    return '$serverUrl/drive/files/${picture.id}';
  }
  return null;
}

String getChatRoomSuggestionDisplayName(
  SnChatRoom room,
  String? currentUserId,
) {
  final explicitName = room.name?.trim();
  if (explicitName != null && explicitName.isNotEmpty) {
    return explicitName;
  }

  final nick = getDirectChatCounterpartNick(room, currentUserId);
  if (nick != null && nick.isNotEmpty) {
    return nick;
  }

  final accountName = getDirectChatCounterpartAccountName(room, currentUserId);
  if (accountName != null && accountName.isNotEmpty) {
    return accountName;
  }

  return room.type == 1 ? 'Direct Message' : 'Chat';
}
