import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:island/accounts/widgets/account/stellar_program_tab.dart';
import 'package:island/auth/create_account_modal.dart';
import 'package:island/auth/login_modal.dart';
import 'package:island/core/config.dart';
import 'package:island/shared/widgets/content/markdown.dart';
import 'package:material_ui/material_ui.dart';
import 'package:solsynth_express/solsynth_express.dart';

Future<void> showAppOnboardingSheet(
  BuildContext context, {
  required String version,
  required bool isFirstLaunch,
  required bool suggestAuth,
  bool updateChecksEnabled = true,
  String updateChannel = kDefaultUpdateChannel,
}) async {
  await Navigator.of(context, rootNavigator: true).push<void>(
    _OnboardingRoute(
      version: version,
      isFirstLaunch: isFirstLaunch,
      suggestAuth: suggestAuth,
      updateChecksEnabled: updateChecksEnabled,
      updateChannel: updateChannel,
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

/// Opens the membership details as a screen so the onboarding flow never nests
/// a second bottom sheet inside its full-screen route.
void showStellarProgramSheet(BuildContext context) {
  Navigator.of(context, rootNavigator: true).push<void>(
    MaterialPageRoute<void>(builder: (_) => const _StellarProgramScreen()),
  );
}

class _OnboardingRoute extends PageRouteBuilder<void> {
  _OnboardingRoute({
    required String version,
    required bool isFirstLaunch,
    required bool suggestAuth,
    required bool updateChecksEnabled,
    required String updateChannel,
    required VoidCallback onLogin,
    required VoidCallback onCreateAccount,
  }) : super(
         transitionDuration: const Duration(milliseconds: 600),
         reverseTransitionDuration: const Duration(milliseconds: 350),
         opaque: true,
         pageBuilder: (context, animation, secondaryAnimation) =>
             _OnboardingScreen(
               version: version,
               isFirstLaunch: isFirstLaunch,
               suggestAuth: suggestAuth,
               updateChecksEnabled: updateChecksEnabled,
               updateChannel: updateChannel,
               onLogin: onLogin,
               onCreateAccount: onCreateAccount,
             ),
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           final curved = CurvedAnimation(
             parent: animation,
             curve: Curves.easeOutCubic,
           );
           return FadeTransition(
             opacity: curved,
             child: ScaleTransition(
               scale: Tween<double>(begin: 0.97, end: 1).animate(curved),
               child: child,
             ),
           );
         },
       );
}

class _OnboardingPageData {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final String? changelog;
  final bool isPerksPage;
  final _PerksType? perksType;

  const _OnboardingPageData({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    this.changelog,
    this.isPerksPage = false,
    this.perksType,
  });
}

enum _PerksType { boosts, identity, tiers }

class _OnboardingScreen extends HookWidget {
  final String version;
  final bool isFirstLaunch;
  final bool suggestAuth;
  final bool updateChecksEnabled;
  final String updateChannel;
  final VoidCallback onLogin;
  final VoidCallback onCreateAccount;

  const _OnboardingScreen({
    required this.version,
    required this.isFirstLaunch,
    required this.suggestAuth,
    required this.updateChecksEnabled,
    required this.updateChannel,
    required this.onLogin,
    required this.onCreateAccount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final pageController = usePageController();
    final currentPage = useState(0);
    final changelog = useState<String?>(null);
    final isLoading = useState(!isFirstLaunch);

    useEffect(() {
      if (isFirstLaunch) return null;

      UpdateService(
            channel: updateChannel,
            productId: kDistributionProductId,
            enabled: updateChecksEnabled,
          )
          .fetchLatestRelease()
          .then((release) {
            changelog.value = release?.body;
            isLoading.value = false;
          })
          .catchError((_) {
            isLoading.value = false;
          });
      return null;
    }, [isFirstLaunch, updateChecksEnabled, updateChannel]);

    final pages = _buildPages(
      colorScheme,
      changelog: changelog.value,
      isLoading: isLoading.value,
    );

    return PopScope(
      canPop: !isFirstLaunch,
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.surface,
                      Color.alphaBlend(
                        colorScheme.primary.withValues(alpha: 0.06),
                        colorScheme.surface,
                      ),
                      colorScheme.surface,
                    ],
                    stops: const [0, 0.5, 1],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: _SignalBackdrop(
                accent: colorScheme.primary,
                animate: !MediaQuery.disableAnimationsOf(context),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                child: Column(
                  children: [
                    _OnboardingHeader(
                      version: version,
                      canClose: !isFirstLaunch,
                      onClose: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: isLoading.value
                          ? _OnboardingLoading(version: version)
                          : PageView.builder(
                              controller: pageController,
                              itemCount: pages.length,
                              onPageChanged: (index) {
                                currentPage.value = index;
                              },
                              itemBuilder: (context, index) {
                                return _OnboardingPage(
                                  key: ValueKey(
                                    isFirstLaunch
                                        ? 'first_$index'
                                        : 'update_$index',
                                  ),
                                  pageNumber: index + 1,
                                  pageCount: pages.length,
                                  data: pages[index],
                                  isActive: currentPage.value == index,
                                  isLastPage: index == pages.length - 1,
                                );
                              },
                            ),
                    ),
                    if (!isLoading.value) ...[
                      _SignalProgress(
                        pageCount: pages.length,
                        currentPage: currentPage.value,
                        accent: colorScheme.primary,
                      ),
                      const SizedBox(height: 18),
                      _FlowControls(
                        currentPage: currentPage.value,
                        pageCount: pages.length,
                        pageController: pageController,
                        suggestAuth: suggestAuth && isFirstLaunch,
                        isFirstLaunch: isFirstLaunch,
                        onFinish: () => Navigator.of(context).pop(),
                        onCreateAccount: () {
                          Navigator.of(context).pop();
                          onCreateAccount();
                        },
                        onLogin: () {
                          Navigator.of(context).pop();
                          onLogin();
                        },
                        onSkip: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_OnboardingPageData> _buildPages(
    ColorScheme colorScheme, {
    required String? changelog,
    required bool isLoading,
  }) {
    if (!isFirstLaunch) {
      return [
        if (!isLoading)
          _OnboardingPageData(
            icon: Icons.rocket_launch_rounded,
            iconColor: colorScheme.primary,
            title: 'onboardingWhatsNewTitle'.tr(args: [version]),
            description: 'onboardingWhatsNewDesc'.tr(),
            changelog: changelog,
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
      ];
    }

    return [
      _OnboardingPageData(
        icon: Icons.favorite_rounded,
        iconColor: colorScheme.primary,
        title: 'onboardingWelcomeTitle'.tr(),
        description: 'onboardingWelcomeDesc'.tr(),
      ),
      _OnboardingPageData(
        icon: Icons.edit_note_rounded,
        iconColor: Colors.orange,
        title: 'onboardingExpressTitle'.tr(),
        description: 'onboardingExpressDesc'.tr(),
      ),
      _OnboardingPageData(
        icon: Icons.groups_rounded,
        iconColor: Colors.teal,
        title: 'onboardingRealmsTitle'.tr(),
        description: 'onboardingRealmsDesc'.tr(),
      ),
      _OnboardingPageData(
        icon: Icons.chat_rounded,
        iconColor: Colors.indigo,
        title: 'onboardingChatTitle'.tr(),
        description: 'onboardingChatDesc'.tr(),
      ),
      _OnboardingPageData(
        icon: Icons.star_rounded,
        iconColor: Colors.amber,
        title: 'onboardingStellarTitle'.tr(),
        description: 'onboardingStellarDesc'.tr(),
      ),
    ];
  }
}

class _OnboardingHeader extends StatelessWidget {
  final String version;
  final bool canClose;
  final VoidCallback onClose;

  const _OnboardingHeader({
    required this.version,
    required this.canClose,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final utilityStyle = theme.textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: 1.8,
      color: colorScheme.onSurface.withValues(alpha: 0.62),
    );
    return Row(
      children: [
        Text('SOLAR NETWORK', style: utilityStyle),
        const Spacer(),
        Text(
          'v$version',
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.48),
          ),
        ),
        if (canClose) ...[
          const SizedBox(width: 8),
          IconButton(
            onPressed: onClose,
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            icon: const Icon(Icons.close_rounded),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ],
    );
  }
}

class _OnboardingLoading extends StatelessWidget {
  final String version;

  const _OnboardingLoading({required this.version});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'onboardingWhatsNewTitle'.tr(args: [version]),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatefulWidget {
  final int pageNumber;
  final int pageCount;
  final _OnboardingPageData data;
  final bool isActive;
  final bool isLastPage;

  const _OnboardingPage({
    super.key,
    required this.pageNumber,
    required this.pageCount,
    required this.data,
    required this.isActive,
    required this.isLastPage,
  });

  @override
  State<_OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<_OnboardingPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _heroScale;
  late final Animation<double> _heroOpacity;
  late final Animation<double> _copyOffset;
  late final Animation<double> _copyOpacity;
  bool _reducedMotion = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 720),
      vsync: this,
    );
    _heroScale = Tween<double>(begin: 0.72, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.6, curve: Curves.easeOutBack),
      ),
    );
    _heroOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.28, curve: Curves.easeOut),
      ),
    );
    _copyOffset = Tween<double>(begin: 28, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.18, 0.72, curve: Curves.easeOutCubic),
      ),
    );
    _copyOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.22, 0.85, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reducedMotion = MediaQuery.disableAnimationsOf(context);
    if (_reducedMotion) {
      _controller.value = 1;
    } else if (widget.isActive && !_controller.isAnimating) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant _OnboardingPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      if (_reducedMotion) {
        _controller.value = 1;
      } else {
        _controller.forward(from: 0);
      }
    } else if (!widget.isActive && oldWidget.isActive && !_reducedMotion) {
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _copyOpacity.value,
          child: Transform.translate(
            offset: Offset(0, _copyOffset.value),
            child: child,
          ),
        );
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final minHeight = math.max(0.0, constraints.maxHeight - 32);
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: minHeight),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${widget.pageNumber.toString().padLeft(2, '0')} · '
                        '${widget.pageCount.toString().padLeft(2, '0')}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.4,
                          color: colorScheme.onSurface.withValues(alpha: 0.46),
                        ),
                      ),
                      const SizedBox(height: 12),
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _heroOpacity.value,
                            child: Transform.scale(
                              scale: _heroScale.value,
                              child: child,
                            ),
                          );
                        },
                        child: _OrbitHero(
                          icon: widget.data.icon,
                          color: widget.data.iconColor,
                          animate: !_reducedMotion,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        widget.data.title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1.15,
                              height: 1.02,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.data.description,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                          height: 1.48,
                        ),
                      ),
                      if (widget.data.changelog?.isNotEmpty == true) ...[
                        const SizedBox(height: 22),
                        _ChangelogCard(content: widget.data.changelog!),
                      ],
                      if (widget.data.isPerksPage) ...[
                        const SizedBox(height: 22),
                        _buildPerksContent(context, widget.data.perksType),
                        if (widget.isLastPage) ...[
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: () => showStellarProgramSheet(context),
                            icon: const Icon(
                              Icons.open_in_new_rounded,
                              size: 18,
                            ),
                            label: Text('onboardingViewFullDetails'.tr()),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPerksContent(BuildContext context, _PerksType? type) {
    switch (type) {
      case _PerksType.boosts:
        return const _RealmBoostsTable();
      case _PerksType.identity:
        return const _LabelsIdentityTable();
      case _PerksType.tiers:
      default:
        return const _StellarPerksTable();
    }
  }
}

class _OrbitHero extends StatefulWidget {
  final IconData icon;
  final Color color;
  final bool animate;

  const _OrbitHero({
    required this.icon,
    required this.color,
    required this.animate,
  });

  @override
  State<_OrbitHero> createState() => _OrbitHeroState();
}

class _OrbitHeroState extends State<_OrbitHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 9),
      vsync: this,
    );
    if (widget.animate) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant _OrbitHero oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !oldWidget.animate) {
      _controller.repeat();
    } else if (!widget.animate && oldWidget.animate) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 196,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _OrbitPainter(
              color: widget.color,
              phase: _controller.value * math.pi * 2,
            ),
            child: Center(child: child),
          );
        },
        child: Container(
          width: 92,
          height: 92,
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: widget.color.withValues(alpha: 0.34),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.16),
                blurRadius: 34,
                spreadRadius: 3,
              ),
            ],
          ),
          child: Icon(widget.icon, size: 44, color: widget.color),
        ),
      ),
    );
  }
}

