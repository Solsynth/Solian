import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/accounts/widgets/account/account_picker.dart';
import 'package:island/core/network.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/route.gr.dart';
import 'package:island/payments/payment_overlay.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/loading_indicator.dart';
import 'package:island/core/widgets/content/cloud_file_picker.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'workspace_detail.dart';

class WorkspaceSummary {
  final String id;
  final String slug;
  final String name;
  final String description;
  final int type;
  final String ownerAccountId;
  final int plan;
  final bool isBundled;

  /// Cloud file id of the workspace avatar, if the server provided one.
  final String? pictureId;

  /// Cloud file id of the workspace banner, if the server provided one.
  final String? backgroundId;

  const WorkspaceSummary({
    required this.id,
    required this.slug,
    required this.name,
    required this.description,
    required this.type,
    required this.ownerAccountId,
    required this.plan,
    required this.isBundled,
    this.pictureId,
    this.backgroundId,
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
      pictureId: _referenceId(json['picture']),
      backgroundId: _referenceId(json['background']),
    );
  }

  static String _string(dynamic value) => value?.toString() ?? '';

  /// The id of a `SnCloudFileReferenceObject`-shaped payload, or null.
  static String? _referenceId(dynamic value) {
    if (value is! Map) return null;
    return value['id']?.toString();
  }

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

class WorkspaceMailboxAliasRecord {
  final String id;
  final String mailboxId;
  final String customDomainId;
  final String localPart;
  final String address;
  final String name;

  const WorkspaceMailboxAliasRecord({
    required this.id,
    required this.mailboxId,
    required this.customDomainId,
    required this.localPart,
    required this.address,
    required this.name,
  });

  factory WorkspaceMailboxAliasRecord.fromJson(dynamic value) {
    final json = _jsonMap(value);
    return WorkspaceMailboxAliasRecord(
      id: _jsonString(json['id']),
      mailboxId: _jsonString(json['mailbox_id']),
      customDomainId: _jsonString(json['custom_domain_id']),
      localPart: _jsonString(json['local_part']),
      address: _jsonString(json['address']),
      name: _jsonString(json['name']),
    );
  }
}

class WorkspaceMailboxForwardingRecord {
  final String id;
  final String mailboxId;
  final String aliasId;
  final String destination;

  const WorkspaceMailboxForwardingRecord({
    required this.id,
    required this.mailboxId,
    required this.aliasId,
    required this.destination,
  });

