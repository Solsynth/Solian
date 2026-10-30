import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:island/notifications/notification.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/widgets/account/account_name.dart';
import 'package:island/accounts/widgets/account/activity_presence.dart';
import 'package:island/accounts/widgets/account/leveling_progress.dart';
import 'package:island/accounts/widgets/account/status.dart';
import 'package:island/accounts/check_in.dart';
import 'package:island/core/websocket.dart';
import 'package:island/core/database.dart';
import 'package:island/core/network.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/accounts/widgets/account/artwork_reflection.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/page_app_bar.dart';
import 'package:island/shared/widgets/attention_modal.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/core/debug_sheet.dart';
import 'package:island/core/config.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:island/core/theme.dart';
import 'package:island/discovery/widgets/pill_app_bar.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Height of the artwork at the head of the account page.
///
/// The picture is content, not chrome: it dissolves into the page before its
/// last row, so the identity below reads as belonging to it rather than
/// sitting on the far side of a cut.
const double _kAccountBannerHeight = 220;

/// Radius of the avatar that straddles the banner's dissolving edge.
const double _kAccountAvatarRadius = 32;

@RoutePage()
class AccountListScreen extends StatelessWidget {
  const AccountListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (isWideScreen(context)) return const SizedBox.shrink();
    return const AccountFeatureWidget();
  }
}

@RoutePage()
class AccountScreen extends HookConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = isWideScreen(context);

    return AppBackground(
      isRoot: true,
      child: isWide
          ? SafeArea(
              child: Row(
                children: [
                  Flexible(
                    flex: 2,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      child: const AccountFeatureWidget(isAside: true),
                    ),
                  ),
                  const VerticalDivider(width: 1),
                  Flexible(flex: 3, child: const AutoRouter()),
                ],
              ),
            )
          : const AutoRouter(),
    );
  }
}