class _OrbitPainter extends CustomPainter {
  final Color color;
  final double phase;

  const _OrbitPainter({required this.color, required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final shortestSide = math.min(size.width, size.height);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = color.withValues(alpha: 0.24);
    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: shortestSide * 0.84,
        height: shortestSide * 0.32,
      ),
      paint,
    );
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-0.5);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: shortestSide * 0.92,
        height: shortestSide * 0.38,
      ),
      paint..color = color.withValues(alpha: 0.16),
    );
    canvas.restore();

    final dotPaint = Paint()..style = PaintingStyle.fill;
    for (var index = 0; index < 7; index++) {
      final angle = phase + index * math.pi * 2 / 7;
      final radiusX = shortestSide * 0.42;
      final radiusY = shortestSide * 0.16;
      final dot = Offset(
        center.dx + math.cos(angle) * radiusX,
        center.dy + math.sin(angle) * radiusY,
      );
      dotPaint.color = color.withValues(alpha: index.isEven ? 0.72 : 0.28);
      canvas.drawCircle(dot, index.isEven ? 3 : 2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) =>
      oldDelegate.phase != phase || oldDelegate.color != color;
}

class _SignalBackdrop extends StatefulWidget {
  final Color accent;
  final bool animate;

  const _SignalBackdrop({required this.accent, required this.animate});

