import 'package:solar_network_sdk/solar_network_sdk.dart';

DateTime chatRoomActivityAt(
  SnChatRoom room,
  Map<String, SnChatSummary> summaries,
) => summaries[room.id]?.lastMessage?.createdAt ?? room.updatedAt;

List<SnChatRoom> sortChatRoomsByActivity(
  Iterable<SnChatRoom> rooms,
  Map<String, SnChatSummary> summaries,
) {
  return rooms.toList()..sort((a, b) {
    final activityComparison = chatRoomActivityAt(
      b,
      summaries,
    ).compareTo(chatRoomActivityAt(a, summaries));
    if (activityComparison != 0) return activityComparison;

    final createdComparison = b.createdAt.compareTo(a.createdAt);
    if (createdComparison != 0) return createdComparison;

    return a.id.compareTo(b.id);
  });
}

bool chatRoomMatchesSearch(SnChatRoom room, String query) {
  final normalizedQuery = query.trim().toLowerCase();
  if (normalizedQuery.isEmpty) return true;

  return [room.name, ...?room.members?.map((member) => member.account.nick)]
      .whereType<String>()
      .any((value) => value.toLowerCase().contains(normalizedQuery));
}
