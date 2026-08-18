import 'dart:async';
import 'dart:io';

import 'package:ndef/records/well_known/uri.dart';
import 'package:island/accounts/screens/me/account_settings.dart';
import 'package:island/accounts/widgets/account/account_nameplate.dart';
import 'package:island/core/services/nfc_scan_service.dart';
import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/material.dart' as legacy_material;
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:island/shared/hooks/material_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/auth/models/authorize_client_info.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/deeplink_service.dart';
import 'package:island/core/services/event_bus.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:path_provider/path_provider.dart';
import 'package:island/wallets/wallet.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:relative_time/relative_time.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher.dart';

Color _monoInk(ThemeData theme) {
  return theme.brightness == Brightness.dark ? Colors.white : Colors.black;
}

Color _monoSurface(ThemeData theme, double opacity) {
  return Color.alphaBlend(
    _monoInk(theme).withOpacity(opacity),
    theme.colorScheme.surface,
  );
}

@RoutePage()
class AccountQrScreen extends HookConsumerWidget {
  const AccountQrScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userInfoProvider);
    final wallet = ref.watch(walletCurrentProvider);
    final supportsPhysicalPassportScan =
        !kIsWeb && (Platform.isAndroid || Platform.isIOS);
    final theme = Theme.of(context);
    final activeTransferRequest = useState<WalletTransferRequestData?>(null);
    final selectedSection = useState<_QrSectionId?>(_QrSectionId.profile);
    final modeController = useMaterialTabController(initialLength: 3);
    final profileQrShot = useMemoized(ScreenshotController.new);
    final transferQrShot = useMemoized(ScreenshotController.new);

    if (user.value == null) {
      return AppScaffold(
        appBar: AppBar(title: Text('accountQrCodeTitle').tr()),
        body: const SizedBox.shrink(),
      );
    }

    final account = user.value!;
    final profileUrl = 'https://solian.app/accounts/${account.name}';
    final transferWallet = wallet.value;
    final requestData = activeTransferRequest.value;
    final transferQrData = requestData != null
        ? buildWalletTransferRequestShareUrl(requestData.id)
        : transferWallet?.publicId != null
        ? buildWalletTransferQrData(
            publicId: transferWallet!.publicId!,
            displayName: account.nick,
          )
        : null;
    final transferShareLink = requestData != null
        ? buildWalletTransferRequestShareUrl(requestData.id)
        : transferWallet?.publicId != null
        ? buildWalletTransferQrData(
            publicId: transferWallet!.publicId!,
            displayName: account.nick,
          )
        : null;

    Future<void> startTransferFromRequest(String requestId) async {
      try {
        showLoadingModal(context);
        if (context.mounted) hideLoadingModal(context);
        await handleWalletTransferRequestDeepLink(
          context: context,
          ref: ref,
          requestId: requestId,
        );
      } catch (err) {
        if (context.mounted) hideLoadingModal(context);
        showErrorAlert(err);
      }
    }

    Future<void> enableWalletId(String walletId) async {
      try {
        showLoadingModal(context);
        await ref
            .read(solarNetworkClientProvider)
            .wallet
            .enablePublicId(walletId);
        ref.invalidate(walletCurrentProvider);
        ref.invalidate(walletListProvider);
        if (context.mounted) {
          hideLoadingModal(context);
          showSnackBar('walletPublicIdEnabled'.tr());
        }
      } catch (err) {
        if (context.mounted) hideLoadingModal(context);
        showErrorAlert(err);
      }
    }

    Future<void> createTransferRequestFlow(SnWallet wallet) async {
      final draft = await showModalBottomSheet<_TransferRequestDraft>(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        builder: (context) => _TransferRequestSheet(
          walletId: wallet.id,
          walletPublicId: wallet.publicId!,
        ),
      );
      if (draft == null) return;

      try {
        if (!context.mounted) return;
        showLoadingModal(context);
        final request = await createWalletTransferRequest(
          ref,
          amount: draft.amount,
          currency: draft.currency,
          walletId: wallet.id,
          remark: draft.remark,
          expirationHours: draft.expirationHours,
          freeze: draft.freeze,
          requireConfirmation: draft.requireConfirmation,
        );
        activeTransferRequest.value = request;
        if (context.mounted) {
          hideLoadingModal(context);
          showSnackBar('accountQrRequestCreated'.tr());
        }
      } catch (err) {
        if (context.mounted) hideLoadingModal(context);
        showErrorAlert(err);
      }
    }

    Future<Uint8List?> captureQrCard(ScreenshotController controller) async {
      return await controller.capture(
        pixelRatio: MediaQuery.of(context).devicePixelRatio,
      );
    }

    Future<void> shareQrImage(
      ScreenshotController controller, {
      required String fileName,
      String? fallbackText,
    }) async {
      try {
        final bytes = await captureQrCard(controller);
        if (bytes == null) return;

        if (kIsWeb) {
          if (fallbackText != null) {
            await SharePlus.instance.share(ShareParams(text: fallbackText));
          }
          return;
        }

        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/$fileName.png');
        await file.writeAsBytes(bytes, flush: true);
        await Share.shareXFiles([XFile(file.path)]);
      } catch (err) {
        showErrorAlert(err);
      }
    }

    Future<void> saveQrImage(
      ScreenshotController controller, {
      required String fileName,
    }) async {
      try {
        final bytes = await captureQrCard(controller);
        if (bytes == null) return;
        await FileSaver.instance.saveFile(
          name: fileName,
          bytes: bytes,
          fileExtension: 'png',
          mimeType: MimeType.png,
        );
        showSnackBar('accountQrImageSaved'.tr());
      } catch (err) {
        showErrorAlert(err);
      }
    }

    Future<void> openScanner() async {
      final value = await showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        builder: (context) => const _AccountQrScannerSheet(),
      );
      if (value == null || !context.mounted) return;

      final qrChallengeId = parseAuthQrChallengeId(value);
      if (qrChallengeId != null) {
        await handleQrLoginChallengeScan(
          context: context,
          ref: ref,
          qrChallengeId: qrChallengeId,
        );
        return;
      }

      final requestId = parseWalletTransferRequestId(value);
      if (requestId != null) {
        await startTransferFromRequest(requestId);
        return;
      }

      final transferPayload = parseWalletTransferQrPayload(value);
      if (transferPayload != null) {
        await handleWalletTransferPayloadDeepLink(
          context: context,
          ref: ref,
          payload: transferPayload,
        );
        return;
      }

      // ponytail: matches /auth/device?code=XXXX-XXXX from the doc
      final deviceCode = _parseDeviceAuthUserCode(value);
      if (deviceCode != null) {
        await _checkAndShowDeviceApproval(context, ref, deviceCode);
        return;
      }

      final target = _resolveScannedAccountName(value);
      if (target != null) {
        await context.router.push(AccountProfileRoute(name: target));
        return;
      }

      final uri = Uri.tryParse(value);
      if (uri != null && solianLinkToRoutePath(uri) != null) {
        eventBus.fire(SolianDeepLinkEvent(uri));
        return;
      }

      if (uri != null && (uri.hasScheme || uri.hasAuthority)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }

      showSnackBar('accountQrScanUnsupported'.tr());
    }

    Future<void> openNfcScanner() async {
      if (!supportsPhysicalPassportScan) return;
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        builder: (context) => const _PhysicalPassportScanSheet(),
      );
    }

    Widget buildProfileMode() {
      return Screenshot(
        controller: profileQrShot,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _QrPanel(
              data: profileUrl,
              theme: theme,
              embedImage: account.profilePicture != null
                  ? CloudImageWidget.provider(
                      file: account.profilePicture!,
                      serverUrl: ref.watch(serverUrlProvider),
                    )
                  : null,
            ),
            const Gap(16),
            Row(
              spacing: 12,
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: () => shareQrImage(
                      profileQrShot,
                      fileName: 'profile-qr',
                      fallbackText: profileUrl,
                    ),
                    icon: const Icon(Symbols.share),
                    label: Text('share').tr(),
                  ),
                ),
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: () =>
                        saveQrImage(profileQrShot, fileName: 'profile-qr'),
                    icon: const Icon(Symbols.download),
                    label: Text('save').tr(),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    Widget buildTransferMode() {
      return Screenshot(
        controller: transferQrShot,
        child: wallet.when(
          data: (currentWallet) {
            if (currentWallet == null) {
              return _TransferUnavailableCard(
                theme: theme,
                onOpenWallet: () => context.router.push(const WalletRoute()),
                messageKey: 'accountQrWalletUnavailable',
              );
            }
            if (currentWallet.publicId == null) {
              return _TransferUnavailableCard(
                theme: theme,
                onOpenWallet: () => context.router.push(const WalletRoute()),
                onEnableWalletId: () => enableWalletId(currentWallet.id),
                messageKey: 'accountQrTransferUnavailable',
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (transferQrData != null)
                  _QrPanel(
                    data: transferQrData,
                    theme: theme,
                    embedImage: const AssetImage('assets/icons/icon.webp'),
                  ),
                const Gap(16),
                _QrDataStrip(
                  label: activeTransferRequest.value != null
                      ? 'accountQrTransferRequestLabel'.tr()
                      : 'walletPublicId'.tr(),
                  value: activeTransferRequest.value != null
                      ? transferShareLink!
                      : currentWallet.publicId!,
                  detail: activeTransferRequest.value != null
                      ? 'accountQrTransferRequestSummary'.tr(
                          namedArgs: {
                            'amount': activeTransferRequest.value!.amount
                                .toStringAsFixed(2),
                            'currency': activeTransferRequest.value!.currency,
                            'expiry': DateFormat.yMd().add_Hm().format(
                              activeTransferRequest.value!.expiresAt,
                            ),
                          },
                        )
                      : null,
                ),
                const Gap(16),
                FilledButton.icon(
                  onPressed: () => createTransferRequestFlow(currentWallet),
                  icon: const Icon(Symbols.request_quote),
                  label: Text(
                    activeTransferRequest.value != null
                        ? 'accountQrRequestRefresh'.tr()
                        : 'accountQrRequestCreate'.tr(),
                  ),
                ),
                if (activeTransferRequest.value != null)
                  OutlinedButton.icon(
                    onPressed: () => activeTransferRequest.value = null,
                    icon: const Icon(Symbols.qr_code_2),
                    label: Text('accountQrRequestClear').tr(),
                  ).padding(top: 12),
              ],
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator.adaptive()),
          ),
          error: (_, _) => _TransferUnavailableCard(
            theme: theme,
            onOpenWallet: () => context.router.push(const WalletRoute()),
            messageKey: 'accountQrTransferUnavailable',
          ),
        ),
      );
    }

    final modeContent = switch (selectedSection.value) {
      _QrSectionId.profile => buildProfileMode(),
      _QrSectionId.transfer => buildTransferMode(),
      _QrSectionId.deviceAuth => const _DeviceAuthSection(),
      null => buildProfileMode(),
    };

    return AppScaffold(
      appBar: AppBar(
        title: Text('accountQrCodeTitle').tr(),
        leading: const AutoLeadingButton(),
        actions: [
          if (supportsPhysicalPassportScan)
            IconButton(
              onPressed: openNfcScanner,
              tooltip: 'scanPhysicalPassport'.tr(),
              icon: const Icon(Symbols.nfc),
            ),
          IconButton(
            onPressed: openScanner,
            tooltip: 'accountQrScannerTitle'.tr(),
            icon: const Icon(Symbols.qr_code_scanner),
          ),
          const Gap(8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          _QrIdentityHero(
            account: account,
            profileUrl: profileUrl,
            theme: theme,
          ),
          const Gap(20),
          _QrModeTabBar(
            controller: modeController,
            transferLabel: activeTransferRequest.value != null
                ? 'accountQrTransferRequestSectionTitle'.tr()
                : 'accountQrTransferSectionTitle'.tr(),
            onTap: (index) {
              selectedSection.value = _QrSectionId.values[index];
            },
          ),
          const Gap(16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: KeyedSubtree(
              key: ValueKey(selectedSection.value),
              child: _QrContentFrame(
                title: switch (selectedSection.value) {
                  _QrSectionId.profile => 'accountQrProfileSectionTitle'.tr(),
                  _QrSectionId.transfer =>
                    activeTransferRequest.value != null
                        ? 'accountQrTransferRequestSectionTitle'.tr()
                        : 'accountQrTransferSectionTitle'.tr(),
                  _QrSectionId.deviceAuth =>
                    'accountQrDeviceAuthSectionTitle'.tr(),
                  null => 'accountQrProfileSectionTitle'.tr(),
                },
                subtitle: switch (selectedSection.value) {
                  _QrSectionId.profile => 'accountQrCodeHint'.tr(),
                  _QrSectionId.transfer =>
                    activeTransferRequest.value != null
                        ? 'accountQrTransferRequestHint'.tr()
                        : 'accountQrTransferHint'.tr(),
                  _QrSectionId.deviceAuth => 'accountQrDeviceAuthHint'.tr(),
                  null => 'accountQrCodeHint'.tr(),
                },
                child: modeContent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QrIdentityHero extends StatelessWidget {
  final SnAccount account;
  final String profileUrl;
  final ThemeData theme;

  const _QrIdentityHero({
    required this.account,
    required this.profileUrl,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final hasBackground = account.profile.background != null;
    final ink = hasBackground ? Colors.white : _monoInk(theme);
    final heroColor = _monoSurface(theme, 0.08);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        color: heroColor,
        child: Stack(
          children: [
            if (hasBackground)
              Positioned.fill(
                child: CloudImageWidget(
                  file: account.profile.background!,
                  fit: BoxFit.cover,
                  imageOnly: true,
                ),
              ),
            if (hasBackground)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.12),
                        Colors.black.withOpacity(0.78),
                      ],
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Symbols.qr_code_2, size: 20, color: ink),
                      const Gap(8),
                      Text(
                        'Solarpass',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: ink.withOpacity(0.82),
                          letterSpacing: 1.6,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      Icon(Symbols.verified_user, size: 18, color: ink),
                    ],
                  ),
                  const Gap(48),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (account.profile.picture != null)
                        ClipOval(
                          child: SizedBox(
                            width: 52,
                            height: 52,
                            child: CloudImageWidget(
                              file: account.profile.picture!,
                              fit: BoxFit.cover,
                              imageOnly: true,
                            ),
                          ),
                        ),
                      if (account.profile.picture != null) const Gap(12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              account.nick,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: ink,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const Gap(3),
                            Text(
                              '@${account.name}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: ink.withOpacity(0.72),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Gap(18),
                  Row(
                    children: [
                      Icon(
                        Symbols.link,
                        size: 16,
                        color: ink.withOpacity(0.82),
                      ),
                      const Gap(8),
                      Expanded(
                        child: Text(
                          profileUrl,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: ink.withOpacity(0.78),
                            fontFamily: 'monospace',
                          ),
                        ),
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

class _QrModeTabBar extends StatelessWidget {
  final TabController controller;
  final String transferLabel;
  final ValueChanged<int> onTap;

  const _QrModeTabBar({
    required this.controller,
    required this.transferLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ink = _monoInk(theme);

    return Material(
      color: _monoSurface(theme, 0.06),
      borderRadius: BorderRadius.circular(16),
      child: TabBar(
        controller: controller,
        onTap: onTap,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: _monoSurface(theme, 0.14),
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: ink,
        unselectedLabelColor: ink.withOpacity(0.58),
        labelStyle: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: theme.textTheme.labelLarge,
        padding: const EdgeInsets.all(4),
        tabs: [
          Tab(
            icon: const Icon(Symbols.person, size: 18),
            text: 'accountQrProfileSectionTitle'.tr(),
          ),
          Tab(
            icon: const Icon(Symbols.swap_horiz, size: 18),
            text: transferLabel,
          ),
          Tab(
            icon: const Icon(Symbols.phonelink_lock, size: 18),
            text: 'accountQrDeviceAuthSectionTitle'.tr(),
          ),
        ],
      ),
    );
  }
}

class _QrContentFrame extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _QrContentFrame({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ink = _monoInk(theme);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      decoration: BoxDecoration(
        color: _monoSurface(theme, 0.045),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ink.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const Gap(4),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: ink.withOpacity(0.62),
            ),
          ),
          const Gap(18),
          child,
        ],
      ),
    );
  }
}

class _QrDataStrip extends StatelessWidget {
  final String label;
  final String value;
  final String? detail;

  const _QrDataStrip({required this.label, required this.value, this.detail});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ink = _monoInk(theme);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _monoSurface(theme, 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: ink.withOpacity(0.62),
            ),
          ),
          const Gap(6),
          SelectableText(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              color: ink,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
            ),
          ),
          if (detail != null) ...[
            const Gap(10),
            Text(
              detail!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: ink.withOpacity(0.62),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QrPanel extends StatelessWidget {
  final String data;
  final ImageProvider<Object>? embedImage;
  final ThemeData theme;

  const _QrPanel({required this.data, required this.theme, this.embedImage});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
        ),
        child: QrImageView(
          data: data,
          version: QrVersions.auto,
          size: 240,
          embeddedImage: embedImage,
          embeddedImageStyle: QrEmbeddedImageStyle(size: Size(40, 40)),
          errorCorrectionLevel: QrErrorCorrectLevel.H,
          eyeStyle: QrEyeStyle(
            eyeShape: QrEyeShape.circle,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          dataModuleStyle: QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.circle,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          backgroundColor: theme.colorScheme.surface,
        ),
      ),
    );
  }
}

enum _QrSectionId { profile, transfer, deviceAuth }

class _TransferUnavailableCard extends StatelessWidget {
  final ThemeData theme;
  final VoidCallback onOpenWallet;
  final VoidCallback? onEnableWalletId;
  final String messageKey;

  const _TransferUnavailableCard({
    required this.theme,
    required this.onOpenWallet,
    required this.messageKey,
    this.onEnableWalletId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'accountQrTransferSectionTitle'.tr(),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const Gap(6),
        Text(
          messageKey.tr(),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const Gap(20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            if (onEnableWalletId != null)
              FilledButton.icon(
                onPressed: onEnableWalletId,
                icon: const Icon(Symbols.credit_card_heart),
                label: Text('accountQrEnableWalletId').tr(),
              ),
            FilledButton.tonalIcon(
              onPressed: onOpenWallet,
              icon: const Icon(Symbols.account_balance_wallet),
              label: Text('accountQrOpenWallet').tr(),
            ),
          ],
        ),
      ],
    );
  }
}

class _TransferRequestDraft {
  final double amount;
  final String currency;
  final String? remark;
  final int expirationHours;
  final bool freeze;
  final bool requireConfirmation;

  const _TransferRequestDraft({
    required this.amount,
    required this.currency,
    required this.expirationHours,
    required this.freeze,
    required this.requireConfirmation,
    this.remark,
  });
}

class _TransferRequestSheet extends StatefulWidget {
  final String walletId;
  final String walletPublicId;

  const _TransferRequestSheet({
    required this.walletId,
    required this.walletPublicId,
  });

  @override
  State<_TransferRequestSheet> createState() => _TransferRequestSheetState();
}

class _TransferRequestSheetState extends State<_TransferRequestSheet> {
  final amountController = TextEditingController();
  final remarkController = TextEditingController();
  String selectedCurrency = 'golds';
  int expirationHours = 24;
  bool freeze = false;
  bool requireConfirmation = false;

  String _formatExpiryLabel(int hours) {
    return hours == 1 ? '1 hour' : '$hours hours';
  }

  @override
  void dispose() {
    amountController.dispose();
    remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dropdownDecoration = legacy_material.InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 14),
      border: legacy_material.OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
    final dropdownButtonStyle = const FormFieldButtonStyleData(height: 24);
    final dropdownMenuStyle = MenuItemStyleData(
      // padding: EdgeInsets.zero,
      overlayColor: WidgetStatePropertyAll(_monoInk(theme).withOpacity(0.08)),
    );
    final dropdownPopupStyle = DropdownStyleData(
      maxHeight: 240,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
    );

    return SheetScaffold(
      titleText: 'accountQrRequestCreate'.tr(),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16,
                children: [
                  Text(
                    'accountQrRequestSheetHint'.tr(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                    decoration: InputDecoration(
                      labelText: 'transferAmount'.tr(),
                      hintText: '0.00',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  DropdownButtonFormField2<String>(
                    isExpanded: true,
                    valueListenable: ValueNotifier(selectedCurrency),
                    decoration: dropdownDecoration.copyWith(
                      labelText: 'currency'.tr(),
                    ),
                    items: kCurrencyIconData.keys.map((currency) {
                      return DropdownItem(
                        value: currency,
                        child: Text(
                          'walletCurrency${currency[0].toUpperCase()}${currency.substring(1).toLowerCase()}'
                              .tr(),
                        ).padding(right: 8),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedCurrency = value);
                      }
                    },
                    buttonStyleData: dropdownButtonStyle,
                    menuItemStyleData: dropdownMenuStyle,
                    dropdownStyleData: dropdownPopupStyle,
                  ),
                  TextField(
                    controller: remarkController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      alignLabelWithHint: true,
                      labelText: 'transferRemark'.tr(),
                      hintText: 'addRemarkForTransfer'.tr(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  DropdownButtonFormField2<int>(
                    isExpanded: true,
                    valueListenable: ValueNotifier(expirationHours),
                    decoration: dropdownDecoration.copyWith(
                      labelText: 'accountQrRequestExpiry'.tr(),
                    ),
                    items: const [1, 6, 24, 72, 168].map((hours) {
                      return DropdownItem(
                        value: hours,
                        child: Text(
                          _formatExpiryLabel(hours),
                        ).padding(right: 8),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => expirationHours = value);
                      }
                    },
                    buttonStyleData: dropdownButtonStyle,
                    menuItemStyleData: dropdownMenuStyle,
                    dropdownStyleData: dropdownPopupStyle,
                  ),
                  SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    title: Text('freezeTransfer'.tr()),
                    subtitle: Text('freezeTransferHint'.tr()),
                    value: freeze,
                    onChanged: (value) {
                      setState(() => freeze = value);
                    },
                  ),
                  SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    title: Text('requireConfirmation'.tr()),
                    subtitle: Text('requireConfirmationHint'.tr()),
                    value: requireConfirmation,
                    onChanged: (value) {
                      setState(() => requireConfirmation = value);
                    },
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('cancel'.tr()),
                  ),
                ),
                const Gap(12),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: () {
                      final amount = double.tryParse(amountController.text);
                      if (amount == null || amount <= 0) {
                        showErrorAlert('invalidAmount'.tr());
                        return;
                      }

                      Navigator.of(context).pop(
                        _TransferRequestDraft(
                          amount: amount,
                          currency: selectedCurrency,
                          remark: remarkController.text.trim().isEmpty
                              ? null
                              : remarkController.text.trim(),
                          expirationHours: expirationHours,
                          freeze: freeze,
                          requireConfirmation: requireConfirmation,
                        ),
                      );
                    },
                    child: Text('accountQrRequestCreate').tr(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountQrScannerSheet extends StatefulWidget {
  const _AccountQrScannerSheet();

  @override
  State<_AccountQrScannerSheet> createState() => _AccountQrScannerSheetState();
}

class _AccountQrScannerSheetState extends State<_AccountQrScannerSheet> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );
  bool _hasScanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_hasScanned) return;

    for (final barcode in capture.barcodes) {
      final code = barcode.rawValue;
      if (code != null && code.isNotEmpty) {
        setState(() => _hasScanned = true);
        await _controller.stop();
        if (!mounted) return;
        Navigator.of(context).pop(code);
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SheetScaffold(
      titleText: 'accountQrScannerTitle'.tr(),
      heightFactor: 0.88,
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    MobileScanner(controller: _controller, onDetect: _onDetect),
                    Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _monoInk(theme).withOpacity(0.84),
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      child: Row(
                        children: [
                          IconButton.filledTonal(
                            onPressed: () => _controller.toggleTorch(),
                            icon: ValueListenableBuilder(
                              valueListenable: _controller,
                              builder: (context, state, child) {
                                return Icon(
                                  state.torchState == TorchState.on
                                      ? Symbols.flashlight_on
                                      : Symbols.flashlight_off,
                                );
                              },
                            ),
                          ),
                          const Gap(16),
                          IconButton.filledTonal(
                            onPressed: () => _controller.switchCamera(),
                            icon: const Icon(Symbols.cameraswitch),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Gap(24),
        ],
      ),
    );
  }
}

String? _parseDeviceAuthUserCode(String rawValue) {
  final value = rawValue.trim();
  if (value.isEmpty) return null;

  // Direct user code: XXXX-XXXX
  final codePattern = RegExp(r'^[A-Z]{4}-[A-Z]{4}$');
  if (codePattern.hasMatch(value.toUpperCase())) {
    return value.toUpperCase();
  }

  // Verification URI with code param: /auth/device?code=XXXX-XXXX
  final uri = Uri.tryParse(value);
  if (uri != null) {
    final code = uri.queryParameters['code'];
    if (code != null && codePattern.hasMatch(code.toUpperCase())) {
      return code.toUpperCase();
    }
  }

  return null;
}

String? _resolveScannedAccountName(String rawValue) {
  final value = rawValue.trim();
  if (value.isEmpty) return null;

  final uri = Uri.tryParse(value);
  if (uri != null) {
    final segments = uri.pathSegments;
    final isSolianHost =
        uri.host == 'solian.app' || uri.host.endsWith('.solian.app');
    if (isSolianHost && segments.length >= 2 && segments.first == 'accounts') {
      final name = segments[1].trim();
      return name.isEmpty ? null : name;
    }
  }

  if (!value.contains(' ') && !value.contains('/') && !value.contains('@')) {
    return value;
  }

  return null;
}

String _qrLoginStatusName(int status) {
  return switch (status) {
    1 => 'loginQrCodeStatusScanned'.tr(),
    2 => 'loginQrCodeStatusApproved'.tr(),
    3 => 'loginQrCodeStatusDeclined'.tr(),
    4 => 'expired'.tr(),
    _ => 'loginQrCodeStatusPending'.tr(),
  };
}

IconData _qrLoginPlatformIcon(int? platform) {
  return switch (platform) {
    2 => Symbols.phone_iphone,
    3 => Symbols.phone_android,
    4 || 5 || 6 => Symbols.computer,
    1 => Symbols.language,
    _ => Symbols.devices,
  };
}

String _qrLoginPlatformName(int? platform) {
  return switch (platform) {
    2 => 'platformIos'.tr(),
    3 => 'platformAndroid'.tr(),
    4 => 'platformMacos'.tr(),
    5 => 'platformWindows'.tr(),
    6 => 'platformLinux'.tr(),
    1 => 'platformWeb'.tr(),
    _ => 'platformUnknown'.tr(),
  };
}

class _QrLoginChallengeSnapshot {
  final String qrChallengeId;
  final String authChallengeId;
  final int status;
  final DateTime expiresAt;
  final String? deviceName;
  final int? platform;

  const _QrLoginChallengeSnapshot({
    required this.qrChallengeId,
    required this.authChallengeId,
    required this.status,
    required this.expiresAt,
    this.deviceName,
    this.platform,
  });

  factory _QrLoginChallengeSnapshot.fromJson(Map<String, dynamic> json) {
    return _QrLoginChallengeSnapshot(
      qrChallengeId: json['qr_challenge_id'] as String,
      authChallengeId: json['auth_challenge_id'] as String,
      status: switch (json['status']) {
        num value => value.toInt(),
        String value => switch (value.toLowerCase()) {
          'scanned' => 1,
          'approved' => 2,
          'declined' => 3,
          'expired' => 4,
          _ => 0,
        },
        _ => 0,
      },
      expiresAt: DateTime.parse(json['expires_at'] as String),
      deviceName: json['device_name'] as String?,
      platform: (json['platform'] as num?)?.toInt(),
    );
  }
}

Future<void> handleQrLoginChallengeScan({
  required BuildContext context,
  required WidgetRef ref,
  required String qrChallengeId,
}) async {
  try {
    showLoadingModal(context);
    final client = ref.read(solarNetworkClientProvider);

    try {
      await client.dio.post('/stargate/auth/qr/$qrChallengeId/scan');
    } on DioException catch (err) {
      if (!{400, 409}.contains(err.response?.statusCode)) rethrow;
    }

    final snapshotResp = await client.dio.get(
      '/stargate/auth/qr/$qrChallengeId',
    );
    final snapshot = _QrLoginChallengeSnapshot.fromJson(
      Map<String, dynamic>.from(snapshotResp.data as Map),
    );

    SnAuthChallenge? challenge;
    try {
      final challengeResp = await client.dio.get(
        '/stargate/auth/challenge/${snapshot.authChallengeId}',
      );
      challenge = SnAuthChallenge.fromJson(
        Map<String, dynamic>.from(challengeResp.data as Map),
      );
    } on DioException {
      challenge = null;
    }

    if (!context.mounted) return;
    hideLoadingModal(context);
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => _QrLoginApprovalSheet(
        qrChallengeId: qrChallengeId,
        snapshot: snapshot,
        challenge: challenge,
      ),
    );
  } catch (err) {
    if (context.mounted) hideLoadingModal(context);
    showErrorAlert(err);
  }
}

class _QrLoginApprovalSheet extends HookConsumerWidget {
  final String qrChallengeId;
  final _QrLoginChallengeSnapshot snapshot;
  final SnAuthChallenge? challenge;

  const _QrLoginApprovalSheet({
    required this.qrChallengeId,
    required this.snapshot,
    required this.challenge,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final ink = _monoInk(theme);
    final isBusy = useState(false);
    final remaining = useState<int?>(null);

    useEffect(() {
      void syncRemaining() {
        final diff = snapshot.expiresAt.difference(DateTime.now()).inSeconds;
        remaining.value = diff > 0 ? diff : 0;
      }

      syncRemaining();
      final timer = Timer.periodic(const Duration(seconds: 1), (_) {
        syncRemaining();
      });
      return timer.cancel;
    }, [snapshot.qrChallengeId]);

    final expired = remaining.value != null && remaining.value! <= 0;
    final currentChallenge = challenge;
    final deviceName =
        currentChallenge?.deviceName ??
        snapshot.deviceName ??
        'unknownDevice'.tr();
    final platform = _qrLoginPlatformName(
      currentChallenge?.platform ?? snapshot.platform,
    );

    Future<void> resolveQrLogin(bool approve) async {
      isBusy.value = true;
      try {
        final client = ref.read(solarNetworkClientProvider);
        await client.dio.post(
          '/stargate/auth/qr/$qrChallengeId/${approve ? 'approve' : 'decline'}',
        );
        if (!context.mounted) return;
        showSnackBar(
          approve
              ? 'qrLoginApprovedByYou'.tr(args: [deviceName])
              : 'qrLoginDeclinedByYou'.tr(args: [deviceName]),
        );
        Navigator.of(context).pop();
      } catch (err) {
        showErrorAlert(err);
      } finally {
        isBusy.value = false;
      }
    }

    return SheetScaffold(
      titleText: 'qrLoginApprovalTitle'.tr(),
      heightFactor: 0.82,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: _monoSurface(theme, 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _qrLoginPlatformIcon(
                                  currentChallenge?.platform ??
                                      snapshot.platform,
                                ),
                                color: ink.withOpacity(0.84),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    deviceName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  const Gap(2),
                                  Text(
                                    platform,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _DetailRow(
                        icon: Symbols.info,
                        label: 'loginQrCodeStatusLabel'.tr(),
                        value: _qrLoginStatusName(snapshot.status),
                      ),
                      _DetailRow(
                        icon: Symbols.language,
                        label: 'challengeIpAddress'.tr(),
                        value: currentChallenge?.ipAddress,
                      ),
                      if (currentChallenge != null)
                        _DetailRow(
                          icon: Symbols.schedule,
                          label: 'challengeRequested'.tr(),
                          value: RelativeTime(
                            context,
                          ).format(currentChallenge.createdAt),
                        ),
                      if (remaining.value != null)
                        _DetailRow(
                          icon: Symbols.timer,
                          label: 'challengeExpiresIn'.tr(),
                          value: expired
                              ? 'expired'.tr()
                              : 'challengeSeconds'.tr(
                                  args: ['${remaining.value}'],
                                ),
                          valueColor: expired
                              ? Theme.of(context).colorScheme.error
                              : null,
                        ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _monoSurface(theme, 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: ink.withOpacity(0.16)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Symbols.info,
                              size: 20,
                              color: ink.withOpacity(0.84),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'qrLoginApprovalDescription'.tr(),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Gap(16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: isBusy.value || expired
                          ? null
                          : () => resolveQrLogin(false),
                      icon: const Icon(Symbols.close),
                      label: Text('decline').tr(),
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: isBusy.value || expired
                          ? null
                          : () => resolveQrLogin(true),
                      icon: isBusy.value
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Symbols.check),
                      label: Text('approve').tr(),
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

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value!,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: valueColor ?? theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> handleWalletTransferRequestDeepLink({
  required BuildContext context,
  required WidgetRef ref,
  required String requestId,
}) async {
  final request = await getWalletTransferRequest(ref, requestId);
  if (!context.mounted) return;

  final result = await showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (context) => CreateTransferSheet(
      initialTransferRequestId: request.id,
      initialPayeePublicId: request.payeePublicId,
      initialCurrency: request.currency,
      initialAmount: request.amount,
      initialRemark: request.remark,
      initialFreezeTransfer: request.freeze,
      initialRequireConfirmation: request.requireConfirmation,
      lockPayee: true,
      lockAmount: true,
      lockCurrency: true,
      lockRemark: request.remark != null,
      hideTransferOptions: true,
    ),
  );

  if (result != null && context.mounted) {
    await submitWalletTransfer(context, ref, result);
  }
}

Future<void> _openDeviceAuthFlow(BuildContext context, WidgetRef ref) async {
  final codeController = TextEditingController();
  final userCode = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    builder: (context) => SheetScaffold(
      titleText: 'accountQrDeviceAuthEnterCode'.tr(),
      heightFactor: 0.5,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'accountQrDeviceAuthEnterCodeHint'.tr(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const Gap(16),
            TextField(
              controller: codeController,
              textCapitalization: TextCapitalization.characters,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'accountQrDeviceAuthUserCode'.tr(),
                hintText: 'XXXX-XXXX',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const Spacer(),
            FilledButton(
              onPressed: () {
                final code = codeController.text.trim();
                if (code.isNotEmpty) Navigator.of(context).pop(code);
              },
              child: Text('accountQrDeviceAuthCheck').tr(),
            ),
          ],
        ),
      ),
    ),
  );
  codeController.dispose();
  if (userCode == null || !context.mounted) return;
  await _checkAndShowDeviceApproval(context, ref, userCode);
}

Future<void> _checkAndShowDeviceApproval(
  BuildContext context,
  WidgetRef ref,
  String userCode,
) async {
  try {
    showLoadingModal(context);
    final client = ref.read(solarNetworkClientProvider);
    final resp = await client.dio.get(
      '/stargate/auth/open/device/code/${Uri.encodeComponent(userCode)}',
    );
    final data = Map<String, dynamic>.from(resp.data as Map);
    final clientId =
        data['clientId'] as String? ?? data['client_id'] as String?;
    if (clientId == null || clientId.isEmpty) {
      throw StateError('Invalid device code');
    }
    final clientInfo = AuthorizeClientInfo.fromJson(data);
    if (context.mounted) hideLoadingModal(context);
    if (!context.mounted) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => _DeviceAuthApprovalSheet(
        userCode: userCode,
        clientInfo: clientInfo,
        status: data['status'] as String? ?? 'pending',
        expiresAt: data['expires_at'] != null
            ? DateTime.parse(data['expires_at'] as String)
            : null,
      ),
    );
  } on DioException catch (err) {
    if (context.mounted) hideLoadingModal(context);
    if (err.response?.statusCode == 404) {
      showErrorAlert('accountQrDeviceAuthInvalidCode'.tr());
    } else {
      showErrorAlert(err);
    }
  } catch (err) {
    if (context.mounted) hideLoadingModal(context);
    showErrorAlert(err);
  }
}

class _DeviceAuthSection extends HookConsumerWidget {
  const _DeviceAuthSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'accountQrDeviceAuthDescription'.tr(),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const Gap(16),
        FilledButton.icon(
          onPressed: () => _openDeviceAuthFlow(context, ref),
          icon: const Icon(Symbols.vpn_key),
          label: Text('accountQrDeviceAuthEnterCode').tr(),
        ),
      ],
    );
  }
}

class _DeviceAuthApprovalSheet extends HookConsumerWidget {
  final String userCode;
  final AuthorizeClientInfo clientInfo;
  final String status;
  final DateTime? expiresAt;

  const _DeviceAuthApprovalSheet({
    required this.userCode,
    required this.clientInfo,
    required this.status,
    this.expiresAt,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final ink = _monoInk(theme);
    final picture = clientInfo.picture;
    final isBusy = useState(false);
    final remaining = useState<int?>(null);
    final resolved = useState<String?>(status);

    useEffect(() {
      if (expiresAt == null) return null;
      void sync() {
        final diff = expiresAt!.difference(DateTime.now()).inSeconds;
        remaining.value = diff > 0 ? diff : 0;
      }

      sync();
      final timer = Timer.periodic(const Duration(seconds: 1), (_) => sync());
      return timer.cancel;
    }, [userCode]);

    final expired = remaining.value != null && remaining.value! <= 0;
    final alreadyResolved =
        resolved.value == 'approved' ||
        resolved.value == 'declined' ||
        resolved.value == 'expired';

    Future<void> resolve(bool approve) async {
      isBusy.value = true;
      try {
        final client = ref.read(solarNetworkClientProvider);
        await client.dio.post(
          '/stargate/auth/open/device/code/${Uri.encodeComponent(userCode)}/${approve ? 'approve' : 'decline'}',
        );
        resolved.value = approve ? 'approved' : 'declined';
        if (!context.mounted) return;
        showSnackBar(
          approve
              ? 'accountQrDeviceAuthApproved'.tr()
              : 'accountQrDeviceAuthDeclined'.tr(),
        );
      } catch (err) {
        showErrorAlert(err);
      } finally {
        isBusy.value = false;
      }
    }

    return SheetScaffold(
      titleText: 'accountQrDeviceAuthApprovalTitle'.tr(),
      heightFactor: 0.75,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: _monoSurface(theme, 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: picture != null
                                    ? Image(
                                        image: CloudImageWidget.provider(
                                          file: picture,
                                          serverUrl: ref.watch(
                                            serverUrlProvider,
                                          ),
                                        ),
                                        fit: BoxFit.cover,
                                      )
                                    : Icon(
                                        Symbols.extension,
                                        color: ink.withOpacity(0.84),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    clientInfo.clientName,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  const Gap(2),
                                  Text(
                                    userCode,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (clientInfo.homeUri != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            clientInfo.homeUri!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: ink.withOpacity(0.72),
                            ),
                          ),
                        ),
                      if (clientInfo.description != null) ...[
                        Text(
                          clientInfo.description!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (clientInfo.scopes.isNotEmpty) ...[
                        _DetailRow(
                          icon: Symbols.shield,
                          label: 'accountQrDeviceAuthScopes'.tr(),
                          value: clientInfo.scopes.join(', '),
                        ),
                      ],
                      _DetailRow(
                        icon: Symbols.info,
                        label: 'loginQrCodeStatusLabel'.tr(),
                        value: resolved.value ?? status,
                      ),
                      if (remaining.value != null)
                        _DetailRow(
                          icon: Symbols.timer,
                          label: 'challengeExpiresIn'.tr(),
                          value: expired
                              ? 'expired'.tr()
                              : 'challengeSeconds'.tr(
                                  args: ['${remaining.value}'],
                                ),
                          valueColor: expired ? theme.colorScheme.error : null,
                        ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _monoSurface(theme, 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: ink.withOpacity(0.16)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Symbols.info,
                              size: 20,
                              color: ink.withOpacity(0.84),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'accountQrDeviceAuthApprovalHint'.tr(),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Gap(16),
              if (!alreadyResolved && !expired)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: isBusy.value ? null : () => resolve(false),
                        icon: const Icon(Symbols.close),
                        label: Text('decline').tr(),
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: isBusy.value ? null : () => resolve(true),
                        icon: isBusy.value
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Symbols.check),
                        label: Text('approve').tr(),
                      ),
                    ),
                  ],
                )
              else
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('done').tr(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> handleWalletTransferPayloadDeepLink({
  required BuildContext context,
  required WidgetRef ref,
  required WalletTransferQrPayload payload,
}) async {
  final result = await showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (context) => CreateTransferSheet(
      initialPayeePublicId: payload.publicId,
      initialPayeeName: payload.displayName,
      initialCurrency: payload.currency,
      initialAmount: payload.amount,
      initialRemark: payload.remark,
      lockPayee: true,
    ),
  );

  if (result != null && context.mounted) {
    await submitWalletTransfer(context, ref, result);
  }
}

class _PhysicalPassportScanSheet extends ConsumerStatefulWidget {
  const _PhysicalPassportScanSheet();

  @override
  ConsumerState<_PhysicalPassportScanSheet> createState() =>
      _PhysicalPassportScanSheetState();
}

class _PhysicalPassportScanSheetState
    extends ConsumerState<_PhysicalPassportScanSheet> {
  bool _isScanning = false;
  SnScanResult? _scanResult;
  String? _error;
  String? _scannedUid; // For claim flow
  bool _isClaiming = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SheetScaffold(
      heightFactor: 0.5,
      titleText: 'scanPhysicalPassport'.tr(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_scanResult == null)
              ...([
                Text(
                  'scanPhysicalPassportDescription'.tr(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const Gap(24),
              ]),
            if (_scanResult == null) ...[
              FilledButton.tonalIcon(
                onPressed: _isScanning ? null : _scanPassport,
                icon: _isScanning
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Symbols.nfc),
                label: Text(
                  _isScanning
                      ? 'scanning'.tr()
                      : 'scanPhysicalPassportButton'.tr(),
                ),
              ),
              if (_error != null) ...[
                const Gap(16),
                Card(
                  elevation: 0,
                  color: colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Symbols.error,
                          color: colorScheme.onErrorContainer,
                          size: 20,
                        ),
                        const Gap(8),
                        Expanded(
                          child: Text(
                            _error!,
                            style: TextStyle(
                              color: colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ] else ...[
              _PhysicalPassportScanResultCard(
                passport: _scanResult!,
                onScanAgain: () {
                  setState(() {
                    _scanResult = null;
                    _error = null;
                    _scannedUid = null;
                  });
                },
              ),
              if (_scanResult!.actions.contains("claim_tag") &&
                  _scannedUid != null) ...[
                const Gap(8),
                FilledButton.icon(
                  onPressed: (_isScanning || _isClaiming)
                      ? null
                      : () => _claimTag(_scanResult!.id),
                  icon: _isClaiming
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Symbols.card_membership),
                  label: Text('claimTag').tr(),
                ),
              ],
            ],
            const Gap(16),
          ],
        ),
      ),
    );
  }

  Future<void> _scanPassport() async {
    setState(() {
      _isScanning = true;
      _error = null;
    });

    try {
      final availability = await NfcScanService().checkAvailability();
      if (availability != NFCAvailability.available) {
        setState(() {
          _error = 'nfcNotAvailable'.tr();
          _isScanning = false;
        });
        return;
      }

      final tag = await NfcScanService().scanTag();

      if (tag.ndefAvailable != true) {
        setState(() {
          _error = 'nfcTagNotNdef'.tr();
          _isScanning = false;
        });
        return;
      }

      final records = await NfcScanService().readNdefRecords(tag);
      if (records.isEmpty) {
        setState(() {
          _error = 'nfcTagEmpty'.tr();
          _isScanning = false;
        });
        return;
      }

      final firstRecord = records.first;
      if (firstRecord is! UriRecord || firstRecord.uri == null) {
        setState(() {
          _error = 'nfcTagInvalid'.tr();
          _isScanning = false;
        });
        return;
      }
      final uri = firstRecord.uri!;

      final client = ref.read(solarNetworkClientProvider);
      SnScanResult? result;

      // Check if URI has a path segment (unencrypted tag with entry ID)
      // e.g., solian://phpass/{tag_id}
      if (uri.host == 'phpass' && uri.pathSegments.isNotEmpty) {
        final tagId = uri.pathSegments.first;
        final response = await client.dio.get('/passport/nfc/tags/$tagId');
        result = SnScanResult.fromJson(response.data);
      } else {
        // Forward all query parameters directly to /passport/nfc
        // This handles both encrypted (e, c, mac) and unencrypted (uid) tags
        final queryParams = uri.queryParameters;
        if (queryParams.isEmpty) {
          setState(() {
            _error = 'nfcTagInvalid'.tr();
            _isScanning = false;
          });
          return;
        }
        final response = await client.dio.get(
          '/passport/nfc',
          queryParameters: {...queryParams, 'tag': tag.id},
        );
        result = SnScanResult.fromJson(response.data);
      }

      setState(() {
        _scanResult = result;
        _isScanning = false;
        _scannedUid = tag.id;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isScanning = false;
      });
    } finally {
      // Always finish NFC session to prevent iOS session leak
      await NfcScanService().finish();
    }
  }

  Future<void> _claimTag(String recordId) async {
    setState(() => _isClaiming = true);

    try {
      final client = ref.read(solarNetworkClientProvider);
      await client.dio.post(
        '/passport/nfc/tags/claim',
        data: {'record_id': recordId},
      );

      // Refresh the scan result to show claimed status
      final response = await client.dio.get('/passport/nfc/tags/$recordId');
      final result = SnScanResult.fromJson(response.data);

      setState(() {
        _scanResult = result;
        _isClaiming = false;
      });

      if (mounted) {
        showSnackBar('tagClaimed'.tr());
      }
    } catch (e) {
      setState(() => _isClaiming = false);
      if (mounted) {
        showErrorAlert(e);
      }
    }
  }
}

class _PhysicalPassportScanResultCard extends StatelessWidget {
  final SnScanResult passport;
  final VoidCallback onScanAgain;

  const _PhysicalPassportScanResultCard({
    required this.passport,
    required this.onScanAgain,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ink = _monoInk(theme);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (passport.account != null)
          Card(
            margin: EdgeInsets.zero,
            child: InkWell(
              child: AccountNameplate(
                name: passport.account!.name,
                isOutlined: false,
              ),
              onTap: () {
                context.router.push(
                  AccountProfileRoute(name: passport.account!.name),
                );
              },
            ),
          )
        else
          Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            color: _monoSurface(theme, 0.08),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Symbols.check_circle,
                        color: ink.withOpacity(0.84),
                        size: 20,
                      ),
                      const Gap(8),
                      Text(
                        'physicalPassportScanned'.tr(),
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: ink.withOpacity(0.84),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Gap(12),
                  Text(
                    'ID: ${passport.id}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(fontFamily: 'monospace'),
                  ),
                  const Gap(12),
                  Text(
                    'tagNotClaimed',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ).tr(),
                ],
              ),
            ),
          ),
        const Gap(24),
        OutlinedButton.icon(
          onPressed: onScanAgain,
          icon: const Icon(Symbols.nfc),
          label: Text('scanAnother').tr(),
        ),
      ],
    );
  }
}

final scanPhysicalPassportProvider = FutureProvider.autoDispose
    .family<SnScanResult, String>((ref, id) async {
      final client = ref.watch(solarNetworkClientProvider);
      final response = await client.dio.get('/passport/nfc/tags/$id');
      return SnScanResult.fromJson(response.data);
    });

final scanPhysicalPassportByParamsProvider = FutureProvider.autoDispose
    .family<SnScanResult, Map<String, String>>((ref, params) async {
      final client = ref.watch(solarNetworkClientProvider);
      final response = await client.dio.get(
        '/passport/nfc',
        queryParameters: params,
      );
      return SnScanResult.fromJson(response.data);
    });