  factory WorkspaceMailboxForwardingRecord.fromJson(dynamic value) {
    final json = _jsonMap(value);
    return WorkspaceMailboxForwardingRecord(
      id: _jsonString(json['id']),
      mailboxId: _jsonString(json['mailbox_id']),
      aliasId: _jsonString(json['alias_id']),
      destination: _jsonString(json['destination']),
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

class WorkspaceDomainDnsRecord {
  final String name;
  final String type;
  final String value;

  const WorkspaceDomainDnsRecord({
    required this.name,
    required this.type,
    required this.value,
  });

  factory WorkspaceDomainDnsRecord.fromJson(dynamic value) {
    final json = _jsonMap(value);
    return WorkspaceDomainDnsRecord(
      name: _jsonString(json['name']),
      type: _jsonString(json['type']),
      value: _jsonString(json['value']),
    );
  }
}

class WorkspaceDomainRecord {
  final String id;
  final String domain;
  final String status;
  final String stage;
  final bool verifiedForSending;
  final String dkimStatus;
  final String mailFromDomain;
  final String mailFromStatus;
  final List<WorkspaceDomainDnsRecord> dnsRecords;

  const WorkspaceDomainRecord({
    required this.id,
    required this.domain,
    required this.status,
    required this.stage,
    required this.verifiedForSending,
    required this.dkimStatus,
    required this.mailFromDomain,
    required this.mailFromStatus,
    required this.dnsRecords,
  });

  factory WorkspaceDomainRecord.fromJson(dynamic value) {
    final json = _jsonMap(value);
    final records = json['dns_records'];
    return WorkspaceDomainRecord(
      id: _jsonString(json['id']),
      domain: _jsonString(json['domain']),
      status: _jsonString(json['verification_status']),
      stage: _jsonString(json['stage']),
      verifiedForSending: _jsonBool(json['verified_for_sending_status']),
      dkimStatus: _jsonString(json['dkim_status']),
      mailFromDomain: _jsonString(json['mail_from_domain']),
      mailFromStatus: _jsonString(json['mail_from_status']),
      dnsRecords: records is List
          ? records
                .map(WorkspaceDomainDnsRecord.fromJson)
                .toList(growable: false)
          : const [],
    );
  }
}

class WorkspaceCustomDomainUsage {
  final int used;
  final int limit;
  final int remaining;

  const WorkspaceCustomDomainUsage({
    required this.used,
    required this.limit,
    required this.remaining,
  });

  factory WorkspaceCustomDomainUsage.fromJson(dynamic value) {
    final json = _jsonMap(value);
    return WorkspaceCustomDomainUsage(
      used: _jsonInt(json['used']),
      limit: _jsonInt(json['limit']),
      remaining: _jsonInt(json['remaining']),
    );
  }
}

class WorkspaceMailCredential {
  final String id;
  final String mailboxId;
  final String label;
  final List<String> protocols;
  final DateTime? createdAt;

  const WorkspaceMailCredential({
    required this.id,
    required this.mailboxId,
    required this.label,
    required this.protocols,
    required this.createdAt,
  });

  factory WorkspaceMailCredential.fromJson(dynamic value) {
    final json = _jsonMap(value);
    final protocols = json['protocols'];
    return WorkspaceMailCredential(
      id: _jsonString(json['id']),
      mailboxId: _jsonString(json['mailbox_id']),
      label: _jsonString(json['label']),
      protocols: protocols is List
          ? protocols.map((item) => item.toString()).toList(growable: false)
          : const [],
      createdAt: DateTime.tryParse(_jsonString(json['created_at'])),
    );
  }
}

class WorkspaceMailCredentialCreated {
  final WorkspaceMailCredential credential;
  final String secret;

  const WorkspaceMailCredentialCreated({
    required this.credential,
    required this.secret,
  });

  factory WorkspaceMailCredentialCreated.fromJson(dynamic value) {
    final json = _jsonMap(value);
    return WorkspaceMailCredentialCreated(
      credential: WorkspaceMailCredential.fromJson(json['credential']),
      secret: _jsonString(json['secret']),
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

final workspaceMailboxAliasesProvider = FutureProvider.autoDispose
    .family<List<WorkspaceMailboxAliasRecord>, String>((ref, mailboxId) async {
      final client = ref.read(solarNetworkClientProvider);
      final response = await client.dio.get(
        '/postal/mailboxes/${Uri.encodeComponent(mailboxId)}/aliases',
      );
      final data = response.data;
      if (data is! List) throw StateError('Invalid mailbox alias response.');
      return data
          .map(WorkspaceMailboxAliasRecord.fromJson)
          .toList(growable: false);
    });

final workspaceMailboxForwardingProvider = FutureProvider.autoDispose
    .family<List<WorkspaceMailboxForwardingRecord>, String>((
      ref,
      mailboxId,
    ) async {
      final client = ref.read(solarNetworkClientProvider);
      final response = await client.dio.get(
        '/postal/mailboxes/${Uri.encodeComponent(mailboxId)}/forwarding',
      );
      final data = response.data;
      if (data is! List) {
        throw StateError('Invalid mailbox forwarding response.');
      }
      return data
          .map(WorkspaceMailboxForwardingRecord.fromJson)
          .toList(growable: false);
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

final workspaceCustomDomainUsageProvider = FutureProvider.autoDispose
    .family<WorkspaceCustomDomainUsage, String>((ref, workspaceId) async {
      final client = ref.read(solarNetworkClientProvider);
      final response = await client.dio.get(
        '/postal/workspaces/$workspaceId/custom-domain-usage',
      );
      return WorkspaceCustomDomainUsage.fromJson(response.data);
    });

final workspaceMailCredentialsProvider =
    FutureProvider.autoDispose<List<WorkspaceMailCredential>>((ref) async {
      final client = ref.read(solarNetworkClientProvider);
      final response = await client.dio.get('/postal/credentials');
      final data = response.data;
      if (data is! List) throw StateError('Invalid mail credential response.');
      return data.map(WorkspaceMailCredential.fromJson).toList(growable: false);
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

// ============================================================================
// UI
//
// This surface is the network's backstage: workspaces are its islands, and an
// owner reads this screen the way a crew reads an instrument panel. The visual
// language is deliberately "spec sheet": hairline rules, monogram seals, and
// data set in Roboto Mono (the app's established data face). The one animated
// moment is the usage meter charging when figures arrive.
// ============================================================================

/// Content is set at a book measure so registry rows and panels stay scannable
/// on desktop; on narrow phones the same layout flows full width.
const double _kContentMaxWidth = 720;

@RoutePage()
class WorkspaceManagementScreen extends HookConsumerWidget {
  const WorkspaceManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspaces = ref.watch(workspaceListProvider);
    final isCardMode = useState(false);

    Future<void> refreshWorkspaces() async {
      ref.invalidate(workspaceListProvider);
      await ref.read(workspaceListProvider.future);
    }

    return AppScaffold(
      appBar: AppBar(
        title: Text('workspaceManagementTitle').tr(),
        leading: IconButton(
          icon: const Icon(Symbols.menu),
          onPressed: () => rootScaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isCardMode.value ? Symbols.view_list : Symbols.grid_view,
            ),
            tooltip:
                (isCardMode.value
                        ? 'workspaceSwitchToListView'
                        : 'workspaceSwitchToCardView')
                    .tr(),
            onPressed: () => isCardMode.value = !isCardMode.value,
          ),
          IconButton(
            onPressed: workspaces.isLoading ? null : refreshWorkspaces,
            icon: const Icon(Symbols.refresh),
            tooltip: 'refresh'.tr(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'workspaceCreateOrganization'.tr(),
        onPressed: () => _openEditor(context, ref),
        child: const Icon(Symbols.add),
      ),
      body: workspaces.when(
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: _WorkspaceError(
              message: 'workspaceLoadError'.tr(),
              onRetry: refreshWorkspaces,
            ),
          ),
        ),
        data: (items) => RefreshIndicator(
          onRefresh: refreshWorkspaces,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 96),
            itemCount: items.isEmpty ? 1 : items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              if (items.isEmpty) {
                return _CenteredContent(
                  child: _WorkspaceEmptyState(
                    onCreate: () => _openEditor(context, ref),
                  ),
                );
              }
              final workspace = items[index];
              final child = isCardMode.value
                  ? _WorkspaceCard(
                      workspace: workspace,
                      onOpen: () => context.router.push(
                        WorkspaceDetailRoute(slug: workspace.slug),
                      ),
                      onEdit: () => _openEditor(context, ref, workspace),
                      onMembers: () => _openMembers(context, workspace),
                    )
                  : _WorkspaceRow(
                      workspace: workspace,
                      onOpen: () => context.router.push(
                        WorkspaceDetailRoute(slug: workspace.slug),
                      ),
                      onEdit: () => _openEditor(context, ref, workspace),
                      onMembers: () => _openMembers(context, workspace),
                    );
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: _kContentMaxWidth,
                  ),
                  child: child,
                ),
              );
            },
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

// ---------------------------------------------------------------------------
// Building blocks
// ---------------------------------------------------------------------------

/// Centers content at a comfortable measure on wide screens.
class _CenteredContent extends StatelessWidget {
  final Widget child;

  const _CenteredContent({required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _kContentMaxWidth),
        child: child,
      ),
    );
  }
}

/// Quiet surface with a hairline border — the screen's one container language.
class _Panel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _Panel({required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

/// A column with 1px rules between children — the registry ledger.
class _DividedColumn extends StatelessWidget {
  final List<Widget> children;

  const _DividedColumn({required this.children});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0)
            Divider(height: 1, thickness: 1, color: scheme.outlineVariant),
          children[i],
        ],
      ],
    );
  }
}

/// Section label with an optional action on the right.
class _SectionHeader extends StatelessWidget {
  final String title;
  final Widget? action;

  const _SectionHeader({required this.title, this.action});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
        ),
        action ?? const SizedBox.shrink(),
      ],
    );
  }
}

