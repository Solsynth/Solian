import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/core/network.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:material_symbols_icons/symbols.dart';

class WorkspaceSummary {
  final String id;
  final String slug;
  final String name;
  final String description;
  final int type;
  final String ownerAccountId;
  final int plan;
  final bool isBundled;

  const WorkspaceSummary({
    required this.id,
    required this.slug,
    required this.name,
    required this.description,
    required this.type,
    required this.ownerAccountId,
    required this.plan,
    required this.isBundled,
  });

  bool get isIndividual => type == 0;

  String get planLabel => switch (plan) {
    1 => 'workspacePlanPro'.tr(),
    2 => 'workspacePlanEnterprise'.tr(),
    _ => 'workspacePlanFree'.tr(),
  };

  factory WorkspaceSummary.fromJson(dynamic value) {
    final json = Map<String, dynamic>.from(value as Map);
    return WorkspaceSummary(
      id: _string(json['id']),
      slug: _string(json['slug']),
      name: _string(json['name']),
      description: _string(json['description']),
      type: _enumValue(json['type'], individual: 0, organization: 1),
      ownerAccountId: _string(json['owner_account_id']),
      plan: _enumValue(json['plan'], free: 0, pro: 1, enterprise: 2),
      isBundled: json['is_bundled'] == true,
    );
  }

  static String _string(dynamic value) => value?.toString() ?? '';

  static int _enumValue(
    dynamic value, {
    int individual = 0,
    int organization = 0,
    int free = 0,
    int pro = 0,
    int enterprise = 0,
  }) {
    if (value is num) return value.toInt();
    final normalized = value?.toString().toLowerCase();
    return switch (normalized) {
      'organization' => organization,
      'pro' => pro,
      'enterprise' => enterprise,
      'individual' => individual,
      _ => int.tryParse(normalized ?? '') ?? free,
    };
  }
}

class WorkspaceMemberSummary {
  final String accountId;
  final int role;
  final Map<String, dynamic>? account;

  const WorkspaceMemberSummary({
    required this.accountId,
    required this.role,
    this.account,
  });

  String get displayName {
    final nick = _accountString('nick');
    if (nick.isNotEmpty) return nick;
    final name = _accountString('name');
    return name.isNotEmpty ? name : accountId;
  }

  String? get username {
    final name = _accountString('name');
    return name.isEmpty ? null : name;
  }

  String? get profilePictureId {
    final profile = _accountMap('profile');
    final picture = _map(profile?['picture']);
    final id = picture?['id'];
    return id?.toString();
  }

  String get roleLabel => switch (role) {
    >= 100 => 'workspaceRoleOwner'.tr(),
    >= 75 => 'workspaceRoleAdmin'.tr(),
    >= 50 => 'workspaceRoleMember'.tr(),
    _ => 'workspaceRoleViewer'.tr(),
  };

  factory WorkspaceMemberSummary.fromJson(dynamic value) {
    final json = Map<String, dynamic>.from(value as Map);
    return WorkspaceMemberSummary(
      accountId: (json['account_id'] ?? '').toString(),
      role: json['role'] is num
          ? (json['role'] as num).toInt()
          : int.tryParse('${json['role'] ?? 25}') ?? 25,
      account: _map(json['account']),
    );
  }
  String _accountString(String key) => _accountValue(key)?.toString() ?? '';

  Map<String, dynamic>? _accountMap(String key) => _map(_accountValue(key));

  dynamic _accountValue(String key) {
    final values = account;
    if (values == null) return null;
    final direct = values[key];
    if (direct != null) return direct;
    final normalized = key.replaceAll('_', '').toLowerCase();
    for (final entry in values.entries) {
      final entryKey = entry.key.replaceAll('_', '').toLowerCase();
      if (entryKey == normalized) return entry.value;
    }
    return null;
  }

  static Map<String, dynamic>? _map(dynamic value) {
    if (value is! Map) return null;
    return Map<String, dynamic>.from(value);
  }
}

final workspaceListProvider =
    FutureProvider.autoDispose<List<WorkspaceSummary>>((ref) async {
      final client = ref.read(solarNetworkClientProvider);
      final response = await client.dio.get('/valve/workspaces');
      if (response.data is! List) {
        throw StateError('Workspace list returned an invalid response.');
      }
      return (response.data as List)
          .map(WorkspaceSummary.fromJson)
          .toList(growable: false);
    });

final workspaceMembersProvider = FutureProvider.autoDispose
    .family<List<WorkspaceMemberSummary>, String>((ref, slug) async {
      final client = ref.read(solarNetworkClientProvider);
      final response = await client.dio.get(
        '/valve/workspaces/${Uri.encodeComponent(slug)}/members',
      );
      if (response.data is! List) {
        throw StateError('Workspace members returned an invalid response.');
      }
      return (response.data as List)
          .map(WorkspaceMemberSummary.fromJson)
          .toList(growable: false);
    });

class WorkspacePlanStatus {
  final int plan;
  final bool isBundled;
  final int proPrice;
  final int enterprisePrice;
  final String currency;

  const WorkspacePlanStatus({
    required this.plan,
    required this.isBundled,
    required this.proPrice,
    required this.enterprisePrice,
    required this.currency,
  });

  factory WorkspacePlanStatus.fromJson(dynamic value) {
    final json = _jsonMap(value);
    final prices = _jsonMap(json['prices']);
    return WorkspacePlanStatus(
      plan: _jsonInt(json['plan']),
      isBundled: _jsonBool(json['is_bundled']),
      proPrice: _jsonInt(prices['pro']),
      enterprisePrice: _jsonInt(prices['enterprise']),
      currency: _jsonString(prices['currency']),
    );
  }
}

class WorkspaceMailboxRecord {
  final String id;
  final String address;
  final String name;
  final bool isDefault;
  final bool isVerified;

  const WorkspaceMailboxRecord({
    required this.id,
    required this.address,
    required this.name,
    required this.isDefault,
    required this.isVerified,
  });

