import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/accounts/widgets/account/account_name.dart';
import 'package:island/core/network.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/shared/widgets/response.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ndef/ndef.dart' as ndef;
import 'package:ndef/records/well_known/uri.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'physical_passport.freezed.dart';
part 'physical_passport.g.dart';

@freezed
sealed class SnPhysicalPassport with _$SnPhysicalPassport {
  const factory SnPhysicalPassport({
    required String id,
    String? label,
    required bool isActive,
    required bool isLocked,
    DateTime? lastSeenAt,
    required DateTime createdAt,
    String? uid,
  }) = _SnPhysicalPassport;

  factory SnPhysicalPassport.fromJson(Map<String, dynamic> json) =>
      _$SnPhysicalPassportFromJson(json);
}

@freezed
sealed class SnScanResult with _$SnScanResult {
  const factory SnScanResult({
    required SnAccount user,
    @Default(false) bool isFriend,
    @Default([]) List<String> actions,
  }) = _SnScanResult;

  factory SnScanResult.fromJson(Map<String, dynamic> json) =>
      _$SnScanResultFromJson(json);
}

final physicalPassportsProvider =
    FutureProvider.autoDispose<List<SnPhysicalPassport>>((ref) async {
      final client = ref.watch(apiClientProvider);
      final response = await client.get('/passport/nfc/tags');
      return (response.data as List)
          .map((e) => SnPhysicalPassport.fromJson(e))
          .toList();
    });

final scanPhysicalPassportProvider = FutureProvider.autoDispose
    .family<SnScanResult, String>((ref, id) async {
      final client = ref.watch(apiClientProvider);
      final response = await client.get('/passport/nfc/tags/$id');
      return SnScanResult.fromJson(response.data);
    });

enum PassportScanMode { read, write }

@RoutePage()
class PhysicalPassportScreen extends HookConsumerWidget {
  const PhysicalPassportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passportsAsync = ref.watch(physicalPassportsProvider);
    final user = ref.watch(userInfoProvider);

    return AppScaffold(
      appBar: AppBar(
        title: Text('physicalPassports').tr(),
        leading: const AutoLeadingButton(),
        actions: [
          IconButton(
            icon: const Icon(Symbols.nfc),
            tooltip: 'scanPhysicalPassport'.tr(),
            onPressed: () => _showScanSheet(context),
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
                onAddPassport: () => _showAddSheet(context, ref),
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
                  onDelete: passport.isLocked
                      ? null
                      : () => _confirmDelete(context, ref, passport),
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
        data: (passports) => passports.isNotEmpty && user.value != null
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

  void _showScanSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => const _PhysicalPassportScanSheet(),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    SnPhysicalPassport passport,
  ) async {
    final confirm = await showConfirmAlert(
      'physicalPassportDeleteConfirm'.tr(),
      'physicalPassportDelete'.tr(),
      isDanger: true,
    );
    if (!confirm || !context.mounted) return;

    try {
      showLoadingModal(context);
      final client = ref.read(apiClientProvider);
      await client.delete('/passport/nfc/tags/${passport.id}');
      ref.invalidate(physicalPassportsProvider);
      if (context.mounted) {
        hideLoadingModal(context);
        showSnackBar('physicalPassportDeleted'.tr());
      }
    } catch (e) {
      if (context.mounted) {
        hideLoadingModal(context);
        showErrorAlert(e);
      }
    }
  }
}

class _PhysicalPassportsEmptyState extends StatelessWidget {
  final VoidCallback onAddPassport;

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
            const Gap(32),
            FilledButton.icon(
              onPressed: onAddPassport,
              icon: const Icon(Symbols.add),
              label: Text('addPhysicalPassport').tr(),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhysicalPassportListItem extends StatelessWidget {
  final SnPhysicalPassport passport;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _PhysicalPassportListItem({
    required this.passport,
    required this.onTap,
    this.onDelete,
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
                      const Gap(4),
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
                            backgroundColor: colorScheme.errorContainer,
                            textColor: colorScheme.onErrorContainer,
                          ),
                        if (passport.isLocked)
                          _StatusChip(
                            label: 'physicalPassportLocked'.tr(),
                            backgroundColor: colorScheme.tertiaryContainer,
                            textColor: colorScheme.onTertiaryContainer,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Symbols.delete),
                  onPressed: onDelete,
                  color: colorScheme.error,
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
  final Color backgroundColor;
  final Color textColor;

  const _StatusChip({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: textColor),
      ),
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
                onPressed: _isScanning ? null : _scanPassport,
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
              const Gap(32),
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
    setState(() => _isScanning = true);

    try {
      final availability = await FlutterNfcKit.nfcAvailability;
      if (availability != NFCAvailability.available) {
        if (mounted) {
          showErrorAlert(Exception('nfcNotAvailable'.tr()));
        }
        return;
      }

      final tag = await FlutterNfcKit.poll();

      final uid = tag.id;

      setState(() {
        _scannedUid = uid;
        _uidController.text = uid;
      });

      await FlutterNfcKit.finish();
    } catch (e) {
      if (mounted) {
        showErrorAlert(e);
      }
    } finally {
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
      final client = ref.read(apiClientProvider);
      final response = await client.post(
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
      await _showWriteDeepLinkSheet(passport);
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

  Future<void> _showWriteDeepLinkSheet(SnPhysicalPassport passport) async {
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
            _performWrite(passport)
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
                    const CircularProgressIndicator(),
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

  Future<bool> _performWrite(SnPhysicalPassport passport) async {
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SheetScaffold(
      heightFactor: 0.4,
      titleText: 'scanPhysicalPassport'.tr(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'scanPhysicalPassportDescription'.tr(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const Gap(24),
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
                  });
                },
              ),
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
      final availability = await FlutterNfcKit.nfcAvailability;
      if (availability != NFCAvailability.available) {
        setState(() {
          _error = 'nfcNotAvailable'.tr();
          _isScanning = false;
        });
        return;
      }

      final tag = await FlutterNfcKit.poll();

      if (tag.ndefAvailable != true) {
        setState(() {
          _error = 'nfcTagNotNdef'.tr();
          _isScanning = false;
        });
        return;
      }

      final records = await FlutterNfcKit.readNDEFRecords(cached: false);
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
      final pathSegments = uri.pathSegments;

      if (pathSegments.isEmpty || uri.host != 'phpass') {
        setState(() {
          _error = 'nfcTagInvalid'.tr();
          _isScanning = false;
        });
        return;
      }

      final id = pathSegments.first;
      final passport = await ref.read(scanPhysicalPassportProvider(id).future);

      setState(() {
        _scanResult = passport;
        _isScanning = false;
      });

      await FlutterNfcKit.finish();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isScanning = false;
      });
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
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Card(
          elevation: 0,
          clipBehavior: Clip.antiAlias,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primaryContainer,
                  colorScheme.secondaryContainer,
                ],
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(children: [AccountName(account: passport.user)]),
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
                    ],
                  ),
                ),
              ],
            ),
            const Gap(24),
            const Divider(),
            const Gap(16),
            if (!passport.isLocked) ...[
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('physicalPassportActive'.tr()),
                subtitle: Text('physicalPassportActiveDescription'.tr()),
                value: _isActive,
                onChanged: (value) async {
                  setState(() => _isActive = value);
                  await _saveChanges();
                },
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
      final client = ref.read(apiClientProvider);
      await client.patch(
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
      final client = ref.read(apiClientProvider);
      await client.post('/passport/nfc/tags/${widget.passport.id}/lock');
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

  Future<void> _writePassport() async {
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