/// The signature instrument: used / limit, a hairline track that charges on
/// arrival, and the remaining figure. Near the limit the fill turns error
/// tinted so the panel reads like a health gauge.
class _UsageMeter extends StatelessWidget {
  final String label;
  final int used;
  final int limit;
  final int remaining;

  /// When true, figures are rendered as human-readable bytes.
  final bool formatBytes;

  const _UsageMeter({
    required this.label,
    required this.used,
    required this.limit,
    required this.remaining,
    this.formatBytes = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final ratio = limit <= 0 ? 0.0 : (used / limit).clamp(0.0, 1.0).toDouble();
    final critical = limit > 0 && used >= limit * 0.9;
    final fill = critical ? scheme.error : scheme.primary;

    String figure(int value) => formatBytes ? _formatBytes(value) : '$value';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${figure(used)} / ${figure(limit)}',
              style: GoogleFonts.robotoMono(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: critical ? scheme.error : scheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: SizedBox(
            height: 6,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(color: scheme.surfaceContainerHighest),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: ratio),
                  duration: reduceMotion
                      ? Duration.zero
                      : const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) => Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: value,
                      heightFactor: 1,
                      child: Container(color: fill),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 7),
        Row(
          children: [
            Text(
              'workspaceRemaining'.tr(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              figure(remaining),
              style: GoogleFonts.robotoMono(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Quiet placeholder while a meter's figures are loading.
class _MeterSkeleton extends StatelessWidget {
  const _MeterSkeleton();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 120,
            height: 14,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ],
      ),
    );
  }
}

/// Monogram seal: the workspace's initials on a tonal disk, or the workspace
/// picture when the server provided one. The one place the screen carries a
/// shape; it stands in for the workspace's identity.
class _WorkspaceSeal extends StatelessWidget {
  final String name;
  final bool isIndividual;
  final double radius;
  final String? fileId;

  const _WorkspaceSeal({
    required this.name,
    required this.isIndividual,
    required this.radius,
    this.fileId,
  });

  @override
  Widget build(BuildContext context) {
    final picture = fileId;
    if (picture != null && picture.isNotEmpty) {
      return ClipOval(
        child: ProfilePictureWidget(
          fileId: picture,
          radius: radius,
          fallbackIcon: isIndividual ? Symbols.person : Symbols.apartment,
        ),
      );
    }

    final scheme = Theme.of(context).colorScheme;
    final background = isIndividual
        ? scheme.secondaryContainer
        : scheme.primaryContainer;
    final foreground = isIndividual
        ? scheme.onSecondaryContainer
        : scheme.onPrimaryContainer;
    final letters = _sealLetters(name, radius);

    return Container(
      width: radius * 2,
      height: radius * 2,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Text(
        letters,
        style: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w700,
          fontSize: radius * (letters.length > 1 ? 0.62 : 0.9),
          letterSpacing: -0.5,
          height: 1,
        ),
      ),
    );
  }

  static String _sealLetters(String name, double radius) {
    final words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    if (words.isEmpty) return '?';
    if (words.length >= 2) {
      return '${String.fromCharCode(words[0].runes.first)}'
              '${String.fromCharCode(words[1].runes.first)}'
          .toUpperCase();
    }
    final word = words.first;
    final count = radius >= 24 ? 2 : 1;
    final runes = word.runes.take(count).toList();
    if (runes.isEmpty) return '?';
    return String.fromCharCodes(runes).toUpperCase();
  }
}

/// Small tonal tag. Outline variant is the neutral default for identity marks.
class _WorkspaceBadge extends StatelessWidget {
  final String label;
  final Color? background;
  final Color? foreground;

  const _WorkspaceBadge({
    required this.label,
    this.background,
    this.foreground,
  });

  const _WorkspaceBadge.outline(String label)
    : this(label: label, background: Colors.transparent);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = background ?? scheme.secondaryContainer;
    final fg = foreground ?? scheme.onSecondaryContainer;
    final outline = bg == Colors.transparent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(5),
        border: outline ? Border.all(color: scheme.outlineVariant) : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
          color: outline ? scheme.onSurfaceVariant : fg,
        ),
      ),
    );
  }
}

