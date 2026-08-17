import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/workspace_management.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('renders workspace management cards', (tester) async {
    const workspace = WorkspaceSummary(
      id: 'workspace-id',
      slug: 'studio',
      name: 'Studio',
      description: 'A shared creative space',
      type: 1,
      ownerAccountId: 'owner-id',
      plan: 1,
      isBundled: false,
    );

    await tester.runAsync(() async {
      await tester.pumpWidget(
        EasyLocalization(
          supportedLocales: const [Locale('en', 'US')],
          path: 'assets/i18n',
          saveLocale: false,
          child: Builder(
            builder: (context) => MaterialApp(
              locale: const Locale('en', 'US'),
              supportedLocales: const [Locale('en', 'US')],
              localizationsDelegates: context.localizationDelegates,
              home: ProviderScope(
                overrides: [
                  workspaceListProvider.overrideWith(
                    (ref) async => [workspace],
                  ),
                ],
                child: const WorkspaceManagementScreen(),
              ),
            ),
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();

    expect(find.text('Your workspaces'), findsOneWidget);
    expect(find.text('Studio'), findsOneWidget);
    expect(find.text('A shared creative space'), findsOneWidget);
    expect(find.text('Create organization'), findsOneWidget);
  });

  testWidgets('renders workspace detail management tabs', (tester) async {
    const workspace = WorkspaceSummary(
      id: 'workspace-id',
      slug: 'studio',
      name: 'Studio',
      description: 'A shared creative space',
      type: 1,
      ownerAccountId: 'owner-id',
      plan: 1,
      isBundled: false,
    );

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en', 'US')],
        path: 'assets/i18n',
        saveLocale: false,
        child: Builder(
          builder: (context) => MaterialApp(
            locale: const Locale('en', 'US'),
            supportedLocales: const [Locale('en', 'US')],
            localizationsDelegates: context.localizationDelegates,
            home: ProviderScope(
              overrides: [
                workspaceListProvider.overrideWith((ref) async => [workspace]),
                workspaceMembersProvider.overrideWith(
                  (ref, slug) async => const [],
                ),
              ],
              child: const WorkspaceDetailScreen(slug: 'studio'),
            ),
          ),
        ),
      ),
    );
    await tester.runAsync(
      () async => await Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Overview'), findsOneWidget);
    expect(find.text('Plan'), findsOneWidget);
    expect(find.text('Cloud saves'), findsOneWidget);
  });

  test('parses member profile details from the workspace response', () {
    final member = WorkspaceMemberSummary.fromJson({
      'account_id': 'account-id',
      'role': 50,
      'account': {
        'name': 'alice',
        'nick': 'Alice',
        'profile': {
          'picture': {'id': 'avatar-id'},
        },
      },
    });

    expect(member.displayName, 'Alice');
    expect(member.username, 'alice');
    expect(member.profilePictureId, 'avatar-id');
  });

  test('parses workspace management payloads with snake case keys', () {
    final plan = WorkspacePlanStatus.fromJson({
      'plan': 1,
      'is_bundled': false,
      'prices': {'pro': 25, 'enterprise': 100, 'currency': 'golds'},
    });
    final mailbox = WorkspaceMailboxRecord.fromJson({
      'id': 'mailbox-id',
      'address': 'hello@example.com',
      'name': 'Hello',
      'is_default': true,
      'is_verified': true,
    });
    final quota = FlywheelQuotaSummary.fromJson({
      'used_bytes': 1024,
      'budget_bytes': 4096,
    });
    final blob = FlywheelBlobRecord.fromJson({
      'blob_id': 'blob-id',
      'current_revision': 2,
      'retained_revision_count': 1,
      'retained_bytes': 2048,
    });
    final audit = FlywheelAuditRecord.fromJson({
      'action': 'blob.uploaded',
      'blob_id': 'blob-id',
      'revision': 2,
      'actor_account_id': 'account-id',
      'created_at': '2026-01-01T00:00:00Z',
    });

    expect(plan.proPrice, 25);
    expect(plan.currency, 'golds');
    expect(mailbox.isDefault, isTrue);
    expect(mailbox.isVerified, isTrue);
    expect(quota.usedBytes, 1024);
    expect(blob.currentRevision, 2);
    expect(blob.retainedBytes, 2048);
    expect(audit.action, 'blob.uploaded');
    expect(audit.actorAccountId, 'account-id');
    expect(quota.budgetBytes, 4096);
  });
}
