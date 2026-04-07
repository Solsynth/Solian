import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/widgets/account/account_devices.dart';
import 'package:island/accounts/widgets/account/account_authorized_apps.dart';
import 'package:island/core/network.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/accounts/screens/me/settings_auth_factors.dart';
import 'package:island/accounts/screens/me/settings_connections.dart';
import 'package:island/accounts/screens/me/settings_contacts.dart';
import 'package:island/auth/captcha.dart';
import 'package:island/auth/login.dart';
import 'package:island/creators/screens/publishers_form.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart' hide PageBackButton;
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/shared/widgets/response.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'account_settings.g.dart';

@riverpod
Future<List<SnAuthFactor>> authFactors(Ref ref) async {
  final client = ref.read(solarNetworkClientProvider);
  return await client.auth.getFactors();
}

@riverpod
Future<List<SnContactMethod>> contactMethods(Ref ref) async {
  final client = ref.read(solarNetworkClientProvider);
  return await client.auth.getContacts();
}

@riverpod
Future<List<SnAccountConnection>> accountConnections(Ref ref) async {
  final client = ref.read(solarNetworkClientProvider);
  return await client.auth.getConnections();
}

@riverpod
Future<SnPublishingSettings> publishingSettings(Ref ref) async {
  final client = ref.read(solarNetworkClientProvider);
  return await client.sphere.getPublishingSettings();
}

@riverpod
Future<SnFediverseAvailabilityResponse> fediverseAvailability(Ref ref) async {
  final client = ref.read(solarNetworkClientProvider);
  return await client.sphere.getFediverseAvailability();
}

@riverpod
bool hasFediverseIdentity(Ref ref) {
  final publishingSettings = ref.watch(publishingSettingsProvider);
  final fediverseAvailability = ref.watch(fediverseAvailabilityProvider);

  final hasDefaultPublisher =
      publishingSettings.whenOrNull(
        data: (settings) => settings.defaultFediversePublisherId != null,
      ) ??
      false;

  final hasAnyEnabledPublisher =
      fediverseAvailability.whenOrNull(
        data: (response) => response.publishers.any((p) => p.isEnabled),
      ) ??
      false;

  return hasDefaultPublisher || hasAnyEnabledPublisher;
}