  @override
  State<_SignalBackdrop> createState() => _SignalBackdropState();
}

class _SignalBackdropState extends State<_SignalBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 16),
      vsync: this,
    );
    if (widget.animate) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant _SignalBackdrop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !oldWidget.animate) {
      _controller.repeat();
    } else if (!widget.animate && oldWidget.animate) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _BackdropPainter(
              accent: widget.accent,
              phase: _controller.value * math.pi * 2,
            ),
          );
        },
      ),
    );
  }
}

class _BackdropPainter extends CustomPainter {
  final Color accent;
  final double phase;

  const _BackdropPainter({required this.accent, required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = accent.withValues(alpha: 0.045);
    final center = Offset(size.width * 0.78, size.height * 0.18);
    for (var index = 0; index < 4; index++) {
      final inset = index * 44.0 + math.sin(phase) * 8;
      canvas.drawCircle(center, 105 + inset, paint);
    }
    final glow = Paint()
      ..style = PaintingStyle.fill
      ..color = accent.withValues(alpha: 0.035);
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.88),
      180 + math.cos(phase) * 12,
      glow,
    );
  }

  @override
  bool shouldRepaint(covariant _BackdropPainter oldDelegate) =>
      oldDelegate.phase != phase || oldDelegate.accent != accent;
}

