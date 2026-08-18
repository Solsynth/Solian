part of 'workspace_management.dart';

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
      isNoBackground: false,
      appBar: AppBar(
        centerTitle: true,
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
          const Gap(8),
        ],
      ),
      body: workspaces.when(
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: _WorkspaceError(
              message: 'workspaceLoadError'.tr(),
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
    final scheme = Theme.of(context).colorScheme;
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Material(
            color: scheme.surface,
            child: TabBar(
              isScrollable: true,
              tabAlignment: .center,
              dividerColor: scheme.outlineVariant,
              dividerHeight: 1,
              labelColor: scheme.onSecondaryContainer,
              unselectedLabelColor: scheme.onSurfaceVariant,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
              ),
              tabs: [
                Tab(
                  height: 36,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('workspaceOverview'.tr()),
                  ),
                ),
                Tab(
                  height: 36,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('workspaceMailboxes'.tr()),
                  ),
                ),
                Tab(
                  height: 36,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('workspaceFlywheel'.tr()),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _WorkspaceOverviewPanel(
                  workspace: workspace,
                  members: members,
                  onMembers: onMembers,
                  onEdit: onEdit,
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

/// Overview: the workspace identity plate.
class _WorkspaceOverviewPanel extends StatelessWidget {
  final WorkspaceSummary workspace;
  final VoidCallback onMembers;
  final VoidCallback onEdit;
  final AsyncValue<List<WorkspaceMemberSummary>> members;

  const _WorkspaceOverviewPanel({
    required this.workspace,
    required this.members,
    required this.onMembers,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final people = members.value;
    final backgroundId = workspace.backgroundId;
    final hasBanner = backgroundId != null && backgroundId.isNotEmpty;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        _CenteredContent(
          child: _Panel(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasBanner)
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: SizedBox(
                          height: 150,
                          width: double.infinity,
                          child: CloudImageWidget(
                            fileId: backgroundId,
                            fit: BoxFit.cover,
                            imageOnly: true,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -30,
                        left: 20,
                        child: _WorkspaceSeal(
                          name: workspace.name,
                          isIndividual: workspace.isIndividual,
                          radius: 30,
                          fileId: workspace.pictureId,
                        ),
                      ),
                    ],
                  ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, hasBanner ? 44 : 20, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hasBanner)
                        _identityBlock(theme, scheme)
                      else
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _WorkspaceSeal(
                              name: workspace.name,
                              isIndividual: workspace.isIndividual,
                              radius: 28,
                              fileId: workspace.pictureId,
                            ),
                            const SizedBox(width: 16),
                            Expanded(child: _identityBlock(theme, scheme)),
                          ],
                        ),
                      if (workspace.description.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Text(
                          workspace.description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.45,
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _WorkspaceBadge(label: workspace.planLabel),
                          if (workspace.isBundled)
                            _WorkspaceBadge(
                              label: 'workspaceBundled'.tr(),
                              background: scheme.tertiaryContainer,
                              foreground: scheme.onTertiaryContainer,
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _SectionHeader(title: 'workspacePlan'.tr()),
                      const SizedBox(height: 10),
                      _WorkspacePlanSection(workspace: workspace),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Divider(
                          height: 1,
                          thickness: 1,
                          color: scheme.outlineVariant,
                        ),
                      ),
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
                      if (people != null && people.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _MemberAvatarStrip(members: people.take(6).toList()),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Name and `@address` block, shared by the banner and header-row layouts.
  Widget _identityBlock(ThemeData theme, ColorScheme scheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          workspace.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Flexible(
              child: Text(
                '@${workspace.slug}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.robotoMono(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: 8),
            _WorkspaceBadge.outline(
              workspace.isIndividual
                  ? 'workspaceIndividual'.tr()
                  : 'workspaceOrganization'.tr(),
            ),
          ],
        ),
      ],
    );
  }
}

/// Plan: current tier plus the upgrades still on the table.
class _WorkspacePlanSection extends ConsumerWidget {
  final WorkspaceSummary workspace;

  const _WorkspacePlanSection({required this.workspace});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(workspacePlanStatusProvider(workspace.slug));
    return status.when(
      loading: () => const _WorkspacePanelLoading(),
      error: (error, _) => _WorkspaceError(
        message: 'workspaceLoadError'.tr(),
        onRetry: () =>
            ref.invalidate(workspacePlanStatusProvider(workspace.slug)),
      ),
      data: (plan) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  workspace.planLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (plan.isBundled)
                _WorkspaceBadge(
                  label: 'workspaceBundled'.tr(),
                  background: Theme.of(context).colorScheme.tertiaryContainer,
                  foreground: Theme.of(context).colorScheme.onTertiaryContainer,
                ),
            ],
          ),
          if (plan.plan < 1) ...[
            const SizedBox(height: 12),
            _PlanUpgradeRow(
              label: 'workspacePlanPro'.tr(),
              price: plan.proPrice,
              currency: plan.currency,
              onPressed: () => _subscribe(context, ref, 1),
            ),
          ],
          if (plan.plan < 2) ...[
            const SizedBox(height: 8),
            _PlanUpgradeRow(
              label: 'workspacePlanEnterprise'.tr(),
              price: plan.enterprisePrice,
              currency: plan.currency,
              onPressed: () => _subscribe(context, ref, 2),
            ),
          ],
        ],
      ),
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
        final order = await client.wallet.getOrder(orderId);
        if (!context.mounted) return;
        final paidOrder = await PaymentOverlay.show(
          context: context,
          order: order,
          payerWalletId: order.payerWalletId,
          enableBiometric: true,
        );
        if (paidOrder != null && context.mounted) {
          showSnackBar('workspacePlanPaymentCompleted'.tr());
        }
      }
      ref.invalidate(workspacePlanStatusProvider(workspace.slug));
    } catch (error) {
      showErrorAlert(error);
    }
  }
}