@RoutePage()
class AccountSettingsScreen extends HookConsumerWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> requestAccountDeletion() async {
      final confirm = await showConfirmAlert(
        'accountDeletionHint'.tr(),
        'accountDeletion'.tr(),
        isDanger: true,
      );
      if (!confirm || !context.mounted) return;
      try {
        showLoadingModal(context);
        final client = ref.read(solarNetworkClientProvider);
        await client.accounts.deleteCurrentAccount();
        if (context.mounted) {
          showSnackBar('accountDeletionSent'.tr());
        }
      } catch (err) {
        showErrorAlert(err);
      } finally {
        if (context.mounted) hideLoadingModal(context);
      }
    }

    Future<void> requestResetPassword() async {
      final confirm = await showConfirmAlert(
        'accountPasswordChangeDescription'.tr(),
        'accountPasswordChange'.tr(),
      );
      if (!confirm || !context.mounted) return;
      final captchaTk = await CaptchaScreen.show(context);
      if (captchaTk == null) return;
      try {
        if (context.mounted) showLoadingModal(context);
        final userInfo = ref.read(userInfoProvider);
        // Note: Password reset is not yet in the typed API, using raw Dio
        final dio = ref.read(apiClientProvider);
        await dio.post(
          '/passport/accounts/recovery/password',
          data: {'account': userInfo.value!.name, 'captcha_token': captchaTk},
        );
        if (context.mounted) {
          showSnackBar('accountPasswordChangeSent'.tr());
        }
      } catch (err) {
        showErrorAlert(err);
      } finally {
        if (context.mounted) hideLoadingModal(context);
      }
    }

    final authFactors = ref.watch(authFactorsProvider);

    // Group settings into categories for better organization
    final securitySettings = [
      ListTile(
        minLeadingWidth: 48,
        leading: const Icon(Symbols.devices),
        title: Text('authSessions').tr(),
        subtitle: Text('authSessionsDescription').tr().fontSize(12),
        contentPadding: const EdgeInsets.only(left: 24, right: 17),
        trailing: const Icon(Symbols.chevron_right),
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => const AccountSessionSheet(),
          );
        },
      ),
      ListTile(
        minLeadingWidth: 48,
        leading: const Icon(Symbols.connected_tv),
        title: Text('authorizedApps').tr(),
        subtitle: Text('authorizedAppsDescription').tr().fontSize(12),
        contentPadding: const EdgeInsets.only(left: 24, right: 17),
        trailing: const Icon(Symbols.chevron_right),
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => const AccountAuthorizedAppsSheet(),
          );
        },
      ),
      ExpansionTile(
        leading: const Icon(
          Symbols.link,
        ).alignment(Alignment.centerLeft).width(48),
        title: Text('accountConnections').tr(),
        subtitle: Text('accountConnectionsDescription').tr().fontSize(12),
        tilePadding: const EdgeInsets.only(left: 24, right: 17),
        children: [
          ref
              .watch(accountConnectionsProvider)
              .when(
                data: (connections) => Column(
                  children: [
                    for (final connection in connections)
                      ListTile(
                        minLeadingWidth: 48,
                        contentPadding: const EdgeInsets.only(
                          left: 16,
                          right: 17,
                          top: 2,
                          bottom: 4,
                        ),
                        title: Text(
                          getLocalizedProviderName(connection.provider),
                        ).tr(),
                        subtitle: connection.meta['email'] != null
                            ? Text(connection.meta['email'])
                            : Text(connection.providedIdentifier),
                        leading: CircleAvatar(
                          child: getProviderIcon(
                            connection.provider,
                            size: 16,
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                          ),
                        ).padding(top: 4),
                        trailing: const Icon(Symbols.chevron_right),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) =>
                                AccountConnectionSheet(connection: connection),
                          ).then((value) {
                            if (value == true) {
                              ref.invalidate(accountConnectionsProvider);
                            }
                          });
                        },
                      ),
                    if (connections.isNotEmpty) const Divider(height: 1),
                    ListTile(
                      minLeadingWidth: 48,
                      contentPadding: const EdgeInsets.only(
                        left: 24,
                        right: 17,
                      ),
                      title: Text('accountConnectionAdd').tr(),
                      leading: const Icon(Symbols.add),
                      trailing: const Icon(Symbols.chevron_right),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) =>
                              const AccountConnectionNewSheet(),
                        ).then((value) {
                          if (value == true) {
                            ref.invalidate(accountConnectionsProvider);
                          }
                        });
                      },
                    ),
                  ],
                ),
                error: (err, _) => ResponseErrorWidget(
                  error: err,
                  onRetry: () => ref.invalidate(accountConnectionsProvider),
                ),
                loading: () => const ResponseLoadingWidget(),
              ),
        ],
      ),
      ExpansionTile(
        leading: const Icon(
          Symbols.security,
        ).alignment(Alignment.centerLeft).width(48),
        title: Text('accountAuthFactor').tr(),
        subtitle: Text('accountAuthFactorDescription').tr().fontSize(12),
        tilePadding: const EdgeInsets.only(left: 24, right: 17),
        children: [
          authFactors.when(
            data: (factors) => Column(
              children: [
                for (final factor in factors)
                  ListTile(
                    minLeadingWidth: 48,
                    contentPadding: const EdgeInsets.only(
                      left: 16,
                      right: 17,
                      top: 2,
                      bottom: 4,
                    ),
                    title: Text(
                      kFactorTypes[factor.type]!.$1,
                      style: factor.enabledAt == null
                          ? TextStyle(decoration: TextDecoration.lineThrough)
                          : null,
                    ).tr(),
                    subtitle: Text(
                      kFactorTypes[factor.type]!.$2,
                      style: factor.enabledAt == null
                          ? TextStyle(decoration: TextDecoration.lineThrough)
                          : null,
                    ).tr(),
                    leading: CircleAvatar(
                      backgroundColor: factor.enabledAt == null
                          ? Theme.of(context).colorScheme.secondaryContainer
                          : Theme.of(context).colorScheme.primaryContainer,
                      child: Icon(kFactorTypes[factor.type]!.$3),
                    ).padding(top: 4),
                    trailing: const Icon(Symbols.chevron_right),
                    isThreeLine: true,
                    onTap: () {
                      if (factor.type == 0) {
                        requestResetPassword();
                        return;
                      }
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => AuthFactorSheet(factor: factor),
                      ).then((value) {
                        if (value == true) {
                          ref.invalidate(authFactorsProvider);
                        }
                      });
                    },
                  ),
                if (factors.isNotEmpty) Divider(height: 1),
                ListTile(
                  minLeadingWidth: 48,
                  contentPadding: const EdgeInsets.only(left: 24, right: 17),
                  title: Text('authFactorNew').tr(),
                  leading: const Icon(Symbols.add),
                  trailing: const Icon(Symbols.chevron_right),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => const AuthFactorNewSheet(),
                    ).then((value) {
                      if (value == true) {
                        ref.invalidate(authFactorsProvider);
                      }
                    });
                  },
                ),
              ],
            ),
            error: (err, _) => ResponseErrorWidget(
              error: err,
              onRetry: () => ref.invalidate(authFactorsProvider),
            ),
            loading: () => ResponseLoadingWidget(),
          ),
        ],
      ),
      ExpansionTile(
        leading: const Icon(
          Symbols.contact_mail,
        ).alignment(Alignment.centerLeft).width(48),
        title: Text('accountContactMethod').tr(),
        subtitle: Text('accountContactMethodDescription').tr().fontSize(12),
        tilePadding: const EdgeInsets.only(left: 24, right: 17),
        children: [
          ref
              .watch(contactMethodsProvider)
              .when(
                data: (contacts) => Column(
                  children: [
                    for (final contact in contacts)
                      ListTile(
                        minLeadingWidth: 48,
                        contentPadding: const EdgeInsets.only(
                          left: 16,
                          right: 17,
                          top: 2,
                          bottom: 4,
                        ),
                        title: Text(
                          contact.content,
                          style: contact.verifiedAt == null
                              ? TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                )
                              : null,
                        ),
                        subtitle: Text(
                          contact.type == 0
                              ? 'contactMethodTypeEmail'.tr()
                              : 'contactMethodTypePhone'.tr(),
                          style: contact.verifiedAt == null
                              ? TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                )
                              : null,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: contact.verifiedAt == null
                              ? Theme.of(context).colorScheme.secondaryContainer
                              : Theme.of(context).colorScheme.primaryContainer,
                          child: Icon(
                            contact.type == 0 ? Symbols.mail : Symbols.phone,
                          ),
                        ).padding(top: 4),
                        trailing: const Icon(Symbols.chevron_right),
                        isThreeLine: false,
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) =>
                                ContactMethodSheet(contact: contact),
                          ).then((value) {
                            if (value == true) {
                              ref.invalidate(contactMethodsProvider);
                            }
                          });
                        },
                      ),
                    if (contacts.isNotEmpty) const Divider(height: 1),
                    ListTile(
                      minLeadingWidth: 48,
                      contentPadding: const EdgeInsets.only(
                        left: 24,
                        right: 17,
                      ),
                      title: Text('contactMethodNew').tr(),
                      leading: const Icon(Symbols.add),
                      trailing: const Icon(Symbols.chevron_right),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => const ContactMethodNewSheet(),
                        ).then((value) {
                          if (value == true) {
                            ref.invalidate(contactMethodsProvider);
                          }
                        });
                      },
                    ),
                  ],
                ),
                error: (err, _) => ResponseErrorWidget(
                  error: err,
                  onRetry: () => ref.invalidate(contactMethodsProvider),
                ),
                loading: () => const ResponseLoadingWidget(),
              ),
        ],
      ),
    ];

    final publishingSettings = ref.watch(publishingSettingsProvider);
    final publishers = ref.watch(publishersManagedProvider);
    final fediverseAvailability = ref.watch(fediverseAvailabilityProvider);

    final defaultPublisherSettings = [
      ExpansionTile(
        leading: const Icon(
          Symbols.edit,
        ).alignment(Alignment.centerLeft).width(48),
        title: Text('defaultPublisher').tr(),
        subtitle: Text('defaultPublisherDescription').tr().fontSize(12),
        tilePadding: const EdgeInsets.only(left: 24, right: 17),
        children: [
          publishingSettings.when(
            data: (settings) => publishers.when(
              data: (publisherList) => fediverseAvailability.when(
                data: (fediversePublishers) => Column(
                  children: [
                    _PublisherListTile(
                      title: 'defaultPostingPublisher'.tr(),
                      publisherId: settings.defaultPostingPublisherId,
                      publishers: publisherList,
                      onTap: () => _showPublisherPicker(
                        context,
                        ref,
                        settings.defaultPostingPublisherId,
                        publisherList,
                        'posting',
                      ),
                    ),
                    _PublisherListTile(
                      title: 'defaultReplyPublisher'.tr(),
                      publisherId: settings.defaultReplyPublisherId,
                      publishers: publisherList,
                      onTap: () => _showPublisherPicker(
                        context,
                        ref,
                        settings.defaultReplyPublisherId,
                        publisherList,
                        'reply',
                      ),
                    ),
                    _FediversePublisherListTile(
                      title: 'defaultFediversePublisher'.tr(),
                      publisherId: settings.defaultFediversePublisherId,
                      fediversePublishers: fediversePublishers,
                      onTap: () => _showFediversePublisherPicker(
                        context,
                        ref,
                        settings.defaultFediversePublisherId,
                        fediversePublishers,
                      ),
                    ),
                  ],
                ),
                error: (err, _) => ResponseErrorWidget(
                  error: err,
                  onRetry: () => ref.invalidate(fediverseAvailabilityProvider),
                ),
                loading: () => const ResponseLoadingWidget(),
              ),
              error: (err, _) => ResponseErrorWidget(
                error: err,
                onRetry: () => ref.invalidate(publishersManagedProvider),
              ),
              loading: () => const ResponseLoadingWidget(),
            ),
            error: (err, _) => ResponseErrorWidget(
              error: err,
              onRetry: () => ref.invalidate(publishingSettingsProvider),
            ),
            loading: () => const ResponseLoadingWidget(),
          ),
        ],
      ),
    ];

    final dangerZoneSettings = [
      ListTile(
        minLeadingWidth: 48,
        title: Text('accountDeletion').tr(),
        subtitle: Text('accountDeletionDescription').tr().fontSize(12),
        contentPadding: const EdgeInsets.only(left: 24, right: 17),
        leading: const Icon(Symbols.delete_forever, color: Colors.red),
        trailing: const Icon(Symbols.chevron_right),
        onTap: requestAccountDeletion,
      ),
    ];

    // Create a responsive layout based on screen width
    Widget buildSettingsList() {
      return Column(
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SettingsSection(
            title: 'accountPublishingTitle',
            children: defaultPublisherSettings,
          ),
          _SettingsSection(
            title: 'accountSecurityTitle',
            children: securitySettings,
          ),
          _SettingsSection(
            title: 'accountDangerZoneTitle',
            children: dangerZoneSettings,
          ),
        ],
      ).padding(horizontal: 16);
    }

    return AppScaffold(
      appBar: AppBar(
        title: Text('accountSettings').tr(),
        leading: const AutoLeadingButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: buildSettingsList(),
      ),
    );
  }

  Future<void> _showPublisherPicker(
    BuildContext context,
    WidgetRef ref,
    String? currentId,
    List<SnPublisher> publishers,
    String type,
  ) async {
    final selected = await showModalBottomSheet<String?>(
      context: context,
      builder: (context) => _PublisherPickerSheet(
        publishers: publishers,
        currentId: currentId,
        type: type,
      ),
    );
    if (selected == null) return;

    showLoadingModal(context);
    try {
      final client = ref.read(solarNetworkClientProvider);
      await client.sphere.updatePublishingSettings(
        defaultPostingPublisherId: type == 'posting' ? selected : null,
        defaultReplyPublisherId: type == 'reply' ? selected : null,
      );
      ref.invalidate(publishingSettingsProvider);
      if (context.mounted) {
        showSnackBar('settingsSaved'.tr());
      }
    } catch (err) {
      showErrorAlert(err);
    } finally {
      if (context.mounted) hideLoadingModal(context);
    }
  }

  Future<void> _showFediversePublisherPicker(
    BuildContext context,
    WidgetRef ref,
    String? currentId,
    SnFediverseAvailabilityResponse fediversePublishers,
  ) async {
    final selected = await showModalBottomSheet<String?>(
      context: context,
      builder: (context) => _FediversePublisherPickerSheet(
        publishers: fediversePublishers,
        currentId: currentId,
      ),
    );
    if (selected == null) return;

    showLoadingModal(context);
    try {
      final client = ref.read(solarNetworkClientProvider);
      await client.sphere.updatePublishingSettings(
        defaultFediversePublisherId: selected,
      );
      ref.invalidate(publishingSettingsProvider);
      if (context.mounted) {
        showSnackBar('settingsSaved'.tr());
      }
    } catch (err) {
      showErrorAlert(err);
    } finally {
      if (context.mounted) hideLoadingModal(context);
    }
  }
}

