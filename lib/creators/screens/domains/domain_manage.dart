import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/time.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart' hide PageBackButton;
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'domain_manage.g.dart';

@riverpod
Future<List<SnPublisherVerifiedDomain>> publisherDomains(
  Ref ref,
  String publisherName,
) async {
  final apiClient = ref.watch(apiClientProvider);
  final resp = await apiClient.get(
    '/sphere/publishers/$publisherName/domains',
  );
  return (resp.data as List)
      .map((e) => SnPublisherVerifiedDomain.fromJson(e))
      .toList();
}

@RoutePage()
class CreatorDomainManageScreen extends HookConsumerWidget {
  final String pubName;
  const CreatorDomainManageScreen({
    super.key,
    @PathParam("pubName") required this.pubName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final domains = ref.watch(publisherDomainsProvider(pubName));
    final addController = useTextEditingController();

    Future<void> addDomain() async {
      final domain = addController.text.trim();
      if (domain.isEmpty) return;
      try {
        final apiClient = ref.read(apiClientProvider);
        await apiClient.post(
          '/sphere/publishers/$pubName/domains',
          data: {'domain': domain},
        );
        addController.clear();
        ref.invalidate(publisherDomainsProvider(pubName));
      } catch (err) {
        showErrorAlert(err);
      }
    }

    Future<void> removeDomain(String domainId) async {
      final confirm = await showConfirmAlert(
        'removeDomainHint'.tr(),
        'removeDomain'.tr(),
        isDanger: true,
      );
      if (!confirm) return;
      try {
        final apiClient = ref.read(apiClientProvider);
        await apiClient.delete(
          '/sphere/publishers/$pubName/domains/$domainId',
        );
        ref.invalidate(publisherDomainsProvider(pubName));
      } catch (err) {
        showErrorAlert(err);
      }
    }

    Future<void> recheckDomain(String domainId) async {
      try {
        showLoadingModal(context);
        final apiClient = ref.read(apiClientProvider);
        await apiClient.post(
          '/sphere/publishers/$pubName/domains/$domainId/recheck',
        );
        ref.invalidate(publisherDomainsProvider(pubName));
      } catch (err) {
        showErrorAlert(err);
      } finally {
        if (context.mounted) hideLoadingModal(context);
      }
    }

    return AppScaffold(
      appBar: AppBar(
        leading: const AutoLeadingButton(),
        title: Text('verifiedDomains'.tr()),
      ),
      body: domains.when(
        data: (items) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Add domain form
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('addDomain'.tr(),
                        style: Theme.of(context).textTheme.titleMedium),
                    const Gap(8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: addController,
                            decoration: InputDecoration(
                              hintText: 'blog.example.com',
                              border: const OutlineInputBorder(),
                              isDense: true,
                            ),
                            keyboardType: TextInputType.url,
                            onSubmitted: (_) => addDomain(),
                          ),
                        ),
                        const Gap(8),
                        FilledButton(
                          onPressed: addDomain,
                          child: Text('add'.tr()),
                        ),
                      ],
                    ),
                    const Gap(4),
                    Text(
                      'domainVerificationHint'.tr(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const Gap(16),

            // Domain list
            if (items.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Symbols.domain_disabled,
                          size: 48,
                          color: Theme.of(context).colorScheme.onSurfaceVariant),
                      const Gap(8),
                      Text('noDomains'.tr()),
                    ],
                  ),
                ),
              ),
            for (final domain in items)
              Card(
                child: ListTile(
                  leading: Icon(
                    _statusIcon(domain.status),
                    color: _statusColor(domain.status, context),
                  ),
                  title: Text(domain.domain),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_statusLabel(domain.status).tr()),
                      if (domain.verifiedAt != null)
                        Text(
                          'verifiedAt'.tr(
                            args: [domain.verifiedAt!.formatRelative(context)],
                          ),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      if (domain.lastError != null)
                        Text(
                          domain.lastError!,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Symbols.refresh),
                        tooltip: 'recheck'.tr(),
                        onPressed: () => recheckDomain(domain.id),
                      ),
                      IconButton(
                        icon: const Icon(Symbols.delete),
                        tooltip: 'removeDomain'.tr(),
                        onPressed: () => removeDomain(domain.id),
                      ),
                    ],
                  ),
                  isThreeLine: domain.lastError != null ||
                      domain.verifiedAt != null,
                ),
              ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  static IconData _statusIcon(DomainVerificationStatus status) {
    return switch (status) {
      DomainVerificationStatus.pending => Symbols.pending,
      DomainVerificationStatus.verified => Symbols.verified,
      DomainVerificationStatus.failed => Symbols.error,
      DomainVerificationStatus.revoked => Symbols.block,
    };
  }

  static Color _statusColor(
      DomainVerificationStatus status, BuildContext context) {
    return switch (status) {
      DomainVerificationStatus.pending =>
        Theme.of(context).colorScheme.secondary,
      DomainVerificationStatus.verified => Colors.green,
      DomainVerificationStatus.failed => Theme.of(context).colorScheme.error,
      DomainVerificationStatus.revoked =>
        Theme.of(context).colorScheme.onSurfaceVariant,
    };
  }

  static String _statusLabel(DomainVerificationStatus status) {
    return switch (status) {
      DomainVerificationStatus.pending => 'domainPending',
      DomainVerificationStatus.verified => 'domainVerified',
      DomainVerificationStatus.failed => 'domainFailed',
      DomainVerificationStatus.revoked => 'domainRevoked',
    };
  }
}
