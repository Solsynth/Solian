/// Shared card layout IDs and migration for mobile / desktop dashboards.
class DashboardLayout {
  DashboardLayout._();

  /// Default card order for both mobile (single column) and desktop (waterfall).
  static const defaultCardLayouts = [
    'checkIn',
    'fortuneCard',
    'postFeatured',
    'friendsOverview',
    'notifications',
    'chatList',
    'fortuneGraph',
  ];

  /// Legacy full-height column groups → individual section cards.
  static const columnToCards = <String, List<String>>{
    'activityColumn': ['checkIn', 'fortuneGraph', 'fortuneCard'],
    'postsColumn': ['postFeatured'],
    'socialColumn': ['friendsOverview', 'notifications'],
    'chatsColumn': ['chatList'],
  };

  /// Normalize a saved layout list: expand old column IDs, drop unactivated.
  static List<String> resolveCardLayouts(List<String>? layouts) {
    final source = (layouts == null || layouts.isEmpty)
        ? defaultCardLayouts
        : layouts;
    return source
        .expand((id) => columnToCards[id] ?? <String>[id])
        .where((id) => id != 'accountUnactivated')
        .toList();
  }
}
