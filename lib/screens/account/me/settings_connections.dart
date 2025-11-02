import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/auth.dart';
import 'package:island/pods/config.dart';
import 'package:island/pods/network.dart';
import 'package:island/screens/account/me/account_settings.dart';
import 'package:island/utils/text.dart';
import 'package:island/services/time.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/content/sheet.dart';
import 'package:island/widgets/response.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';

// Helper function to get provider icon and localized name
Widget getProviderIcon(String provider, {double size = 24, Color? color}) {
  final providerLower = provider.toLowerCase();

  // Check if we have an SVG for this provider
  switch (providerLower) {
    case 'apple':
    case 'microsoft':
    case 'google':
    case 'github':
    case 'discord':
    case 'afdian':
      return SvgPicture.asset(
        'assets/images/oidc/$providerLower.svg',
        width: size,
        height: size,
        color: color,
      );
    case 'spotify':
      return Image.asset(
        'assets/images/oidc/spotify.png',
        width: size,
        height: size,
        color: color,
      );
    default:
      return Icon(Symbols.link, size: size);
  }
}

String getLocalizedProviderName(String provider) {
  switch (provider.toLowerCase()) {
    case 'apple':
      return 'accountConnectionProviderApple'.tr();
    case 'microsoft':
      return 'accountConnectionProviderMicrosoft'.tr();
    case 'google':
      return 'accountConnectionProviderGoogle'.tr();
    case 'github':
      return 'accountConnectionProviderGithub'.tr();
    case 'discord':
      return 'accountConnectionProviderDiscord'.tr();
    case 'afdian':
      return 'accountConnectionProviderAfdian'.tr();
    case 'spotify':
      return 'accountConnectionProviderSpotify'.tr();
    default:
      return provider;
  }
}

class AccountConnectionSheet extends HookConsumerWidget {
  final SnAccountConnection connection;
  const AccountConnectionSheet({super.key, required this.connection});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> deleteConnection() async {
      final confirm = await showConfirmAlert(
        'accountConnectionDeleteHint'.tr(),
        'accountConnectionDelete'.tr(),
      );
      if (!confirm || !context.mounted) return;
      try {
        showLoadingModal(context);
        final client = ref.read(apiClientProvider);
        await client.delete('/pass/accounts/me/connections/${connection.id}');
        if (context.mounted) Navigator.pop(context, true);
      } catch (err) {
        showErrorAlert(err);
      } finally {
        if (context.mounted) hideLoadingModal(context);
      }
    }

    return SheetScaffold(
      titleText: 'accountConnections'.tr(),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                getProviderIcon(
                  connection.provider,
                  size: 32,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                const Gap(8),
                Text(getLocalizedProviderName(connection.provider)).tr(),
                const Gap(4),
                if (connection.meta.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final meta in connection.meta.entries)
                        Text(
                          '${meta.key.replaceAll('_', ' ').capitalizeEachWord()}: ${meta.value}',
                          style: const TextStyle(fontSize: 12),
                        ),
                    ],
                  ),
                Text(
                  connection.providedIdentifier,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Gap(8),
                Text(
                  connection.lastUsedAt.formatSystem(),
                  style: Theme.of(context).textTheme.bodySmall,
                ).opacity(0.85),
              ],
            ).padding(all: 20),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Symbols.delete),
              title: Text('accountConnectionDelete').tr(),
              onTap: deleteConnection,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class AccountConnectionNewSheet extends HookConsumerWidget {
  const AccountConnectionNewSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedProvider = useState<String>('apple');

    // List of available providers
    final providers = [
      'apple',
      'microsoft',
      'google',
      'github',
      'discord',
      'afdian',
      'spotify',
    ];

    Future<void> addConnection() async {
      final client = ref.watch(apiClientProvider);

      switch (selectedProvider.value.toLowerCase()) {
        case 'apple':
          try {
            final credential = await SignInWithApple.getAppleIDCredential(
              scopes: [AppleIDAuthorizationScopes.email],
              webAuthenticationOptions: WebAuthenticationOptions(
                clientId: 'dev.solsynth.solarpass',
                redirectUri: Uri.parse('https://solian.app/auth/callback'),
              ),
            );

            if (context.mounted) showLoadingModal(context);

            await client.post(
              '/pass/auth/connect/apple/mobile',
              data: {
                'identity_token': credential.identityToken!,
                'authorization_code': credential.authorizationCode,
              },
            );
            if (context.mounted) {
              showSnackBar('accountConnectionAddSuccess'.tr());
              Navigator.pop(context, true);
            }
          } catch (err) {
            if (err is SignInWithAppleAuthorizationException) return;
            showErrorAlert(err);
          } finally {
            if (context.mounted) hideLoadingModal(context);
          }
        case 'microsoft':
        case 'google':
        case 'github':
        case 'discord':
        case 'afdian':
        case 'spotify':
          final serverUrl = ref.watch(serverUrlProvider);
          final accessToken = ref.watch(tokenProvider);
          launchUrlString(
            '$serverUrl/pass/auth/login/${selectedProvider.value}?tk=${accessToken!.token}',
          );
          if (context.mounted) Navigator.pop(context, true);
          break;
        default:
          showSnackBar('accountConnectionAddError'.tr());
          return;
      }
    }

    return SheetScaffold(
      titleText: 'accountConnectionAdd'.tr(),
      child: SingleChildScrollView(
        child: Column(
          spacing: 16,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: selectedProvider.value,
              decoration: InputDecoration(
                prefixIcon: getProviderIcon(
                  selectedProvider.value,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurface,
                ).padding(all: 16),
                labelText: 'accountConnectionProvider'.tr(),
                border: const OutlineInputBorder(),
              ),
              items:
                  providers.map((String provider) {
                    return DropdownMenuItem<String>(
                      value: provider,
                      child: Row(
                        children: [
                          Text(getLocalizedProviderName(provider)).tr(),
                        ],
                      ),
                    );
                  }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  selectedProvider.value = newValue;
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('accountConnectionDescription'.tr()),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: addConnection,
                  icon: const Icon(Symbols.add),
                  label: Text('next').tr(),
                ),
              ],
            ),
          ],
        ).padding(horizontal: 20, vertical: 24),
      ),
    );
  }
}