  factory WorkspaceMailboxRecord.fromJson(dynamic value) {
    final json = _jsonMap(value);
    return WorkspaceMailboxRecord(
      id: _jsonString(json['id']),
      address: _jsonString(json['address']),
      name: _jsonString(json['name']),
      isDefault: _jsonBool(json['is_default']),
      isVerified: _jsonBool(json['is_verified']),
    );
  }
}

class WorkspaceUsageSummary {
  final int used;
  final int limit;
  final int remaining;

  const WorkspaceUsageSummary({
    required this.used,
    required this.limit,
    required this.remaining,
  });

  factory WorkspaceUsageSummary.fromJson(dynamic value) {
    final json = _jsonMap(value);
    return WorkspaceUsageSummary(
      used: _jsonInt(json['used']),
      limit: _jsonInt(json['limit']),
      remaining: _jsonInt(json['remaining']),
    );
  }
}

class WorkspaceSendUsage {
  final WorkspaceUsageSummary daily;
  final WorkspaceUsageSummary monthly;

  const WorkspaceSendUsage({required this.daily, required this.monthly});

  factory WorkspaceSendUsage.fromJson(dynamic value) {
    final json = _jsonMap(value);
    return WorkspaceSendUsage(
      daily: WorkspaceUsageSummary.fromJson(json['daily']),
      monthly: WorkspaceUsageSummary.fromJson(json['monthly']),
    );
  }
}

class WorkspaceDomainRecord {
  final String id;
  final String domain;
  final String status;
  final String stage;

  const WorkspaceDomainRecord({
    required this.id,
    required this.domain,
    required this.status,
    required this.stage,
  });

  factory WorkspaceDomainRecord.fromJson(dynamic value) {
    final json = _jsonMap(value);
    return WorkspaceDomainRecord(
      id: _jsonString(json['id']),
      domain: _jsonString(json['domain']),
      status: _jsonString(json['verification_status']),
      stage: _jsonString(json['stage']),
    );
  }
}

class FlywheelAppRecord {
  final String appId;
  final int blobCount;
  final int retainedBytes;
  final DateTime? lastUpdatedAt;

  const FlywheelAppRecord({
    required this.appId,
    required this.blobCount,
    required this.retainedBytes,
    required this.lastUpdatedAt,
  });

  factory FlywheelAppRecord.fromJson(dynamic value) {
    final json = _jsonMap(value);
    return FlywheelAppRecord(
      appId: _jsonString(json['app_id']),
      blobCount: _jsonInt(json['blob_count']),
      retainedBytes: _jsonInt(json['retained_bytes']),
      lastUpdatedAt: DateTime.tryParse(_jsonString(json['last_updated_at'])),
    );
  }
}

class FlywheelBlobRecord {
  final String blobId;
  final int currentRevision;
  final int retainedRevisionCount;
  final int retainedBytes;

  const FlywheelBlobRecord({
    required this.blobId,
    required this.currentRevision,
    required this.retainedRevisionCount,
    required this.retainedBytes,
  });

  factory FlywheelBlobRecord.fromJson(dynamic value) {
    final json = _jsonMap(value);
    return FlywheelBlobRecord(
      blobId: _jsonString(json['blob_id']),
      currentRevision: _jsonInt(json['current_revision']),
      retainedRevisionCount: _jsonInt(json['retained_revision_count']),
      retainedBytes: _jsonInt(json['retained_bytes']),
    );
  }
}

class FlywheelAuditRecord {
  final String action;
  final String blobId;
  final int? revision;
  final String actorAccountId;
  final DateTime? createdAt;

  const FlywheelAuditRecord({
    required this.action,
    required this.blobId,
    required this.revision,
    required this.actorAccountId,
    required this.createdAt,
  });

  factory FlywheelAuditRecord.fromJson(dynamic value) {
    final json = _jsonMap(value);
    return FlywheelAuditRecord(
      action: _jsonString(json['action']),
      blobId: _jsonString(json['blob_id']),
      revision: json['revision'] == null ? null : _jsonInt(json['revision']),
      actorAccountId: _jsonString(json['actor_account_id']),
      createdAt: DateTime.tryParse(_jsonString(json['created_at'])),
    );
  }
}

final flywheelBlobsProvider = FutureProvider.autoDispose
    .family<List<FlywheelBlobRecord>, ({String workspaceId, String appId})>((
      ref,
      args,
    ) async {
      final client = ref.read(solarNetworkClientProvider);
      final response = await client.dio.get(
        '/flywheel/workspaces/${args.workspaceId}/apps/${Uri.encodeComponent(args.appId)}/management/blobs',
      );
      final data = response.data;
      if (data is! List) throw StateError('Invalid Flywheel blob response.');
      return data.map(FlywheelBlobRecord.fromJson).toList(growable: false);
    });

final flywheelAuditProvider = FutureProvider.autoDispose
    .family<List<FlywheelAuditRecord>, ({String workspaceId, String appId})>((
      ref,
      args,
    ) async {
      final client = ref.read(solarNetworkClientProvider);
      final response = await client.dio.get(
        '/flywheel/workspaces/${args.workspaceId}/apps/${Uri.encodeComponent(args.appId)}/management/audit',
        queryParameters: {'take': 100},
      );
      final data = response.data;
      if (data is! List) throw StateError('Invalid Flywheel audit response.');
      return data.map(FlywheelAuditRecord.fromJson).toList(growable: false);
    });

class FlywheelQuotaSummary {
  final int usedBytes;
  final int budgetBytes;

  const FlywheelQuotaSummary({
    required this.usedBytes,
    required this.budgetBytes,
  });

  factory FlywheelQuotaSummary.fromJson(dynamic value) {
    final json = _jsonMap(value);
    return FlywheelQuotaSummary(
      usedBytes: _jsonInt(json['used_bytes']),
      budgetBytes: _jsonInt(json['budget_bytes']),
    );
  }
}

