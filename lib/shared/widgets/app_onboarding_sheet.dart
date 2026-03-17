import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:island/auth/create_account_modal.dart';
import 'package:island/auth/login_modal.dart';
import 'package:island/accounts/widgets/account/stellar_program_tab.dart';
import 'package:island/core/services/update_service.dart';

Future<void> showAppOnboardingSheet(
  BuildContext context, {
  required String version,
  required bool isFirstLaunch,
  required bool suggestAuth,
}) async {
  final fullHeight = MediaQuery.sizeOf(context).height * 0.80;
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    isDismissible: !isFirstLaunch,
    enableDrag: !isFirstLaunch,
    showDragHandle: !isFirstLaunch,
    useSafeArea: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (context) => _OnboardingSheet(
      version: version,
      isFirstLaunch: isFirstLaunch,
      suggestAuth: suggestAuth,
      height: fullHeight,
      onLogin: () => _showLoginSheet(context),
      onCreateAccount: () => _showCreateAccountSheet(context),
    ),
  );
}

void _showLoginSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    builder: (context) => const LoginModal(),
  );
}

void _showCreateAccountSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    builder: (context) => const CreateAccountModal(),
  );
}

void showStellarProgramSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(child: StellarProgramTab()),
        ],
      ),
    ),
  );
}

class _OnboardingPageData {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final List<_FeatureItem>? features;
  final String? changelog;
  final bool isPerksPage;
  final _PerksType? perksType;

  const _OnboardingPageData({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    this.features,
    this.changelog,
    this.isPerksPage = false,
    this.perksType,
  });
}

class _FeatureItem {
  final IconData icon;
  final String label;

  const _FeatureItem({required this.icon, required this.label});
}

enum _PerksType { boosts, identity, tiers }

class _OnboardingSheet extends HookWidget {
  final String version;
  final bool isFirstLaunch;
  final bool suggestAuth;
  final double height;
  final VoidCallback onLogin;
  final VoidCallback onCreateAccount;

  const _OnboardingSheet({
    required this.version,
    required this.isFirstLaunch,
    required this.suggestAuth,
    required this.height,
    required this.onLogin,
    required this.onCreateAccount,
  });

