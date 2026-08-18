import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:gap/gap.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:ndef/ndef.dart' as ndef;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:island/core/services/nfc_scan_service.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:material_ui/material_ui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/widgets/account/account_devices.dart';
import 'package:island/accounts/widgets/account/account_authorized_apps.dart';
import 'package:island/accounts/widgets/name_change_card_sheet.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/accounts/screens/me/settings_auth_factors.dart';
import 'package:island/accounts/screens/me/settings_connections.dart';
import 'package:island/accounts/screens/me/settings_contacts.dart';
import 'package:island/accounts/screens/me/settings_webdav.dart';
import 'package:island/auth/captcha.dart';
import 'package:island/auth/login.dart';
import 'package:island/chat/widgets/chat_groups_manager.dart';
import 'package:island/core/database.dart';
import 'package:island/core/network.dart';
import 'package:island/core/server_compatibility.dart';
import 'package:island/creators/screens/publishers_form.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart' hide PageBackButton;
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/shared/widgets/response.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:island/route.gr.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'account_settings.g.dart';
part 'physical_passport.freezed.dart';
part 'physical_passport.g.dart';

bool get _supportsPhysicalPassportScan =>
    !kIsWeb && (Platform.isAndroid || Platform.isIOS);

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
List<SnNotificationTopic> notificationTopics(Ref ref) {
  final client = ref.read(solarNetworkClientProvider);
  return client.notifications.getTopics();
}

@riverpod
Future<Map<String, SnNotificationPreferenceLevel>> notificationPreferences(
  Ref ref,
) async {
  final client = ref.read(solarNetworkClientProvider);
  final prefs = await client.notifications.getPreferences();
  return {for (var p in prefs) p.topic: p.preference};
}

@riverpod
Future<List<SnNotificationPushSubscription>> notificationSubscriptions(
  Ref ref,
) async {
  final client = ref.read(solarNetworkClientProvider);
  return await client.notifications.getSubscriptions();
}

final accountBillingRecordsProvider = AsyncNotifierProvider.autoDispose(
  AccountBillingRecordsNotifier.new,
);