class _PlanUpgradeRow extends StatelessWidget {
  final String label;
  final int price;
  final String currency;
  final VoidCallback onPressed;

  const _PlanUpgradeRow({
    required this.label,
    required this.price,
    required this.currency,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FilledButton.tonal(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Text(
            '$price $currency',
            style: GoogleFonts.robotoMono(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: scheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

/// Mail: the delivery side of the workspace — mailboxes, domains, send usage.
class _WorkspaceMailPanel extends ConsumerWidget {
  final WorkspaceSummary workspace;

  const _WorkspaceMailPanel({required this.workspace});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mailboxes = ref.watch(workspaceMailboxesProvider(workspace.id));
    final mailboxUsage = ref.watch(workspaceMailboxUsageProvider(workspace.id));
    final sendUsage = ref.watch(workspaceSendUsageProvider(workspace.id));
    final domains = ref.watch(workspaceDomainsProvider(workspace.id));
    final domainUsage = ref.watch(
      workspaceCustomDomainUsageProvider(workspace.id),
    );
    final credentials = ref.watch(workspaceMailCredentialsProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        _CenteredContent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SectionHeader(
                title: 'workspaceMailboxes'.tr(),
                action: FilledButton.icon(
                  onPressed: () => _createMailbox(context, ref),
                  icon: const Icon(Symbols.add),
                  label: Text('workspaceAddMailbox'.tr()),
                ),
              ),
              const SizedBox(height: 12),
              mailboxUsage.when(
                loading: () => const _MeterSkeleton(),
                error: (error, _) => const SizedBox.shrink(),
                data: (usage) => _Panel(
                  child: _UsageMeter(
                    label: 'workspaceMailboxes'.tr(),
                    used: usage.used,
                    limit: usage.limit,
                    remaining: usage.remaining,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              mailboxes.when(
                loading: () => const _WorkspacePanelLoading(),
                error: (error, _) => _WorkspaceError(
                  message: 'workspaceMailboxesLoadError'.tr(),
                  onRetry: () =>
                      ref.invalidate(workspaceMailboxesProvider(workspace.id)),
                ),
                data: (items) => items.isEmpty
                    ? _PanelEmpty(message: 'workspaceMailboxesEmpty'.tr())
                    : _Panel(
                        padding: EdgeInsets.zero,
                        child: _DividedColumn(
                          children: [
                            for (final mailbox in items)
                              _MailboxRow(
                                mailbox: mailbox,
                                onTap: () =>
                                    _showMailboxRouting(context, ref, mailbox),
                              ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 20),
              _SectionHeader(
                title: 'workspaceMailCredentials'.tr(),
                action: FilledButton.tonalIcon(
                  onPressed: mailboxes.value?.isNotEmpty == true
                      ? () => _createCredential(context, ref, mailboxes.value!)
                      : null,
                  icon: const Icon(Symbols.key),
                  label: Text('workspaceCreateCredential'.tr()),
                ),
              ),
              const SizedBox(height: 12),
              credentials.when(
                loading: () => const _WorkspacePanelLoading(),
                error: (error, _) => _WorkspaceError(
                  message: 'workspaceCredentialsLoadError'.tr(),
                  onRetry: () =>
                      ref.invalidate(workspaceMailCredentialsProvider),
                ),
                data: (items) {
                  final mailboxIds = mailboxes.value
                      ?.map((mailbox) => mailbox.id)
                      .toSet();
                  final workspaceItems = mailboxIds == null
                      ? const <WorkspaceMailCredential>[]
                      : items
                            .where(
                              (credential) =>
                                  mailboxIds.contains(credential.mailboxId),
                            )
                            .toList(growable: false);
                  return workspaceItems.isEmpty
                      ? _PanelEmpty(message: 'workspaceCredentialsEmpty'.tr())
                      : _Panel(
                          padding: EdgeInsets.zero,
                          child: _DividedColumn(
                            children: [
                              for (final credential in workspaceItems)
                                _WorkspaceCredentialRow(
                                  credential: credential,
                                  mailbox: mailboxes.value!.firstWhere(
                                    (mailbox) =>
                                        mailbox.id == credential.mailboxId,
                                  ),
                                  onRevoke: () => _revokeCredential(
                                    context,
                                    ref,
                                    credential,
                                  ),
                                ),
                            ],
                          ),
                        );
                },
              ),
              const SizedBox(height: 20),
              _SectionHeader(
                title: 'workspaceCustomDomains'.tr(),
                action: FilledButton.tonalIcon(
                  onPressed: () => _createDomain(context, ref),
                  icon: const Icon(Symbols.add),
                  label: Text('workspaceAddDomain'.tr()),
                ),
              ),
              const SizedBox(height: 12),
              domainUsage.when(
                loading: () => const _MeterSkeleton(),
                error: (error, _) => const SizedBox.shrink(),
                data: (usage) => _Panel(
                  child: _UsageMeter(
                    label: 'workspaceCustomDomains'.tr(),
                    used: usage.used,
                    limit: usage.limit,
                    remaining: usage.remaining,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              domains.when(
                loading: () => const _WorkspacePanelLoading(),
                error: (error, _) => _WorkspaceError(
                  message: 'workspaceDomainsLoadError'.tr(),
                  onRetry: () =>
                      ref.invalidate(workspaceDomainsProvider(workspace.id)),
                ),
                data: (items) => items.isEmpty
                    ? _PanelEmpty(message: 'workspaceDomainsEmpty'.tr())
                    : _Panel(
                        padding: EdgeInsets.zero,
                        child: _DividedColumn(
                          children: [
                            for (final domain in items)
                              _DomainRow(
                                domain: domain,
                                onRefresh: () =>
                                    _refreshDomain(context, ref, domain),
                              ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 20),
              _SectionHeader(title: 'workspaceSendUsage'.tr()),
              const SizedBox(height: 12),
              sendUsage.when(
                loading: () => const _WorkspacePanelLoading(),
                error: (error, _) => _WorkspaceError(
                  message: 'workspaceSendUsageLoadError'.tr(),
                  onRetry: () =>
                      ref.invalidate(workspaceSendUsageProvider(workspace.id)),
                ),
                data: (usage) => _Panel(
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: _UsageMeter(
                            label: 'workspaceDaily'.tr(),
                            used: usage.daily.used,
                            limit: usage.daily.limit,
                            remaining: usage.daily.remaining,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: VerticalDivider(
                            width: 1,
                            thickness: 1,
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                        ),
                        Expanded(
                          child: _UsageMeter(
                            label: 'workspaceMonthly'.tr(),
                            used: usage.monthly.used,
                            limit: usage.monthly.limit,
                            remaining: usage.monthly.remaining,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _createMailbox(BuildContext context, WidgetRef ref) async {
    final draft = await showModalBottomSheet<_MailboxDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
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

  Future<void> _showMailboxRouting(
    BuildContext context,
    WidgetRef ref,
    WorkspaceMailboxRecord mailbox,
  ) async {
    final container = ProviderScope.containerOf(context);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => UncontrolledProviderScope(
        container: container,
        child: _MailboxRoutingSheet(
          mailbox: mailbox,
          workspaceId: workspace.id,
        ),
      ),
    );
  }

  Future<void> _createCredential(
    BuildContext context,
    WidgetRef ref,
    List<WorkspaceMailboxRecord> mailboxes,
  ) async {
    final draft = await showModalBottomSheet<_MailCredentialDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _MailCredentialDialog(mailboxes: mailboxes),
    );
    if (draft == null || !context.mounted) return;
    try {
      final client = ref.read(solarNetworkClientProvider);
      final response = await client.dio.post(
        '/postal/credentials',
        data: {
          'mailbox_id': draft.mailboxId,
          'label': draft.label,
          'protocols': draft.protocols,
        },
      );
      final created = WorkspaceMailCredentialCreated.fromJson(response.data);
      ref.invalidate(workspaceMailCredentialsProvider);
      if (created.secret.isNotEmpty && context.mounted) {
        await showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (_) => _MailCredentialSecretSheet(secret: created.secret),
        );
      }
    } catch (error) {
      showErrorAlert(error);
    }
  }

  Future<void> _revokeCredential(
    BuildContext context,
    WidgetRef ref,
    WorkspaceMailCredential credential,
  ) async {
    final confirmed = await showConfirmAlert(
      'workspaceRevokeCredentialDescription'.tr(),
      'workspaceRevokeCredential'.tr(),
      isDanger: true,
    );
    if (!confirmed) return;
    try {
      final client = ref.read(solarNetworkClientProvider);
      await client.dio.delete(
        '/postal/credentials/${Uri.encodeComponent(credential.id)}',
      );
      ref.invalidate(workspaceMailCredentialsProvider);
    } catch (error) {
      showErrorAlert(error);
    }
  }

  Future<void> _createDomain(BuildContext context, WidgetRef ref) async {
    final domain = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
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

class _MailboxRoutingSheet extends ConsumerStatefulWidget {
  final WorkspaceMailboxRecord mailbox;
  final String workspaceId;

  const _MailboxRoutingSheet({
    required this.mailbox,
    required this.workspaceId,
  });

  @override
  ConsumerState<_MailboxRoutingSheet> createState() =>
      _MailboxRoutingSheetState();
}

class _MailboxRoutingSheetState extends ConsumerState<_MailboxRoutingSheet> {
  final _aliasLocalPartController = TextEditingController();
  final _aliasNameController = TextEditingController();
  final _forwardingDestinationController = TextEditingController();
  String? _customDomainId;
  String? _aliasId;
  bool _aliasSaving = false;
  bool _forwardingSaving = false;

  @override
  void dispose() {
    _aliasLocalPartController.dispose();
    _aliasNameController.dispose();
    _forwardingDestinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final aliases = ref.watch(
      workspaceMailboxAliasesProvider(widget.mailbox.id),
    );
    final forwarding = ref.watch(
      workspaceMailboxForwardingProvider(widget.mailbox.id),
    );
    final domains = ref.watch(workspaceDomainsProvider(widget.workspaceId));
    final verifiedDomains =
        domains.value?.where((domain) => domain.verifiedForSending).toList() ??
        const <WorkspaceDomainRecord>[];
    final selectedDomainId =
        verifiedDomains.any((domain) => domain.id == _customDomainId)
        ? _customDomainId
        : null;
    final selectedAliasId =
        aliases.value?.any((alias) => alias.id == _aliasId) == true
        ? _aliasId
        : null;

    return SheetScaffold(
      titleText: widget.mailbox.address,
      heightFactor: 0.88,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DialogEyebrow('workspaceAliases'.tr()),
            const SizedBox(height: 8),
            domains.when(
              loading: () => const _WorkspacePanelLoading(),
              error: (error, _) => Text(
                'workspaceDomainsLoadError'.tr(),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              data: (_) => verifiedDomains.isEmpty
                  ? Text(
                      'workspaceAliasDomainRequired'.tr(),
                      style: Theme.of(context).textTheme.bodySmall,
                    )
                  : Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: selectedDomainId,
                          decoration: InputDecoration(
                            labelText: 'workspaceSelectCustomDomain'.tr(),
                          ),
                          items: [
                            for (final domain in verifiedDomains)
                              DropdownMenuItem(
                                value: domain.id,
                                child: Text(domain.domain),
                              ),
                          ],
                          onChanged: (value) =>
                              setState(() => _customDomainId = value),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _aliasLocalPartController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'workspaceAliasLocalPart'.tr(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _aliasNameController,
                          decoration: InputDecoration(
                            labelText: 'workspaceAliasName'.tr(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: FilledButton.tonalIcon(
                            onPressed: _aliasSaving || selectedDomainId == null
                                ? null
                                : _createAlias,
                            icon: _aliasSaving
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Symbols.add),
                            label: Text('workspaceAddAlias'.tr()),
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 10),
            aliases.when(
              loading: () => const _WorkspacePanelLoading(),
              error: (error, _) => _WorkspaceError(
                message: 'workspaceMailboxDetailsLoadError'.tr(),
                onRetry: () => ref.invalidate(
                  workspaceMailboxAliasesProvider(widget.mailbox.id),
                ),
              ),
              data: (items) => items.isEmpty
                  ? _PanelEmpty(message: 'workspaceAliasesEmpty'.tr())
                  : _Panel(
                      padding: EdgeInsets.zero,
                      child: _DividedColumn(
                        children: [
                          for (final alias in items)
                            _MailboxAliasRow(
                              alias: alias,
                              onDelete: () => _deleteAlias(alias),
                            ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 20),
            _DialogEyebrow('workspaceForwarding'.tr()),
            const SizedBox(height: 8),
            aliases.when(
              loading: () => const SizedBox.shrink(),
              error: (error, _) => const SizedBox.shrink(),
              data: (items) => items.isEmpty
                  ? Text(
                      'workspaceForwardingAliasRequired'.tr(),
                      style: Theme.of(context).textTheme.bodySmall,
                    )
                  : Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: selectedAliasId,
                          decoration: InputDecoration(
                            labelText: 'workspaceSelectAlias'.tr(),
                          ),
                          items: [
                            for (final alias in items)
                              DropdownMenuItem(
                                value: alias.id,
                                child: Text(alias.address),
                              ),
                          ],
                          onChanged: (value) =>
                              setState(() => _aliasId = value),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _forwardingDestinationController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'workspaceForwardingDestination'.tr(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: FilledButton.tonalIcon(
                            onPressed:
                                _forwardingSaving || selectedAliasId == null
                                ? null
                                : _createForwarding,
                            icon: _forwardingSaving
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Symbols.add),
                            label: Text('workspaceAddForwarding'.tr()),
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 10),
            forwarding.when(
              loading: () => const _WorkspacePanelLoading(),
              error: (error, _) => _WorkspaceError(
                message: 'workspaceMailboxDetailsLoadError'.tr(),
                onRetry: () => ref.invalidate(
                  workspaceMailboxForwardingProvider(widget.mailbox.id),
                ),
              ),
              data: (items) => items.isEmpty
                  ? _PanelEmpty(message: 'workspaceForwardingEmpty'.tr())
                  : _Panel(
                      padding: EdgeInsets.zero,
                      child: _DividedColumn(
                        children: [
                          for (final rule in items)
                            _MailboxForwardingRow(
                              rule: rule,
                              alias: aliases.value
                                  ?.where((alias) => alias.id == rule.aliasId)
                                  .firstOrNull,
                              onDelete: () => _deleteForwarding(rule),
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

  Future<void> _createAlias() async {
    final domainId = _customDomainId;
    final localPart = _aliasLocalPartController.text.trim().toLowerCase();
    if (domainId == null || localPart.isEmpty) return;
    setState(() => _aliasSaving = true);
    try {
      final client = ref.read(solarNetworkClientProvider);
      await client.dio.post(
        '/postal/mailboxes/${Uri.encodeComponent(widget.mailbox.id)}/aliases',
        data: {
          'custom_domain_id': domainId,
          'local_part': localPart,
          'name': _aliasNameController.text.trim(),
        },
      );
      ref.invalidate(workspaceMailboxAliasesProvider(widget.mailbox.id));
      _aliasLocalPartController.clear();
      _aliasNameController.clear();
    } catch (error) {
      showErrorAlert(error);
    } finally {
      if (mounted) setState(() => _aliasSaving = false);
    }
  }

  Future<void> _deleteAlias(WorkspaceMailboxAliasRecord alias) async {
    final confirmed = await showConfirmAlert(
      'workspaceRemoveAliasDescription'.tr(),
      'workspaceRemoveAlias'.tr(),
      isDanger: true,
    );
    if (!confirmed) return;
    try {
      final client = ref.read(solarNetworkClientProvider);
      await client.dio.delete(
        '/postal/mailboxes/${Uri.encodeComponent(widget.mailbox.id)}/aliases/${Uri.encodeComponent(alias.id)}',
      );
      ref.invalidate(workspaceMailboxAliasesProvider(widget.mailbox.id));
      ref.invalidate(workspaceMailboxForwardingProvider(widget.mailbox.id));
    } catch (error) {
      showErrorAlert(error);
    }
  }

  Future<void> _createForwarding() async {
    final aliasId = _aliasId;
    final destination = _forwardingDestinationController.text
        .trim()
        .toLowerCase();
    if (aliasId == null || destination.isEmpty) return;
    setState(() => _forwardingSaving = true);
    try {
      final client = ref.read(solarNetworkClientProvider);
      await client.dio.post(
        '/postal/mailboxes/${Uri.encodeComponent(widget.mailbox.id)}/forwarding',
        data: {'alias_id': aliasId, 'destination': destination},
      );
      ref.invalidate(workspaceMailboxForwardingProvider(widget.mailbox.id));
      _forwardingDestinationController.clear();
    } catch (error) {
      showErrorAlert(error);
    } finally {
      if (mounted) setState(() => _forwardingSaving = false);
    }
  }

  Future<void> _deleteForwarding(WorkspaceMailboxForwardingRecord rule) async {
    final confirmed = await showConfirmAlert(
      'workspaceRemoveForwardingDescription'.tr(),
      'workspaceRemoveForwarding'.tr(),
      isDanger: true,
    );
    if (!confirmed) return;
    try {
      final client = ref.read(solarNetworkClientProvider);
      await client.dio.delete(
        '/postal/mailboxes/${Uri.encodeComponent(widget.mailbox.id)}/forwarding/${Uri.encodeComponent(rule.id)}',
      );
      ref.invalidate(workspaceMailboxForwardingProvider(widget.mailbox.id));
    } catch (error) {
      showErrorAlert(error);
    }
  }
}

class _MailboxAliasRow extends StatelessWidget {
  final WorkspaceMailboxAliasRecord alias;
  final VoidCallback onDelete;

  const _MailboxAliasRow({required this.alias, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alias.address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.robotoMono(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (alias.name.isNotEmpty)
                  Text(
                    alias.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: Icon(Symbols.delete_outline, color: scheme.error),
            tooltip: 'workspaceRemoveAlias'.tr(),
          ),
        ],
      ),
    );
  }
}

class _MailboxForwardingRow extends StatelessWidget {
  final WorkspaceMailboxForwardingRecord rule;
  final WorkspaceMailboxAliasRecord? alias;
  final VoidCallback onDelete;

  const _MailboxForwardingRow({
    required this.rule,
    required this.alias,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rule.destination,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.robotoMono(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  alias?.address ?? rule.aliasId,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: Icon(Symbols.delete_outline, color: scheme.error),
            tooltip: 'workspaceRemoveForwarding'.tr(),
          ),
        ],
      ),
    );
  }
}

/// Flywheel: retained cloud saves and their audit trail.
class _WorkspaceFlywheelPanel extends ConsumerWidget {
  final WorkspaceSummary workspace;

  const _WorkspaceFlywheelPanel({required this.workspace});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apps = ref.watch(flywheelAppsProvider(workspace.id));
    final quota = ref.watch(flywheelQuotaProvider(workspace.id));
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        _CenteredContent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SectionHeader(title: 'workspaceFlywheel'.tr()),
              const SizedBox(height: 12),
              quota.when(
                loading: () => const _MeterSkeleton(),
                error: (error, _) => const SizedBox.shrink(),
                data: (value) => _Panel(
                  child: _UsageMeter(
                    label: 'workspaceFlywheel'.tr(),
                    used: value.usedBytes,
                    limit: value.budgetBytes,
                    remaining: value.budgetBytes - value.usedBytes,
                    formatBytes: true,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              apps.when(
                loading: () => const _WorkspacePanelLoading(),
                error: (error, _) => _WorkspaceError(
                  message: 'workspaceFlywheelLoadError'.tr(),
                  onRetry: () =>
                      ref.invalidate(flywheelAppsProvider(workspace.id)),
                ),
                data: (items) => items.isEmpty
                    ? _PanelEmpty(message: 'workspaceFlywheelEmpty'.tr())
                    : _Panel(
                        padding: EdgeInsets.zero,
                        child: _DividedColumn(
                          children: [
                            for (final app in items)
                              _FlywheelAppRow(
                                app: app,
                                onTap: () =>
                                    _showAppManagement(context, ref, app),
                              ),
                          ],
                        ),
                      ),
              ),
            ],
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
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => _FlywheelAppSheet(
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

class _FlywheelAppSheet extends StatelessWidget {
  final FlywheelAppRecord app;
  final List<FlywheelBlobRecord> blobs;
  final List<FlywheelAuditRecord> audit;
  final Future<void> Function(FlywheelBlobRecord blob) onDelete;

  const _FlywheelAppSheet({
    required this.app,
    required this.blobs,
    required this.audit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return SheetScaffold(
      titleText: app.appId,
      heightFactor: 0.85,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DialogEyebrow('workspaceBlobs'.tr()),
            const SizedBox(height: 6),
            if (blobs.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'workspaceFlywheelEmpty'.tr(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              _DividedColumn(
                children: [
                  for (final blob in blobs)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  blob.blobId,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.robotoMono(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    _RevisionBadge(
                                      text: 'r${blob.currentRevision}',
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _formatBytes(blob.retainedBytes),
                                      style: GoogleFonts.robotoMono(
                                        fontSize: 12,
                                        color: scheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => onDelete(blob),
                            icon: Icon(
                              Symbols.delete_outline,
                              color: scheme.error,
                            ),
                            tooltip: 'workspaceDeleteBlob'.tr(),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            const SizedBox(height: 16),
            _DialogEyebrow('workspaceAudit'.tr()),
            const SizedBox(height: 6),
            if (audit.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'workspaceAuditEmpty'.tr(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              _DividedColumn(
                children: [
                  for (final entry in audit.take(10))
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.action,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${entry.blobId} · ${entry.actorAccountId}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.robotoMono(
                              fontSize: 11.5,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
