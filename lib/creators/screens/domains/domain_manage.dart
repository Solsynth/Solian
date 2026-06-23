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
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
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

    void showAddDomainSheet() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        builder: (_) => _AddDomainSheet(pubName: pubName),
      );
    }

    return AppScaffold(
      appBar: AppBar(
        leading: const AutoLeadingButton(),
        title: Text('verifiedDomains'.tr()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddDomainSheet,
        child: const Icon(Symbols.add),
      ),
      body: domains.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Symbols.domain_disabled,
                    size: 48,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const Gap(8),
                  Text('noDomains'.tr()),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final domain = items[index];
              return ListTile(
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
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
                isThreeLine:
                    domain.lastError != null || domain.verifiedAt != null,
              );
            },
          );
        },
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

class _AddDomainSheet extends HookConsumerWidget {
  final String pubName;
  const _AddDomainSheet({required this.pubName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController();
    final submitting = useState(false);

    Future<void> submit() async {
      final domain = controller.text.trim();
      if (domain.isEmpty) return;
      submitting.value = true;
      try {
        final apiClient = ref.read(apiClientProvider);
        await apiClient.post(
          '/sphere/publishers/$pubName/domains',
          data: {'domain': domain},
        );
        ref.invalidate(publisherDomainsProvider(pubName));
        if (context.mounted) Navigator.pop(context);
      } catch (err) {
        showErrorAlert(err);
      } finally {
        submitting.value = false;
      }
    }

    return SheetScaffold(
      titleText: 'addDomain'.tr(),
      actions: [
        IconButton(
          onPressed: submitting.value ? null : submit,
          icon: submitting.value
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Symbols.check),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        children: [
          TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              hintText: 'blog.example.com',
              prefixIcon: const Icon(Symbols.domain),
            ),
            onSubmitted: (_) => submit(),
          ),
          const Gap(12),
          Text(
            'domainVerificationHint'.tr(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
