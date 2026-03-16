import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:island/auth/create_account_modal.dart';
import 'package:island/auth/login_modal.dart';

Future<void> showAppOnboardingSheet(
  BuildContext context, {
  required String version,
  required bool isFirstLaunch,
  required bool suggestAuth,
}) async {
  final fullHeight = MediaQuery.sizeOf(context).height * 0.75;
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

class _OnboardingPageData {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final List<_FeatureItem>? features;

  const _OnboardingPageData({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    this.features,
  });
}

class _FeatureItem {
  final IconData icon;
  final String label;

  const _FeatureItem({required this.icon, required this.label});
}

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

    final List<_OnboardingPageData> firstLaunchPages = [
      _OnboardingPageData(
        icon: Icons.favorite_rounded,
        iconColor: colorScheme.primary,
        title: 'Welcome to Solar Network',
        description:
            'A peaceful space to express yourself freely and connect with others. Join a vibrant community built on respect and creativity.',
        features: const [
          _FeatureItem(icon: Icons.people_outline, label: 'Friendly community'),
          _FeatureItem(
            icon: Icons.privacy_tip_outlined,
            label: 'Your privacy matters',
          ),
          _FeatureItem(
            icon: Icons.rocket_launch_outlined,
            label: 'No pressure',
          ),
        ],
      ),
      _OnboardingPageData(
        icon: Icons.edit_note_rounded,
        iconColor: Colors.orange,
        title: 'Express Yourself',
        description:
            'Share your thoughts with Posts, write long-form Articles, or capture moments with Moments — choose the format that fits your story.',
        features: const [
          _FeatureItem(icon: Icons.article_outlined, label: 'Posts & Articles'),
          _FeatureItem(
            icon: Icons.auto_awesome_outlined,
            label: 'Rich formatting',
          ),
          _FeatureItem(icon: Icons.image_outlined, label: 'Media support'),
        ],
      ),
      _OnboardingPageData(
        icon: Icons.groups_rounded,
        iconColor: Colors.teal,
        title: 'Join Realms',
        description:
            'Discover communities organized by shared interests. From hobby groups to creative collectives, find your people.',
        features: const [
          _FeatureItem(
            icon: Icons.explore_outlined,
            label: 'Discover communities',
          ),
          _FeatureItem(icon: Icons.topic_outlined, label: 'Topic-based'),
          _FeatureItem(
            icon: Icons.celebration_outlined,
            label: 'Events & more',
          ),
        ],
      ),
      _OnboardingPageData(
        icon: Icons.chat_rounded,
        iconColor: Colors.indigo,
        title: 'Chat Instantly',
        description:
            'Connect through real-time messaging with friends and group chats. Stay in touch across all your devices.',
        features: const [
          _FeatureItem(
            icon: Icons.security_outlined,
            label: 'End-to-end encryption supported',
          ),
          _FeatureItem(icon: Icons.group_outlined, label: 'Group chats'),
          _FeatureItem(icon: Icons.devices_outlined, label: 'Cross-device'),
        ],
      ),
      _OnboardingPageData(
        icon: Icons.star_rounded,
        iconColor: Colors.amber,
        title: 'Stellar Program',
        description:
            'Unlock exclusive benefits with our membership program. Earn rewards, access premium features, and support the community.',
        features: const [
          _FeatureItem(
            icon: Icons.workspace_premium_outlined,
            label: 'Premium features',
          ),
          _FeatureItem(
            icon: Icons.card_giftcard_outlined,
            label: 'Exclusive rewards',
          ),
          _FeatureItem(
            icon: Icons.volunteer_activism_outlined,
            label: 'Support the community',
          ),
        ],
      ),
    ];

    final List<_OnboardingPageData> whatsNewPages = [
      _OnboardingPageData(
        icon: Icons.rocket_launch_rounded,
        iconColor: colorScheme.primary,
        title: "What's New in $version",
        description:
            'Check out the latest features and improvements we\'ve brought to Solar Network.',
        features: const [
          _FeatureItem(
            icon: Icons.upgrade_outlined,
            label: 'Performance boost',
          ),
          _FeatureItem(icon: Icons.tune_outlined, label: 'Better experience'),
          _FeatureItem(icon: Icons.bug_report_outlined, label: 'Bug fixes'),
        ],
      ),
      _OnboardingPageData(
        icon: Icons.edit_note_rounded,
        iconColor: Colors.orange,
        title: 'Enhanced Content',
        description:
            'New ways to express yourself with improved Posts, Articles, and Moments.',
        features: const [
          _FeatureItem(icon: Icons.edit_outlined, label: 'Better editor'),
          _FeatureItem(icon: Icons.format_size_outlined, label: 'Rich text'),
          _FeatureItem(
            icon: Icons.photo_library_outlined,
            label: 'Media gallery',
          ),
        ],
      ),
      _OnboardingPageData(
        icon: Icons.chat_rounded,
        iconColor: Colors.indigo,
        title: 'Better Connections',
        description:
            'Improved chat experience with faster messaging and enhanced group support.',
        features: const [
          _FeatureItem(icon: Icons.speed_outlined, label: 'Faster delivery'),
          _FeatureItem(icon: Icons.group_add_outlined, label: 'Bigger groups'),
          _FeatureItem(
            icon: Icons.notifications_outlined,
            label: 'Smart alerts',
          ),
        ],
      ),
    ];

    final pages = isFirstLaunch ? firstLaunchPages : whatsNewPages;

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

  const _OnboardingPage({
    super.key,
    required this.data,
    required this.isActive,
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
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _iconScale.value,
                    child: Opacity(opacity: _iconOpacity.value, child: child),
                  );
                },
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        widget.data.iconColor.withValues(alpha: 0.15),
                        widget.data.iconColor.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Icon(
                    widget.data.icon,
                    size: 44,
                    color: widget.data.iconColor,
                  ),
                ),
              ),
              const SizedBox(height: 24),
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
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Opacity(opacity: _descFade.value, child: child);
                },
                child: Column(
                  children: [
                    Text(
                      widget.data.description,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (widget.data.features != null) ...[
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
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
            ],
          ),
        ),
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
                    ? (isFirstLaunch ? 'Get Started' : 'Got it')
                    : 'Continue',
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
          _SecondaryButton(text: 'Create Account', onPressed: onCreateAccount),
          const SizedBox(height: 8),
          _SecondaryButton(
            text: 'Log In',
            onPressed: onLogin,
            isOutlined: true,
          ),
        ],
        if (!isFirstLaunch && !suggestAuth) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: onSkip,
            child: Text(
              'Skip for now',
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