// Helper widget for displaying settings sections with titles
class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Text(
              title.tr(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...children,
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _PublisherListTile extends StatelessWidget {
  final String title;
  final String? publisherId;
  final List<SnPublisher> publishers;
  final VoidCallback onTap;

  const _PublisherListTile({
    required this.title,
    required this.publisherId,
    required this.publishers,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final publisher = publisherId != null
        ? publishers.where((p) => p.id == publisherId).firstOrNull
        : null;

    return ListTile(
      minLeadingWidth: 48,
      contentPadding: const EdgeInsets.only(
        left: 16,
        right: 17,
        top: 8,
        bottom: 4,
      ),
      leading: publisher != null
          ? ProfilePictureWidget(file: publisher.picture)
          : const CircleAvatar(child: Icon(Symbols.close)),
      title: Text(title),
      subtitle: Text(
        publisher != null ? '@${publisher.name}' : 'none'.tr(),
      ).fontSize(12),
      trailing: const Icon(Symbols.chevron_right),
      onTap: onTap,
    );
  }
}

class _FediversePublisherListTile extends StatelessWidget {
  final String title;
  final String? publisherId;
  final SnFediverseAvailabilityResponse fediversePublishers;
  final VoidCallback onTap;

  const _FediversePublisherListTile({
    required this.title,
    required this.publisherId,
    required this.fediversePublishers,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final publisher = publisherId != null
        ? fediversePublishers.publishers
              .where((p) => p.publisherId == publisherId)
              .firstOrNull
        : null;

    return ListTile(
      minLeadingWidth: 48,
      contentPadding: const EdgeInsets.only(
        left: 16,
        right: 17,
        top: 2,
        bottom: 8,
      ),
      leading: CircleAvatar(
        backgroundImage: publisher?.avatarUrl != null
            ? NetworkImage(publisher!.avatarUrl!)
            : null,
        child: publisher?.avatarUrl == null
            ? const Icon(Symbols.language)
            : null,
      ),
      title: Text(title),
      subtitle: Text(
        publisher != null ? publisher.fediverseHandle : 'none'.tr(),
      ).fontSize(12),
      trailing: const Icon(Symbols.chevron_right),
      onTap: onTap,
    );
  }
}

class _PublisherPickerSheet extends StatelessWidget {
  final List<SnPublisher> publishers;
  final String? currentId;
  final String type;

  const _PublisherPickerSheet({
    required this.publishers,
    required this.currentId,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final selectedColor = Theme.of(context).colorScheme.primary;
    return SheetScaffold(
      titleText: type == 'posting'
          ? 'selectPostingPublisher'.tr()
          : 'selectReplyPublisher'.tr(),
      child: publishers.isEmpty
          ? Center(child: Text('publishersEmpty').tr().fontSize(17).bold())
          : ListView.builder(
              itemCount: publishers.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return ListTile(
                    leading: const Icon(Symbols.close),
                    title: Text('none').tr(),
                    selected: currentId == null,
                    trailing: currentId == null
                        ? Icon(Symbols.check, color: selectedColor)
                        : null,
                    onTap: () => Navigator.of(context).pop(null),
                  );
                }
                final publisher = publishers[index - 1];
                final isSelected = publisher.id == currentId;
                return ListTile(
                  leading: ProfilePictureWidget(file: publisher.picture),
                  title: Text(publisher.nick),
                  subtitle: Text('@${publisher.name}'),
                  selected: isSelected,
                  trailing: isSelected
                      ? Icon(Symbols.check, color: selectedColor)
                      : null,
                  onTap: () => Navigator.of(context).pop(publisher.id),
                );
              },
            ),
    );
  }
}

class _FediversePublisherPickerSheet extends StatelessWidget {
  final SnFediverseAvailabilityResponse publishers;
  final String? currentId;

  const _FediversePublisherPickerSheet({
    required this.publishers,
    required this.currentId,
  });

  @override
  Widget build(BuildContext context) {
    final selectedColor = Theme.of(context).colorScheme.primary;
    return SheetScaffold(
      titleText: 'selectFediversePublisher'.tr(),
      child: publishers.publishers.isEmpty
          ? Center(
              child: Text('noFediversePublishers').tr().fontSize(17).bold(),
            )
          : ListView.builder(
              itemCount: publishers.publishers.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return ListTile(
                    leading: const Icon(Symbols.close),
                    title: Text('none').tr(),
                    selected: currentId == null,
                    trailing: currentId == null
                        ? Icon(Symbols.check, color: selectedColor)
                        : null,
                    onTap: () => Navigator.of(context).pop(null),
                  );
                }
                final publisher = publishers.publishers[index - 1];
                final isSelected = publisher.publisherId == currentId;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: publisher.avatarUrl != null
                        ? NetworkImage(publisher.avatarUrl!)
                        : null,
                    child: publisher.avatarUrl == null
                        ? Text(publisher.publisherName[0].toUpperCase())
                        : null,
                  ),
                  title: Text(publisher.publisherName),
                  subtitle: Text(publisher.fediverseHandle),
                  selected: isSelected,
                  trailing: isSelected
                      ? Icon(Symbols.check, color: selectedColor)
                      : null,
                  onTap: () => Navigator.of(context).pop(publisher.publisherId),
                );
              },
            ),
    );
  }
}
