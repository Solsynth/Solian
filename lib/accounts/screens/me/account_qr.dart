import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/accounts/widgets/account/account_name.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class AccountQrScreen extends HookConsumerWidget {
  const AccountQrScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userInfoProvider);
    final theme = Theme.of(context);

    if (user.value == null) {
      return AppScaffold(
        appBar: AppBar(title: Text('accountQrCodeTitle').tr()),
        body: const SizedBox.shrink(),
      );
    }

    final account = user.value!;
    final profileUrl = 'https://solian.app/accounts/${account.name}';

    Future<void> copyProfileUrl() async {
      await Clipboard.setData(ClipboardData(text: profileUrl));
      showSnackBar('copiedToClipboard'.tr());
    }

    Future<void> openScanner() async {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => _AccountQrScannerSheet(
          onScanned: (value) async {
            final target = _resolveScannedAccountName(value);
            if (target != null && context.mounted) {
              await context.router.push(AccountProfileRoute(name: target));
              return;
            }

            final uri = Uri.tryParse(value);
            if (uri != null && (uri.hasScheme || uri.hasAuthority)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
              return;
            }

            showSnackBar('accountQrScanUnsupported'.tr());
          },
        ),
      );
    }

    return AppScaffold(
      appBar: AppBar(
        title: Text('accountQrCodeTitle').tr(),
        leading: const AutoLeadingButton(),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            color: theme.colorScheme.surfaceContainerLow,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ProfilePictureWidget(
                    file: account.profile.picture,
                    radius: 30,
                  ),
                  const Gap(14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AccountName(
                          account: account,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Gap(2),
                        Text(
                          '@${account.name}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Gap(20),
          Card.filled(
            clipBehavior: Clip.antiAlias,
            color: theme.colorScheme.surfaceContainerLow,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: QrImageView(
                      data: profileUrl,
                      version: QrVersions.auto,
                      size: 240,
                      eyeStyle: QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: theme.colorScheme.onSurface,
                      ),
                      dataModuleStyle: QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: theme.colorScheme.onSurface,
                      ),
                      backgroundColor: theme.colorScheme.surface,
                    ),
                  ),
                  const Gap(20),
                  Text(
                    'accountQrCodeHint'.tr(),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const Gap(8),
                  SelectableText(
                    profileUrl,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Gap(20),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: copyProfileUrl,
                          icon: const Icon(Symbols.content_copy),
                          label: Text('copyLink').tr(),
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            context.router.push(
                              AccountProfileRoute(name: account.name),
                            );
                          },
                          icon: const Icon(Symbols.person),
                          label: Text('accountQrOpenProfile').tr(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Gap(20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Symbols.qr_code_scanner,
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                      ),
                      const Gap(14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'accountQrScannerTitle'.tr(),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Gap(4),
                            Text(
                              'accountQrScannerHint'.tr(),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Gap(20),
                  FilledButton.tonalIcon(
                    onPressed: openScanner,
                    icon: const Icon(Symbols.center_focus_strong),
                    label: Text('accountQrStartScanning').tr(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountQrScannerSheet extends StatefulWidget {
  final ValueChanged<String> onScanned;

  const _AccountQrScannerSheet({required this.onScanned});

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

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;

    for (final barcode in capture.barcodes) {
      final code = barcode.rawValue;
      if (code != null && code.isNotEmpty) {
        setState(() => _hasScanned = true);
        widget.onScanned(code);
        Navigator.of(context).pop();
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
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 20),
            child: Text(
              'accountQrScannerSheetHint'.tr(),
              style: TextStyle(color: theme.colorScheme.secondary),
              textAlign: TextAlign.center,
            ),
          ),
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
