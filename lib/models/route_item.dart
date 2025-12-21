import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:material_symbols_icons/symbols.dart';

part 'route_item.freezed.dart';

@freezed
sealed class RouteItem with _$RouteItem {
  const factory RouteItem({
    required String name,
    required String path,
    required String description,
    @Default([]) List<String> searchableAliases,
    required IconData icon,
  }) = _RouteItem;
}

final List<RouteItem> kAvailableRoutes = [
  RouteItem(
    name: 'dashboard'.tr(),
    path: '/',
    description: 'dashboardDescription'.tr(),
    searchableAliases: ['dashboard', 'home'],
    icon: Symbols.home,
  ),
  RouteItem(
    name: 'explore'.tr(),
    path: '/explore',
    description: 'exploreDescription'.tr(),
    searchableAliases: ['explore', 'discover'],
    icon: Symbols.explore,
  ),
  RouteItem(
    name: 'searchPosts'.tr(),
    path: '/posts/search',
    description: 'searchPostsDescription'.tr(),
    searchableAliases: ['search', 'posts'],
    icon: Symbols.search,
  ),
  RouteItem(
    name: 'postShuffle'.tr(),
    path: '/posts/shuffle',
    description: 'postShuffleDescription'.tr(),
    searchableAliases: ['shuffle', 'random', 'posts'],
    icon: Symbols.shuffle,
  ),
  RouteItem(
    name: 'postTagsCategories'.tr(),
    path: '/posts/categories',
    description: 'postTagsCategoriesDescription'.tr(),
    searchableAliases: ['tags', 'categories', 'posts'],
    icon: Symbols.category,
  ),
  RouteItem(
    name: 'discoverRealms'.tr(),
    path: '/discovery/realms',
    description: 'discoverRealmsDescription'.tr(),
    searchableAliases: ['realms', 'groups', 'communities'],
    icon: Symbols.public,
  ),
  RouteItem(
    name: 'chat'.tr(),
    path: '/chat',
    description: 'chatDescription'.tr(),
    searchableAliases: ['chat', 'messages', 'conversations', 'dm'],
    icon: Symbols.chat,
  ),
  RouteItem(
    name: 'realms'.tr(),
    path: '/realms',
    description: 'realmsDescription'.tr(),
    searchableAliases: ['realms', 'groups', 'communities'],
    icon: Symbols.group,
  ),
  RouteItem(
    name: 'account'.tr(),
    path: '/account',
    description: 'accountDescription'.tr(),
    searchableAliases: ['account', 'me', 'profile', 'user'],
    icon: Symbols.person,
  ),
  RouteItem(
    name: 'stickerMarketplace'.tr(),
    path: '/stickers',
    description: 'stickerMarketplaceDescription'.tr(),
    searchableAliases: ['stickers', 'marketplace', 'emojis', 'emojis'],
    icon: Symbols.emoji_emotions,
  ),
  RouteItem(
    name: 'webFeeds'.tr(),
    path: '/feeds',
    description: 'webFeedsDescription'.tr(),
    searchableAliases: ['feeds', 'web feeds', 'rss', 'news'],
    icon: Symbols.feed,
  ),
  RouteItem(
    name: 'wallet'.tr(),
    path: '/account/wallet',
    description: 'walletDescription'.tr(),
    searchableAliases: [
      'wallet',
      'balance',
      'money',
      'source points',
      'gold points',
      'nsp',
      'shd',
    ],
    icon: Symbols.account_balance_wallet,
  ),
  RouteItem(
    name: 'relationships'.tr(),
    path: '/account/relationships',
    description: 'relationshipsDescription'.tr(),
    searchableAliases: ['relationships', 'friends', 'block list', 'blocks'],
    icon: Symbols.people,
  ),
  RouteItem(
    name: 'updateYourProfile'.tr(),
    path: '/account/me/update',
    description: 'updateYourProfileDescription'.tr(),
    searchableAliases: ['profile', 'update', 'edit', 'my profile'],
    icon: Symbols.edit,
  ),
  RouteItem(
    name: 'leveling'.tr(),
    path: '/account/me/leveling',
    description: 'levelingDescription'.tr(),
    searchableAliases: [
      'leveling',
      'level',
      'levels',
      'subscriptions',
      'social credits',
    ],
    icon: Symbols.trending_up,
  ),
  RouteItem(
    name: 'accountSettings'.tr(),
    path: '/account/me/settings',
    description: 'accountSettingsDescription'.tr(),
    searchableAliases: [
      'settings',
      'preferences',
      'account',
      'account settings',
    ],
    icon: Symbols.settings,
  ),
  RouteItem(
    name: 'abuseReports'.tr(),
    path: '/safety/reports/me',
    description: 'abuseReportsDescription'.tr(),
    searchableAliases: ['reports', 'abuse', 'safety'],
    icon: Symbols.report,
  ),
  RouteItem(
    name: 'files'.tr(),
    path: '/files',
    description: 'filesDescription'.tr(),
    searchableAliases: ['files', 'folders', 'storage', 'drive', 'cloud'],
    icon: Symbols.folder,
  ),
  RouteItem(
    name: 'aiThought'.tr(),
    path: '/thought',
    description: 'aiThoughtTitle'.tr(),
    searchableAliases: ['thought', 'ai', 'ai thought'],
    icon: Symbols.psychology,
  ),
  RouteItem(
    name: 'creatorHub'.tr(),
    path: '/creators',
    description: 'creatorHubDescription'.tr(),
    searchableAliases: ['creators', 'hub', 'creator hub', 'creators hub'],
    icon: Symbols.create,
  ),
  RouteItem(
    name: 'developerPortal'.tr(),
    path: '/developers',
    description: 'developerPortalDescription'.tr(),
    searchableAliases: [
      'developers',
      'dev',
      'developer',
      'developer hub',
      'developers hub',
    ],
    icon: Symbols.code,
  ),
  RouteItem(
    name: 'debugLogs'.tr(),
    path: '/logs',
    description: 'debugLogsDescription'.tr(),
    searchableAliases: ['logs', 'debug', 'debug logs'],
    icon: Symbols.bug_report,
  ),
  RouteItem(
    name: 'webArticlesStand'.tr(),
    path: '/feeds/articles',
    description: 'webArticlesStandDescription'.tr(),
    searchableAliases: ['articles', 'stand', 'feed', 'web feed'],
    icon: Symbols.article,
  ),
  RouteItem(
    name: 'appSettings'.tr(),
    path: '/settings',
    description: 'appSettingsDescription'.tr(),
    searchableAliases: ['settings', 'preferences', 'app', 'app settings'],
    icon: Symbols.settings,
  ),
  RouteItem(
    name: 'about'.tr(),
    path: '/about',
    description: 'about'.tr(),
    searchableAliases: ['about', 'info'],
    icon: Symbols.info,
  ),
];

@freezed
sealed class SpecialAction with _$SpecialAction {
  const factory SpecialAction({
    required String name,
    required String description,
    required IconData icon,
    required VoidCallback action,
    @Default([]) List<String> searchableAliases,
  }) = _SpecialAction;
}
