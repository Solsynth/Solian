import 'dart:async';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
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

@RoutePage()
class AccountQrScreen extends HookConsumerWidget {
  const AccountQrScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userInfoProvider);
    final wallet = ref.watch(walletCurrentProvider);
    final theme = Theme.of(context);
    final activeTransferRequest = useState<WalletTransferRequestData?>(null);
    final selectedSection = useState<_QrSectionId?>(_QrSectionId.profile);
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
      if (uri != null && uri.scheme == 'solian') {
        eventBus.fire(SolianDeepLinkEvent(uri));
        return;
      }

      if (uri != null && (uri.hasScheme || uri.hasAuthority)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }

      showSnackBar('accountQrScanUnsupported'.tr());
    }

    return AppScaffold(
      appBar: AppBar(
        title: Text('accountQrCodeTitle').tr(),
        leading: const AutoLeadingButton(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openScanner,
        child: const Icon(Symbols.qr_code_scanner),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _QrModeSection(
            sectionId: _QrSectionId.profile,
            title: 'accountQrProfileSectionTitle'.tr(),
            subtitle: 'accountQrCodeHint'.tr(),
            icon: Symbols.person,
            isExpanded: selectedSection.value == _QrSectionId.profile,
            onExpansionChanged: (value) {
              selectedSection.value = value ? _QrSectionId.profile : null;
            },
            child: Screenshot(
              controller: profileQrShot,
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _QrPanel(
                      data: profileUrl,
                      theme: theme,
                      embedImage: user.value?.profilePicture != null
                          ? CloudImageWidget.provider(
                              file: user.value!.profilePicture!,
                              serverUrl: ref.watch(serverUrlProvider),
                            )
                          : null,
                    ),
                    const Gap(20),
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
                            onPressed: () => saveQrImage(
                              profileQrShot,
                              fileName: 'profile-qr',
                            ),
                            icon: const Icon(Symbols.download),
                            label: Text('save').tr(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Gap(20),
          _QrModeSection(
            sectionId: _QrSectionId.deviceAuth,
            title: 'accountQrDeviceAuthSectionTitle'.tr(),
            subtitle: 'accountQrDeviceAuthHint'.tr(),
            icon: Symbols.phonelink_lock,
            isExpanded: selectedSection.value == _QrSectionId.deviceAuth,
            onExpansionChanged: (value) {
              selectedSection.value = value ? _QrSectionId.deviceAuth : null;
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _DeviceAuthSection(),
            ),
          ),
          const Gap(20),
          _QrModeSection(
            sectionId: _QrSectionId.transfer,
            title: activeTransferRequest.value != null
                ? 'accountQrTransferRequestSectionTitle'.tr()
                : 'accountQrTransferSectionTitle'.tr(),
            subtitle: activeTransferRequest.value != null
                ? 'accountQrTransferRequestHint'.tr()
                : 'accountQrTransferHint'.tr(),
            icon: Symbols.swap_horiz,
            isExpanded: selectedSection.value == _QrSectionId.transfer,
            onExpansionChanged: (value) {
              selectedSection.value = value ? _QrSectionId.transfer : null;
            },
            child: Screenshot(
              controller: transferQrShot,
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: wallet.when(
                  data: (currentWallet) {
                    if (currentWallet == null) {
                      return _TransferUnavailableCard(
                        theme: theme,
                        onOpenWallet: () {
                          context.router.push(const WalletRoute());
                        },
                        messageKey: 'accountQrWalletUnavailable',
                      );
                    }

                    if (currentWallet.publicId == null) {
                      return _TransferUnavailableCard(
                        theme: theme,
                        onOpenWallet: () {
                          context.router.push(const WalletRoute());
                        },
                        onEnableWalletId: () =>
                            enableWalletId(currentWallet.id),
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
                            embedImage: AssetImage("assets/icons/icon.webp"),
                          ),
                        const Gap(16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activeTransferRequest.value != null
                                    ? 'accountQrTransferRequestLabel'.tr()
                                    : 'walletPublicId'.tr(),
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const Gap(6),
                              SelectableText(
                                activeTransferRequest.value != null
                                    ? transferShareLink!
                                    : currentWallet.publicId!,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (activeTransferRequest.value != null) ...[
                                const Gap(10),
                                Text(
                                  'accountQrTransferRequestSummary'.tr(
                                    namedArgs: {
                                      'amount': activeTransferRequest
                                          .value!
                                          .amount
                                          .toStringAsFixed(2),
                                      'currency':
                                          activeTransferRequest.value!.currency,
                                      'expiry': DateFormat.yMd()
                                          .add_Hm()
                                          .format(
                                            activeTransferRequest
                                                .value!
                                                .expiresAt,
                                          ),
                                    },
                                  ),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const Gap(16),
                        FilledButton.icon(
                          onPressed: () =>
                              createTransferRequestFlow(currentWallet),
                          icon: const Icon(Symbols.request_quote),
                          label: Text(
                            activeTransferRequest.value != null
                                ? 'accountQrRequestRefresh'.tr()
                                : 'accountQrRequestCreate'.tr(),
                          ),
                        ),
                        if (activeTransferRequest.value != null)
                          OutlinedButton.icon(
                            onPressed: () {
                              activeTransferRequest.value = null;
                            },
                            icon: const Icon(Symbols.qr_code_2),
                            label: Text('accountQrRequestClear').tr(),
                          ).padding(top: 16),
                      ],
                    );
                  },
                  loading: () => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator.adaptive()),
                  ),
                  error: (_, _) => _TransferUnavailableCard(
                    theme: theme,
                    onOpenWallet: () {
                      context.router.push(const WalletRoute());
                    },
                    messageKey: 'accountQrTransferUnavailable',
                  ),
                ),
              ),
            ),
          ),
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

class _QrModeSection extends StatelessWidget {
  final _QrSectionId sectionId;
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;
  final bool isExpanded;
  final ValueChanged<bool>? onExpansionChanged;

  const _QrModeSection({
    required this.sectionId,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
    required this.isExpanded,
    this.onExpansionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card.filled(
      clipBehavior: Clip.antiAlias,
      color: theme.colorScheme.surfaceContainerLow,
      child: InkWell(
        onTap: () => onExpansionChanged?.call(!isExpanded),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const Gap(12),
                            AnimatedRotation(
                              turns: isExpanded ? 0.5 : 0,
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeInOut,
                              child: Icon(
                                Symbols.keyboard_arrow_down,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const Gap(4),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(14),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      icon,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeInOut,
                alignment: Alignment.topCenter,
                child: isExpanded
                    ? Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: child,
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
    final dropdownDecoration = InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
    final dropdownButtonStyle = const FormFieldButtonStyleData(height: 24);
    final dropdownMenuStyle = MenuItemStyleData(
      // padding: EdgeInsets.zero,
      overlayColor: WidgetStatePropertyAll(
        theme.colorScheme.primary.withOpacity(0.08),
      ),
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
                          color: theme.colorScheme.primary,
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
      await client.dio.post('/padlock/auth/qr/$qrChallengeId/scan');
    } on DioException catch (err) {
      if (!{400, 409}.contains(err.response?.statusCode)) rethrow;
    }

    final snapshotResp = await client.dio.get(
      '/padlock/auth/qr/$qrChallengeId',
    );
    final snapshot = _QrLoginChallengeSnapshot.fromJson(
      Map<String, dynamic>.from(snapshotResp.data as Map),
    );

    SnAuthChallenge? challenge;
    try {
      final challengeResp = await client.dio.get(
        '/padlock/auth/challenge/${snapshot.authChallengeId}',
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
          '/padlock/auth/qr/$qrChallengeId/${approve ? 'approve' : 'decline'}',
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
                                color: Theme.of(
                                  context,
                                ).colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _qrLoginPlatformIcon(
                                  currentChallenge?.platform ??
                                      snapshot.platform,
                                ),
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
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
                          color: Theme.of(context).colorScheme.primaryContainer
                              .withAlpha((255 * 0.3).round()),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary
                                .withAlpha((255 * 0.3).round()),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Symbols.info,
                              size: 20,
                              color: Theme.of(context).colorScheme.primary,
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
      '/padlock/auth/open/device/code/$userCode',
    );
    if (context.mounted) hideLoadingModal(context);
    final data = Map<String, dynamic>.from(resp.data as Map);
    if (!context.mounted) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => _DeviceAuthApprovalSheet(
        userCode: userCode,
        clientId: data['client_id'] as String? ?? 'unknownClient'.tr(),
        scopes: (data['scopes'] as List?)?.cast<String>() ?? const [],
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
  final String clientId;
  final List<String> scopes;
  final String status;
  final DateTime? expiresAt;

  const _DeviceAuthApprovalSheet({
    required this.userCode,
    required this.clientId,
    required this.scopes,
    required this.status,
    this.expiresAt,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
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
          '/padlock/auth/open/device/code/$userCode/${approve ? 'approve' : 'decline'}',
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
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Symbols.devices,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    clientId,
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
                      if (scopes.isNotEmpty) ...[
                        _DetailRow(
                          icon: Symbols.shield,
                          label: 'accountQrDeviceAuthScopes'.tr(),
                          value: scopes.join(', '),
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
                          color: theme.colorScheme.primaryContainer.withAlpha(
                            (255 * 0.3).round(),
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.primary.withAlpha(
                              (255 * 0.3).round(),
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Symbols.info,
                              size: 20,
                              color: theme.colorScheme.primary,
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