class _ChangelogCard extends StatelessWidget {
  final String content;

  const _ChangelogCard({required this.content});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560, maxHeight: 260),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
        ),
        child: SingleChildScrollView(
          child: MarkdownTextContent(
            content: content,
            textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.72),
              height: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _SignalProgress extends StatelessWidget {
  final int pageCount;
  final int currentPage;
  final Color accent;

  const _SignalProgress({
    required this.pageCount,
    required this.currentPage,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Row(
          children: [
            for (var index = 0; index < pageCount; index++) ...[
              AnimatedContainer(
                duration: const Duration(milliseconds: 360),
                curve: Curves.easeOutCubic,
                width: currentPage == index ? 26 : 8,
                height: 6,
                decoration: BoxDecoration(
                  color: currentPage == index
                      ? accent
                      : colorScheme.onSurface.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              if (index != pageCount - 1)
                Expanded(
                  child: Container(
                    height: 1,
                    color: colorScheme.onSurface.withValues(alpha: 0.12),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FlowControls extends StatelessWidget {
  final int currentPage;
  final int pageCount;
  final PageController pageController;
  final bool suggestAuth;
  final bool isFirstLaunch;
  final VoidCallback onFinish;
  final VoidCallback onCreateAccount;
  final VoidCallback onLogin;
  final VoidCallback onSkip;

  const _FlowControls({
    required this.currentPage,
    required this.pageCount,
    required this.pageController,
    required this.suggestAuth,
    required this.isFirstLaunch,
    required this.onFinish,
    required this.onCreateAccount,
    required this.onLogin,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final isLastPage = currentPage == pageCount - 1;
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      child: Align(
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: () {
                    if (isLastPage) {
                      onFinish();
                      return;
                    }
                    pageController.nextPage(
                      duration: const Duration(milliseconds: 480),
                      curve: Curves.easeOutCubic,
                    );
                  },
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: Icon(
                      isLastPage
                          ? Icons.check_rounded
                          : Icons.arrow_forward_rounded,
                      key: ValueKey(isLastPage),
                    ),
                  ),
                  label: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: Text(
                      isLastPage
                          ? (isFirstLaunch
                                ? 'onboardingContinueAnonymous'.tr()
                                : 'onboardingGotIt'.tr())
                          : 'onboardingContinue'.tr(),
                      key: ValueKey(isLastPage),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
              if (suggestAuth && isLastPage) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: OutlinedButton(
                          onPressed: onCreateAccount,
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            side: BorderSide(
                              color: colorScheme.primary.withValues(
                                alpha: 0.45,
                              ),
                            ),
                          ),
                          child: Text('onboardingCreateAccount'.tr()),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: TextButton(
                          onPressed: onLogin,
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text('onboardingLogIn'.tr()),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (!isFirstLaunch && !suggestAuth) ...[
                const SizedBox(height: 2),
                TextButton(
                  onPressed: onSkip,
                  child: Text(
                    'onboardingSkipForNow'.tr(),
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.52),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StellarProgramScreen extends StatelessWidget {
  const _StellarProgramScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('onboardingStellarTitle'.tr())),
      body: const SafeArea(child: StellarProgramView()),
    );
  }
}

class _ComparisonTable extends StatelessWidget {
  final List<String> headers;
  final List<List<String>> rows;
  final List<Color> headerColors;

  const _ComparisonTable({
    required this.headers,
    required this.rows,
    required this.headerColors,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.64),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.16)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.58),
            child: _ComparisonRow(
              values: headers,
              colors: headerColors,
              bold: true,
            ),
          ),
          for (var index = 0; index < rows.length; index++)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                border: index == rows.length - 1
                    ? null
                    : Border(
                        bottom: BorderSide(
                          color: colorScheme.outline.withValues(alpha: 0.1),
                        ),
                      ),
              ),
              child: _ComparisonRow(values: rows[index]),
            ),
        ],
      ),
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  final List<String> values;
  final List<Color>? colors;
  final bool bold;

  const _ComparisonRow({required this.values, this.colors, this.bold = false});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            values.first,
            style: TextStyle(
              fontSize: bold ? 11 : 12,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              color: colorScheme.onSurface.withValues(
                alpha: bold ? 0.68 : 0.84,
              ),
            ),
          ),
        ),
        for (var index = 1; index < values.length; index++)
          Expanded(
            child: Text(
              values[index],
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: bold ? 11 : 11,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                color: colors != null && index < colors!.length
                    ? colors![index]
                    : colorScheme.onSurface.withValues(alpha: 0.68),
              ),
            ),
          ),
      ],
    );
  }
}

class _RealmBoostsTable extends StatelessWidget {
  const _RealmBoostsTable();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return _ComparisonTable(
      headers: [
        'onboardingLevel'.tr(),
        'onboardingLv1'.tr(),
        'onboardingLv2'.tr(),
        'onboardingLv3'.tr(),
      ],
      rows: [
        ['onboardingCustomLabel'.tr(), '✓', '✓', '✓'],
        ['onboardingExtraQuota'.tr(), '', '✓', '✓'],
        ['onboardingBoostedVisibility'.tr(), '', '✓', '✓'],
        ['onboardingMaxQuota'.tr(), '', '', '✓'],
      ],
      headerColors: [Colors.transparent, primary, primary, primary],
    );
  }
}

class _LabelsIdentityTable extends StatelessWidget {
  const _LabelsIdentityTable();

  @override
  Widget build(BuildContext context) {
    return _ComparisonTable(
      headers: const ['Features', 'Stellar', 'Nova', 'Supernova'],
      rows: const [
        ['Realm nick', 'Not Incl.', 'Incl.', 'Incl.'],
        ['Realm bio', 'Not Incl.', 'Incl.', 'Incl.'],
        ['Chat nick', 'Not Incl.', 'Incl.', 'Incl.'],
      ],
      headerColors: const [
        Colors.transparent,
        Colors.blue,
        Colors.purple,
        Colors.orange,
      ],
    );
  }
}

class _StellarPerksTable extends StatelessWidget {
  const _StellarPerksTable();

  @override
  Widget build(BuildContext context) {
    return _ComparisonTable(
      headers: const ['Benefit', 'Stellar', 'Nova', 'Supernova'],
      rows: const [
        ['Cloud storage', '5GB', '10GB', '15GB'],
        ['Username color', 'Limited', 'Unlimited', 'Unlimited + gradient'],
        ['Translation', 'Included', 'Included', 'Included'],
        ['Leveling boost', '1.5x', '2x', '2.5x'],
        ['Verification', 'Eligible', 'Eligible', 'Eligible'],
        ['Publisher quota', '2/3/5*', 'Same', 'Same'],
        ['Realm quota', 'Not included', '0-3*', 'Same'],
        ['Bot quota', 'Not included', '0-3*', 'Same'],
      ],
      headerColors: const [
        Colors.transparent,
        Colors.blue,
        Colors.purple,
        Colors.orange,
      ],
    );
  }
}