class AccountBillingRecordsNotifier
    extends AsyncNotifier<PaginationState<SnWalletBillingRecord>>
    with AsyncPaginationController<SnWalletBillingRecord> {
  static const int pageSize = 20;

  @override
  Future<List<SnWalletBillingRecord>> fetch() async {
    final client = ref.read(solarNetworkClientProvider);
    final result = await client.wallet.getBillingRecords(
      offset: fetchedCount,
      take: pageSize,
    );
    totalCount = result.totalCount;
    return result.items;
  }
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
    final profileSettings = [
      ListTile(
        minLeadingWidth: 48,
        leading: const Icon(Symbols.person_edit),
        title: Text('updateYourProfile').tr(),
        subtitle: Text('updateYourProfileDescription').tr().fontSize(12),
        contentPadding: const EdgeInsets.only(left: 24, right: 17),
        trailing: const Icon(Symbols.chevron_right),
        onTap: () {
          context.router.push(const AccountUpdateProfileRoute());
        },
      ),
      ListTile(
        minLeadingWidth: 48,
        leading: const Icon(Symbols.badge),
        title: Text('changeName').tr(),
        subtitle: Text('changeNameDescription').tr().fontSize(12),
        contentPadding: const EdgeInsets.only(left: 24, right: 17),
        trailing: const Icon(Symbols.chevron_right),
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            builder: (context) => const NameChangeCardSheet(),
          );
        },
      ),
      ListTile(
        minLeadingWidth: 48,
        leading: const Icon(Symbols.dashboard_customize),
        title: Text('editBoard').tr(),
        subtitle: Text('editBoardDescription').tr().fontSize(12),
        contentPadding: const EdgeInsets.only(left: 24, right: 17),
        trailing: const Icon(Symbols.chevron_right),
        onTap: () {
          context.router.push(const AccountBoardEditRoute());
        },
      ),
    ];

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
      ListTile(
        leading: const Icon(Symbols.nfc).alignment(Alignment.centerLeft).width(48),
        title: Text('physicalPassports').tr(),
        subtitle: Text('physicalPassportsEmptyDescription').tr().fontSize(12),
        contentPadding: const EdgeInsets.only(left: 24, right: 17),
        trailing: const Icon(Symbols.chevron_right),
        onTap: () {
          context.router.push(const PhysicalPassportRoute());
        },
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

    final notificationPreferencesSettings = [
      ListTile(
        minLeadingWidth: 48,
        leading: const Icon(Symbols.notifications),
        title: Text('notificationPreferences').tr(),
        subtitle: Text('notificationPreferencesDescription').tr().fontSize(12),
        contentPadding: const EdgeInsets.only(left: 24, right: 17),
        trailing: const Icon(Symbols.chevron_right),
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => NotificationTopicsSheet(),
          ).then((value) {
            if (value == true) {
              ref.invalidate(notificationPreferencesProvider);
            }
          });
        },
      ),
      ListTile(
        minLeadingWidth: 48,
        leading: const Icon(Symbols.cell_tower),
        title: Text('notificationSubscriptions').tr(),
        subtitle: Text(
          'notificationSubscriptionsDescription',
        ).tr().fontSize(12),
        contentPadding: const EdgeInsets.only(left: 24, right: 17),
        trailing: const Icon(Symbols.chevron_right),
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => const NotificationSubscriptionsSheet(),
          ).then((value) {
            if (value == true) {
              ref.invalidate(notificationSubscriptionsProvider);
            }
          });
        },
      ),
    ];

    final activitySettings = [
      ListTile(
        minLeadingWidth: 48,
        leading: const Icon(Symbols.history),
        title: Text('actionLogs').tr(),
        subtitle: Text('actionLogsDescription').tr().fontSize(12),
        contentPadding: const EdgeInsets.only(left: 24, right: 17),
        trailing: const Icon(Symbols.chevron_right),
        onTap: () {
          context.router.push(const ActionLogsRoute());
        },
      ),
      ListTile(
        minLeadingWidth: 48,
        leading: const Icon(Symbols.gavel),
        title: Text('punishments').tr(),
        subtitle: Text('punishmentsDescription').tr().fontSize(12),
        contentPadding: const EdgeInsets.only(left: 24, right: 17),
        trailing: const Icon(Symbols.chevron_right),
        onTap: () {
          context.router.push(const PunishmentsRoute());
        },
      ),
      if (serverFeatureEnabled(
        ref.watch(serverCapabilitiesProvider).value,
        'affiliations',
      ))
        ListTile(
          minLeadingWidth: 48,
          leading: const Icon(Symbols.auto_fix_high),
          title: Text('affiliations').tr(),
          subtitle: Text('affiliationsDescription').tr().fontSize(12),
          contentPadding: const EdgeInsets.only(left: 24, right: 17),
          trailing: const Icon(Symbols.chevron_right),
          onTap: () {
            context.router.push(const AffiliationRoute());
          },
        ),
    ];

    final billingSettings = [
      ListTile(
        minLeadingWidth: 48,
        leading: const Icon(Symbols.receipt_long),
        title: const Text('Billing'),
        subtitle: const Text('Inbound purchase orders').fontSize(12),
        contentPadding: const EdgeInsets.only(left: 24, right: 17),
        trailing: const Icon(Symbols.chevron_right),
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            builder: (context) => const AccountBillingSheet(),
          );
        },
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

    final integrationsSettings = [
      ListTile(
        minLeadingWidth: 48,
        leading: const Icon(Symbols.group),
        title: const Text('Chat Groups'),
        subtitle: const Text('Manage your chat room groups').fontSize(12),
        contentPadding: const EdgeInsets.only(left: 24, right: 17),
        trailing: const Icon(Symbols.chevron_right),
        onTap: () async {
          final accountId = ref.read(userInfoProvider).value?.id;
          if (accountId == null) return;

          final client = ref.read(apiClientProvider);
          final db = ref.read(databaseProvider);
          final groups =
              ref.read(chatGroupsProvider).value ?? const <SnChatGroup>[];

          final changed = await showChatGroupsManagerSheet(
            context,
            client: client,
            db: db,
            accountId: accountId,
            groups: groups,
          );
          if (changed) {
            ref.invalidate(chatGroupsProvider);
          }
        },
      ),
      ListTile(
        minLeadingWidth: 48,
        leading: const Icon(Symbols.cloud_sync),
        title: Text('storageSettings').tr(),
        subtitle: Text('storageSettingsDescription').tr().fontSize(12),
        contentPadding: const EdgeInsets.only(left: 24, right: 17),
        trailing: const Icon(Symbols.chevron_right),
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => const StorageSettingsSheet(),
          );
        },
      ),
    ];

    // Create a responsive layout based on screen width
    Widget buildSettingsList() {
      return Column(
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SettingsSection(
            title: 'accountProfileTitle',
            children: profileSettings,
          ),
          _SettingsSection(
            title: 'accountPublishingTitle',
            children: defaultPublisherSettings,
          ),
          _SettingsSection(
            title: 'accountNotificationPreferencesTitle',
            children: notificationPreferencesSettings,
          ),
          _SettingsSection(
            title: 'accountActivityTitle',
            children: activitySettings,
          ),
          _SettingsSection(
            title: 'accountSecurityTitle',
            children: securitySettings,
          ),
          _SettingsSection(
            title: 'accountIntegrationsTitle',
            children: integrationsSettings,
          ),
          _SettingsSection(title: 'Billing', children: billingSettings),
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
    if (context.mounted) showLoadingModal(context);

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
    if (context.mounted) showLoadingModal(context);

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

class AccountBillingSheet extends ConsumerWidget {
  const AccountBillingSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = accountBillingRecordsProvider;
    final records = ref.watch(provider);
    final items = records.value?.items ?? const <SnWalletBillingRecord>[];

    if (items.isEmpty &&
        records.hasValue &&
        records.isLoading == false &&
        records.hasError == false) {
      return SheetScaffold(
        titleText: 'Billing',
        heightFactor: 0.8,
        child: Center(
          child: Text(
            'noPurchasesToRestore'.tr(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      );
    }

    return SheetScaffold(
      titleText: 'Billing',
      heightFactor: 0.8,
      child: PaginationList(
        padding: const EdgeInsets.symmetric(vertical: 8),
        provider: provider,
        notifier: provider.notifier,
        itemBuilder: (context, index, record) {
          final order = record.orders.firstOrNull;
          final subscription = record.subscriptions.firstOrNull;
          final providerName = _billingProviderName(record.provider);
          final rawTitle =
              subscription?.identifier ??
              order?.productIdentifier ??
              record.productIdentifier;
          final title = rawTitle == null
              ? providerName
              : _billingProviderName(rawTitle);
          final detail = [
            providerName,
            if (record.externalId.isNotEmpty) record.externalId,
            DateFormat.yMMMd().format(record.begunAt),
          ].join(' · ');
          final status = order?.status;
          final statusText = switch (status) {
            0 => 'pending'.tr(),
            1 => 'paymentSuccess'.tr(),
            2 => 'cancel'.tr(),
            3 => 'done'.tr(),
            4 => 'expired'.tr(),
            _ =>
              subscription != null
                  ? (subscription.isActive ? 'active'.tr() : 'inactive'.tr())
                  : null,
          };
          final statusColor = switch (status) {
            0 => Colors.orange,
            1 => Colors.green,
            2 => Colors.grey,
            3 => Colors.blue,
            4 => Colors.red,
            _ => Theme.of(context).colorScheme.onSurfaceVariant,
          };

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Symbols.receipt_long,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            title: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              detail,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (order != null)
                  Text(
                    '${order.amount.toStringAsFixed(2)} ${order.currency.toUpperCase()}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                if (statusText != null)
                  Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

String _billingProviderName(String provider) {
  switch (provider.trim().toLowerCase()) {
    case 'gdp':
      return 'walletBillingProviderGdp'.tr();
    case 'apple_store':
    case 'apple-store':
    case 'applestore':
      return 'walletBillingProviderAppleStore'.tr();
    case 'order':
      return 'walletBillingProviderOrder'.tr();
    default:
      return provider;
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

class NotificationPreferenceSheet extends HookConsumerWidget {
  final SnNotificationTopic topic;
  final SnNotificationPreferenceLevel currentPreference;

  const NotificationPreferenceSheet({
    super.key,
    required this.topic,
    required this.currentPreference,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SheetScaffold(
      titleText: topic.description,
      heightFactor: 0.5,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Symbols.notifications),
            title: Text('notificationPreferenceNormal').tr(),
            subtitle: Text(
              'notificationPreferenceNormalDesc',
            ).tr().fontSize(12),
            trailing: currentPreference == SnNotificationPreferenceLevel.normal
                ? Icon(
                    Symbols.check,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : null,
            onTap: () => _setPreference(
              context,
              ref,
              SnNotificationPreferenceLevel.normal,
            ),
          ),
          ListTile(
            leading: const Icon(Symbols.notifications_off),
            title: Text('notificationPreferenceSilent').tr(),
            subtitle: Text(
              'notificationPreferenceSilentDesc',
            ).tr().fontSize(12),
            trailing: currentPreference == SnNotificationPreferenceLevel.silent
                ? Icon(
                    Symbols.check,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : null,
            onTap: () => _setPreference(
              context,
              ref,
              SnNotificationPreferenceLevel.silent,
            ),
          ),
          ListTile(
            leading: const Icon(Symbols.block),
            title: Text('notificationPreferenceReject').tr(),
            subtitle: Text(
              'notificationPreferenceRejectDesc',
            ).tr().fontSize(12),
            trailing: currentPreference == SnNotificationPreferenceLevel.reject
                ? Icon(
                    Symbols.check,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : null,
            onTap: () => _setPreference(
              context,
              ref,
              SnNotificationPreferenceLevel.reject,
            ),
          ),
          if (currentPreference != SnNotificationPreferenceLevel.normal)
            ListTile(
              leading: Icon(
                Symbols.restore,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text('notificationResetToDefault').tr(),
              onTap: () => _resetPreference(context, ref),
            ),
        ],
      ),
    );
  }

  Future<void> _setPreference(
    BuildContext context,
    WidgetRef ref,
    SnNotificationPreferenceLevel preference,
  ) async {
    showLoadingModal(context);
    try {
      final client = ref.read(solarNetworkClientProvider);
      await client.notifications.setPreference(topic.topic, preference);
      if (context.mounted) {
        Navigator.pop(context, true);
        showSnackBar('settingsSaved'.tr());
      }
    } catch (err) {
      showErrorAlert(err);
    } finally {
      if (context.mounted) hideLoadingModal(context);
    }
  }

  Future<void> _resetPreference(BuildContext context, WidgetRef ref) async {
    final confirm = await showConfirmAlert(
      'notificationResetHint'.tr(),
      'notificationReset'.tr(),
    );
    if (!confirm || !context.mounted) return;

    showLoadingModal(context);
    try {
      final client = ref.read(solarNetworkClientProvider);
      await client.notifications.deletePreference(topic.topic);
      if (context.mounted) {
        Navigator.pop(context, true);
        showSnackBar('settingsSaved'.tr());
      }
    } catch (err) {
      showErrorAlert(err);
    } finally {
      if (context.mounted) hideLoadingModal(context);
    }
  }
}

class NotificationTopicsSheet extends ConsumerWidget {
  const NotificationTopicsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topics = ref.read(notificationTopicsProvider);
    final prefs = ref.watch(notificationPreferencesProvider);

    return SheetScaffold(
      titleText: 'notificationPreferences'.tr(),
      heightFactor: 0.8,
      actions: [
        IconButton(
          icon: const Icon(Symbols.add),
          onPressed: () {
            Navigator.pop(context);
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => const NotificationCustomTopicSheet(),
            ).then((value) {
              if (value == true) {
                ref.invalidate(notificationPreferencesProvider);
              }
            });
          },
        ),
      ],
      child: prefs.when(
        data: (preferenceMap) => ListView.builder(
          itemCount: topics.length,
          itemBuilder: (context, index) {
            final topic = topics[index];
            final currentPref =
                preferenceMap[topic.topic] ??
                SnNotificationPreferenceLevel.normal;
            return ListTile(
              minLeadingWidth: 48,
              contentPadding: const EdgeInsets.only(
                left: 16,
                right: 17,
                top: 2,
                bottom: 4,
              ),
              title: Text(topic.description),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topic.topic,
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getPreferenceLabel(currentPref),
                    style: TextStyle(
                      fontSize: 11,
                      color: _getPreferenceColor(context, currentPref),
                    ),
                  ),
                ],
              ),
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(_getPreferenceIcon(currentPref), size: 16),
              ).padding(top: 4),
              trailing: const Icon(Symbols.chevron_right),
              onTap: () {
                Navigator.pop(context);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => NotificationPreferenceSheet(
                    topic: topic,
                    currentPreference: currentPref,
                  ),
                ).then((value) {
                  if (value == true) {
                    ref.invalidate(notificationPreferencesProvider);
                  }
                });
              },
            );
          },
        ),
        error: (err, _) => ResponseErrorWidget(
          error: err,
          onRetry: () => ref.invalidate(notificationPreferencesProvider),
        ),
        loading: () => const ResponseLoadingWidget(),
      ),
    );
  }

  String _getPreferenceLabel(SnNotificationPreferenceLevel level) {
    switch (level) {
      case SnNotificationPreferenceLevel.normal:
        return 'notificationPreferenceNormal'.tr();
      case SnNotificationPreferenceLevel.silent:
        return 'notificationPreferenceSilent'.tr();
      case SnNotificationPreferenceLevel.reject:
        return 'notificationPreferenceReject'.tr();
    }
  }

  Color _getPreferenceColor(
    BuildContext context,
    SnNotificationPreferenceLevel level,
  ) {
    switch (level) {
      case SnNotificationPreferenceLevel.normal:
        return Theme.of(context).colorScheme.primary;
      case SnNotificationPreferenceLevel.silent:
        return Theme.of(context).colorScheme.tertiary;
      case SnNotificationPreferenceLevel.reject:
        return Theme.of(context).colorScheme.error;
    }
  }

  IconData _getPreferenceIcon(SnNotificationPreferenceLevel level) {
    switch (level) {
      case SnNotificationPreferenceLevel.normal:
        return Symbols.notifications;
      case SnNotificationPreferenceLevel.silent:
        return Symbols.notifications_off;
      case SnNotificationPreferenceLevel.reject:
        return Symbols.block;
    }
  }
}

class NotificationCustomTopicSheet extends ConsumerStatefulWidget {
  const NotificationCustomTopicSheet({super.key});

  @override
  ConsumerState<NotificationCustomTopicSheet> createState() =>
      _NotificationCustomTopicSheetState();
}

class _NotificationCustomTopicSheetState
    extends ConsumerState<NotificationCustomTopicSheet> {
  final _topicController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _topicController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SheetScaffold(
      titleText: 'notificationAddCustom'.tr(),
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _topicController,
              decoration: InputDecoration(
                labelText: 'notificationCustomTopic'.tr(),
                hintText: 'notificationCustomTopicHint'.tr(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'notificationCustomDescription'.tr(),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text('add'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final topic = _topicController.text.trim();
    final description = _descriptionController.text.trim();

    if (topic.isEmpty || description.isEmpty) {
      showSnackBar('notificationCustomTopicError'.tr());
      return;
    }

    setState(() => _isLoading = true);

    try {
      final client = ref.read(solarNetworkClientProvider);
      await client.notifications.addCustomTopic(topic, description);
      if (mounted) {
        Navigator.pop(context, true);
        showSnackBar('settingsSaved'.tr());
      }
    } catch (err) {
      showErrorAlert(err);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

class NotificationSubscriptionsSheet extends ConsumerWidget {
  const NotificationSubscriptionsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptions = ref.watch(notificationSubscriptionsProvider);

    return SheetScaffold(
      titleText: 'notificationSubscriptions'.tr(),
      heightFactor: 0.8,
      child: subscriptions.when(
        data: (subs) => subs.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Symbols.cell_tower,
                      size: 48,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'notificationSubscriptionsEmpty'.tr(),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: subs.length,
                itemBuilder: (context, index) {
                  final sub = subs[index];
                  final presentation =
                      _NotificationSubscriptionPresentation.forProvider(
                        sub.provider,
                      );
                  return ListTile(
                    minLeadingWidth: 48,
                    contentPadding: const EdgeInsets.only(
                      left: 16,
                      right: 17,
                      top: 2,
                      bottom: 4,
                    ),
                    title: Text(presentation.label),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (sub.deviceName != null &&
                            sub.deviceName!.isNotEmpty)
                          Text(sub.deviceName!),
                        const SizedBox(height: 2),
                        Text(
                          presentation.roleHint,
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          sub.deviceId,
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          sub.isActivated
                              ? 'notificationSubscriptionActive'.tr()
                              : 'notificationSubscriptionInactive'.tr(),
                          style: TextStyle(
                            fontSize: 11,
                            color: sub.isActivated
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                      child: Icon(presentation.icon, size: 16),
                    ).padding(top: 4),
                    trailing: const Icon(Symbols.chevron_right),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) =>
                            NotificationSubscriptionDetailSheet(
                              subscription: sub,
                            ),
                      ).then((value) {
                        if (value == true) {
                          ref.invalidate(notificationSubscriptionsProvider);
                        }
                      });
                    },
                  );
                },
              ),
        error: (err, _) => ResponseErrorWidget(
          error: err,
          onRetry: () => ref.invalidate(notificationSubscriptionsProvider),
        ),
        loading: () => const ResponseLoadingWidget(),
      ),
    );
  }
}

class NotificationSubscriptionDetailSheet extends ConsumerWidget {
  final SnNotificationPushSubscription subscription;

  const NotificationSubscriptionDetailSheet({
    super.key,
    required this.subscription,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presentation = _NotificationSubscriptionPresentation.forProvider(
      subscription.provider,
    );

    Future<void> unsubscribe() async {
      final confirm = await showConfirmAlert(
        'notificationSubscriptionDeleteHint'.tr(),
        'notificationSubscriptionDelete'.tr(),
        isDanger: true,
      );
      if (!confirm || !context.mounted) return;
      try {
        showLoadingModal(context);
        final client = ref.read(solarNetworkClientProvider);
        await client.notifications.deleteSubscription(subscription.id);
        if (context.mounted) {
          Navigator.pop(context, true);
          showSnackBar('settingsSaved'.tr());
        }
      } catch (err) {
        showErrorAlert(err);
      } finally {
        if (context.mounted) hideLoadingModal(context);
      }
    }

    return SheetScaffold(
      titleText: 'notificationSubscriptionDetail'.tr(),
      heightFactor: 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  presentation.icon,
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  presentation.label,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                if (subscription.deviceName != null &&
                    subscription.deviceName!.isNotEmpty) ...[
                  Text(
                    subscription.deviceName!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  presentation.roleHint,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subscription.deviceId,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      subscription.isActivated
                          ? Symbols.check_circle
                          : Symbols.cancel,
                      size: 16,
                      color: subscription.isActivated
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      subscription.isActivated
                          ? 'notificationSubscriptionActive'.tr()
                          : 'notificationSubscriptionInactive'.tr(),
                      style: TextStyle(
                        fontSize: 13,
                        color: subscription.isActivated
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              Symbols.delete,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              'notificationSubscriptionDelete'.tr(),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            onTap: unsubscribe,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          ),
        ],
      ),
    );
  }
}

class _NotificationSubscriptionPresentation {
  final String label;
  final String roleHint;
  final IconData icon;

  const _NotificationSubscriptionPresentation({
    required this.label,
    required this.roleHint,
    required this.icon,
  });

  factory _NotificationSubscriptionPresentation.forProvider(
    SnNotificationPushSubscriptionProvider provider,
  ) {
    return switch (provider) {
      SnNotificationPushSubscriptionProvider.fcm =>
        const _NotificationSubscriptionPresentation(
          label: 'Firebase Cloud Messaging',
          roleHint:
              'Standard push notifications on Android and supported web flows.',
          icon: Symbols.android,
        ),
      SnNotificationPushSubscriptionProvider.apple =>
        const _NotificationSubscriptionPresentation(
          label: 'Apple Push (APNs)',
          roleHint:
              'Standard alerts, badges, and message notifications on Apple devices.',
          icon: Symbols.phone_iphone,
        ),
      SnNotificationPushSubscriptionProvider.sop =>
        const _NotificationSubscriptionPresentation(
          label: 'Solar Network Push (SOP)',
          roleHint:
              'Solar Network native stream-based delivery for this device session.',
          icon: Symbols.cloud,
        ),
      SnNotificationPushSubscriptionProvider.unifiedPush =>
        const _NotificationSubscriptionPresentation(
          label: 'UnifiedPush',
          roleHint: 'Self-hosted push endpoint registration.',
          icon: Symbols.link,
        ),
      SnNotificationPushSubscriptionProvider.appk =>
        const _NotificationSubscriptionPresentation(
          label: 'Apple PushKit',
          roleHint: 'VoIP push delivery for incoming calls on iPhone and iPad.',
          icon: Symbols.call,
        ),
    };
  }
}

@freezed
sealed class SnPhysicalPassport with _$SnPhysicalPassport {
  const factory SnPhysicalPassport({
    required String id,
    String? label,
    required bool isActive,
    required bool isLocked,
    required bool isEncrypted,
    DateTime? lastSeenAt,
    required DateTime createdAt,
    String? uid,
  }) = _SnPhysicalPassport;

  factory SnPhysicalPassport.fromJson(Map<String, dynamic> json) =>
      _$SnPhysicalPassportFromJson(json);
}

final physicalPassportsProvider =
    FutureProvider.autoDispose<List<SnPhysicalPassport>>((ref) async {
      final client = ref.watch(solarNetworkClientProvider);
      final response = await client.dio.get('/passport/nfc/tags');
      return (response.data as List)
          .map((e) => SnPhysicalPassport.fromJson(e))
          .toList();
    });

@RoutePage()
class PhysicalPassportScreen extends HookConsumerWidget {
  const PhysicalPassportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passportsAsync = ref.watch(physicalPassportsProvider);
    final user = ref.watch(userInfoProvider);
    final isAdmin = user.value?.isSuperuser == true;

    return AppScaffold(
      appBar: AppBar(
        title: Text('physicalPassports').tr(),
        leading: const AutoLeadingButton(),
        actions: [
          if (isAdmin && _supportsPhysicalPassportScan)
            IconButton(
              icon: const Icon(Symbols.admin_panel_settings),
              tooltip: 'adminRegisterEncryptedTag'.tr(),
              onPressed: () => _showAdminRegisterSheet(context, ref),
            ),
          const Gap(8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(physicalPassportsProvider);
        },
        child: passportsAsync.when(
          data: (passports) {
            if (passports.isEmpty) {
              return _PhysicalPassportsEmptyState(
                onAddPassport: _supportsPhysicalPassportScan
                    ? () => _showAddSheet(context, ref)
                    : null,
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: passports.length,
              itemBuilder: (context, index) {
                final passport = passports[index];
                return _PhysicalPassportListItem(
                  passport: passport,
                  onTap: () => _showDetailSheet(context, ref, passport),
                );
              },
            );
          },
          error: (error, _) => ResponseErrorWidget(
            error: error,
            onRetry: () => ref.invalidate(physicalPassportsProvider),
          ),
          loading: () => const ResponseLoadingWidget(),
        ),
      ),
      floatingActionButton: passportsAsync.maybeWhen(
        data: (passports) =>
            _supportsPhysicalPassportScan &&
                passports.isNotEmpty &&
                user.value != null
            ? FloatingActionButton.extended(
                onPressed: () => _showAddSheet(context, ref),
                icon: const Icon(Symbols.add),
                label: Text('addPhysicalPassport').tr(),
              )
            : null,
        orElse: () => null,
      ),
    );
  }

  void _showAddSheet(BuildContext context, WidgetRef ref) {
    if (!_supportsPhysicalPassportScan) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => const _AddPhysicalPassportSheet(),
    ).then((_) {
      ref.invalidate(physicalPassportsProvider);
    });
  }

  void _showDetailSheet(
    BuildContext context,
    WidgetRef ref,
    SnPhysicalPassport passport,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => _PhysicalPassportDetailSheet(passport: passport),
    ).then((_) {
      ref.invalidate(physicalPassportsProvider);
    });
  }

  void _showAdminRegisterSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => const _AdminRegisterEncryptedTagSheet(),
    ).then((_) {
      ref.invalidate(physicalPassportsProvider);
    });
  }
}

class _PhysicalPassportsEmptyState extends StatelessWidget {
  final VoidCallback? onAddPassport;

  const _PhysicalPassportsEmptyState({required this.onAddPassport});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              elevation: 0,
              color: colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Icon(
                  Symbols.badge,
                  size: 64,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const Gap(24),
            Text(
              'physicalPassportsEmpty'.tr(),
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const Gap(8),
            Text(
              'physicalPassportsEmptyDescription'.tr(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (onAddPassport != null) ...[
              const Gap(32),
              FilledButton.icon(
                onPressed: onAddPassport,
                icon: const Icon(Symbols.add),
                label: Text('addPhysicalPassport').tr(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PhysicalPassportListItem extends StatelessWidget {
  final SnPhysicalPassport passport;
  final VoidCallback onTap;

  const _PhysicalPassportListItem({
    required this.passport,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: passport.isLocked
                      ? colorScheme.tertiaryContainer
                      : colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  passport.isLocked ? Symbols.lock : Symbols.badge,
                  color: passport.isLocked
                      ? colorScheme.onTertiaryContainer
                      : colorScheme.onPrimaryContainer,
                ),
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      passport.label ?? 'physicalPassportUnnamed'.tr(),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (passport.lastSeenAt != null) ...[
                      Text(
                        'physicalPassportLastSeen'.tr(
                          args: [
                            _formatRelativeTime(context, passport.lastSeenAt!),
                          ],
                        ),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const Gap(8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (!passport.isActive)
                          _StatusChip(
                            label: 'physicalPassportInactive'.tr(),
                            color: colorScheme.onErrorContainer,
                            icon: Symbols.error,
                          ),
                        if (passport.isLocked)
                          _StatusChip(
                            label: 'physicalPassportLocked'.tr(),
                            color: colorScheme.onTertiaryContainer,
                            icon: Symbols.lock,
                          ),
                        if (passport.isEncrypted)
                          _StatusChip(
                            label: 'physicalPassportEncrypted'.tr(),
                            color: colorScheme.onPrimaryContainer,
                            icon: Symbols.lock,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Symbols.chevron_right, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  String _formatRelativeTime(BuildContext context, DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return 'timeDaysAgo'.tr(args: [difference.inDays.toString()]);
    } else if (difference.inHours > 0) {
      return 'timeHoursAgo'.tr(args: [difference.inHours.toString()]);
    } else if (difference.inMinutes > 0) {
      return 'timeMinutesAgo'.tr(args: [difference.inMinutes.toString()]);
    } else {
      return 'timeJustNow'.tr();
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _StatusChip({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        Icon(icon, color: color, size: 16),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
        ),
      ],
    );
  }
}

class _AddPhysicalPassportSheet extends ConsumerStatefulWidget {
  const _AddPhysicalPassportSheet();

  @override
  ConsumerState<_AddPhysicalPassportSheet> createState() =>
      _AddPhysicalPassportSheetState();
}

class _AddPhysicalPassportSheetState
    extends ConsumerState<_AddPhysicalPassportSheet> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _uidController = TextEditingController();
  bool _isSubmitting = false;
  bool _isScanning = false;
  String? _scannedUid;
  NFCTag? _scannedTag;

  @override
  void dispose() {
    _labelController.dispose();
    _uidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SheetScaffold(
      titleText: 'addPhysicalPassport'.tr(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'addPhysicalPassportDescription'.tr(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const Gap(24),
              FilledButton.tonalIcon(
                onPressed: !_supportsPhysicalPassportScan || _isScanning
                    ? null
                    : _scanPassport,
                icon: _isScanning
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Symbols.nfc),
                label: Text(
                  _isScanning ? 'scanning'.tr() : 'scanPhysicalPassport'.tr(),
                ),
              ),
              if (_scannedUid != null) ...[
                const Gap(24),
                Card(
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  color: colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Symbols.check_circle,
                              color: colorScheme.primary,
                              size: 20,
                            ),
                            const Gap(8),
                            Text(
                              'physicalPassportScanned'.tr(),
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const Gap(12),
                        Text(
                          'UID: $_scannedUid',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontFamily: 'monospace'),
                        ),
                        const Gap(12),
                        Text(
                          'Tag Type: ${_scannedTag?.type}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontFamily: 'monospace'),
                        ),
                        const Gap(12),
                        Text('NDEF Type: ${_scannedTag?.ndefType}'),
                      ],
                    ),
                  ),
                ),
              ],
              const Gap(24),
              TextFormField(
                controller: _labelController,
                decoration: InputDecoration(
                  labelText: 'physicalPassportLabel'.tr(),
                  hintText: 'physicalPassportLabelHint'.tr(),
                  prefixIcon: const Icon(Symbols.label),
                ),
                maxLength: 64,
              ),
              const Gap(16),
              TextFormField(
                controller: _uidController,
                decoration: InputDecoration(
                  labelText: 'physicalPassportUid'.tr(),
                  hintText: 'physicalPassportUidHint'.tr(),
                  prefixIcon: const Icon(Symbols.tag),
                ),
                enabled: false,
              ),
              const Gap(24),
              if (_scannedTag?.type == .iso7816)
                Text(
                  'encryptedTagRegsiterHint'.tr(),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: colorScheme.tertiary),
                  textAlign: TextAlign.center,
                )
              else
                FilledButton(
                  onPressed: _isSubmitting || _scannedUid == null
                      ? null
                      : _register,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text('registerPhysicalPassport').tr(),
                ),
              const Gap(16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _scanPassport() async {
    if (!_supportsPhysicalPassportScan) return;
    setState(() => _isScanning = true);

    try {
      final availability = await NfcScanService().checkAvailability();
      if (availability != NFCAvailability.available) {
        if (mounted) {
          showErrorAlert(Exception('nfcNotAvailable'.tr()));
        }
        return;
      }

      final tag = await NfcScanService().scanTag();
      final uid = tag.id;

      setState(() {
        _scannedUid = uid;
        _scannedTag = tag;
        _uidController.text = uid;
      });
    } catch (e) {
      if (mounted) {
        showErrorAlert(e);
      }
    } finally {
      // Always finish NFC session to prevent iOS session leak
      await NfcScanService().finish();
      if (mounted) {
        setState(() => _isScanning = false);
      }
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_scannedUid == null) return;

    setState(() => _isSubmitting = true);

    try {
      final client = ref.read(solarNetworkClientProvider);
      final response = await client.dio.post(
        '/passport/nfc/tags',
        data: {
          'uid': _scannedUid,
          if (_labelController.text.trim().isNotEmpty)
            'label': _labelController.text.trim(),
        },
      );
      final passport = SnPhysicalPassport.fromJson(response.data);
      ref.invalidate(physicalPassportsProvider);

      if (!mounted) return;

      Navigator.of(context).pop();
      showSnackBar('physicalPassportRegistered'.tr());
      await _showWriteDeepLinkSheet(_scannedTag!, passport);
    } catch (e) {
      if (mounted) {
        showErrorAlert(e);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _showWriteDeepLinkSheet(
    NFCTag tag,
    SnPhysicalPassport passport,
  ) async {
    bool isWriting = true;
    bool writeSuccess = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      enableDrag: false,
      isDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          if (isWriting) {
            _performWrite(tag, passport)
                .then((result) {
                  if (ctx.mounted) {
                    setSheetState(() {
                      isWriting = false;
                      writeSuccess = result;
                    });
                  }
                })
                .catchError((e) {
                  if (ctx.mounted) {
                    setSheetState(() {
                      isWriting = false;
                      writeSuccess = false;
                    });
                  }
                });
          }

          return SheetScaffold(
            heightFactor: 0.4,
            titleText: 'nfcWritingDeepLink'.tr(),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isWriting) ...[
                    const CircularProgressIndicator().center(),
                    const Gap(16),
                    Text('nfcTapToWrite'.tr()),
                  ] else ...[
                    Icon(
                      writeSuccess ? Symbols.check_circle : Symbols.error,
                      size: 48,
                      color: writeSuccess
                          ? Theme.of(ctx).colorScheme.primary
                          : Theme.of(ctx).colorScheme.error,
                    ),
                    const Gap(16),
                    Text(
                      writeSuccess
                          ? 'nfcWriteSuccess'.tr()
                          : 'nfcWriteFailed'.tr(),
                    ),
                    const Gap(24),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text('done').tr(),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<bool> _performWrite(NFCTag tag, SnPhysicalPassport passport) async {
    try {
      final availability = await FlutterNfcKit.nfcAvailability;
      if (availability != NFCAvailability.available) {
        return false;
      }

      await FlutterNfcKit.poll(iosAlertMessage: 'nfcTapToWrite'.tr());

      final deepLink = 'solian://phpass/${passport.id}';
      final uriRecord = ndef.UriRecord.fromUri(Uri.parse(deepLink));
      await FlutterNfcKit.writeNDEFRecords([uriRecord]);

      await FlutterNfcKit.finish(iosAlertMessage: 'Success');
      return true;
    } catch (e) {
      await FlutterNfcKit.finish(iosErrorMessage: e.toString());
      return false;
    }
  }
}

class _PhysicalPassportDetailSheet extends ConsumerStatefulWidget {
  final SnPhysicalPassport passport;

  const _PhysicalPassportDetailSheet({required this.passport});

  @override
  ConsumerState<_PhysicalPassportDetailSheet> createState() =>
      _PhysicalPassportDetailSheetState();
}

class _PhysicalPassportDetailSheetState
    extends ConsumerState<_PhysicalPassportDetailSheet> {
  late TextEditingController _labelController;
  late bool _isActive;
  bool _isEditing = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.passport.label ?? '');
    _isActive = widget.passport.isActive;
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final passport = widget.passport;

    return SheetScaffold(
      titleText: 'physicalPassportDetails'.tr(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: passport.isLocked
                        ? colorScheme.tertiaryContainer
                        : colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    passport.isLocked ? Symbols.lock : Symbols.badge,
                    color: passport.isLocked
                        ? colorScheme.onTertiaryContainer
                        : colorScheme.onPrimaryContainer,
                    size: 28,
                  ),
                ),
                const Gap(16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_isEditing)
                        TextFormField(
                          controller: _labelController,
                          decoration: InputDecoration(
                            labelText: 'physicalPassportLabel'.tr(),
                            isDense: true,
                          ),
                          maxLength: 64,
                        )
                      else
                        Text(
                          passport.label ?? 'physicalPassportUnnamed'.tr(),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      if (!_isEditing && (passport.uid?.isNotEmpty ?? false))
                        Text(
                          'UID: ${passport.uid}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontFamily: 'monospace',
                              ),
                        ),
                      if (!passport.isLocked && passport.isEncrypted)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Icon(
                                Symbols.lock,
                                size: 14,
                                color: colorScheme.primary,
                              ),
                              const Gap(4),
                              Text(
                                'Encrypted (NTAG424)',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(24),
            const Divider(),
            const Gap(16),
            if (!passport.isLocked && !passport.isEncrypted) ...[
              OutlinedButton.icon(
                onPressed: _isSubmitting ? null : _writePassport,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Symbols.edit),
                label: Text('writePhysicalPassport'.tr()),
              ),
              const Gap(8),
            ],
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Symbols.schedule),
              title: Text('physicalPassportCreatedAt'.tr()),
              subtitle: Text(_formatDateTime(passport.createdAt)),
            ),
            if (passport.lastSeenAt != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Symbols.visibility),
                title: Text('physicalPassportLastSeenAt'.tr()),
                subtitle: Text(_formatDateTime(passport.lastSeenAt!)),
              ),
            const Gap(24),
            if (!passport.isLocked && !_isEditing) ...[
              if (!passport.isEncrypted)
                ...([
                  const Gap(8),
                  OutlinedButton.icon(
                    onPressed: _isSubmitting ? null : _writePassport,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Symbols.edit),
                    label: Text('writePhysicalPassport'.tr()),
                  ),
                ]),
              OutlinedButton.icon(
                onPressed: _isSubmitting ? null : _lockPassport,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Symbols.lock),
                label: Text('lockPhysicalPassport'.tr()),
              ),
              const Gap(8),
              OutlinedButton.icon(
                onPressed: () => setState(() => _isEditing = true),
                icon: const Icon(Symbols.edit),
                label: Text('editPhysicalPassport'.tr()),
              ),
              const Gap(8),
              OutlinedButton.icon(
                onPressed: _isSubmitting ? null : _deletePassport,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Symbols.delete, color: colorScheme.error),
                label: Text(
                  'physicalPassportDelete'.tr(),
                  style: TextStyle(color: colorScheme.error),
                ),
              ),
            ],
            if (_isEditing) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () {
                              setState(() {
                                _isEditing = false;
                                _labelController.text = passport.label ?? '';
                                _isActive = passport.isActive;
                              });
                            },
                      child: Text('cancel'.tr()),
                    ),
                  ),
                  const Gap(8),
                  Expanded(
                    child: FilledButton(
                      onPressed: _isSubmitting ? null : _saveChanges,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text('save'.tr()),
                    ),
                  ),
                ],
              ),
            ],
            const Gap(16),
          ],
        ),
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      final client = ref.read(solarNetworkClientProvider);
      await client.dio.patch(
        '/passport/nfc/tags/${widget.passport.id}',
        data: {
          'label': _labelController.text.trim().isEmpty
              ? null
              : _labelController.text.trim(),
          'is_active': _isActive,
        },
      );
      ref.invalidate(physicalPassportsProvider);
      if (mounted) {
        setState(() => _isEditing = false);
        showSnackBar('physicalPassportUpdated'.tr());
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        showErrorAlert(e);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _lockPassport() async {
    final confirm = await showConfirmAlert(
      'physicalPassportLockConfirm'.tr(),
      'lockPhysicalPassport'.tr(),
    );
    if (!confirm) return;

    setState(() => _isSubmitting = true);

    try {
      final client = ref.read(solarNetworkClientProvider);
      await client.dio.post('/passport/nfc/tags/${widget.passport.id}/lock');
      ref.invalidate(physicalPassportsProvider);
      if (mounted) {
        showSnackBar('physicalPassportLocked'.tr());
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        showErrorAlert(e);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _deletePassport() async {
    final confirm = await showConfirmAlert(
      'physicalPassportDeleteConfirm'.tr(),
      'physicalPassportDelete'.tr(),
      isDanger: true,
    );
    if (!confirm) return;

    setState(() => _isSubmitting = true);

    try {
      final client = ref.read(solarNetworkClientProvider);
      await client.dio.delete('/passport/nfc/tags/${widget.passport.id}');
      ref.invalidate(physicalPassportsProvider);
      if (mounted) {
        showSnackBar('physicalPassportDeleted'.tr());
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        showErrorAlert(e);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _writePassport() async {
    if (!_supportsPhysicalPassportScan) return;
    setState(() => _isSubmitting = true);

    try {
      final availability = await FlutterNfcKit.nfcAvailability;
      if (availability != NFCAvailability.available) {
        if (mounted) {
          showErrorAlert(Exception('nfcNotAvailable'.tr()));
        }
        return;
      }

      await FlutterNfcKit.poll(iosAlertMessage: 'nfcTapToWrite'.tr());

      final deepLink = 'solian://phpass/${widget.passport.id}';
      final uriRecord = ndef.UriRecord.fromUri(Uri.parse(deepLink));
      await FlutterNfcKit.writeNDEFRecords([uriRecord]);

      await FlutterNfcKit.finish(iosAlertMessage: 'Success');

      if (mounted) {
        showSnackBar('nfcTagWritten'.tr());
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        await FlutterNfcKit.finish(iosErrorMessage: e.toString());
        showErrorAlert(e);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat.yMMMd().add_Hm().format(dateTime.toLocal());
  }
}

class _AdminRegisterEncryptedTagSheet extends ConsumerStatefulWidget {
  const _AdminRegisterEncryptedTagSheet();

  @override
  ConsumerState<_AdminRegisterEncryptedTagSheet> createState() =>
      _AdminRegisterEncryptedTagSheetState();
}

class _AdminRegisterEncryptedTagSheetState
    extends ConsumerState<_AdminRegisterEncryptedTagSheet> {
  final _formKey = GlobalKey<FormState>();
  final _uidController = TextEditingController();
  final _sunKeyController = TextEditingController();
  final _assignedUserIdController = TextEditingController();
  bool _isSubmitting = false;
  bool _isScanning = false;
  String? _scannedUid;
  NFCTag? _scannedTag;

  @override
  void dispose() {
    _uidController.dispose();
    _sunKeyController.dispose();
    _assignedUserIdController.dispose();
    super.dispose();
  }

  void _generateSunKey() {
    final rng = Random.secure();
    final key = List.generate(16, (_) => rng.nextInt(256));
    _sunKeyController.text = base64Encode(key);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SheetScaffold(
      titleText: 'adminRegisterEncryptedTag'.tr(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'adminRegisterEncryptedTagDescription'.tr(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const Gap(24),
              FilledButton.tonalIcon(
                onPressed: _isScanning ? null : _scanTag,
                icon: _isScanning
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Symbols.nfc),
                label: Text(_isScanning ? 'scanning'.tr() : 'scanTag'.tr()),
              ),
              if (_scannedUid != null) ...[
                const Gap(16),
                Card(
                  elevation: 0,
                  color: colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Symbols.check_circle,
                              color: colorScheme.primary,
                              size: 20,
                            ),
                            const Gap(8),
                            Text(
                              'tagScanned'.tr(),
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const Gap(12),
                        Text(
                          'UID: $_scannedUid',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontFamily: 'monospace'),
                        ),
                        const Gap(12),
                        Text(
                          'Tag Type: ${_scannedTag?.type}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontFamily: 'monospace'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const Gap(24),
              TextFormField(
                controller: _uidController,
                decoration: InputDecoration(
                  labelText: 'tagUid'.tr(),
                  hintText: 'tagUidHint'.tr(),
                  prefixIcon: const Icon(Symbols.tag),
                ),
                enabled: false,
              ),
              const Gap(16),
              TextFormField(
                controller: _sunKeyController,
                decoration: InputDecoration(
                  labelText: 'physicalPassportSunKey'.tr(),
                  hintText: 'physicalPassportSunKeyHint'.tr(),
                  prefixIcon: const Icon(Symbols.key),
                  suffixIcon: IconButton(
                    icon: const Icon(Symbols.autorenew),
                    tooltip: 'generateKey'.tr(),
                    onPressed: _generateSunKey,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'sunKeyRequired'.tr();
                  }
                  return null;
                },
              ),
              Text(
                'physicalPassportSunKeyDescription'.tr(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ).padding(horizontal: 8, top: 4),
              const Gap(16),
              TextFormField(
                controller: _assignedUserIdController,
                decoration: InputDecoration(
                  labelText: 'assignedUserId'.tr(),
                  hintText: 'assignedUserIdHint'.tr(),
                  prefixIcon: const Icon(Symbols.person),
                ),
              ),
              Text(
                'assignedUserIdDescription'.tr(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ).padding(horizontal: 8, top: 4),
              const Gap(32),
              FilledButton(
                onPressed: _isSubmitting || _scannedUid == null
                    ? null
                    : _registerEncryptedTag,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('registerEncryptedTag').tr(),
              ),
              const Gap(16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _scanTag() async {
    if (!_supportsPhysicalPassportScan) return;
    setState(() => _isScanning = true);

    try {
      final availability = await NfcScanService().checkAvailability();
      if (availability != NFCAvailability.available) {
        if (mounted) {
          showErrorAlert(Exception('nfcNotAvailable'.tr()));
        }
        return;
      }

      final tag = await NfcScanService().scanTag();
      final uid = tag.id;

      setState(() {
        _scannedUid = uid;
        _scannedTag = tag;
        _uidController.text = uid;
      });
    } catch (e) {
      if (mounted) {
        showErrorAlert(e);
      }
    } finally {
      // Always finish NFC session to prevent iOS session leak
      await NfcScanService().finish();
      if (mounted) {
        setState(() => _isScanning = false);
      }
    }
  }

  Future<void> _registerEncryptedTag() async {
    if (!_formKey.currentState!.validate()) return;
    if (_scannedUid == null) return;

    setState(() => _isSubmitting = true);

    try {
      final client = ref.read(solarNetworkClientProvider);
      await client.dio.post(
        '/passport/admin/nfc/tags',
        data: {
          'uid': _scannedUid,
          'sun_key': _sunKeyController.text.trim(),
          if (_assignedUserIdController.text.trim().isNotEmpty)
            'assigned_user_id': _assignedUserIdController.text.trim(),
        },
      );
      ref.invalidate(physicalPassportsProvider);

      if (!mounted) return;

      Navigator.of(context).pop();
      showSnackBar('encryptedTagRegistered'.tr());
    } catch (e) {
      if (mounted) {
        showErrorAlert(e);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

class _ClaimByUidSheet extends ConsumerStatefulWidget {
  const _ClaimByUidSheet();

  @override
  ConsumerState<_ClaimByUidSheet> createState() => _ClaimByUidSheetState();
}

class _ClaimByUidSheetState extends ConsumerState<_ClaimByUidSheet> {
  final _formKey = GlobalKey<FormState>();
  final _uidController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _uidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SheetScaffold(
      titleText: 'claimEncryptedTag'.tr(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'claimEncryptedTagDescription'.tr(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const Gap(24),
              TextFormField(
                controller: _uidController,
                decoration: InputDecoration(
                  labelText: 'tagUid'.tr(),
                  hintText: 'claimTagUidHint'.tr(),
                  prefixIcon: const Icon(Symbols.tag),
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'tagUidRequired'.tr();
                  }
                  return null;
                },
              ),
              const Gap(32),
              FilledButton.icon(
                onPressed: _isSubmitting ? null : _claimTag,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Symbols.card_membership),
                label: Text('claimTag').tr(),
              ),
              const Gap(16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _claimTag() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final client = ref.read(solarNetworkClientProvider);
      await client.dio.post(
        '/passport/nfc/tags/claim',
        data: {'uid': _uidController.text.trim().toUpperCase()},
      );
      ref.invalidate(physicalPassportsProvider);

      if (!mounted) return;

      Navigator.of(context).pop();
      showSnackBar('tagClaimed'.tr());
    } catch (e) {
      if (mounted) {
        showErrorAlert(e);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

@freezed
sealed class SnScanResult with _$SnScanResult {
  const factory SnScanResult({
    required String id,
    required SnAccount? account,
    @Default(false) bool isFriend,
    @Default(false) bool isClaimed,
    @Default([]) List<String> actions,
  }) = _SnScanResult;

  factory SnScanResult.fromJson(Map<String, dynamic> json) =>
      _$SnScanResultFromJson(json);
}