  @override
  Widget build(BuildContext context) {
    final pageController = usePageController();
    final currentPage = useState(0);
    final colorScheme = Theme.of(context).colorScheme;
    final changelog = useState<String?>(null);
    final isLoading = useState(true);

    useEffect(() {
      if (!isFirstLaunch) {
        UpdateService()
            .fetchLatestRelease()
            .then((release) {
              changelog.value = release?.body;
              isLoading.value = false;
            })
            .catchError((_) {
              isLoading.value = false;
            });
      } else {
        isLoading.value = false;
      }
      return null;
    }, [isFirstLaunch]);

    final List<_OnboardingPageData> firstLaunchPages = [
      _OnboardingPageData(
        icon: Icons.favorite_rounded,
        iconColor: colorScheme.primary,
        title: 'onboardingWelcomeTitle'.tr(),
        description: 'onboardingWelcomeDesc'.tr(),
        features: [
          _FeatureItem(
            icon: Icons.people_outline,
            label: 'onboardingFeatureFriendlyCommunity'.tr(),
          ),
          _FeatureItem(
            icon: Icons.privacy_tip_outlined,
            label: 'onboardingFeaturePrivacy'.tr(),
          ),
          _FeatureItem(
            icon: Icons.rocket_launch_outlined,
            label: 'onboardingFeatureNoPressure'.tr(),
          ),
        ],
      ),
      _OnboardingPageData(
        icon: Icons.edit_note_rounded,
        iconColor: Colors.orange,
        title: 'onboardingExpressTitle'.tr(),
        description: 'onboardingExpressDesc'.tr(),
        features: [
          _FeatureItem(
            icon: Icons.article_outlined,
            label: 'onboardingFeaturePostsArticles'.tr(),
          ),
          _FeatureItem(
            icon: Icons.auto_awesome_outlined,
            label: 'onboardingFeatureRichFormatting'.tr(),
          ),
          _FeatureItem(
            icon: Icons.image_outlined,
            label: 'onboardingFeatureMediaSupport'.tr(),
          ),
        ],
      ),
      _OnboardingPageData(
        icon: Icons.groups_rounded,
        iconColor: Colors.teal,
        title: 'onboardingRealmsTitle'.tr(),
        description: 'onboardingRealmsDesc'.tr(),
        features: [
          _FeatureItem(
            icon: Icons.explore_outlined,
            label: 'onboardingFeatureDiscover'.tr(),
          ),
          _FeatureItem(
            icon: Icons.topic_outlined,
            label: 'onboardingFeatureTopicBased'.tr(),
          ),
          _FeatureItem(
            icon: Icons.celebration_outlined,
            label: 'onboardingFeatureEvents'.tr(),
          ),
        ],
      ),
      _OnboardingPageData(
        icon: Icons.chat_rounded,
        iconColor: Colors.indigo,
        title: 'onboardingChatTitle'.tr(),
        description: 'onboardingChatDesc'.tr(),
        features: [
          _FeatureItem(
            icon: Icons.security_outlined,
            label: 'onboardingFeatureE2E'.tr(),
          ),
          _FeatureItem(
            icon: Icons.group_outlined,
            label: 'onboardingFeatureGroupChats'.tr(),
          ),
          _FeatureItem(
            icon: Icons.devices_outlined,
            label: 'onboardingFeatureCrossDevice'.tr(),
          ),
        ],
      ),
      _OnboardingPageData(
        icon: Icons.star_rounded,
        iconColor: Colors.amber,
        title: 'onboardingStellarTitle'.tr(),
        description: 'onboardingStellarDesc'.tr(),
        features: [
          _FeatureItem(
            icon: Icons.workspace_premium_outlined,
            label: 'onboardingFeaturePremium'.tr(),
          ),
          _FeatureItem(
            icon: Icons.card_giftcard_outlined,
            label: 'onboardingFeatureRewards'.tr(),
          ),
          _FeatureItem(
            icon: Icons.volunteer_activism_outlined,
            label: 'onboardingFeatureSupport'.tr(),
          ),
        ],
      ),
    ];

    final List<_OnboardingPageData> whatsNewPages = [
      if (!isLoading.value) ...[
        _OnboardingPageData(
          icon: Icons.rocket_launch_rounded,
          iconColor: colorScheme.primary,
          title: 'onboardingWhatsNewTitle'.tr(args: [version]),
          description: changelog.value?.isNotEmpty == true
              ? 'onboardingWhatsNewDesc'.tr()
              : 'onboardingWhatsNewDesc'.tr(),
          features: changelog.value?.isNotEmpty == true
              ? null
              : [
                  _FeatureItem(
                    icon: Icons.upgrade_outlined,
                    label: 'onboardingPerformance'.tr(),
                  ),
                  _FeatureItem(
                    icon: Icons.tune_outlined,
                    label: 'onboardingBetterExperience'.tr(),
                  ),
                  _FeatureItem(
                    icon: Icons.bug_report_outlined,
                    label: 'onboardingBugFixes'.tr(),
                  ),
                ],
          changelog: changelog.value,
        ),
        _OnboardingPageData(
          icon: Icons.speed_rounded,
          iconColor: Colors.green,
          title: 'onboardingRealmBoostsTitle'.tr(),
          description: 'onboardingRealmBoostsDesc'.tr(),
          isPerksPage: true,
          perksType: _PerksType.boosts,
        ),
        _OnboardingPageData(
          icon: Icons.badge_rounded,
          iconColor: Colors.purple,
          title: 'onboardingLabelIdentityTitle'.tr(),
          description: 'onboardingLabelIdentityDesc'.tr(),
          isPerksPage: true,
          perksType: _PerksType.identity,
        ),
        _OnboardingPageData(
          icon: Icons.star_rounded,
          iconColor: Colors.amber,
          title: 'onboardingStellarTitle'.tr(),
          description: 'onboardingStellarDesc'.tr(),
          isPerksPage: true,
          perksType: _PerksType.tiers,
        ),
      ],
    ];

    final pages = isFirstLaunch ? firstLaunchPages : whatsNewPages;

    if (isLoading.value && !isFirstLaunch) {
      return SafeArea(
        child: SizedBox(
          height: height,
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return SafeArea(
      child: SizedBox(
        height: height,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: pageController,
                  itemCount: pages.length,
                  onPageChanged: (idx) => currentPage.value = idx,
                  itemBuilder: (context, idx) {
                    final page = pages[idx];
                    return _OnboardingPage(
                      key: ValueKey(isFirstLaunch ? 'first_$idx' : 'new_$idx'),
                      data: page,
                      isActive: currentPage.value == idx,
                      isLastPage: idx == pages.length - 1,
                    );
                  },
                ),
              ),
              _PageIndicator(
                pageCount: pages.length,
                currentPage: currentPage.value,
              ),
              const SizedBox(height: 24),
              _ActionButtons(
                currentPage: currentPage.value,
                pageCount: pages.length,
                pageController: pageController,
                suggestAuth: suggestAuth && isFirstLaunch,
                onFinish: () => Navigator.pop(context),
                onCreateAccount: () {
                  Navigator.pop(context);
                  onCreateAccount();
                },
                onLogin: () {
                  Navigator.pop(context);
                  onLogin();
                },
                onSkip: () => Navigator.pop(context),
                isFirstLaunch: isFirstLaunch,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatefulWidget {
  final _OnboardingPageData data;
  final bool isActive;
  final bool isLastPage;

  const _OnboardingPage({
    super.key,
    required this.data,
    required this.isActive,
    this.isLastPage = false,
  });

  @override
  State<_OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<_OnboardingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _iconScale;
  late Animation<double> _iconOpacity;
  late Animation<double> _titleSlide;
  late Animation<double> _titleOpacity;
  late Animation<double> _descFade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _iconScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _iconOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    _titleSlide = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
      ),
    );

    _descFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    if (widget.isActive) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant _OnboardingPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller.forward(from: 0.0);
    } else if (!widget.isActive && oldWidget.isActive) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: widget.isActive ? 1.0 : 0.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _iconScale.value,
                  child: Opacity(opacity: _iconOpacity.value, child: child),
                );
              },
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.data.iconColor.withValues(alpha: 0.15),
                      widget.data.iconColor.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  widget.data.icon,
                  size: 36,
                  color: widget.data.iconColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _titleSlide.value),
                  child: Opacity(opacity: _titleOpacity.value, child: child),
                );
              },
              child: Text(
                widget.data.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(opacity: _descFade.value, child: child);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.data.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (widget.data.changelog != null &&
                      widget.data.changelog!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(maxHeight: 60),
                      child: SingleChildScrollView(
                        child: Text(
                          widget.data.changelog!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                        ),
                      ),
                    ),
                  ],
                  if (widget.data.isPerksPage) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 180,
                      child: SingleChildScrollView(
                        child: _buildPerksContent(widget.data.perksType),
                      ),
                    ),
                    if (widget.isLastPage) ...[
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => showStellarProgramSheet(context),
                        icon: const Icon(Icons.open_in_new, size: 18),
                        label: Text('onboardingViewFullDetails'.tr()),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 40),
                        ),
                      ),
                    ],
                  ],
                  if (widget.data.features != null &&
                      !widget.data.isPerksPage) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      alignment: WrapAlignment.center,
                      children: widget.data.features!
                          .map(
                            (f) => _FeatureChip(
                              icon: f.icon,
                              label: f.label,
                              color: widget.data.iconColor,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPerksContent(_PerksType? type) {
    switch (type) {
      case _PerksType.boosts:
        return _RealmBoostsTable();
      case _PerksType.identity:
        return _LabelsIdentityTable();
      case _PerksType.tiers:
      default:
        return _StellarPerksTable();
    }
  }
}

class _RealmBoostsTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(11),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Level',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Lv 1',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Lv 2',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Lv 3',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildBoostRow(context, 'onboardingCustomLabel'.tr(), '✓', '✓', '✓'),
          _buildBoostRow(context, 'onboardingExtraQuota'.tr(), '', '✓', '✓'),
          _buildBoostRow(
            context,
            'onboardingBoostedVisibility'.tr(),
            '',
            '✓',
            '✓',
          ),
          _buildBoostRow(
            context,
            'onboardingMaxQuota'.tr(),
            '',
            '',
            '✓',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildBoostRow(
    BuildContext context,
    String benefit,
    String lv1,
    String lv2,
    String lv3, {
    bool isLast = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.1),
                ),
              ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              benefit,
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
          Expanded(
            child: Text(
              lv1,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: colorScheme.primary),
            ),
          ),
          Expanded(
            child: Text(
              lv2,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: colorScheme.primary),
            ),
          ),
          Expanded(
            child: Text(
              lv3,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _LabelsIdentityTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(11),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Features',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Stellar',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Colors.blue,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Nova',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Colors.purple,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Supernova',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildLabelRow(context, 'Realm nick', 'Not Incl.', 'Incl.', 'Incl.'),
          _buildLabelRow(context, 'Realm bio', 'Not Incl.', 'Incl.', 'Incl.'),
          _buildLabelRow(context, 'Chat nick', 'Not Incl.', 'Incl.', 'Incl.'),
        ],
      ),
    );
  }

  Widget _buildLabelRow(
    BuildContext context,
    String feature,
    String stellar,
    String nova,
    String supernova, {
    bool isLast = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.1),
                ),
              ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              feature,
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
          for (var label in [stellar, nova, supernova])
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StellarPerksTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(11),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Benefit',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Stellar',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Colors.blue,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Nova',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Colors.purple,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Supernova',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildPerkRow(context, 'Cloud storage', '5GB', '10GB', '15GB'),
          _buildPerkRow(
            context,
            'Username color',
            'Limited',
            'Unlimited',
            'Unlimited + gradient',
          ),
          _buildPerkRow(
            context,
            'Translation',
            'Included',
            'Included',
            'Included',
          ),
          _buildPerkRow(context, 'Leveling boost', '1.5x', '2x', '2.5x'),
          _buildPerkRow(
            context,
            'Verification',
            'Eligible',
            'Eligible',
            'Eligible',
          ),
          _buildPerkRow(context, 'Publisher quota', '2/3/5*', 'Same', 'Same'),
          _buildPerkRow(context, 'Realm quota', 'Not included', '0-3*', 'Same'),
          _buildPerkRow(
            context,
            'Bot quota',
            'Not included',
            '0-3*',
            'Same',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPerkRow(
    BuildContext context,
    String benefit,
    String stellar,
    String nova,
    String supernova, {
    bool isLast = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.1),
                ),
              ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              benefit,
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
          Expanded(
            child: Text(
              stellar,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Colors.blue.withValues(alpha: 0.8),
              ),
            ),
          ),
          Expanded(
            child: Text(
              nova,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Colors.purple.withValues(alpha: 0.8),
              ),
            ),
          ),
          Expanded(
            child: Text(
              supernova,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Colors.orange.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _FeatureChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  final int pageCount;
  final int currentPage;

  const _PageIndicator({required this.pageCount, required this.currentPage});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        pageCount,
        (idx) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          width: currentPage == idx ? 28 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: currentPage == idx
                ? Theme.of(context).colorScheme.primary
                : Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(99),
          ),
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final int currentPage;
  final int pageCount;
  final PageController pageController;
  final bool suggestAuth;
  final VoidCallback onFinish;
  final VoidCallback onCreateAccount;
  final VoidCallback onLogin;
  final VoidCallback onSkip;
  final bool isFirstLaunch;

  const _ActionButtons({
    required this.currentPage,
    required this.pageCount,
    required this.pageController,
    required this.suggestAuth,
    required this.onFinish,
    required this.onCreateAccount,
    required this.onLogin,
    required this.onSkip,
    required this.isFirstLaunch,
  });

  @override
  Widget build(BuildContext context) {
    final isLastPage = currentPage == pageCount - 1;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton(
            onPressed: () {
              if (isLastPage) {
                onFinish();
                return;
              }
              pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
              );
            },
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                isLastPage
                    ? (isFirstLaunch
                          ? 'onboardingGetStarted'.tr()
                          : 'onboardingGotIt'.tr())
                    : 'onboardingContinue'.tr(),
                key: ValueKey(isLastPage),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        if (suggestAuth && isLastPage) ...[
          const SizedBox(height: 12),
          _SecondaryButton(
            text: 'onboardingCreateAccount'.tr(),
            onPressed: onCreateAccount,
          ),
          const SizedBox(height: 8),
          _SecondaryButton(
            text: 'onboardingLogIn'.tr(),
            onPressed: onLogin,
            isOutlined: true,
          ),
        ],
        if (!isFirstLaunch && !suggestAuth) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: onSkip,
            child: Text(
              'onboardingSkipForNow'.tr(),
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _SecondaryButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isOutlined;

  const _SecondaryButton({
    required this.text,
    required this.onPressed,
    this.isOutlined = false,
  });

  @override
  State<_SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<_SecondaryButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: widget.isOutlined
              ? OutlinedButton(
                  onPressed: null,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(widget.text),
                )
              : TextButton(onPressed: null, child: Text(widget.text)),
        ),
      ),
    );
  }
}