/// A member's rank, color coded by tier: Owner, Admin, Member, Viewer.
class _RoleBadge extends StatelessWidget {
  final int role;
  final String label;

  const _RoleBadge({required this.role, required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (background, foreground) = switch (role) {
      >= 100 => (scheme.primaryContainer, scheme.onPrimaryContainer),
      >= 75 => (scheme.tertiaryContainer, scheme.onTertiaryContainer),
      >= 50 => (scheme.secondaryContainer, scheme.onSecondaryContainer),
      _ => (scheme.surfaceContainerHighest, scheme.onSurfaceVariant),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
          color: foreground,
        ),
      ),
    );
  }
}

/// Small mono tag for revision numbers.
class _RevisionBadge extends StatelessWidget {
  final String text;

  const _RevisionBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: GoogleFonts.robotoMono(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _DialogEyebrow extends StatelessWidget {
  final String text;

  const _DialogEyebrow(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

/// Icon in a tonal tile — used for row leading marks.
class _RowGlyph extends StatelessWidget {
  final IconData icon;

  const _RowGlyph({required this.icon});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Icon(icon, size: 18, color: scheme.onSurfaceVariant),
    );
  }
}

// ---------------------------------------------------------------------------
// Rows
// ---------------------------------------------------------------------------

/// Registry entry on the workspace list.
class _WorkspaceRow extends StatelessWidget {
  final WorkspaceSummary workspace;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onMembers;

  const _WorkspaceRow({
    required this.workspace,
    required this.onOpen,
    required this.onEdit,
    required this.onMembers,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpen,
        hoverColor: scheme.surfaceContainerHigh,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
          child: Row(
            children: [
              _WorkspaceSeal(
                name: workspace.name,
                isIndividual: workspace.isIndividual,
                radius: 20,
                fileId: workspace.pictureId,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            workspace.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            '@${workspace.slug}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.robotoMono(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (workspace.description.isNotEmpty) ...[
                      Text(
                        workspace.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          _WorkspaceBadge(label: workspace.planLabel),
                          if (workspace.isBundled)
                            _WorkspaceBadge.outline('workspaceBundled'.tr()),
                        ],
                      ),
                    ],
                  ],
                ),
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
    final scheme = theme.colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 124,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    scheme.primaryContainer,
                    scheme.surfaceContainerHighest,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: _WorkspaceSeal(
                  name: workspace.name,
                  isIndividual: workspace.isIndividual,
                  radius: 26,
                  fileId: workspace.pictureId,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          workspace.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '@${workspace.slug}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.robotoMono(
                            fontSize: 12,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _WorkspaceBadge(label: workspace.planLabel),
                      if (workspace.isBundled)
                        _WorkspaceBadge.outline('workspaceBundled'.tr()),
                    ],
                  ),
                  if (workspace.description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      workspace.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: onMembers,
                        icon: const Icon(Symbols.group),
                        tooltip: 'workspaceMembers'.tr(),
                      ),
                      IconButton(
                        onPressed: onEdit,
                        icon: const Icon(Symbols.edit),
                        tooltip: 'edit'.tr(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _WorkspaceAction { edit, members }

/// Member entry used on both the detail tab and the manage sheet.
class _MemberRow extends StatelessWidget {
  final WorkspaceMemberSummary member;
  final Widget? trailing;

  const _MemberRow({required this.member, this.trailing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final username = member.username;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
      child: Row(
        children: [
          ProfilePictureWidget(
            fileId: member.profilePictureId,
            radius: 18,
            fallbackIcon: Symbols.person,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    if (username != null) ...[
                      Flexible(
                        child: Text(
                          '@$username',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.robotoMono(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    _RoleBadge(role: member.role, label: member.roleLabel),
                  ],
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class _MailboxRow extends StatelessWidget {
  final WorkspaceMailboxRecord mailbox;
  final VoidCallback onTap;

  const _MailboxRow({required this.mailbox, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final name = mailbox.name;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
          child: Row(
            children: [
              const _RowGlyph(icon: Symbols.mail),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mailbox.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.robotoMono(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(
                          mailbox.isVerified ? Symbols.verified : Symbols.error,
                          size: 14,
                          color: mailbox.isVerified
                              ? scheme.primary
                              : scheme.outline,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            name.isEmpty
                                ? (mailbox.isVerified
                                      ? 'workspaceVerified'.tr()
                                      : 'workspaceUnverified'.tr())
                                : name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (mailbox.isDefault) ...[
                const SizedBox(width: 8),
                Icon(Symbols.star, size: 18, color: scheme.tertiary),
              ],
              const SizedBox(width: 4),
              Icon(Symbols.chevron_right, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkspaceCredentialRow extends StatelessWidget {
  final WorkspaceMailCredential credential;
  final WorkspaceMailboxRecord mailbox;
  final VoidCallback onRevoke;

  const _WorkspaceCredentialRow({
    required this.credential,
    required this.mailbox,
    required this.onRevoke,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
      child: Row(
        children: [
          const _RowGlyph(icon: Symbols.key),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  credential.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  '${mailbox.address} · '
                  '${credential.protocols.map((value) => value.toUpperCase()).join(', ')}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.robotoMono(
                    fontSize: 11.5,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRevoke,
            icon: Icon(Symbols.delete_outline, color: scheme.error),
            tooltip: 'workspaceRevokeCredential'.tr(),
          ),
        ],
      ),
    );
  }
}

class _DomainRow extends StatelessWidget {
  final WorkspaceDomainRecord domain;
  final VoidCallback onRefresh;

  const _DomainRow({required this.domain, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final status = domain.verifiedForSending
        ? 'workspaceDomainReady'.tr()
        : 'workspaceDomainNeedsDns'.tr();
    return ExpansionTile(
      tilePadding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      shape: const Border(),
      collapsedShape: const Border(),
      controlAffinity: ListTileControlAffinity.leading,
      leading: const _RowGlyph(icon: Symbols.language),
      title: Text(
        domain.domain,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.robotoMono(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        '$status · ${domain.status} · ${domain.stage} · '
        '${'workspaceDomainExpandHint'.tr()}',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.robotoMono(
          fontSize: 12,
          color: scheme.onSurfaceVariant,
        ),
      ),
      trailing: IconButton(
        onPressed: onRefresh,
        icon: const Icon(Symbols.refresh),
        tooltip: 'refresh'.tr(),
      ),
      children: [
        if (domain.dkimStatus.isNotEmpty || domain.mailFromStatus.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${'workspaceDomainDkim'.tr()}: ${domain.dkimStatus} · '
                '${'workspaceDomainMailFrom'.tr()}: ${domain.mailFromStatus}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ),
          ),
        if (domain.dnsRecords.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'workspaceDomainDnsEmpty'.tr(),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ),
          )
        else
          for (final record in domain.dnsRecords)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.type,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    SelectableText(
                      record.name,
                      style: GoogleFonts.robotoMono(fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    SelectableText(
                      record.value,
                      style: GoogleFonts.robotoMono(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
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

class _FlywheelAppRow extends StatelessWidget {
  final FlywheelAppRecord app;
  final VoidCallback onTap;

  const _FlywheelAppRow({required this.app, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        hoverColor: scheme.surfaceContainerHigh,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
          child: Row(
            children: [
              const _RowGlyph(icon: Symbols.cloud_sync),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.appId,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.robotoMono(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${app.blobCount} · ${_formatBytes(app.retainedBytes)}',
                      style: GoogleFonts.robotoMono(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Symbols.chevron_right,
                size: 20,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Overlapping member avatars — the human side of the ledger.
class _MemberAvatarStrip extends StatelessWidget {
  final List<WorkspaceMemberSummary> members;

  const _MemberAvatarStrip({required this.members});

  @override
  Widget build(BuildContext context) {
    const avatarSize = 28.0;
    const overlap = 8.0;
    final scheme = Theme.of(context).colorScheme;
    final count = members.length;
    return SizedBox(
      height: avatarSize,
      width: avatarSize * count - overlap * (count - 1),
      child: Stack(
        children: [
          for (var i = 0; i < count; i++)
            Positioned(
              left: i * (avatarSize - overlap),
              child: Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scheme.surface,
                  border: Border.all(color: scheme.surface, width: 2),
                ),
                child: ClipOval(
                  child: ProfilePictureWidget(
                    fileId: members[i].profilePictureId,
                    radius: 12,
                    fallbackIcon: Symbols.person,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// States
// ---------------------------------------------------------------------------

class _WorkspacePanelLoading extends StatelessWidget {
  const _WorkspacePanelLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(32),
      child: Center(child: LoadingIndicator()),
    );
  }
}

class _PanelEmpty extends StatelessWidget {
  final String message;

  const _PanelEmpty({required this.message});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _Panel(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Center(
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
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
    final scheme = Theme.of(context).colorScheme;
    return _Panel(
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Symbols.add_business,
              size: 30,
              color: scheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'workspaceEmptyTitle'.tr(),
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'workspaceEmptyDescription'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(color: scheme.onSurfaceVariant, height: 1.4),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onCreate,
            icon: const Icon(Symbols.add),
            label: Text('workspaceCreateOrganization'.tr()),
          ),
        ],
      ),
    );
  }
}

class _WorkspaceError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _WorkspaceError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _Panel(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(Symbols.error, size: 28, color: scheme.outline),
          const SizedBox(height: 10),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 14),
          FilledButton.tonal(onPressed: onRetry, child: Text('retry'.tr())),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sheets and dialogs
// ---------------------------------------------------------------------------

class WorkspaceEditorSheet extends StatefulWidget {
  final WorkspaceSummary? workspace;

  const WorkspaceEditorSheet({super.key, this.workspace});

  @override
  State<WorkspaceEditorSheet> createState() => _WorkspaceEditorSheetState();
}

/// Labeled preview row for the workspace picture / background pickers.
class _EditorImageRow extends StatelessWidget {
  final String label;
  final Widget preview;
  final VoidCallback? onEdit;

  const _EditorImageRow({
    required this.label,
    required this.preview,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        preview,
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
        ),
        FilledButton.tonalIcon(
          onPressed: onEdit,
          icon: const Icon(Symbols.edit, size: 18),
          label: Text('edit'.tr()),
        ),
      ],
    );
  }
}

class _WorkspaceEditorSheetState extends State<WorkspaceEditorSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _slugController;
  late final TextEditingController _descriptionController;

  /// Newly picked images; null means keep whatever the workspace has.
  SnCloudFile? _picture;
  SnCloudFile? _background;
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
            const SizedBox(height: 20),
            _EditorImageRow(
              label: 'workspacePicture'.tr(),
              preview: _picturePreview(),
              onEdit: _isLoading ? null : _pickPicture,
            ),
            const SizedBox(height: 14),
            _EditorImageRow(
              label: 'workspaceBackground'.tr(),
              preview: _backgroundPreview(),
              onEdit: _isLoading ? null : _pickBackground,
            ),
            const SizedBox(height: 20),
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
            if (_picture != null) 'picture_id': _picture!.id,
            if (_background != null) 'background_id': _background!.id,
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
            if (_picture != null) 'picture_id': _picture!.id,
            if (_background != null) 'background_id': _background!.id,
          },
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      showErrorAlert(error);
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickPicture() => _pickImage((file) => _picture = file);

  Future<void> _pickBackground() => _pickImage((file) => _background = file);

  Future<void> _pickImage(void Function(SnCloudFile file) assign) async {
    final file = await showModalBottomSheet<SnCloudFile>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (_) => const CloudFilePicker(
        allowedTypes: {UniversalFileType.image},
        usage: 'workspace',
      ),
    );
    if (file != null && mounted) {
      setState(() => assign(file));
    }
  }

  Widget _picturePreview() {
    final scheme = Theme.of(context).colorScheme;
    final picked = _picture;
    final current = widget.workspace?.pictureId;
    if (picked != null) {
      return ProfilePictureWidget(
        file: picked,
        radius: 24,
        fallbackIcon: Symbols.add_photo_alternate,
      );
    }
    if (current != null && current.isNotEmpty) {
      return ProfilePictureWidget(
        fileId: current,
        radius: 24,
        fallbackIcon: Symbols.add_photo_alternate,
      );
    }
    return _imagePlaceholder(scheme, width: 48, height: 48, circle: true);
  }

  Widget _backgroundPreview() {
    final scheme = Theme.of(context).colorScheme;
    final picked = _background;
    final current = widget.workspace?.backgroundId;
    if (picked != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 96,
          height: 56,
          child: CloudImageWidget(
            file: picked,
            fit: BoxFit.cover,
            imageOnly: true,
          ),
        ),
      );
    }
    if (current != null && current.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 96,
          height: 56,
          child: CloudImageWidget(
            fileId: current,
            fit: BoxFit.cover,
            imageOnly: true,
          ),
        ),
      );
    }
    return _imagePlaceholder(scheme, width: 96, height: 56, circle: false);
  }

  Widget _imagePlaceholder(
    ColorScheme scheme, {
    required double width,
    required double height,
    required bool circle,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(8),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Icon(
        Symbols.add_photo_alternate,
        size: 20,
        color: scheme.onSurfaceVariant,
      ),
    );
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

class WorkspaceMembersSheet extends ConsumerStatefulWidget {
  final WorkspaceSummary workspace;

  const WorkspaceMembersSheet({super.key, required this.workspace});

  @override
  ConsumerState<WorkspaceMembersSheet> createState() =>
      _WorkspaceMembersSheetState();
}

class _WorkspaceMembersSheetState extends ConsumerState<WorkspaceMembersSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  WorkspaceSummary get workspace => widget.workspace;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final members = ref.watch(workspaceMembersProvider(workspace.slug));
    final theme = Theme.of(context);

    return SheetScaffold(
      titleText: 'workspaceMembers'.tr(),
      heightFactor: 0.86,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.8,
        ),
        child: Column(
          children: [
            members.when(
              loading: () => _buildHeader(context, 0),
              error: (_, _) => _buildHeader(context, 0),
              data: (items) =>
                  _buildHeader(context, _filteredMembers(items).length),
            ),
            Expanded(
              child: members.when(
                loading: () => const Center(child: LoadingIndicator()),
                error: (error, _) => _WorkspaceError(
                  message: 'workspaceMembersLoadError'.tr(),
                  onRetry: () =>
                      ref.invalidate(workspaceMembersProvider(workspace.slug)),
                ),
                data: (items) {
                  final filtered = _filteredMembers(items);
                  if (filtered.isEmpty) {
                    return _PanelEmpty(
                      message: _query.isEmpty
                          ? 'workspaceMembersEmpty'.tr()
                          : 'workspaceMembersSearchEmpty'.tr(),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 20),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final member = filtered[index];
                      final canManage = member.role < 100;
                      return _MemberRow(
                        member: member,
                        trailing: canManage
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Symbols.edit),
                                    tooltip: 'workspaceChangeRole'.tr(),
                                    onPressed: () => _editRole(member),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Symbols.delete,
                                      color: theme.colorScheme.error,
                                    ),
                                    tooltip: 'workspaceRemoveMember'.tr(),
                                    onPressed: () => _removeMember(member),
                                  ),
                                ],
                              )
                            : null,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'members'.plural(count),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Symbols.person_add),
                tooltip: 'workspaceInvite'.tr(),
                onPressed: _invite,
              ),
              IconButton(
                icon: const Icon(Symbols.refresh),
                tooltip: 'refresh'.tr(),
                onPressed: () =>
                    ref.invalidate(workspaceMembersProvider(workspace.slug)),
              ),
              IconButton(
                icon: const Icon(Symbols.close),
                tooltip: 'close'.tr(),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SearchBar(
            controller: _searchController,
            hintText: 'workspaceMembersSearch'.tr(),
            leading: const Icon(Symbols.search),
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 16),
            ),
            trailing: [
              if (_query.isNotEmpty)
                IconButton(
                  icon: const Icon(Symbols.close),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                ),
            ],
            onChanged: (value) => setState(() => _query = value.trim()),
          ),
        ],
      ),
    );
  }

  List<WorkspaceMemberSummary> _filteredMembers(
    List<WorkspaceMemberSummary> members,
  ) {
    final query = _query.toLowerCase();
    if (query.isEmpty) return members;
    return members
        .where(
          (member) =>
              member.displayName.toLowerCase().contains(query) ||
              (member.username?.toLowerCase().contains(query) ?? false) ||
              member.accountId.toLowerCase().contains(query),
        )
        .toList(growable: false);
  }

  Future<void> _editRole(WorkspaceMemberSummary member) async {
    final role = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (_) => _WorkspaceMemberRoleSheet(role: member.role),
    );
    if (role != null && mounted) await _updateRole(member, role);
  }

  Future<void> _removeMember(WorkspaceMemberSummary member) async {
    final confirmed = await showConfirmAlert(
      'workspaceRemoveMemberDescription'.tr(),
      'workspaceRemoveMember'.tr(),
      isDanger: true,
    );
    if (confirmed != true || !mounted) return;
    await _updateRole(member, -1);
  }

  Future<void> _updateRole(WorkspaceMemberSummary member, int role) async {
    try {
      final client = ref.read(solarNetworkClientProvider);
      if (role == -1) {
        await client.dio.delete(
          '/valve/workspaces/${Uri.encodeComponent(workspace.slug)}/members/'
          '${Uri.encodeComponent(member.accountId)}',
        );
      } else {
        await client.dio.patch(
          '/valve/workspaces/${Uri.encodeComponent(workspace.slug)}/members/'
          '${Uri.encodeComponent(member.accountId)}',
          data: {'role': role},
        );
      }
      ref.invalidate(workspaceMembersProvider(workspace.slug));
    } catch (error) {
      showErrorAlert(error);
    }
  }

  Future<void> _invite() async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (_) => const AccountPickerSheet(),
    );
    if (result == null || !mounted) return;
    try {
      final client = ref.read(solarNetworkClientProvider);
      await client.dio.post(
        '/valve/workspaces/${Uri.encodeComponent(workspace.slug)}/members/invite',
        data: {'account_id': result.id, 'role': 50},
      );
      ref.invalidate(workspaceMembersProvider(workspace.slug));
    } catch (error) {
      showErrorAlert(error);
    }
  }
}

class _WorkspaceMemberRoleSheet extends StatefulWidget {
  final int role;

  const _WorkspaceMemberRoleSheet({required this.role});

  @override
  State<_WorkspaceMemberRoleSheet> createState() =>
      _WorkspaceMemberRoleSheetState();
}

class _WorkspaceMemberRoleSheetState extends State<_WorkspaceMemberRoleSheet> {
  late int _role = widget.role;

  @override
  Widget build(BuildContext context) {
    return SheetScaffold(
      titleText: 'workspaceChangeRole'.tr(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<int>(
              value: _role,
              decoration: InputDecoration(labelText: 'workspaceRole'.tr()),
              items: [
                DropdownMenuItem(
                  value: 25,
                  child: Text('workspaceRoleViewer'.tr()),
                ),
                DropdownMenuItem(
                  value: 50,
                  child: Text('workspaceRoleMember'.tr()),
                ),
                DropdownMenuItem(
                  value: 75,
                  child: Text('workspaceRoleAdmin'.tr()),
                ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _role = value);
              },
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context, _role),
              icon: const Icon(Symbols.save),
              label: Text('saveChanges'.tr()),
            ),
          ],
        ),
      ),
    );
  }
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
    return SheetScaffold(
      titleText: 'workspaceAddMailbox'.tr(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
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
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('cancel'.tr()),
              ),
              const SizedBox(width: 8),
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
          ),
        ],
      ),
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
    return SheetScaffold(
      titleText: 'workspaceAddDomain'.tr(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          TextField(
            controller: _controller,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(labelText: 'workspaceDomain'.tr()),
            autofocus: true,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('cancel'.tr()),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () {
                  final domain = _controller.text.trim().toLowerCase();
                  if (domain.isEmpty) return;
                  Navigator.pop(context, domain);
                },
                child: Text('create'.tr()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MailCredentialDraft {
  final String mailboxId;
  final String label;
  final List<String> protocols;

  const _MailCredentialDraft({
    required this.mailboxId,
    required this.label,
    required this.protocols,
  });
}

class _MailCredentialDialog extends StatefulWidget {
  final List<WorkspaceMailboxRecord> mailboxes;

  const _MailCredentialDialog({required this.mailboxes});

  @override
  State<_MailCredentialDialog> createState() => _MailCredentialDialogState();
}

class _MailCredentialDialogState extends State<_MailCredentialDialog> {
  final _labelController = TextEditingController();
  late String _mailboxId;
  final _protocols = <String>{'smtp', 'imap'};

  @override
  void initState() {
    super.initState();
    _mailboxId = widget.mailboxes.first.id;
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SheetScaffold(
      titleText: 'workspaceCreateCredential'.tr(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          TextField(
            controller: _labelController,
            decoration: InputDecoration(
              labelText: 'workspaceCredentialLabel'.tr(),
              helperText: 'workspaceCredentialLabelHint'.tr(),
            ),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _mailboxId,
            decoration: InputDecoration(
              labelText: 'workspaceCredentialMailbox'.tr(),
            ),
            items: [
              for (final mailbox in widget.mailboxes)
                DropdownMenuItem(
                  value: mailbox.id,
                  child: Text(mailbox.address),
                ),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _mailboxId = value);
            },
          ),
          const SizedBox(height: 12),
          Text(
            'workspaceCredentialProtocols'.tr(),
            style: Theme.of(context).textTheme.titleSmall,
          ),
          for (final protocol in const ['smtp', 'imap', 'pop3'])
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _protocols.contains(protocol),
              onChanged: (selected) {
                setState(() {
                  if (selected == true) {
                    _protocols.add(protocol);
                  } else {
                    _protocols.remove(protocol);
                  }
                });
              },
              title: Text(protocol.toUpperCase()),
            ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('cancel'.tr()),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () {
                  final label = _labelController.text.trim();
                  if (label.isEmpty || _protocols.isEmpty) return;
                  Navigator.pop(
                    context,
                    _MailCredentialDraft(
                      mailboxId: _mailboxId,
                      label: label,
                      protocols: _protocols.toList(growable: false),
                    ),
                  );
                },
                child: Text('create'.tr()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MailCredentialSecretSheet extends StatelessWidget {
  final String secret;

  const _MailCredentialSecretSheet({required this.secret});

  @override
  Widget build(BuildContext context) {
    return SheetScaffold(
      titleText: 'workspaceCredentialCreated'.tr(),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: Text('done'.tr()),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Text(
            'workspaceCredentialSecretHint'.tr(),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SelectableText(
              secret,
              style: GoogleFonts.robotoMono(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
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

String _formatBytes(int value) {
  if (value >= 1024 * 1024 * 1024) {
    return '${(value / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
  if (value >= 1024 * 1024) {
    return '${(value / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  return '${(value / 1024).round()} KB';
}