class AccountFeatureWidget extends HookConsumerWidget {
  final bool isAside;
  const AccountFeatureWidget({super.key, this.isAside = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = isWideScreen(context);
    final isDeveloperMode = ref.watch(developerModeProvider);

    final user = ref.watch(userInfoProvider);
    final notificationUnreadCount = ref.watch(notificationUnreadCountProvider);

    if (user.value == null || user.value == null) {
      return _UnauthorizedAccountScreen();
    }

    // Periodically refresh presence while app is in foreground.
    useEffect(() {
      final timer = Timer.periodic(const Duration(seconds: 60), (_) {
        if (context.mounted) {
          ref.invalidate(accountStatusProvider(user.value!.name));
        }
      });
      return timer.cancel;
    }, []);
    final account = user.value!;

    final scrollController = useScrollController();
    final statusTop = MediaQuery.paddingOf(context).top;
    final artwork = account.profile.background;
    // With artwork the page opens on a clean header image that runs all the way
    // to the top edge, so the pill is kept out of sight until the page has
    // scrolled 30% of the viewport. Accounts without artwork keep the pill
    // surfaced from the start: there is nothing to uncover.
    final pillRevealThreshold = MediaQuery.sizeOf(context).height * 0.3;
    // The artwork sliding under the pill drives its glass. Without artwork the
    // page opens on the identity block and never scrolls anything behind the
    // bar, so the pill stays surfaced instead of hiding over an empty gap.
    final fade = useValueNotifier(0.0);

    final pillChild = Row(
      children: [
        const SolDrawerButton(),
        const Gap(SolSpace.sm),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'account'.tr(),
              style: Theme.of(context).appBarTheme.titleTextStyle,
            ),
          ),
        ),
      ],
    );

    return AppScaffold(
      isNoBackground: isWide,
      appBarOverContent: true,
      appBar: PillAppBar(
        fade: artwork == null ? null : fade,
        statusTop: statusTop,
        child: artwork == null
            ? pillChild
            : ValueListenableBuilder<double>(
                valueListenable: fade,
                builder: (context, t, child) => IgnorePointer(
                  ignoring: t == 0,
                  child: Opacity(opacity: t, child: child),
                ),
                child: pillChild,
              ),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) =>
            updatePillFade(notification, fade, threshold: pillRevealThreshold),
        child: CustomScrollView(
          controller: scrollController,
          slivers: [
            // The artwork owns the very top of the page while the pill is
            // hidden; once revealed, the pill floats over the content that has
            // scrolled beneath it.
            SliverToBoxAdapter(
              child: _AccountHeader(
                account: account,
                statusTop: statusTop,
                reflectionBand: 0,
                onAvatarTap: () {
                  context.router.push(AccountProfileRoute(name: account.name));
                },
              ),
            ),
            // Everything below the banner: the page's cards.
            SliverToBoxAdapter(
              child: Column(
                spacing: 12,
                children: <Widget>[
                  if (user.value?.activatedAt == null)
                    AccountUnactivatedCard().padding(horizontal: 12, bottom: 4),
                  Card(
                    elevation: 0,
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    margin: EdgeInsets.zero,
                    child: Column(
                      children: [
                        AccountStatusCreationWidget(uname: user.value!.name),
                        ActivityPresenceWidget(
                          uname: user.value!.name,
                          isCompact: true,
                          compactPadding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 8,
                            top: 4,
                          ),
                        ),
                      ],
                    ),
                  ).padding(horizontal: 12, bottom: 4),
                  CheckInWidget(
                    margin: EdgeInsets.zero,
                  ).padding(horizontal: 12, bottom: 4),
                  LevelingProgressCard(
                    isCompact: true,
                    level: user.value!.profile.level,
                    experience: user.value!.profile.experience,
                    progress: user.value!.profile.levelingProgress,
                  ).padding(horizontal: 12),
                  Builder(
                    builder: (context) {
                      final menuItems = [
                        {
                          'icon': Symbols.notifications,
                          'title': 'notifications',
                          'badgeCount': notificationUnreadCount.value ?? 0,
                          'onTap': () {
                            showAttentionModal(
                              id: 'notifications',
                              replaceIfExists: true,
                              barrierDismissible: true,
                              builder: (context, dismiss) =>
                                  NotificationModal(onDismiss: dismiss),
                            );
                          },
                        },
                        {
                          'icon': Symbols.workspace_premium,
                          'title': 'progress',
                          'onTap': () {
                            context.router.push(ProgressRoute());
                          },
                        },
                        {
                          'icon': Symbols.trending_up,
                          'title': 'leveling',
                          'onTap': () {
                            context.router.push(const LevelingRoute());
                          },
                        },
                        {
                          'icon': Symbols.storefront,
                          'title': 'store',
                          'onTap': () {
                            context.router.push(const StoreRoute());
                          },
                        },
                        {
                          'icon': Symbols.handshake,
                          'title': 'meet',
                          'onTap': () {
                            context.router.push(const MeetRoute());
                          },
                        },
                        {
                          'icon': Symbols.qr_code_rounded,
                          'title': 'qrCode',
                          'onTap': () {
                            context.router.push(const AccountQrRoute());
                          },
                        },
                        {
                          'icon': Symbols.people,
                          'title': 'relationships',
                          'onTap': () {
                            context.router.push(const RelationshipRoute());
                          },
                        },
                        {
                          'icon': Symbols.sticker_rounded,
                          'title': 'stickers',
                          'onTap': () {
                            context.router.push(
                              const StickerMarketplaceRoute(),
                            );
                          },
                        },
                      ];
                      return Column(
                        children: menuItems.map((item) {
                          final icon = item['icon'] as IconData;
                          final title = item['title'] as String;
                          final badgeCount = item['badgeCount'] as int?;
                          final onTap = item['onTap'] as VoidCallback?;
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 24,
                            ),
                            trailing: const Icon(Symbols.chevron_right),
                            dense: true,
                            leading: Badge(
                              isLabelVisible:
                                  badgeCount != null && badgeCount > 0,
                              label: Text(badgeCount.toString()),
                              child: Icon(icon, size: 24),
                            ),
                            title: Text(title).tr(),
                            onTap: onTap,
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const Divider(height: 1).padding(vertical: 8),
                  Column(
                    children: [
                      ListTile(
                        leading: const Icon(Symbols.report),
                        trailing: const Icon(Symbols.chevron_right),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24,
                        ),
                        dense: true,
                        title: Text('tickets').tr(),
                        onTap: () {
                          context.router.push(const TicketListRoute());
                        },
                      ),
                      ListTile(
                        leading: const Icon(Symbols.settings),
                        trailing: const Icon(Symbols.chevron_right),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24,
                        ),
                        dense: true,
                        title: Text('appSettings').tr(),
                        onTap: () {
                          context.router.push(const SettingsRoute());
                        },
                      ),
                      ListTile(
                        leading: const Icon(Symbols.manage_accounts),
                        trailing: const Icon(Symbols.chevron_right),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24,
                        ),
                        dense: true,
                        title: Text('accountSettings').tr(),
                        onTap: () {
                          context.router.push(const AccountSettingsRoute());
                        },
                      ),
                    ],
                  ),
                  const Divider(height: 1).padding(vertical: 8),
                  Column(
                    children: [
                      if (isDeveloperMode)
                        ListTile(
                          leading: const Icon(Symbols.bug_report),
                          trailing: const Icon(Symbols.chevron_right),
                          contentPadding: EdgeInsets.symmetric(horizontal: 24),
                          title: Text('debugOptions').tr(),
                          dense: true,
                          onTap: () {
                            toggleDebugOverlay(ref);
                          },
                        ),
                      ListTile(
                        leading: const Icon(Symbols.logout),
                        trailing: const Icon(Symbols.chevron_right),
                        contentPadding: EdgeInsets.symmetric(horizontal: 24),
                        title: Text('logout').tr(),
                        dense: true,
                        onTap: () async {
                          final ws = ref.watch(websocketStateProvider.notifier);
                          final client = ref.watch(solarNetworkClientProvider);
                          showLoadingModal(context);
                          // Fire and forgot
                          client.auth.revokeCurrentSession();
                          await resetDatabase(ref);
                          if (!context.mounted) return;
                          hideLoadingModal(context);
                          final userNotifier = ref.read(
                            userInfoProvider.notifier,
                          );
                          userNotifier.logOut();
                          ws.close();
                        },
                      ),
                    ],
                  ),
                ],
              ).padding(top: 8, bottom: MediaQuery.of(context).padding.bottom),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnauthorizedAccountScreen extends HookConsumerWidget {
  const _UnauthorizedAccountScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDeveloperMode = ref.watch(developerModeProvider);
    final statusTop = MediaQuery.paddingOf(context).top;

    return AppScaffold(
      appBarOverContent: true,
      appBar: PillAppBar(
        statusTop: statusTop,
        child: Row(
          children: [
            const SolDrawerButton(),
            const Gap(SolSpace.sm),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'account'.tr(),
                  style: Theme.of(context).appBarTheme.titleTextStyle,
                ),
              ),
            ),
          ],
        ),
      ),
      // The pill floats over the body, so its band is taken out by hand.
      body: Padding(
        padding: EdgeInsets.only(top: statusTop + kPillAppBarHeight),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Card(
                  elevation: 0,
                  child: InkWell(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    onTap: () {
                      context.router.push(const CreateAccountRoute());
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Symbols.person_add, size: 48),
                          const SizedBox(height: 8),
                          Text('createAccount').tr().bold(),
                          Text('createAccountDescription').tr(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const Gap(8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Card(
                  elevation: 0,
                  child: InkWell(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    onTap: () {
                      context.router.push(LoginRoute());
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Symbols.login, size: 48),
                          const SizedBox(height: 8),
                          Text('login').tr().bold(),
                          Text('loginDescription').tr(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const Gap(8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      context.router.push(const AboutRoute());
                    },
                    iconSize: 18,
                    color: Theme.of(context).colorScheme.secondary,
                    icon: const Icon(Icons.info, fill: 1),
                    tooltip: 'about'.tr(),
                  ),
                  if (isDeveloperMode)
                    IconButton(
                      icon: const Icon(Icons.bug_report, fill: 1),
                      onPressed: () {
                        toggleDebugOverlay(ref);
                      },
                      iconSize: 18,
                      color: Theme.of(context).colorScheme.secondary,
                      tooltip: 'debugOptions'.tr(),
                    ),
                  IconButton(
                    onPressed: () {
                      context.router.push(const SettingsRoute());
                    },
                    icon: const Icon(Icons.settings, fill: 1),
                    iconSize: 18,
                    color: Theme.of(context).colorScheme.secondary,
                    tooltip: 'appSettings'.tr(),
                  ),
                ],
              ),
            ],
          ),
        ).center(),
      ),
    );
  }
}

/// The page's head: the artwork, the avatar that hangs over its dissolving
/// edge, and the name. Kept as one widget because the three only read
/// correctly as one composition — the avatar's vertical center is the seam
/// between them, so they cannot be laid out independently.
class _AccountHeader extends ConsumerWidget {
  final SnAccount account;

  /// Status-bar inset, used only by the no-artwork layout: with artwork the
  /// reflected band above already covers the status bar.
  final double statusTop;

  /// Height of the band above the artwork that this widget paints into, or 0
  /// when there is no artwork to reflect.
  final double reflectionBand;

  final VoidCallback onAvatarTap;

  const _AccountHeader({
    required this.account,
    required this.statusTop,
    required this.reflectionBand,
    required this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final artwork = account.profile.background;

    // Without artwork there is nothing to hang an avatar over: the page opens
    // on the identity block, tight to the pill, instead of reserving two
    // hundred pixels of empty surface for a picture that does not exist.
    if (artwork == null) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          SolSpace.xl,
          statusTop + kPillAppBarHeight + SolSpace.md,
          SolSpace.xl,
          SolSpace.md,
        ),
        child: _AccountIdentity(
          account: account,
          avatarRadius: _kAccountAvatarRadius,
          onAvatarTap: onAvatarTap,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: _kAccountBannerHeight,
          child: Stack(
            // The avatar hangs past the artwork's edge, and the reflected band
            // hangs above it; both need to paint outside this box.
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                // Fading the surface out instead of cutting it means the
                // picture settles into whatever the page is painted with — a
                // theme surface, or the user's own background image — with no
                // color to match, and the avatar's seam never sits against a
                // hard edge.
                child: ShaderMask(
                  blendMode: BlendMode.dstIn,
                  shaderCallback: (bounds) => const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF000000),
                      Color(0xFF000000),
                      Color(0x00000000),
                    ],
                    stops: [0.0, 0.93, 1.0],
                  ).createShader(bounds),
                  child: Stack(
                    key: const ValueKey('header-image'),
                    fit: StackFit.expand,
                    children: [
                      CloudImageWidget(
                        file: artwork,
                        fit: BoxFit.cover,
                        imageOnly: true,
                      ),
                      // Enough shade at the very top that a pale sky does not
                      // swallow the pill's controls; it ends well before the
                      // picture's own detail.
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              colorScheme.scrim.withValues(alpha: 0.32),
                              colorScheme.scrim.withValues(alpha: 0),
                            ],
                            stops: const [0.0, 0.45],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (reflectionBand > 0)
                Positioned(
                  top: -reflectionBand,
                  left: 0,
                  right: 0,
                  height: reflectionBand + kArtworkReflectionFeather,
                  child: ArtworkReflection(
                    image: CloudImageWidget.provider(
                      file: artwork,
                      serverUrl: ref.watch(serverUrlProvider),
                    ),
                    band: reflectionBand,
                  ),
                ),
              Positioned(
                left: SolSpace.xl,
                // The avatar's center sits on the artwork's lower edge, so
                // half of it is over the picture and half over the page. The
                // fall-off above is kept short and late for exactly this: the
                // overlap has to land on solid image, not on a fog band.
                bottom: -_kAccountAvatarRadius,
                child: _AccountAvatar(
                  account: account,
                  radius: _kAccountAvatarRadius,
                  onTap: onAvatarTap,
                ),
              ),
            ],
          ),
        ),
        Padding(
          // Clears the avatar's lower half, then the name's own leading.
          padding: const EdgeInsets.fromLTRB(
            SolSpace.xl,
            _kAccountAvatarRadius + SolSpace.md,
            SolSpace.xl,
            0,
          ),
          child: _AccountIdentity(
            account: account,
            avatarRadius: 0,
            onAvatarTap: onAvatarTap,
          ),
        ),
      ],
    );
  }
}

