import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/core/network.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/shared/widgets/response.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:ndef/ndef.dart' as ndef;

class SnNfcTag {
  final String id;
  final String? label;
  final bool isActive;
  final bool isLocked;
  final DateTime? lastSeenAt;
  final DateTime createdAt;
  final String uid;
  final String? e;
  final String? c;
  final String? mac;

  SnNfcTag({
    required this.id,
    this.label,
    required this.isActive,
    required this.isLocked,
    this.lastSeenAt,
    required this.createdAt,
    required this.uid,
    this.e,
    this.c,
    this.mac,
  });

  factory SnNfcTag.fromJson(Map<String, dynamic> json) {
    return SnNfcTag(
      id: json['id'] as String,
      label: json['label'] as String?,
      isActive: json['is_active'] as bool,
      isLocked: json['is_locked'] as bool,
      lastSeenAt: json['last_seen_at'] != null
          ? DateTime.parse(json['last_seen_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      uid: json['uid'] as String? ?? '',
      e: json['e'] as String?,
      c: json['c'] as String?,
      mac: json['mac'] as String?,
    );
  }
}

class SnNfcScanResult {
  final SnUserProfile user;
  final bool isFriend;
  final List<String> actions;

  SnNfcScanResult({
    required this.user,
    required this.isFriend,
    required this.actions,
  });

  factory SnNfcScanResult.fromJson(Map<String, dynamic> json) {
    return SnNfcScanResult(
      user: SnUserProfile.fromJson(json['user'] as Map<String, dynamic>),
      isFriend: json['is_friend'] as bool? ?? false,
      actions:
          (json['actions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}

class SnUserProfile {
  final String id;
  final String name;
  final String? nick;
  final String? picture;
  final String? bio;

  SnUserProfile({
    required this.id,
    required this.name,
    this.nick,
    this.picture,
    this.bio,
  });

  factory SnUserProfile.fromJson(Map<String, dynamic> json) {
    return SnUserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      nick: json['nick'] as String?,
      picture: json['picture'] as String?,
      bio: json['bio'] as String?,
    );
  }
}

final nfcTagsProvider = FutureProvider.autoDispose<List<SnNfcTag>>((ref) async {
  final client = ref.watch(apiClientProvider);
  final response = await client.get('/passport/nfc/tags');
  return (response.data as List).map((e) => SnNfcTag.fromJson(e)).toList();
});

class RegisterNfcTagNotifier extends AsyncNotifier<SnNfcTag?> {
  @override
  Future<SnNfcTag?> build() async => null;

  Future<SnNfcTag> register({
    required String uid,
    required String sunKey,
    String? label,
  }) async {
    state = const AsyncValue.loading();
    try {
      final client = ref.read(apiClientProvider);
      final response = await client.post(
        '/passport/nfc/tags',
        data: {
          'uid': uid,
          'sun_key': sunKey,
          if (label != null && label.isNotEmpty) 'label': label,
        },
      );
      final tag = SnNfcTag.fromJson(response.data);
      ref.invalidate(nfcTagsProvider);
      state = AsyncValue.data(tag);
      return tag;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final registerNfcTagProvider =
    AsyncNotifierProvider<RegisterNfcTagNotifier, SnNfcTag?>(
      RegisterNfcTagNotifier.new,
    );

class UpdateNfcTagNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> updateTag({
    required String tagId,
    String? label,
    bool? isActive,
  }) async {
    state = const AsyncValue.loading();
    try {
      final client = ref.read(apiClientProvider);
      await client.patch(
        '/passport/nfc/tags/$tagId',
        data: {'label': ?label, 'is_active': ?isActive},
      );
      ref.invalidate(nfcTagsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final updateNfcTagProvider = AsyncNotifierProvider<UpdateNfcTagNotifier, void>(
  UpdateNfcTagNotifier.new,
);

class LockNfcTagNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<SnNfcTag> lock(String tagId) async {
    state = const AsyncValue.loading();
    try {
      final client = ref.read(apiClientProvider);
      final response = await client.post('/passport/nfc/tags/$tagId/lock');
      final tag = SnNfcTag.fromJson(response.data);
      ref.invalidate(nfcTagsProvider);
      state = const AsyncValue.data(null);
      return tag;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final lockNfcTagProvider = AsyncNotifierProvider<LockNfcTagNotifier, void>(
  LockNfcTagNotifier.new,
);

class DeleteNfcTagNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> delete(String tagId) async {
    state = const AsyncValue.loading();
    try {
      final client = ref.read(apiClientProvider);
      await client.delete('/passport/nfc/tags/$tagId');
      ref.invalidate(nfcTagsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final deleteNfcTagProvider = AsyncNotifierProvider<DeleteNfcTagNotifier, void>(
  DeleteNfcTagNotifier.new,
);

final scanNfcTagProvider = FutureProvider.autoDispose
    .family<SnNfcScanResult, Map<String, String>>((ref, params) async {
      final client = ref.watch(apiClientProvider);
      final response = await client.get(
        '/passport/nfc',
        queryParameters: params,
      );
      return SnNfcScanResult.fromJson(response.data);
    });

enum NfcScanMode { read, write }

// @RoutePage()
// ignore: unused_element
class NfcTagsScreen extends HookConsumerWidget {
  const NfcTagsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsAsync = ref.watch(nfcTagsProvider);
    final user = ref.watch(userInfoProvider);

    return AppScaffold(
      appBar: AppBar(
        title: Text('nfcTags').tr(),
        leading: const AutoLeadingButton(),
        actions: [
          IconButton(
            icon: const Icon(Symbols.nfc),
            tooltip: 'nfcScanTag'.tr(),
            onPressed: () => _showScanTagSheet(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(nfcTagsProvider);
        },
        child: tagsAsync.when(
          data: (tags) {
            if (tags.isEmpty) {
              return _NfcTagsEmptyState(
                onAddTag: () => _showAddTagSheet(context, ref),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: tags.length,
              itemBuilder: (context, index) {
                final tag = tags[index];
                return _NfcTagListItem(
                  tag: tag,
                  onTap: () => _showTagDetailSheet(context, ref, tag),
                  onDelete: tag.isLocked
                      ? null
                      : () => _confirmDeleteTag(context, ref, tag),
                );
              },
            );
          },
          error: (error, _) => ResponseErrorWidget(
            error: error,
            onRetry: () => ref.invalidate(nfcTagsProvider),
          ),
          loading: () => const ResponseLoadingWidget(),
        ),
      ),
      floatingActionButton: tagsAsync.maybeWhen(
        data: (tags) => tags.isNotEmpty && user.value != null
            ? FloatingActionButton.extended(
                onPressed: () => _showAddTagSheet(context, ref),
                icon: const Icon(Symbols.add),
                label: Text('addNfcTag').tr(),
              )
            : null,
        orElse: () => null,
      ),
    );
  }

  void _showAddTagSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => const _AddNfcTagSheet(),
    ).then((_) {
      ref.invalidate(nfcTagsProvider);
    });
  }

  void _showTagDetailSheet(BuildContext context, WidgetRef ref, SnNfcTag tag) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => _NfcTagDetailSheet(tag: tag),
    ).then((_) {
      ref.invalidate(nfcTagsProvider);
    });
  }

  void _showScanTagSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => const _NfcScanSheet(),
    );
  }

  Future<void> _confirmDeleteTag(
    BuildContext context,
    WidgetRef ref,
    SnNfcTag tag,
  ) async {
    final confirm = await showConfirmAlert(
      'nfcTagDeleteConfirm'.tr(),
      'nfcTagDelete'.tr(),
      isDanger: true,
    );
    if (!confirm || !context.mounted) return;

    try {
      showLoadingModal(context);
      await ref.read(deleteNfcTagProvider.notifier).delete(tag.id);
      if (context.mounted) {
        hideLoadingModal(context);
        showSnackBar('nfcTagDeleted'.tr());
      }
    } catch (e) {
      if (context.mounted) {
        hideLoadingModal(context);
        showErrorAlert(e);
      }
    }
  }
}

class _NfcTagsEmptyState extends StatelessWidget {
  final VoidCallback onAddTag;

  const _NfcTagsEmptyState({required this.onAddTag});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Symbols.nfc,
              size: 64,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const Gap(16),
            Text(
              'nfcTagsEmpty'.tr(),
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const Gap(8),
            Text(
              'nfcTagsEmptyDescription'.tr(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(24),
            FilledButton.icon(
              onPressed: onAddTag,
              icon: const Icon(Symbols.add),
              label: Text('addNfcTag').tr(),
            ),
          ],
        ),
      ),
    );
  }
}

class _NfcTagListItem extends StatelessWidget {
  final SnNfcTag tag;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _NfcTagListItem({
    required this.tag,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: tag.isLocked
              ? Theme.of(context).colorScheme.tertiaryContainer
              : Theme.of(context).colorScheme.primaryContainer,
          shape: BoxShape.circle,
        ),
        child: Icon(
          tag.isLocked ? Symbols.lock : Symbols.nfc,
          color: tag.isLocked
              ? Theme.of(context).colorScheme.onTertiaryContainer
              : Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(tag.label ?? 'nfcTagUnnamed'.tr()),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (tag.lastSeenAt != null)
            Text(
              'nfcTagLastSeen'.tr(
                args: [_formatRelativeTime(context, tag.lastSeenAt!)],
              ),
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          Row(
            children: [
              if (!tag.isActive)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'nfcTagInactive'.tr(),
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              if (tag.isLocked)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'nfcTagLocked'.tr(),
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.onTertiaryContainer,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onDelete != null)
            IconButton(
              icon: const Icon(Symbols.delete),
              onPressed: onDelete,
              color: Theme.of(context).colorScheme.error,
            ),
          const Icon(Symbols.chevron_right),
        ],
      ),
      onTap: onTap,
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

class _AddNfcTagSheet extends ConsumerStatefulWidget {
  const _AddNfcTagSheet();

  @override
  ConsumerState<_AddNfcTagSheet> createState() => _AddNfcTagSheetState();
}

class _AddNfcTagSheetState extends ConsumerState<_AddNfcTagSheet> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _uidController = TextEditingController();
  final _sunKeyController = TextEditingController();
  bool _isSubmitting = false;
  bool _isScanning = false;
  String? _scannedUid;
  String? _generatedSunKey;

  @override
  void dispose() {
    _labelController.dispose();
    _uidController.dispose();
    _sunKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SheetScaffold(
      titleText: 'addNfcTag'.tr(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'addNfcTagDescription'.tr(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const Gap(16),
              FilledButton.tonalIcon(
                onPressed: _isScanning ? null : _scanTag,
                icon: _isScanning
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Symbols.nfc),
                label: Text(
                  _isScanning ? 'nfcScanning'.tr() : 'scanNfcTag'.tr(),
                ),
              ),
              if (_scannedUid != null) ...[
                const Gap(16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Symbols.check_circle,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                          const Gap(8),
                          Text(
                            'nfcTagScanned'.tr(),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Gap(8),
                      Text(
                        'UID: $_scannedUid',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                      if (_generatedSunKey != null) ...[
                        const Gap(4),
                        Text(
                          'SUN Key: ${_generatedSunKey!.substring(0, 8)}...',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontFamily: 'monospace'),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              const Gap(16),
              TextFormField(
                controller: _labelController,
                decoration: InputDecoration(
                  labelText: 'nfcTagLabel'.tr(),
                  hintText: 'nfcTagLabelHint'.tr(),
                  prefixIcon: const Icon(Symbols.label),
                ),
                maxLength: 64,
              ),
              const Gap(8),
              TextFormField(
                controller: _uidController,
                decoration: InputDecoration(
                  labelText: 'nfcTagUid'.tr(),
                  hintText: 'nfcTagUidHint'.tr(),
                  prefixIcon: const Icon(Symbols.tag),
                ),
                enabled: false,
              ),
              const Gap(16),
              TextFormField(
                controller: _sunKeyController,
                decoration: InputDecoration(
                  labelText: 'nfcTagSunKey'.tr(),
                  hintText: 'nfcTagSunKeyHint'.tr(),
                  prefixIcon: const Icon(Symbols.key),
                ),
                enabled: false,
              ),
              const Gap(8),
              Text(
                'nfcTagSunKeyDescription'.tr(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const Gap(24),
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
                    : Text('registerNfcTag').tr(),
              ),
              const Gap(16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _scanTag() async {
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

      final sunKey = _generateSunKey();

      setState(() {
        _scannedUid = uid;
        _generatedSunKey = sunKey;
        _uidController.text = uid;
        _sunKeyController.text = sunKey;
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

  String _generateSunKey() {
    final bytes = Uint8List(16);
    for (var i = 0; i < 16; i++) {
      bytes[i] = DateTime.now().microsecondsSinceEpoch % 256;
    }
    return base64Encode(bytes);
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_scannedUid == null || _generatedSunKey == null) return;

    setState(() => _isSubmitting = true);

    try {
      final notifier = ref.read(registerNfcTagProvider.notifier);
      final registeredTag = await notifier.register(
        uid: _scannedUid!,
        sunKey: _generatedSunKey!,
        label: _labelController.text.trim().isEmpty
            ? null
            : _labelController.text.trim(),
      );

      if (!mounted) return;

      Navigator.of(context).pop();
      showSnackBar('nfcTagRegistered'.tr());
      await _showWriteDeepLinkSheet(registeredTag);
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

  Future<void> _showWriteDeepLinkSheet(SnNfcTag tag) async {
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
            _performWrite(tag)
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
            titleText: 'nfcWritingDeepLink'.tr(),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
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

  Future<bool> _performWrite(SnNfcTag tag) async {
    try {
      final availability = await FlutterNfcKit.nfcAvailability;
      if (availability != NFCAvailability.available) {
        return false;
      }

      final polledTag = await FlutterNfcKit.poll(
        iosAlertMessage: 'nfcTapToWrite'.tr(),
      );

      String e = tag.e ?? '';
      String c = tag.c ?? '';
      String mac = tag.mac ?? '';

      if (e.isEmpty || c.isEmpty || mac.isEmpty) {
        if (polledTag.ndefAvailable == true) {
          final records = await FlutterNfcKit.readNDEFRecords(cached: false);
          if (records.isNotEmpty) {
            final firstRecord = records.first;
            final uriString = firstRecord.toString();
            final uri = Uri.parse(uriString);
            e = uri.queryParameters['e'] ?? e;
            c = uri.queryParameters['c'] ?? c;
            mac = uri.queryParameters['mac'] ?? mac;
          }
        }
      }

      if (e.isEmpty || c.isEmpty || mac.isEmpty) {
        final client = ref.read(apiClientProvider);
        final response = await client.get('/passport/nfc/tags/${tag.id}');
        final tagData = SnNfcTag.fromJson(response.data);
        e = tagData.e ?? '';
        c = tagData.c ?? '';
        mac = tagData.mac ?? '';
      }

      if (e.isEmpty || c.isEmpty || mac.isEmpty) {
        await FlutterNfcKit.finish(iosErrorMessage: 'Missing required data');
        return false;
      }

      final deepLink = 'solian://phpass/${tag.id}?e=$e&c=$c&mac=$mac';
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

class _NfcScanSheet extends ConsumerStatefulWidget {
  const _NfcScanSheet();

  @override
  ConsumerState<_NfcScanSheet> createState() => _NfcScanSheetState();
}

class _NfcScanSheetState extends ConsumerState<_NfcScanSheet> {
  bool _isScanning = false;
  SnNfcScanResult? _scanResult;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return SheetScaffold(
      titleText: 'nfcScanTag'.tr(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'nfcScanTagDescription'.tr(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const Gap(16),
            if (_scanResult == null) ...[
              FilledButton.tonalIcon(
                onPressed: _isScanning ? null : _scanTag,
                icon: _isScanning
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Symbols.nfc),
                label: Text(
                  _isScanning ? 'nfcScanning'.tr() : 'nfcScanTagButton'.tr(),
                ),
              ),
              if (_error != null) ...[
                const Gap(16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Symbols.error,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                        size: 20,
                      ),
                      const Gap(8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ] else ...[
              _NfcScanResultCard(
                result: _scanResult!,
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

  Future<void> _scanTag() async {
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
      final uriString = firstRecord.toString();

      final uri = Uri.parse(uriString);
      final e = uri.queryParameters['e'];
      final c = uri.queryParameters['c'];
      final mac = uri.queryParameters['mac'];

      if (e == null || c == null || mac == null) {
        setState(() {
          _error = 'nfcTagInvalid'.tr();
          _isScanning = false;
        });
        return;
      }

      final params = {'e': e, 'c': c, 'mac': mac};

      final result = await ref.read(scanNfcTagProvider(params).future);

      setState(() {
        _scanResult = result;
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

class _NfcScanResultCard extends StatelessWidget {
  final SnNfcScanResult result;
  final VoidCallback onScanAgain;

  const _NfcScanResultCard({required this.result, required this.onScanAgain});

  @override
  Widget build(BuildContext context) {
    final user = result.user;

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              width: 1 / MediaQuery.of(context).devicePixelRatio,
              color: Theme.of(context).dividerColor,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(12)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primaryContainer,
                    Theme.of(context).colorScheme.secondaryContainer,
                  ],
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: user.picture != null
                        ? ClipOval(
                            child: Image.network(
                              user.picture!,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Text(
                            (user.nick ?? user.name)
                                .substring(0, 1)
                                .toUpperCase(),
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                  ),
                  const Gap(16),
                  Text(
                    user.nick ?? user.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (user.nick != null) ...[
                    const Gap(4),
                    Text(
                      '@${user.name}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ],
                  if (user.bio != null) ...[
                    const Gap(12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        user.bio!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSecondaryContainer,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        const Gap(20),
        Row(
          children: [
            if (result.actions.contains('view_profile'))
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Symbols.person),
                  label: Text('viewProfile').tr(),
                ),
              ),
            if (result.actions.contains('view_profile') &&
                result.actions.contains('add_friend'))
              const Gap(8),
            if (result.actions.contains('add_friend'))
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Symbols.person_add),
                  label: Text('addFriend').tr(),
                ),
              ),
          ],
        ),
        const Gap(8),
        OutlinedButton.icon(
          onPressed: onScanAgain,
          icon: const Icon(Symbols.nfc),
          label: Text('scanAnother').tr(),
        ),
      ],
    );
  }

  void onScanAnother() {
    onScanAgain();
  }
}

class _NfcTagDetailSheet extends ConsumerStatefulWidget {
  final SnNfcTag tag;

  const _NfcTagDetailSheet({required this.tag});

  @override
  ConsumerState<_NfcTagDetailSheet> createState() => _NfcTagDetailSheetState();
}

class _NfcTagDetailSheetState extends ConsumerState<_NfcTagDetailSheet> {
  late TextEditingController _labelController;
  late bool _isActive;
  bool _isEditing = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.tag.label ?? '');
    _isActive = widget.tag.isActive;
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tag = widget.tag;

    return SheetScaffold(
      titleText: 'nfcTagDetails'.tr(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: tag.isLocked
                        ? Theme.of(context).colorScheme.tertiaryContainer
                        : Theme.of(context).colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    tag.isLocked ? Symbols.lock : Symbols.nfc,
                    color: tag.isLocked
                        ? Theme.of(context).colorScheme.onTertiaryContainer
                        : Theme.of(context).colorScheme.onPrimaryContainer,
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
                            labelText: 'nfcTagLabel'.tr(),
                            isDense: true,
                          ),
                          maxLength: 64,
                        )
                      else
                        Text(
                          tag.label ?? 'nfcTagUnnamed'.tr(),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      if (!_isEditing && tag.uid.isNotEmpty)
                        Text(
                          'UID: ${tag.uid}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                                fontFamily: 'monospace',
                              ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(16),
            const Divider(),
            const Gap(8),
            if (!tag.isLocked) ...[
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('nfcTagActive').tr(),
                subtitle: Text('nfcTagActiveDescription'.tr()),
                value: _isActive,
                onChanged: (value) async {
                  setState(() => _isActive = value);
                  await _saveTagChanges();
                },
              ),
              const Gap(8),
            ],
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Symbols.schedule),
              title: Text('nfcTagCreatedAt').tr(),
              subtitle: Text(_formatDateTime(tag.createdAt)),
            ),
            if (tag.lastSeenAt != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Symbols.visibility),
                title: Text('nfcTagLastSeenAt').tr(),
                subtitle: Text(_formatDateTime(tag.lastSeenAt!)),
              ),
            const Gap(16),
            if (!tag.isLocked && !_isEditing) ...[
              const Gap(8),
              OutlinedButton.icon(
                onPressed: _isSubmitting ? null : _writeTag,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Symbols.edit),
                label: Text('writeNfcTag').tr(),
              ),
              const Gap(8),
              OutlinedButton.icon(
                onPressed: _isSubmitting ? null : _lockTag,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Symbols.lock),
                label: Text('lockNfcTag').tr(),
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
                                _labelController.text = tag.label ?? '';
                                _isActive = tag.isActive;
                              });
                            },
                      child: Text('cancel').tr(),
                    ),
                  ),
                  const Gap(8),
                  Expanded(
                    child: FilledButton(
                      onPressed: _isSubmitting ? null : _saveTagChanges,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text('save').tr(),
                    ),
                  ),
                ],
              ),
            ],
            if (!tag.isLocked && !_isEditing)
              OutlinedButton.icon(
                onPressed: () => setState(() => _isEditing = true),
                icon: const Icon(Symbols.edit),
                label: Text('editNfcTag').tr(),
              ),
            const Gap(16),
          ],
        ),
      ),
    );
  }

  Future<void> _saveTagChanges() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      await ref
          .read(updateNfcTagProvider.notifier)
          .updateTag(
            tagId: widget.tag.id,
            label: _labelController.text.trim().isEmpty
                ? null
                : _labelController.text.trim(),
            isActive: _isActive,
          );
      if (mounted) {
        setState(() => _isEditing = false);
        showSnackBar('nfcTagUpdated'.tr());
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

  Future<void> _lockTag() async {
    final confirm = await showConfirmAlert(
      'nfcTagLockConfirm'.tr(),
      'nfcTagLock'.tr(),
    );
    if (!confirm) return;

    setState(() => _isSubmitting = true);

    try {
      await ref.read(lockNfcTagProvider.notifier).lock(widget.tag.id);
      if (mounted) {
        showSnackBar('nfcTagLocked'.tr());
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

  Future<void> _writeTag() async {
    setState(() => _isSubmitting = true);

    try {
      final availability = await FlutterNfcKit.nfcAvailability;
      if (availability != NFCAvailability.available) {
        if (mounted) {
          showErrorAlert(Exception('nfcNotAvailable'.tr()));
        }
        return;
      }

      final polledTag = await FlutterNfcKit.poll(
        iosAlertMessage: 'nfcTapToWrite'.tr(),
      );

      String? e;
      String? c;
      String? mac;

      if (polledTag.ndefAvailable == true) {
        final records = await FlutterNfcKit.readNDEFRecords(cached: false);
        if (records.isNotEmpty) {
          final firstRecord = records.first;
          final uriString = firstRecord.toString();
          final uri = Uri.parse(uriString);
          e = uri.queryParameters['e'];
          c = uri.queryParameters['c'];
          mac = uri.queryParameters['mac'];
        }
      }

      if (e == null || c == null || mac == null) {
        if (mounted) {
          showErrorAlert(Exception('nfcTagInvalid'.tr()));
        }
        return;
      }

      final deepLink = 'solian://phpass/${widget.tag.id}?e=$e&c=$c&mac=$mac';
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
