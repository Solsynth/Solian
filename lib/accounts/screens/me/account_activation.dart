import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/core/network.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';

class ActivationTestRequirement {
  final String key;
  final String title;
  final bool available;
  final bool passed;
  final int? maxAttempts;
  final int usedAttemptCount;

  const ActivationTestRequirement({
    required this.key,
    required this.title,
    required this.available,
    required this.passed,
    this.maxAttempts,
    required this.usedAttemptCount,
  });

  factory ActivationTestRequirement.fromJson(Map<String, dynamic> json) {
    return ActivationTestRequirement(
      key: json['key'] as String? ?? 'Activation test',
      title: json['title'] as String? ?? 'Activation test',
      available: json['available'] as bool? ?? false,
      passed: json['passed'] as bool? ?? false,
      maxAttempts: (json['maxAttempts'] as num?)?.toInt(),
      usedAttemptCount: (json['usedAttemptCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class AccountActivationProgress {
  final bool isActivated;
  final bool testsEnabled;
  final bool testsBypassed;
  final bool requireVerifiedContact;
  final bool hasVerifiedContact;
  final int requiredRequirementCount;
  final int completedRequirementCount;
  final List<ActivationTestRequirement> tests;

  const AccountActivationProgress({
    required this.isActivated,
    required this.testsEnabled,
    required this.testsBypassed,
    required this.requireVerifiedContact,
    required this.hasVerifiedContact,
    required this.requiredRequirementCount,
    required this.completedRequirementCount,
    required this.tests,
  });

  factory AccountActivationProgress.fromJson(Map<String, dynamic> json) {
    final tests = json['tests'];
    return AccountActivationProgress(
      isActivated: json['isActivated'] as bool? ?? false,
      testsEnabled: json['testsEnabled'] as bool? ?? false,
      testsBypassed: json['testsBypassed'] as bool? ?? false,
      requireVerifiedContact: json['requireVerifiedContact'] as bool? ?? false,
      hasVerifiedContact: json['hasVerifiedContact'] as bool? ?? false,
      requiredRequirementCount:
          (json['requiredRequirementCount'] as num?)?.toInt() ?? 0,
      completedRequirementCount:
          (json['completedRequirementCount'] as num?)?.toInt() ?? 0,
      tests: tests is List
          ? tests
                .whereType<Map>()
                .map(
                  (test) => ActivationTestRequirement.fromJson(
                    Map<String, dynamic>.from(test),
                  ),
                )
                .toList()
          : const [],
    );
  }
}

final accountActivationProgressProvider =
    FutureProvider.autoDispose<AccountActivationProgress>((ref) async {
      final client = ref.watch(apiClientProvider);
      final response = await client.get(
        '/passport/accounts/me/activation/progress',
      );
      return AccountActivationProgress.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    });

@RoutePage()
class AccountActivationScreen extends HookConsumerWidget {
  const AccountActivationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(accountActivationProgressProvider);
    final isRefreshing = useState(false);
    final inviteController = useTextEditingController();
    final inviteCode = useState('');
    final isConsumingInvite = useState(false);
    final inviteError = useState<String?>(null);
    final inviteSuccess = useState<String?>(null);

    Future<void> refresh() async {
      if (isRefreshing.value) return;
      isRefreshing.value = true;
      try {
        final client = ref.read(apiClientProvider);
        await client.post('/passport/tests/activation/recheck');
        ref.invalidate(accountActivationProgressProvider);
        await ref.read(accountActivationProgressProvider.future);
        ref.invalidate(userInfoProvider);
      } catch (error) {
        showErrorAlert(error);
      } finally {
        isRefreshing.value = false;
      }
    }

    Future<void> consumeInvite() async {
      final code = inviteCode.value.trim();
      if (code.isEmpty || isConsumingInvite.value) return;
      isConsumingInvite.value = true;
      inviteError.value = null;
      inviteSuccess.value = null;
      try {
        final client = ref.read(apiClientProvider);
        await client.post(
          '/passport/affiliations/registration-invites/consume',
          data: {'spell': code},
        );
        inviteController.clear();
        inviteCode.value = '';
        await refresh();
        final activated =
            ref.read(accountActivationProgressProvider).value?.isActivated ??
            false;
        inviteSuccess.value = activated
            ? 'Your invitation code has activated this account.'
            : 'Your invitation code was applied. Complete any remaining account requirements to activate.';
      } catch (error) {
        inviteError.value = _errorMessage(error);
      } finally {
        isConsumingInvite.value = false;
      }
    }

    return AppScaffold(
      appBar: AppBar(
        title: const Text('Account activation'),
        leading: const AutoLeadingButton(),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: isRefreshing.value ? null : refresh,
            icon: isRefreshing.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Symbols.refresh),
          ),
        ],
      ),
      body: progress.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Symbols.error, size: 32),
                const SizedBox(height: 12),
                const Text('Unable to load activation requirements.'),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: refresh,
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
        data: (value) => RefreshIndicator(
          onRefresh: refresh,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (value.isActivated) ...[
                _ActivationMessage(
                  icon: Symbols.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                  text:
                      'Your account is active. Your completed activation requirements are shown below.',
                ),
                const SizedBox(height: 16),
              ],
              if (!value.isActivated) ...[
                Text(
                  'Complete the remaining requirements to unlock your account.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
              ],
              Card(
                margin: EdgeInsets.zero,
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: value.requiredRequirementCount == 0
                          ? 0
                          : value.completedRequirementCount /
                                value.requiredRequirementCount,
                    ),
                    if (value.requireVerifiedContact)
                      _RequirementTile(
                        icon: value.hasVerifiedContact
                            ? Symbols.mark_email_read
                            : Symbols.mail,
                        title: 'Verify your contact',
                        detail: value.hasVerifiedContact
                            ? 'Complete'
                            : 'Use the verification link we sent you.',
                        complete: value.hasVerifiedContact,
                      ),
                    for (final test in value.tests) ...[
                      if (value.requireVerifiedContact ||
                          test != value.tests.first)
                        const Divider(height: 1),
                      _RequirementTile(
                        icon: Symbols.quiz,
                        title: test.title,
                        detail: _testDetail(test),
                        complete: test.passed,
                        onTakeTest:
                            !value.isActivated &&
                                !test.passed &&
                                test.available &&
                                (test.maxAttempts == null ||
                                    test.usedAttemptCount <
                                        test.maxAttempts!)
                            ? () => _takeTest(context, test.key)
                            : null,
                      ),
                    ],
                  ],
                ),
              ),
              if (value.testsBypassed) ...[
                const SizedBox(height: 12),
                _ActivationMessage(
                  icon: Symbols.info,
                  color: Theme.of(context).colorScheme.primary,
                  text: 'An invitation has waived the test requirement.',
                ),
              ],
              if (!value.isActivated && !value.testsBypassed) ...[
                const SizedBox(height: 16),
                _AffiliationSection(
                  controller: inviteController,
                  enabled:
                      inviteCode.value.trim().isNotEmpty &&
                      !isConsumingInvite.value,
                  consuming: isConsumingInvite.value,
                  onChanged: (code) => inviteCode.value = code,
                  onSubmit: consumeInvite,
                  error: inviteError.value,
                  success: inviteSuccess.value,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivationMessage extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _ActivationMessage({
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 12),
        Expanded(child: Text(text)),
      ],
    );
  }
}