Map<String, dynamic> _jsonMap(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : const {};

String _jsonString(dynamic value) => value?.toString() ?? '';

int _jsonInt(dynamic value) =>
    value is num ? value.toInt() : int.tryParse(value?.toString() ?? '') ?? 0;

bool _jsonBool(dynamic value) => value == true;

final workspacePlanStatusProvider = FutureProvider.autoDispose
    .family<WorkspacePlanStatus, String>((ref, slug) async {
      final client = ref.read(solarNetworkClientProvider);
      final response = await client.dio.get(
        '/valve/workspaces/${Uri.encodeComponent(slug)}/plan/status',
      );
      return WorkspacePlanStatus.fromJson(response.data);
    });

final workspaceMailboxesProvider = FutureProvider.autoDispose
    .family<List<WorkspaceMailboxRecord>, String>((ref, workspaceId) async {
      final client = ref.read(solarNetworkClientProvider);
      final response = await client.dio.get(
        '/postal/mailboxes',
        queryParameters: {'workspace_id': workspaceId},
      );
      final data = response.data;
      if (data is! List) throw StateError('Invalid mailbox response.');
      return data.map(WorkspaceMailboxRecord.fromJson).toList(growable: false);
    });

final workspaceMailboxUsageProvider = FutureProvider.autoDispose
    .family<WorkspaceUsageSummary, String>((ref, workspaceId) async {
      final client = ref.read(solarNetworkClientProvider);
      final response = await client.dio.get(
        '/postal/workspaces/$workspaceId/mailbox-usage',
      );
      return WorkspaceUsageSummary.fromJson(response.data);
    });

final workspaceSendUsageProvider = FutureProvider.autoDispose
    .family<WorkspaceSendUsage, String>((ref, workspaceId) async {
      final client = ref.read(solarNetworkClientProvider);
      final response = await client.dio.get(
        '/postal/workspaces/$workspaceId/send-usage',
      );
      return WorkspaceSendUsage.fromJson(response.data);
    });

final workspaceDomainsProvider = FutureProvider.autoDispose
    .family<List<WorkspaceDomainRecord>, String>((ref, workspaceId) async {
      final client = ref.read(solarNetworkClientProvider);
      final response = await client.dio.get(
        '/postal/custom-domains',
        queryParameters: {'workspace_id': workspaceId},
      );
      final data = response.data;
      if (data is! List) throw StateError('Invalid domain response.');
      return data.map(WorkspaceDomainRecord.fromJson).toList(growable: false);
    });

final flywheelAppsProvider = FutureProvider.autoDispose
    .family<List<FlywheelAppRecord>, String>((ref, workspaceId) async {
      final client = ref.read(solarNetworkClientProvider);
      final response = await client.dio.get(
        '/flywheel/workspaces/$workspaceId/apps',
      );
      final data = response.data;
      if (data is! List) throw StateError('Invalid Flywheel response.');
      return data.map(FlywheelAppRecord.fromJson).toList(growable: false);
    });

final flywheelQuotaProvider = FutureProvider.autoDispose
    .family<FlywheelQuotaSummary, String>((ref, workspaceId) async {
      final client = ref.read(solarNetworkClientProvider);
      final response = await client.dio.get(
        '/flywheel/workspaces/$workspaceId/quota',
      );
      return FlywheelQuotaSummary.fromJson(response.data);
    });

@RoutePage()
class WorkspaceManagementScreen extends HookConsumerWidget {
  const WorkspaceManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspaces = ref.watch(workspaceListProvider);

    Future<void> refreshWorkspaces() async {
      ref.invalidate(workspaceListProvider);
      await ref.read(workspaceListProvider.future);
    }

    return AppScaffold(
      appBar: AppBar(
        title: Text('workspaceManagementTitle').tr(),
        actions: [
          IconButton(
            onPressed: workspaces.isLoading ? null : refreshWorkspaces,
            icon: const Icon(Symbols.refresh),
            tooltip: 'refresh'.tr(),
          ),
          IconButton(
            onPressed: () => _openEditor(context, ref),
            icon: const Icon(Symbols.add),
            tooltip: 'workspaceCreateOrganization'.tr(),
          ),
        ],
      ),
      body: workspaces.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: _WorkspaceError(onRetry: refreshWorkspaces),
          ),
        ),
        data: (items) => RefreshIndicator(
          onRefresh: refreshWorkspaces,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              if (items.isEmpty)
                _WorkspaceEmptyState(onCreate: () => _openEditor(context, ref))
              else ...[
                for (final workspace in items)
                  _WorkspaceCard(
                    workspace: workspace,
                    onOpen: () => context.router.push(
                      WorkspaceDetailRoute(slug: workspace.slug),
                    ),
                    onEdit: () => _openEditor(context, ref, workspace),
                    onMembers: () => _openMembers(context, workspace),
                  ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: () => _openEditor(context, ref),
                  icon: const Icon(Symbols.add),
                  label: Text('workspaceCreateOrganization'.tr()),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openEditor(
    BuildContext context,
    WidgetRef ref, [
    WorkspaceSummary? workspace,
  ]) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => WorkspaceEditorSheet(workspace: workspace),
    );
    if (changed == true) ref.invalidate(workspaceListProvider);
  }

  Future<void> _openMembers(
    BuildContext context,
    WorkspaceSummary workspace,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => WorkspaceMembersSheet(workspace: workspace),
    );
  }
}

@RoutePage()
class WorkspaceDetailScreen extends HookConsumerWidget {
  final String slug;