/// The avatar as it appears on the page: a soft shadow rather than a ring,
/// because a ring has to match the surface behind it and a shadow does not.
class _AccountAvatar extends StatelessWidget {
  final SnAccount account;
  final double radius;
  final VoidCallback onTap;

  const _AccountAvatar({
    required this.account,
    required this.radius,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.shadow.withValues(alpha: 0.18),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ProfilePictureWidget(
          file: account.profile.picture,
          fallbackName: account.nick,
          radius: radius,
        ),
      ),
    );
  }
}

/// Name, handle and bio.
///
/// [avatarRadius] is only used by the arrangement that has no artwork, where
/// the avatar sits inline and the block has to clear it.
class _AccountIdentity extends StatelessWidget {
  final SnAccount account;
  final double avatarRadius;
  final VoidCallback onAvatarTap;

  const _AccountIdentity({
    required this.account,
    required this.avatarRadius,
    required this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: SolSpace.xxs,
      children: [
        AccountName(
          account: account,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            height: 1.15,
          ),
        ),
        Text(
          '@${account.name}',
          style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
        ),
        const Gap(SolSpace.xs),
        Text(
          account.profile.bio.isNotEmpty
              ? account.profile.bio
              : 'descriptionNone'.tr(),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
      ],
    );

    if (avatarRadius == 0) return text;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: SolSpace.md,
      children: [
        _AccountAvatar(
          account: account,
          radius: avatarRadius,
          onTap: onAvatarTap,
        ),
        Expanded(child: text),
      ],
    );
  }
}