class _RequirementTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String detail;
  final bool complete;
  final VoidCallback? onTakeTest;

  const _RequirementTile({
    required this.icon,
    required this.title,
    required this.detail,
    required this.complete,
    this.onTakeTest,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon, color: complete ? colors.primary : null),
      title: Text(title),
      subtitle: Text(detail),
      trailing: onTakeTest != null
          ? FilledButton.tonalIcon(
              onPressed: onTakeTest,
              icon: const Icon(Symbols.quiz, size: 18),
              label: const Text('Take test'),
            )
          : complete
          ? Icon(Symbols.check, color: colors.primary)
          : const Icon(Symbols.pending),
    );
  }
}

class _AffiliationSection extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final bool consuming;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmit;
  final String? error;
  final String? success;

  const _AffiliationSection({
    required this.controller,
    required this.enabled,
    required this.consuming,
    required this.onChanged,
    required this.onSubmit,
    this.error,
    this.success,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Have an affiliation code?',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Use a registration invitation code to skip eligible entry tests.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    enabled: !consuming,
                    autocorrect: false,
                    onChanged: onChanged,
                    onSubmitted: (_) {
                      if (enabled) onSubmit();
                    },
                    decoration: const InputDecoration(
                      hintText: 'Enter affiliation code',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: enabled ? onSubmit : null,
                  child: consuming
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Use code'),
                ),
              ],
            ),
            if (error != null) ...[
              const SizedBox(height: 12),
              Text(
                error!,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: colors.error),
              ),
            ] else if (success != null) ...[
              const SizedBox(height: 12),
              Text(
                success!,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: colors.primary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String _testDetail(ActivationTestRequirement test) {
  if (test.passed) return 'Passed';
  if (!test.available) return 'Not currently available';
  final maxAttempts = test.maxAttempts;
  if (maxAttempts != null && test.usedAttemptCount >= maxAttempts) {
    return 'Maximum attempts reached';
  }
  if (maxAttempts != null) {
    return 'Attempts: ${test.usedAttemptCount}/$maxAttempts';
  }
  return 'Required before activation';
}

Future<void> _takeTest(BuildContext context, String key) async {
  final uri = Uri.parse('https://solian.app/accounts/tests/$key');
  final container = ProviderScope.containerOf(context);
  await openExternalLinkWithContainer(uri, container);
}

String _errorMessage(Object error) {
  if (error is DioException) {
    final data = error.response?.data;
    final message = data is Map
        ? (data['message'] ?? data['detail'] ?? data['error'])?.toString()
        : data?.toString();
    if (message != null && message.isNotEmpty) return message;
    return error.response?.statusMessage ??
        error.message ??
        error.toString();
  }
  return error.toString();
}
