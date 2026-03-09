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
  final fullHeight = MediaQuery.sizeOf(context).height;
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    isDismissible: !isFirstLaunch,
    enableDrag: !isFirstLaunch,
    showDragHandle: !isFirstLaunch,
    useSafeArea: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder:
        (context) => _OnboardingSheet(
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
    final pages = [
      (
        icon: Icons.waving_hand_rounded,
        title: isFirstLaunch ? 'Welcome to Solian' : 'What\'s new',
        description:
            isFirstLaunch
                ? 'Set up your feed, join realms, and start chatting in minutes.'
                : 'You\'re now on version $version. Here are a few highlights to try.',
      ),
      (
        icon: Icons.rocket_launch_rounded,
        title: 'Highlights',
        description:
            'Explore discovery feeds, realtime chat, creator hub tools, and better desktop integration.',
      ),
      (
        icon: Icons.account_circle_rounded,
        title: 'Account Benefits',
        description:
            'Sign in to sync preferences, publish content, and manage your profile across devices.',
      ),
    ];

    return SafeArea(
      child: SizedBox(
        height: height,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: PageView.builder(
                  controller: pageController,
                  itemCount: pages.length,
                  onPageChanged: (idx) => currentPage.value = idx,
                  itemBuilder: (context, idx) {
                    final page = pages[idx];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          page.icon,
                          size: 44,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          page.title,
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          page.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pages.length,
                  (idx) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: currentPage.value == idx ? 22 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color:
                          currentPage.value == idx
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    final isLastPage = currentPage.value == pages.length - 1;
                    if (isLastPage) {
                      Navigator.pop(context);
                      return;
                    }
                    pageController.nextPage(
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOut,
                    );
                  },
                  child: Text(
                    currentPage.value == pages.length - 1
                        ? 'Get Started'
                        : 'Continue',
                  ),
                ),
              ),
              if (suggestAuth && currentPage.value == pages.length - 1) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onCreateAccount();
                    },
                    child: const Text('Create Account'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onLogin();
                    },
                    child: const Text('Log In'),
                  ),
                ),
              ],
              const SizedBox(height: 4),
              if (!isFirstLaunch)
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Skip for now'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