class AccountConnectionsSheet extends HookConsumerWidget {
  const AccountConnectionsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connections = ref.watch(accountConnectionsProvider);

    return SheetScaffold(
      titleText: 'accountConnections'.tr(),
      actions: [
        IconButton(
          icon: const Icon(Symbols.add),
          onPressed: () async {
            final result = await showModalBottomSheet<bool>(
              context: context,
              isScrollControlled: true,
              builder: (context) => const AccountConnectionNewSheet(),
            );
            if (result == true) {
              ref.invalidate(accountConnectionsProvider);
            }
          },
        ),
      ],
      child: connections.when(
        data:
            (data) => RefreshIndicator(
              onRefresh:
                  () => Future.sync(
                    () => ref.invalidate(accountConnectionsProvider),
                  ),
              child:
                  data.isEmpty
                      ? Center(
                        child: Text(
                          'accountConnectionsEmpty'.tr(),
                          textAlign: TextAlign.center,
                        ).padding(horizontal: 32),
                      )
                      : ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          final connection = data[index];
                          return Dismissible(
                            key: Key('connection-${connection.id}'),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            confirmDismiss: (direction) async {
                              final confirm = await showConfirmAlert(
                                'accountConnectionDeleteHint'.tr(),
                                'accountConnectionDelete'.tr(),
                              );
                              if (confirm && context.mounted) {
                                try {
                                  final client = ref.read(apiClientProvider);
                                  await client.delete(
                                    '/pass/accounts/me/connections/${connection.id}',
                                  );
                                  ref.invalidate(accountConnectionsProvider);
                                  return true;
                                } catch (err) {
                                  showErrorAlert(err);
                                  return false;
                                }
                              }
                              return false;
                            },
                            child: ListTile(
                              leading: getProviderIcon(
                                connection.provider,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              title:
                                  Text(
                                    getLocalizedProviderName(
                                      connection.provider,
                                    ),
                                  ).tr(),
                              subtitle:
                                  connection.meta['email'] != null
                                      ? Text(connection.meta['email'])
                                      : Text(connection.providedIdentifier),
                              trailing: Text(
                                DateFormat.yMd().format(
                                  connection.lastUsedAt.toLocal(),
                                ),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              onTap: () async {
                                final result = await showModalBottomSheet<bool>(
                                  context: context,
                                  isScrollControlled: true,
                                  builder:
                                      (context) => AccountConnectionSheet(
                                        connection: connection,
                                      ),
                                );
                                if (result == true) {
                                  ref.invalidate(accountConnectionsProvider);
                                }
                              },
                            ),
                          );
                        },
                      ),
            ),
        error:
            (err, _) => ResponseErrorWidget(
              error: err,
              onRetry: () => ref.invalidate(accountConnectionsProvider),
            ),
        loading: () => const ResponseLoadingWidget(),
      ),
    );
  }
}
