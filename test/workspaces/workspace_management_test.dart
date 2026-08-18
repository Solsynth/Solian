import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/workspaces/workspace_management.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _storageQuota = WorkspaceStorageQuota(
  usedBytes: 734003200,
  limitBytes: 1073741824,
  remainingBytes: 340787624,
  calculatedAt: '2026-08-19T00:20:00Z',
  services: [
    WorkspaceStorageServiceUsage(name: 'drive', usedBytes: 524288000),
    WorkspaceStorageServiceUsage(name: 'postal', usedBytes: 209715200),
  ],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SharedPreferences preferences;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
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
                  sharedPreferencesProvider.overrideWithValue(preferences),
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

    expect(find.text('Workspaces'), findsOneWidget);
    expect(find.text('Studio'), findsOneWidget);
    expect(find.text('A shared creative space'), findsOneWidget);
    expect(find.byTooltip('Create organization'), findsOneWidget);
  });

  testWidgets('renders searchable workspace member sheet', (tester) async {
    final member = WorkspaceMemberSummary.fromJson({
      'account_id': 'account-id',
      'role': 50,
      'account': {'name': 'alice', 'nick': 'Alice'},
    });

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
                sharedPreferencesProvider.overrideWithValue(preferences),
                workspaceMembersProvider(
                  'studio',
                ).overrideWith((ref) async => [member]),
              ],
              child: const Scaffold(
                body: WorkspaceMembersSheet(
                  workspace: WorkspaceSummary(
                    id: 'workspace-id',
                    slug: 'studio',
                    name: 'Studio',
                    description: 'A shared creative space',
                    type: 1,
                    ownerAccountId: 'owner-id',
                    plan: 1,
                    isBundled: false,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.runAsync(
      () async => await Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('Search member account'), findsOneWidget);
    await tester.enterText(find.byType(SearchBar), 'nomatch');
    await tester.pump();
    expect(find.text('No members match this search.'), findsOneWidget);
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
                sharedPreferencesProvider.overrideWithValue(preferences),
                workspaceListProvider.overrideWith((ref) async => [workspace]),
                workspaceMembersProvider.overrideWith(
                  (ref, slug) async => const [],
                ),
                workspacePlanStatusProvider.overrideWith(
                  (ref, slug) async => const WorkspacePlanStatus(
                    plan: 1,
                    isBundled: false,
                    proPrice: 12,
                    enterprisePrice: 48,
                    currency: 'USD',
                  ),
                ),
                workspaceStorageQuotaProvider.overrideWith(
                  (ref, slug) async => _storageQuota,
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
    expect(find.text('Storage quota'), findsOneWidget);
    expect(find.text('Drive'), findsOneWidget);
    expect(find.text('Postal'), findsOneWidget);

    expect(find.text('Overview'), findsOneWidget);
    expect(find.byType(Tab), findsNWidgets(3));
    expect(find.text('Plan'), findsOneWidget);
    expect(find.text('Cloud saves'), findsOneWidget);
  });

  testWidgets('opens mailbox alias and forwarding actions', (tester) async {
    const workspace = WorkspaceSummary(
      id: 'workspace-id',
      slug: 'studio',
      name: 'Studio',
      description: '',
      type: 1,
      ownerAccountId: 'owner-id',
      plan: 1,
      isBundled: false,
    );
    const mailbox = WorkspaceMailboxRecord(
      id: 'mailbox-id',
      address: 'hello@example.com',
      name: 'Hello',
      isDefault: true,
      isVerified: true,
    );
    const usage = WorkspaceUsageSummary(used: 1, limit: 5, remaining: 4);
    const domain = WorkspaceDomainRecord(
      id: 'domain-id',
      domain: 'example.com',
      status: 'verified',
      stage: 'active',
      verifiedForSending: true,
      dkimStatus: 'verified',
      mailFromDomain: 'mail.example.com',
      mailFromStatus: 'verified',
      dnsRecords: [],
    );
    const alias = WorkspaceMailboxAliasRecord(
      id: 'alias-id',
      mailboxId: 'mailbox-id',
      customDomainId: 'domain-id',
      localPart: 'support',
      address: 'support@example.com',
      name: 'Support',
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
                sharedPreferencesProvider.overrideWithValue(preferences),
                workspaceListProvider.overrideWith((ref) async => [workspace]),
                workspaceMembersProvider.overrideWith(
                  (ref, slug) async => const [],
                ),
                workspacePlanStatusProvider.overrideWith(
                  (ref, slug) async => const WorkspacePlanStatus(
                    plan: 1,
                    isBundled: false,
                    proPrice: 12,
                    enterprisePrice: 48,
                    currency: 'USD',
                  ),
                ),
                workspaceStorageQuotaProvider.overrideWith(
                  (ref, slug) async => _storageQuota,
                ),
                workspaceMailboxesProvider.overrideWith(
                  (ref, workspaceId) async => const [mailbox],
                ),
                workspaceMailboxUsageProvider.overrideWith(
                  (ref, workspaceId) async => usage,
                ),
                workspaceSendUsageProvider.overrideWith(
                  (ref, workspaceId) async =>
                      const WorkspaceSendUsage(daily: usage, monthly: usage),
                ),
                workspaceDomainsProvider.overrideWith(
                  (ref, workspaceId) async => const [domain],
                ),
                workspaceCustomDomainUsageProvider.overrideWith(
                  (ref, workspaceId) async => const WorkspaceCustomDomainUsage(
                    used: 1,
                    limit: 5,
                    remaining: 4,
                  ),
                ),
                workspaceMailCredentialsProvider.overrideWith(
                  (ref) async => const [],
                ),
                flywheelAppsProvider.overrideWith(
                  (ref, workspaceId) async => const [],
                ),
                flywheelQuotaProvider.overrideWith(
                  (ref, workspaceId) async => const FlywheelQuotaSummary(
                    usedBytes: 0,
                    budgetBytes: 1024,
                  ),
                ),
                workspaceMailboxAliasesProvider.overrideWith(
                  (ref, mailboxId) async => const [alias],
                ),
                workspaceMailboxForwardingProvider.overrideWith(
                  (ref, mailboxId) async => const [],
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

    await tester.tap(find.byType(Tab).at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('hello@example.com'));
    await tester.pumpAndSettle();

    expect(find.text('Aliases'), findsOneWidget);
    expect(find.text('Forwarding'), findsOneWidget);
    expect(find.text('Add alias'), findsOneWidget);
    expect(find.text('Add forwarding rule'), findsOneWidget);
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
    final alias = WorkspaceMailboxAliasRecord.fromJson({
      'id': 'alias-id',
      'mailbox_id': 'mailbox-id',
      'custom_domain_id': 'domain-id',
      'local_part': 'support',
      'address': 'support@example.com',
      'name': 'Support',
    });
    final forwarding = WorkspaceMailboxForwardingRecord.fromJson({
      'id': 'forwarding-id',
      'mailbox_id': 'mailbox-id',
      'alias_id': 'alias-id',
      'destination': 'owner@example.net',
    });
    final domain = WorkspaceDomainRecord.fromJson({
      'id': 'domain-id',
      'domain': 'example.com',
      'verification_status': 'pending',
      'stage': 'dns',
      'verified_for_sending_status': false,
      'dkim_status': 'pending',
      'mail_from_domain': 'mail.example.com',
      'mail_from_status': 'pending',
      'dns_records': [
        {'name': 'selector._domainkey', 'type': 'TXT', 'value': 'v=DKIM1'},
      ],
    });
    final domainUsage = WorkspaceCustomDomainUsage.fromJson({
      'used': 1,
      'limit': 5,
      'remaining': 4,
    });
    final credential = WorkspaceMailCredential.fromJson({
      'id': 'credential-id',
      'account_id': 'account-id',
      'mailbox_id': 'mailbox-id',
      'label': 'Laptop',
      'protocols': ['smtp', 'imap'],
      'created_at': '2026-01-01T00:00:00Z',
    });
    final createdCredential = WorkspaceMailCredentialCreated.fromJson({
      'credential': {
        'id': 'credential-id',
        'account_id': 'account-id',
        'mailbox_id': 'mailbox-id',
        'label': 'Laptop',
        'protocols': ['smtp'],
      },
      'secret': 'secret-value',
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
    final workspace = WorkspaceSummary.fromJson({
      'id': 'workspace-id',
      'slug': 'studio',
      'name': 'Studio',
      'description': 'desc',
      'type': 'organization',
      'owner_account_id': 'owner-id',
      'plan': 'pro',
      'is_bundled': true,
      'picture': {'id': 'picture-id', 'name': 'logo.png'},
      'background': {'id': 'background-id'},
    });
    final bare = WorkspaceSummary.fromJson({
      'id': 'workspace-id',
      'slug': 'studio',
      'name': 'Studio',
      'description': 'desc',
      'type': 0,
      'owner_account_id': 'owner-id',
      'plan': 0,
      'is_bundled': false,
    });

    expect(domain.domain, 'example.com');
    expect(domain.dnsRecords.single.value, 'v=DKIM1');
    expect(domainUsage.remaining, 4);
    expect(credential.protocols, ['smtp', 'imap']);
    expect(createdCredential.secret, 'secret-value');
    expect(plan.proPrice, 25);
    expect(plan.currency, 'golds');
    expect(mailbox.isDefault, isTrue);
    expect(alias.address, 'support@example.com');
    expect(alias.customDomainId, 'domain-id');
    expect(forwarding.aliasId, 'alias-id');
    expect(forwarding.destination, 'owner@example.net');
    expect(mailbox.isVerified, isTrue);
    expect(quota.usedBytes, 1024);
    expect(blob.currentRevision, 2);
    expect(blob.retainedBytes, 2048);
    expect(audit.action, 'blob.uploaded');
    expect(audit.actorAccountId, 'account-id');
    expect(quota.budgetBytes, 4096);
    expect(workspace.pictureId, 'picture-id');
    expect(workspace.backgroundId, 'background-id');
    expect(workspace.isIndividual, isFalse);
    expect(bare.pictureId, isNull);
    expect(bare.backgroundId, isNull);
  });
  test('parses workspace storage snapshots and preserves service usage', () {
    final quota = WorkspaceStorageQuota.fromJson({
      'used_bytes': 734003200,
      'limit_bytes': 1073741824,
      'remaining_bytes': 340787624,
      'calculated_at': '2026-08-19T00:20:00Z',
      'services': [
        {'name': 'drive', 'used_bytes': 524288000},
        {'name': 'postal', 'used_bytes': 209715200},
        {'name': 'flywheel', 'used_bytes': 1024},
      ],
    });

    expect(quota.usedBytes, 734003200);
    expect(quota.limitBytes, 1073741824);
    expect(quota.remainingBytes, 340787624);
    expect(quota.calculatedAt, '2026-08-19T00:20:00Z');
    expect(quota.services.map((service) => service.name), [
      'drive',
      'postal',
      'flywheel',
    ]);
    expect(quota.services.first.displayName, 'Drive');
    expect(quota.services[1].displayName, 'Postal');
    expect(quota.services.last.displayName, 'Cloud sync');
    expect(quota.toUsageMap()['used_bytes'], 734003200);
    expect((quota.toUsageMap()['service_usages'] as List).length, 3);
  });
}