  const WorkspaceDetailScreen({
    @PathParam('slug') required this.slug,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspaces = ref.watch(workspaceListProvider);

    return AppScaffold(
      appBar: AppBar(
        title: workspaces.whenOrNull(
          data: (items) {
            final workspace = items
                .where((item) => item.slug == slug)
                .firstOrNull;
            return workspace == null
                ? Text('workspaceManagementTitle').tr()
                : Text(workspace.name);
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              ref.invalidate(workspaceListProvider);
              ref.invalidate(workspaceMembersProvider(slug));
            },
            icon: const Icon(Symbols.refresh),
            tooltip: 'refresh'.tr(),
          ),
        ],
      ),
      body: workspaces.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: _WorkspaceError(
              onRetry: () => ref.invalidate(workspaceListProvider),
            ),
          ),
        ),
        data: (items) {
          final workspace = items
              .where((item) => item.slug == slug)
              .firstOrNull;
          if (workspace == null) {
            return Center(child: Text('workspaceNotFound'.tr()));
          }
          return _WorkspaceDetailBody(
            workspace: workspace,
            onEdit: () async {
              final changed = await showModalBottomSheet<bool>(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                builder: (_) => WorkspaceEditorSheet(workspace: workspace),
              );
              if (changed == true && context.mounted) {
                ref.invalidate(workspaceListProvider);
              }
            },
            onMembers: () {
              showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                builder: (_) => WorkspaceMembersSheet(workspace: workspace),
              );
            },
            members: ref.watch(workspaceMembersProvider(slug)),
          );
        },
      ),
    );
  }
}

class _WorkspaceDetailBody extends StatelessWidget {
  final WorkspaceSummary workspace;
  final VoidCallback onMembers;
  final VoidCallback onEdit;
  final AsyncValue<List<WorkspaceMemberSummary>> members;

