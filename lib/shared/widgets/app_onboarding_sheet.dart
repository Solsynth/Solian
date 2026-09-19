import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:island/auth/create_account_modal.dart';
import 'package:island/auth/login_modal.dart';
import 'package:material_ui/material_ui.dart';

const _kMaxWidth = 520.0;
const _kMotion = Duration(milliseconds: 280);

/// First-launch introduction. Shown once per install, so the flow stays short:
/// three flat pages, no imagery, and no version-update variant.
Future<void> showAppOnboardingSheet(
  BuildContext context, {
  required bool suggestAuth,
}) async {
  await Navigator.of(context, rootNavigator: true).push<void>(
    _OnboardingRoute(
      suggestAuth: suggestAuth,
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

class _OnboardingRoute extends PageRouteBuilder<void> {
  _OnboardingRoute({
    required bool suggestAuth,
    required VoidCallback onLogin,
    required VoidCallback onCreateAccount,
  }) : super(
         transitionDuration: const Duration(milliseconds: 400),
         reverseTransitionDuration: const Duration(milliseconds: 240),
         opaque: true,
         pageBuilder: (context, animation, secondaryAnimation) =>
             _OnboardingScreen(
               suggestAuth: suggestAuth,
               onLogin: onLogin,
               onCreateAccount: onCreateAccount,
             ),
         transitionsBuilder: (context, animation, secondaryAnimation, child) =>
             FadeTransition(
               opacity: CurvedAnimation(
                 parent: animation,
                 curve: Curves.easeOut,
               ),
               child: child,
             ),
       );
}

class _OnboardingPageData {
  final String title;
  final String description;

  const _OnboardingPageData({
    required this.title,
    required this.description,
  });
}

class _OnboardingScreen extends HookWidget {
  final bool suggestAuth;
  final VoidCallback onLogin;
  final VoidCallback onCreateAccount;

  const _OnboardingScreen({
    required this.suggestAuth,
    required this.onLogin,
    required this.onCreateAccount,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final pageController = usePageController();
    final currentPage = useState(0);
    final pages = [
      _OnboardingPageData(
        title: 'onboardingWelcomeTitle'.tr(),
        description: 'onboardingWelcomeDesc'.tr(),
      ),
      _OnboardingPageData(
        title: 'onboardingRealmsTitle'.tr(),
        description: 'onboardingRealmsDesc'.tr(),
      ),
      _OnboardingPageData(
        title: 'onboardingStellarTitle'.tr(),
        description: 'onboardingStellarDesc'.tr(),
      ),
    ];

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _kMaxWidth),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 16, 28, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _OnboardingTopBar(
                      step: currentPage.value + 1,
                      total: pages.length,
                    ),
                    Expanded(
                      child: PageView.builder(
                        controller: pageController,
                        itemCount: pages.length,
                        onPageChanged: (index) => currentPage.value = index,
                        itemBuilder: (context, index) => _OnboardingPage(
                          key: ValueKey('onboarding_page_$index'),
                          data: pages[index],
                        ),
                      ),
                    ),
                    _OnboardingProgress(
                      pageCount: pages.length,
                      currentPage: currentPage.value,
                    ),
                    const SizedBox(height: 20),
                    _OnboardingActions(
                      isLastPage: currentPage.value == pages.length - 1,
                      suggestAuth: suggestAuth,
                      onContinue: () => pageController.nextPage(
                        duration: _kMotion,
                        curve: Curves.easeOutCubic,
                      ),
                      onFinish: () => Navigator.of(context).pop(),
                      onCreateAccount: () {
                        Navigator.of(context).pop();
                        onCreateAccount();
                      },
                      onLogin: () {
                        Navigator.of(context).pop();
                        onLogin();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Brand label plus the only position marker in the chrome. Numbering is
/// meaningful here: the flow is a fixed three-step sequence.
class _OnboardingTopBar extends StatelessWidget {
  final int step;
  final int total;

  const _OnboardingTopBar({required this.step, required this.total});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final style = theme.textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: 1.6,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Text(
            'SOLAR NETWORK',
            style: style?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.62),
            ),
          ),
          const Spacer(),
          Text(
            '${step.toString().padLeft(2, '0')} / '
            '${total.toString().padLeft(2, '0')}',
            style: style?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.42),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingPageData data;

  const _OnboardingPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.title,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                data.description,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.62),
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingProgress extends StatelessWidget {
  final int pageCount;
  final int currentPage;

  const _OnboardingProgress({
    required this.pageCount,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final animate = !MediaQuery.disableAnimationsOf(context);
    final filled = (currentPage + 1) / pageCount;
    return LayoutBuilder(
      builder: (context, constraints) => Container(
        height: 2,
        width: double.infinity,
        decoration: BoxDecoration(
          color: colorScheme.onSurface.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: AnimatedContainer(
            duration: animate ? _kMotion : Duration.zero,
            curve: Curves.easeOutCubic,
            width: constraints.maxWidth * filled,
            height: 2,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingActions extends StatelessWidget {
  final bool isLastPage;
  final bool suggestAuth;
  final VoidCallback onContinue;
  final VoidCallback onFinish;
  final VoidCallback onCreateAccount;
  final VoidCallback onLogin;

  const _OnboardingActions({
    required this.isLastPage,
    required this.suggestAuth,
    required this.onContinue,
    required this.onFinish,
    required this.onCreateAccount,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Reserved on every page so the primary button and the progress line
        // never move when the account choices appear.
        if (suggestAuth)
          Visibility(
            visible: isLastPage,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: onCreateAccount,
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
                        child: Text('onboardingLogIn'.tr()),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        SizedBox(
          height: 52,
          child: FilledButton(
            onPressed: isLastPage ? onFinish : onContinue,
            child: Text(
              isLastPage && suggestAuth
                  ? 'onboardingContinueAnonymous'.tr()
                  : 'onboardingContinue'.tr(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