  const _WorkspaceDetailBody({
    required this.workspace,
    required this.onMembers,
    required this.onEdit,
    required this.members,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Column(
        children: [
          Material(
            color: Theme.of(context).colorScheme.surface,
            child: TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: 'workspaceOverview'.tr()),
                Tab(text: 'workspacePlan'.tr()),
                Tab(text: 'workspaceMembers'.tr()),
                Tab(text: 'workspaceMailboxes'.tr()),
                Tab(text: 'workspaceFlywheel'.tr()),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _WorkspaceOverviewPanel(
                  workspace: workspace,
                  onMembers: onMembers,
                  onEdit: onEdit,
                ),
                _WorkspacePlanPanel(workspace: workspace),
                _WorkspaceMembersPanel(
                  workspace: workspace,
                  members: members,
                  onManage: onMembers,
                ),
                _WorkspaceMailPanel(workspace: workspace),
                _WorkspaceFlywheelPanel(workspace: workspace),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkspaceOverviewPanel extends StatelessWidget {
  final WorkspaceSummary workspace;
  final VoidCallback onMembers;
  final VoidCallback onEdit;

  const _WorkspaceOverviewPanel({
    required this.workspace,
    required this.onMembers,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: colors.primaryContainer,
                      foregroundColor: colors.onPrimaryContainer,
                      child: Icon(
                        workspace.isIndividual
                            ? Symbols.person
                            : Symbols.apartment,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        workspace.name,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('@${workspace.slug}'),
                if (workspace.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    workspace.description,
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                ],
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _WorkspaceChip(
                      label: workspace.isIndividual
                          ? 'workspaceIndividual'.tr()
                          : 'workspaceOrganization'.tr(),
                    ),
                    _WorkspaceChip(label: workspace.planLabel),
                    if (workspace.isBundled)
                      _WorkspaceChip(label: 'workspaceBundled'.tr()),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: onMembers,
                        icon: const Icon(Symbols.group),
                        label: Text('workspaceMembers'.tr()),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      onPressed: onEdit,
                      icon: const Icon(Symbols.edit),
                      tooltip: 'edit'.tr(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _WorkspacePlanPanel extends ConsumerWidget {
  final WorkspaceSummary workspace;

  const _WorkspacePlanPanel({required this.workspace});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(workspacePlanStatusProvider(workspace.slug));
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        status.when(
          loading: () => const _WorkspacePanelLoading(),
          error: (error, _) => _WorkspaceError(
            onRetry: () =>
                ref.invalidate(workspacePlanStatusProvider(workspace.slug)),
          ),
          data: (plan) => Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'workspacePlan'.tr(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    plan.isBundled
                        ? 'workspaceBundled'.tr()
                        : workspace.planLabel,
                  ),
                  const SizedBox(height: 20),
                  if (plan.plan < 1)
                    _PlanButton(
                      label: 'workspacePlanPro'.tr(),
                      price: plan.proPrice,
                      currency: plan.currency,
                      onPressed: () => _subscribe(context, ref, 1),
                    ),
                  if (plan.plan < 2) ...[
                    const SizedBox(height: 8),
                    _PlanButton(
                      label: 'workspacePlanEnterprise'.tr(),
                      price: plan.enterprisePrice,
                      currency: plan.currency,
                      onPressed: () => _subscribe(context, ref, 2),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _subscribe(BuildContext context, WidgetRef ref, int plan) async {
    try {
      final client = ref.read(solarNetworkClientProvider);
      final response = await client.dio.post(
        '/valve/workspaces/${Uri.encodeComponent(workspace.slug)}/plan/subscribe',
        data: {'plan': plan},
      );
      final orderId = _jsonString(_jsonMap(response.data)['order_id']);
      if (orderId.isNotEmpty && context.mounted) {
        context.router.push(WalletOrderDetailRoute(orderId: orderId));
      }
      ref.invalidate(workspacePlanStatusProvider(workspace.slug));
    } catch (error) {
      showErrorAlert(error);
    }
  }
}

class _PlanButton extends StatelessWidget {
  final String label;
  final int price;
  final String currency;
  final VoidCallback onPressed;

  const _PlanButton({
    required this.label,
    required this.price,
    required this.currency,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      onPressed: onPressed,
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text('$price $currency'),
        ],
      ),
    );
  }
}

class _WorkspaceMembersPanel extends StatelessWidget {
  final WorkspaceSummary workspace;
  final AsyncValue<List<WorkspaceMemberSummary>> members;
  final VoidCallback onManage;

  const _WorkspaceMembersPanel({
    required this.workspace,
    required this.members,
    required this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'workspaceMembers'.tr(),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            FilledButton.tonalIcon(
              onPressed: onManage,
              icon: const Icon(Symbols.settings),
              label: Text('manage'.tr()),
            ),
          ],
        ),
        const SizedBox(height: 12),
        members.when(
          loading: () => const _WorkspacePanelLoading(),
          error: (error, _) => Text('workspaceMembersLoadError'.tr()),
          data: (items) => items.isEmpty
              ? Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text('workspaceMembersEmpty'.tr()),
                  ),
                )
              : Card(
                  child: Column(
                    children: [
                      for (final member in items)
                        ListTile(
                          leading: ProfilePictureWidget(
                            fileId: member.profilePictureId,
                            radius: 20,
                            fallbackIcon: Symbols.person,
                          ),
                          title: Text(member.displayName),
                          subtitle: Text(
                            member.username == null
                                ? member.roleLabel
                                : '@${member.username} · ${member.roleLabel}',
                          ),
                        ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

class _WorkspaceMailPanel extends ConsumerWidget {
  final WorkspaceSummary workspace;

  const _WorkspaceMailPanel({required this.workspace});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mailboxes = ref.watch(workspaceMailboxesProvider(workspace.id));
    final mailboxUsage = ref.watch(workspaceMailboxUsageProvider(workspace.id));
    final sendUsage = ref.watch(workspaceSendUsageProvider(workspace.id));
    final domains = ref.watch(workspaceDomainsProvider(workspace.id));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        _MailSectionHeader(
          title: 'workspaceMailboxes'.tr(),
          action: FilledButton.icon(
            onPressed: () => _createMailbox(context, ref),
            icon: const Icon(Symbols.add),
            label: Text('workspaceAddMailbox'.tr()),
          ),
        ),
        const SizedBox(height: 8),
        mailboxUsage.when(
          loading: () => const LinearProgressIndicator(),
          error: (error, _) => const SizedBox.shrink(),
          data: (usage) => Text(
            '${usage.used} / ${usage.limit} ${'workspaceMailboxes'.tr().toLowerCase()}',
          ),
        ),
        const SizedBox(height: 8),
        mailboxes.when(
          loading: () => const _WorkspacePanelLoading(),
          error: (error, _) => Text('workspaceMailboxesLoadError'.tr()),
          data: (items) => items.isEmpty
              ? Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text('workspaceMailboxesEmpty'.tr()),
                  ),
                )
              : Card(
                  child: Column(
                    children: [
                      for (final mailbox in items)
                        ListTile(
                          leading: const Icon(Symbols.mail),
                          title: Text(mailbox.address),
                          subtitle: Text(
                            mailbox.name.isEmpty
                                ? mailbox.isVerified
                                      ? 'workspaceVerified'.tr()
                                      : 'workspaceUnverified'.tr()
                                : mailbox.name,
                          ),
                          trailing: mailbox.isDefault
                              ? const Icon(Symbols.star)
                              : null,
                        ),
                    ],
                  ),
                ),
        ),
        const SizedBox(height: 20),
        _MailSectionHeader(
          title: 'workspaceCustomDomains'.tr(),
          action: FilledButton.tonalIcon(
            onPressed: () => _createDomain(context, ref),
            icon: const Icon(Symbols.add),
            label: Text('workspaceAddDomain'.tr()),
          ),
        ),
        const SizedBox(height: 8),
        domains.when(
          loading: () => const _WorkspacePanelLoading(),
          error: (error, _) => Text('workspaceDomainsLoadError'.tr()),
          data: (items) => items.isEmpty
              ? Text('workspaceDomainsEmpty'.tr())
              : Card(
                  child: Column(
                    children: [
                      for (final domain in items)
                        ListTile(
                          leading: const Icon(Symbols.language),
                          title: Text(domain.domain),
                          subtitle: Text('${domain.status} · ${domain.stage}'),
                          trailing: IconButton(
                            onPressed: () =>
                                _refreshDomain(context, ref, domain),
                            icon: const Icon(Symbols.refresh),
                            tooltip: 'refresh'.tr(),
                          ),
                        ),
                    ],
                  ),
                ),
        ),
        const SizedBox(height: 20),
        _MailSectionHeader(title: 'workspaceSendUsage'.tr()),
        const SizedBox(height: 8),
        sendUsage.when(
          loading: () => const _WorkspacePanelLoading(),
          error: (error, _) => Text('workspaceSendUsageLoadError'.tr()),
          data: (usage) => Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _UsageMetric(
                      label: 'workspaceDaily'.tr(),
                      usage: usage.daily,
                    ),
                  ),
                  Expanded(
                    child: _UsageMetric(
                      label: 'workspaceMonthly'.tr(),
                      usage: usage.monthly,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _createMailbox(BuildContext context, WidgetRef ref) async {
    final draft = await showDialog<_MailboxDraft>(
      context: context,
      builder: (_) => const _MailboxDialog(),
    );
    if (draft == null || !context.mounted) return;
    try {
      final client = ref.read(solarNetworkClientProvider);
      await client.dio.post(
        '/postal/mailboxes',
        data: {
          'workspace_id': workspace.id,
          'address': draft.address,
          'name': draft.name,
          'is_default': draft.isDefault,
        },
      );
      ref.invalidate(workspaceMailboxesProvider(workspace.id));
      ref.invalidate(workspaceMailboxUsageProvider(workspace.id));
    } catch (error) {
      showErrorAlert(error);
    }
  }

  Future<void> _createDomain(BuildContext context, WidgetRef ref) async {
    final domain = await showDialog<String>(
      context: context,
      builder: (_) => const _DomainDialog(),
    );
    if (domain == null || !context.mounted) return;
    try {
      final client = ref.read(solarNetworkClientProvider);
      await client.dio.post(
        '/postal/custom-domains',
        data: {'workspace_id': workspace.id, 'domain': domain},
      );
      ref.invalidate(workspaceDomainsProvider(workspace.id));
    } catch (error) {
      showErrorAlert(error);
    }
  }

  Future<void> _refreshDomain(
    BuildContext context,
    WidgetRef ref,
    WorkspaceDomainRecord domain,
  ) async {
    try {
      final client = ref.read(solarNetworkClientProvider);
      await client.dio.post(
        '/postal/custom-domains/${Uri.encodeComponent(domain.id)}/refresh',
      );
      ref.invalidate(workspaceDomainsProvider(workspace.id));
    } catch (error) {
      showErrorAlert(error);
    }
  }
}

class _WorkspaceFlywheelPanel extends ConsumerWidget {
  final WorkspaceSummary workspace;

  const _WorkspaceFlywheelPanel({required this.workspace});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apps = ref.watch(flywheelAppsProvider(workspace.id));
    final quota = ref.watch(flywheelQuotaProvider(workspace.id));
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        _MailSectionHeader(title: 'workspaceFlywheel'.tr()),
        const SizedBox(height: 8),
        quota.when(
          loading: () => const LinearProgressIndicator(),
          error: (error, _) => const SizedBox.shrink(),
          data: (value) => Text(
            '${_formatBytes(value.usedBytes)} / ${_formatBytes(value.budgetBytes)}',
          ),
        ),
        const SizedBox(height: 12),
        apps.when(
          loading: () => const _WorkspacePanelLoading(),
          error: (error, _) => Text('workspaceFlywheelLoadError'.tr()),
          data: (items) => items.isEmpty
              ? Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text('workspaceFlywheelEmpty'.tr()),
                  ),
                )
              : Card(
                  child: Column(
                    children: [
                      for (final app in items)
                        ListTile(
                          leading: const Icon(Symbols.cloud_sync),
                          title: Text(app.appId),
                          subtitle: Text(
                            '${app.blobCount} · ${_formatBytes(app.retainedBytes)}',
                          ),
                          onTap: () => _showAppManagement(context, ref, app),
                        ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Future<void> _showAppManagement(
    BuildContext context,
    WidgetRef ref,
    FlywheelAppRecord app,
  ) async {
    final args = (workspaceId: workspace.id, appId: app.appId);
    try {
      final blobs = await ref.read(flywheelBlobsProvider(args).future);
      final audit = await ref.read(flywheelAuditProvider(args).future);
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => _FlywheelAppDialog(
          app: app,
          blobs: blobs,
          audit: audit,
          onDelete: (blob) async {
            final confirmed = await showConfirmAlert(
              'workspaceDeleteBlobDescription'.tr(),
              'workspaceDeleteBlob'.tr(),
              isDanger: true,
            );
            if (!confirmed) return;
            final client = ref.read(solarNetworkClientProvider);
            await client.dio.delete(
              '/flywheel/workspaces/${workspace.id}/apps/${Uri.encodeComponent(app.appId)}/management/blobs/${Uri.encodeComponent(blob.blobId)}',
            );
            ref.invalidate(flywheelAppsProvider(workspace.id));
            ref.invalidate(flywheelBlobsProvider(args));
            if (context.mounted) Navigator.pop(context);
          },
        ),
      );
    } catch (error) {
      showErrorAlert(error);
    }
  }
}

class _FlywheelAppDialog extends StatelessWidget {
  final FlywheelAppRecord app;
  final List<FlywheelBlobRecord> blobs;
  final List<FlywheelAuditRecord> audit;
  final Future<void> Function(FlywheelBlobRecord blob) onDelete;

  const _FlywheelAppDialog({
    required this.app,
    required this.blobs,
    required this.audit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(app.appId),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'workspaceBlobs'.tr(),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (blobs.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text('workspaceFlywheelEmpty'.tr()),
                )
              else
                for (final blob in blobs)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(blob.blobId),
                    subtitle: Text(
                      'r${blob.currentRevision} · '
                      '${_formatBytes(blob.retainedBytes)}',
                    ),
                    trailing: IconButton(
                      onPressed: () => onDelete(blob),
                      icon: const Icon(Symbols.delete_outline),
                      tooltip: 'workspaceDeleteBlob'.tr(),
                    ),
                  ),
              const SizedBox(height: 12),
              Text(
                'workspaceAudit'.tr(),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (audit.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text('workspaceAuditEmpty'.tr()),
                )
              else
                for (final entry in audit.take(10))
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(entry.action),
                    subtitle: Text('${entry.blobId} · ${entry.actorAccountId}'),
                  ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('close'.tr()),
        ),
      ],
    );
  }
}

class _WorkspacePanelLoading extends StatelessWidget {
  const _WorkspacePanelLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(32),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _MailSectionHeader extends StatelessWidget {
  final String title;
  final Widget? action;

  const _MailSectionHeader({required this.title, this.action});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        action ?? const SizedBox.shrink(),
      ],
    );
  }
}

class _UsageMetric extends StatelessWidget {
  final String label;
  final WorkspaceUsageSummary usage;

  const _UsageMetric({required this.label, required this.usage});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 4),
        Text('${usage.used} / ${usage.limit}'),
        Text(
          '${'workspaceRemaining'.tr()}: ${usage.remaining}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

String _formatBytes(int value) {
  if (value >= 1024 * 1024 * 1024) {
    return '${(value / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
  if (value >= 1024 * 1024) {
    return '${(value / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  return '${(value / 1024).round()} KB';
}

class _MailboxDraft {
  final String address;
  final String name;
  final bool isDefault;

  const _MailboxDraft({
    required this.address,
    required this.name,
    required this.isDefault,
  });
}

class _MailboxDialog extends StatefulWidget {
  const _MailboxDialog();

  @override
  State<_MailboxDialog> createState() => _MailboxDialogState();
}

class _MailboxDialogState extends State<_MailboxDialog> {
  final _addressController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isDefault = false;

  @override
  void dispose() {
    _addressController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('workspaceAddMailbox'.tr()),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _addressController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'workspaceMailboxAddress'.tr(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'workspaceMailboxName'.tr()),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _isDefault,
            onChanged: (value) => setState(() => _isDefault = value ?? false),
            title: Text('workspaceDefaultMailbox'.tr()),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('cancel'.tr()),
        ),
        FilledButton(
          onPressed: () {
            final address = _addressController.text.trim();
            if (address.isEmpty) return;
            Navigator.pop(
              context,
              _MailboxDraft(
                address: address,
                name: _nameController.text.trim(),
                isDefault: _isDefault,
              ),
            );
          },
          child: Text('create'.tr()),
        ),
      ],
    );
  }
}

class _DomainDialog extends StatefulWidget {
  const _DomainDialog();

  @override
  State<_DomainDialog> createState() => _DomainDialogState();
}

class _DomainDialogState extends State<_DomainDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('workspaceAddDomain'.tr()),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.url,
        decoration: InputDecoration(labelText: 'workspaceDomain'.tr()),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('cancel'.tr()),
        ),
        FilledButton(
          onPressed: () {
            final domain = _controller.text.trim().toLowerCase();
            if (domain.isEmpty) return;
            Navigator.pop(context, domain);
          },
          child: Text('create'.tr()),
        ),
      ],
    );
  }
}

class _WorkspaceCard extends StatelessWidget {
  final WorkspaceSummary workspace;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onMembers;

  const _WorkspaceCard({
    required this.workspace,
    required this.onOpen,
    required this.onEdit,
    required this.onMembers,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = workspace.isIndividual
        ? theme.colorScheme.primary
        : theme.colorScheme.tertiary;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(width: 6, color: accent),
            Expanded(
              child: ListTile(
                contentPadding: const EdgeInsets.fromLTRB(14, 6, 8, 6),
                leading: CircleAvatar(
                  backgroundColor: accent.withValues(alpha: .14),
                  foregroundColor: accent,
                  child: Icon(
                    workspace.isIndividual ? Symbols.person : Symbols.apartment,
                  ),
                ),
                title: Text(
                  workspace.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workspace.description.isEmpty
                          ? workspace.slug
                          : workspace.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _WorkspaceChip(label: workspace.planLabel),
                        if (workspace.isBundled)
                          _WorkspaceChip(label: 'workspaceBundled'.tr()),
                      ],
                    ),
                  ],
                ),
                trailing: Wrap(
                  spacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: onOpen,
                      icon: const Icon(Symbols.arrow_forward, size: 18),
                      label: Text('workspaceOpen'.tr()),
                    ),
                    PopupMenuButton<_WorkspaceAction>(
                      tooltip: 'workspaceActions'.tr(),
                      onSelected: (action) {
                        switch (action) {
                          case _WorkspaceAction.edit:
                            onEdit();
                          case _WorkspaceAction.members:
                            onMembers();
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: _WorkspaceAction.edit,
                          child: ListTile(
                            leading: const Icon(Symbols.edit),
                            title: Text('edit'.tr()),
                          ),
                        ),
                        PopupMenuItem(
                          value: _WorkspaceAction.members,
                          child: ListTile(
                            leading: const Icon(Symbols.group),
                            title: Text('workspaceMembers'.tr()),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _WorkspaceAction { edit, members }

class _WorkspaceChip extends StatelessWidget {
  final String label;

  const _WorkspaceChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: colors.onSecondaryContainer,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _WorkspaceEmptyState extends StatelessWidget {
  final VoidCallback onCreate;

  const _WorkspaceEmptyState({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Symbols.add_business,
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text('workspaceEmptyTitle'.tr(), textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(
              'workspaceEmptyDescription'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Symbols.add),
              label: Text('workspaceCreateOrganization'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkspaceError extends StatelessWidget {
  final VoidCallback onRetry;

  const _WorkspaceError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text('workspaceLoadError'.tr(), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.tonal(onPressed: onRetry, child: Text('retry'.tr())),
          ],
        ),
      ),
    );
  }
}

class WorkspaceEditorSheet extends StatefulWidget {
  final WorkspaceSummary? workspace;

  const WorkspaceEditorSheet({super.key, this.workspace});

  @override
  State<WorkspaceEditorSheet> createState() => _WorkspaceEditorSheetState();
}

class _WorkspaceEditorSheetState extends State<WorkspaceEditorSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _slugController;
  late final TextEditingController _descriptionController;
  bool _isLoading = false;

  bool get _isEditing => widget.workspace != null;

  @override
  void initState() {
    super.initState();
    final workspace = widget.workspace;
    _nameController = TextEditingController(text: workspace?.name ?? '');
    _slugController = TextEditingController(text: workspace?.slug ?? '');
    _descriptionController = TextEditingController(
      text: workspace?.description ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _slugController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SheetScaffold(
      titleText: _isEditing
          ? 'workspaceEditTitle'.tr()
          : 'workspaceCreateTitle'.tr(),
      heightFactor: 0.9,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'workspaceName'.tr(),
                prefixIcon: const Icon(Symbols.badge),
              ),
            ),
            if (!_isEditing) ...[
              const SizedBox(height: 14),
              TextField(
                controller: _slugController,
                decoration: InputDecoration(
                  labelText: 'workspaceSlug'.tr(),
                  prefixIcon: const Icon(Symbols.link),
                  helperText: 'workspaceSlugHint'.tr(),
                ),
                autocorrect: false,
              ),
            ],
            const SizedBox(height: 14),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              maxLength: 4096,
              decoration: InputDecoration(
                labelText: 'workspaceDescription'.tr(),
                prefixIcon: const Icon(Symbols.notes),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            if (!_isEditing)
              Text(
                'workspaceOrganizationHint'.tr(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _isLoading ? null : _save,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isEditing ? 'save'.tr() : 'create'.tr()),
            ),
            if (_isEditing && !(widget.workspace?.isIndividual ?? true)) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _isLoading ? null : _delete,
                icon: const Icon(Symbols.delete_outline),
                label: Text('workspaceDelete'.tr()),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final slug = _slugController.text.trim();
    if (name.isEmpty || (!_isEditing && slug.isEmpty)) {
      showSnackBar('workspaceRequiredFields'.tr());
      return;
    }
    if (!_isEditing && !RegExp(r'^[a-z0-9][a-z0-9-]*$').hasMatch(slug)) {
      showSnackBar('workspaceSlugInvalid'.tr());
      return;
    }

    setState(() => _isLoading = true);
    try {
      final client = ProviderScope.containerOf(
        context,
        listen: false,
      ).read(solarNetworkClientProvider);
      if (_isEditing) {
        await client.dio.patch(
          '/valve/workspaces/${Uri.encodeComponent(widget.workspace!.slug)}',
          data: {
            'name': name,
            'description': _descriptionController.text.trim(),
          },
        );
      } else {
        await client.dio.post(
          '/valve/workspaces',
          data: {
            'slug': slug,
            'name': name,
            'description': _descriptionController.text.trim(),
            'type': 1,
          },
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      showErrorAlert(error);
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showConfirmAlert(
      'workspaceDeleteDescription'.tr(),
      'workspaceDelete'.tr(),
      isDanger: true,
    );
    if (!confirmed || !mounted) return;

    setState(() => _isLoading = true);
    try {
      final client = ProviderScope.containerOf(
        context,
        listen: false,
      ).read(solarNetworkClientProvider);
      await client.dio.delete(
        '/valve/workspaces/${Uri.encodeComponent(widget.workspace!.slug)}',
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      showErrorAlert(error);
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

class WorkspaceMembersSheet extends ConsumerWidget {
  final WorkspaceSummary workspace;

  const WorkspaceMembersSheet({super.key, required this.workspace});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final members = ref.watch(workspaceMembersProvider(workspace.slug));

    return SheetScaffold(
      titleText: 'workspaceMembers'.tr(),
      heightFactor: 0.86,
      actions: [
        IconButton(
          onPressed: () => _invite(context, ref),
          icon: const Icon(Symbols.person_add),
          tooltip: 'workspaceInvite'.tr(),
        ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              workspace.name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            members.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => _WorkspaceError(
                onRetry: () =>
                    ref.invalidate(workspaceMembersProvider(workspace.slug)),
              ),
              data: (items) => items.isEmpty
                  ? Text('workspaceMembersEmpty'.tr())
                  : Column(
                      children: [
                        for (final member in items)
                          _MemberTile(
                            member: member,
                            workspace: workspace,
                            onChanged: () => ref.invalidate(
                              workspaceMembersProvider(workspace.slug),
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _invite(BuildContext context, WidgetRef ref) async {
    final invitation = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const _InviteMemberDialog(),
    );
    if (invitation == null || !context.mounted) return;
    try {
      final client = ref.read(solarNetworkClientProvider);
      await client.dio.post(
        '/valve/workspaces/${Uri.encodeComponent(workspace.slug)}/members/invite',
        data: invitation,
      );
      ref.invalidate(workspaceMembersProvider(workspace.slug));
    } catch (error) {
      showErrorAlert(error);
    }
  }
}

class _MemberTile extends StatelessWidget {
  final WorkspaceMemberSummary member;
  final WorkspaceSummary workspace;
  final VoidCallback onChanged;

  const _MemberTile({
    required this.member,
    required this.workspace,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: ProfilePictureWidget(
          fileId: member.profilePictureId,
          radius: 20,
          fallbackIcon: Symbols.person,
        ),
        title: Text(
          member.displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          member.username == null
              ? member.roleLabel
              : '@${member.username} · ${member.roleLabel}',
        ),
        trailing: member.role >= 100
            ? null
            : PopupMenuButton<int>(
                tooltip: 'workspaceChangeRole'.tr(),
                onSelected: (role) => _updateRole(context, role),
                itemBuilder: (_) => [
                  for (final role in const [25, 50, 75])
                    PopupMenuItem(value: role, child: Text(_roleLabel(role))),
                  PopupMenuItem(
                    value: -1,
                    child: Text('workspaceRemoveMember'.tr()),
                  ),
                ],
              ),
      ),
    );
  }

  String _roleLabel(int role) => switch (role) {
    75 => 'workspaceRoleAdmin'.tr(),
    50 => 'workspaceRoleMember'.tr(),
    _ => 'workspaceRoleViewer'.tr(),
  };

  Future<void> _updateRole(BuildContext context, int role) async {
    try {
      final client = ProviderScope.containerOf(
        context,
        listen: false,
      ).read(solarNetworkClientProvider);
      if (role == -1) {
        await client.dio.delete(
          '/valve/workspaces/${Uri.encodeComponent(workspace.slug)}/members/${Uri.encodeComponent(member.accountId)}',
        );
      } else {
        await client.dio.patch(
          '/valve/workspaces/${Uri.encodeComponent(workspace.slug)}/members/${Uri.encodeComponent(member.accountId)}',
          data: {'role': role},
        );
      }
      onChanged();
    } catch (error) {
      showErrorAlert(error);
    }
  }
}

class _InviteMemberDialog extends StatefulWidget {
  const _InviteMemberDialog();

  @override
  State<_InviteMemberDialog> createState() => _InviteMemberDialogState();
}

class _InviteMemberDialogState extends State<_InviteMemberDialog> {
  final _accountIdController = TextEditingController();
  int _role = 50;

  @override
  void dispose() {
    _accountIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('workspaceInvite'.tr()),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _accountIdController,
              decoration: InputDecoration(
                labelText: 'workspaceAccountId'.tr(),
                helperText: 'workspaceAccountIdHint'.tr(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<int>(
              value: _role,
              decoration: InputDecoration(labelText: 'workspaceRole'.tr()),
              items: const [
                DropdownMenuItem(value: 25, child: Text('Viewer')),
                DropdownMenuItem(value: 50, child: Text('Member')),
                DropdownMenuItem(value: 75, child: Text('Admin')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _role = value);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('cancel'.tr()),
        ),
        FilledButton(
          onPressed: () {
            final accountId = _accountIdController.text.trim();
            if (accountId.isEmpty) return;
            Navigator.pop(context, {'account_id': accountId, 'role': _role});
          },
          child: Text('workspaceInvite'.tr()),
        ),
      ],
    );
  }
}
