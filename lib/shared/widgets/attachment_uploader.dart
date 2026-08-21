import 'dart:async';

import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:material_ui/material_ui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/drive/screens/file_pool.dart';
import 'package:island/core/widgets/content/attachment_preview.dart';
import 'package:island/drive/drive_service.dart';
import 'package:island/shared/widgets/attention_modal.dart';
import 'package:island/shared/widgets/layouts/attention_modal_scaffold.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:island/core/services/responsive.dart';
import 'package:gap/gap.dart';
import 'package:island/posts/widgets/compose/compose_shared.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class AttachmentUploadConfig {
  final String poolId;
  final bool hasConstraints;
  final bool encryptedUpload;
  final bool imageCompressionEnabled;
  final int imageCompressionQuality;

  const AttachmentUploadConfig({
    required this.poolId,
    required this.hasConstraints,
    required this.imageCompressionEnabled,
    required this.imageCompressionQuality,
    this.encryptedUpload = false,
  });
}

Future<AttachmentUploadConfig?> showAttachmentUploaderModal({
  required WidgetRef ref,
  ComposeState? state,
  List<UniversalFile>? attachments,
  required int index,
  bool encryptedUpload = false,
}) {
  final container = ProviderScope.containerOf(ref.context, listen: false);
  final completer = Completer<AttachmentUploadConfig?>();

  void complete(AttachmentUploadConfig? config) {
    if (!completer.isCompleted) {
      completer.complete(config);
    }
  }

  unawaited(
    showAttentionModal(
      id: 'attachment-upload',
      replaceIfExists: true,
      barrierDismissible: true,
      builder: (context, dismiss) => AttachmentUploaderModal(
        container: container,
        state: state,
        attachments: attachments,
        index: index,
        encryptedUpload: encryptedUpload,
        onConfirm: (config) {
          complete(config);
          dismiss();
        },
        onDismiss: () {
          complete(null);
          dismiss();
        },
      ),
    ).whenComplete(() => complete(null)),
  );

  return completer.future;
}

class AttachmentUploaderModal extends StatefulWidget {
  final ProviderContainer container;
  final ComposeState? state;
  final List<UniversalFile>? attachments;
  final int index;
  final bool encryptedUpload;
  final ValueChanged<AttachmentUploadConfig> onConfirm;
  final VoidCallback onDismiss;

  const AttachmentUploaderModal({
    super.key,
    required this.container,
    this.state,
    this.attachments,
    required this.index,
    this.encryptedUpload = false,
    required this.onConfirm,
    required this.onDismiss,
  }) : assert(
         state != null || attachments != null,
         'Either state or attachments must be provided',
       );

  @override
  State<AttachmentUploaderModal> createState() =>
      _AttachmentUploaderModalState();
}

class _AttachmentUploaderModalState extends State<AttachmentUploaderModal> {
  bool imageCompressionEnabled = true;
  int imageCompressionQuality = 80;

  @override
  void initState() {
    super.initState();
    final settings = widget.container.read(appSettingsProvider);
    imageCompressionEnabled = settings.imageCompressionEnabled;
    imageCompressionQuality = settings.imageCompressionQuality;
  }

  String? selectedPoolId;

  @override
  Widget build(BuildContext context) {
    final attachment =
        widget.attachments?[widget.index] ??
        widget.state!.attachments.value[widget.index];

    return AttentionModalScaffold(
      maxWidth: 1000,
      titleText: 'uploadAttachment'.tr(),
      onDismiss: widget.onDismiss,
      child: FutureBuilder<List<SnFilePool>>(
        future: widget.container.read(poolsProvider.future),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('errorLoadingPools'.tr()));
          }
          final pools = snapshot.data!;
          selectedPoolId ??= resolveDefaultPoolId(
            widget.container.read(appSettingsProvider),
            pools,
          );

          final previewSection = Padding(
            padding: isWideScreen(context) ? const EdgeInsets.all(16) : .zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: 6,
                  children: [
                    const Icon(Symbols.info, size: 18),
                    Text(
                      'attachmentPreview'.tr(),
                      style: Theme.of(context).textTheme.titleMedium,
                    ).fontSize(13),
                  ],
                ).padding(horizontal: 4),
                const Gap(8),
                AttachmentPreview(
                  item: attachment,
                  isCompact: true,
                  isEncryptedUpload: widget.encryptedUpload,
                ),
              ],
            ),
          );
          final previewContent = SingleChildScrollView(child: previewSection);
          final wide = isTwoPaneLayout(context);
          final settingsContent = SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  margin: .zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<String>(
                          value: selectedPoolId,
                          items: pools.map((pool) {
                            return DropdownMenuItem<String>(
                              value: pool.id,
                              child: Text(pool.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedPoolId = value;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'selectPool'.tr(),

                            hintText: 'choosePool'.tr(),
                          ),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text('compressionSettings').tr(),
                          subtitle: Text('compressionHint').tr(),
                          leading: const Icon(Symbols.compress),
                          trailing: Switch(
                            value: imageCompressionEnabled,
                            onChanged: (value) {
                              setState(() {
                                imageCompressionEnabled = value;
                              });
                            },
                          ),
                        ),
                        if (imageCompressionEnabled)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text('compressionQuality').tr(),
                            leading: const Icon(Symbols.tune),
                            subtitle: Slider(
                              value: imageCompressionQuality.toDouble(),
                              min: 10,
                              max: 100,
                              divisions: 18,
                              year2023: true,
                              label: '$imageCompressionQuality%',
                              padding: EdgeInsets.zero,
                              onChanged: (value) {
                                setState(() {
                                  imageCompressionQuality = value.round();
                                });
                              },
                            ),
                          ),
                        const Gap(16),
                        FutureBuilder<int?>(
                          future: _getFileSize(attachment),
                          builder: (context, sizeSnapshot) {
                            if (!sizeSnapshot.hasData) {
                              return const SizedBox.shrink();
                            }
                            final fileSize = sizeSnapshot.data!;
                            final selectedPool = pools.firstWhere(
                              (p) => p.id == selectedPoolId,
                            );

                            // Check file size limit
                            final maxFileSize =
                                selectedPool.policyConfig?['max_file_size']
                                    as int?;
                            final fileSizeExceeded =
                                maxFileSize != null && fileSize > maxFileSize;

                            // Check accepted types
                            final acceptTypes =
                                (selectedPool.policyConfig?['accept_types']
                                        as List?)
                                    ?.cast<String>();
                            final mimeType =
                                attachment.data.mimeType ??
                                ComposeLogic.getMimeTypeFromFileType(
                                  attachment.type,
                                );
                            final typeAccepted = _isMimeTypeAccepted(
                              mimeType,
                              acceptTypes,
                            );

                            final hasIssues = fileSizeExceeded || !typeAccepted;
                            final rawAllowEncryption =
                                selectedPool
                                    .policyConfig?['allow_encryption'] ??
                                selectedPool.policyConfig?['allowEncryption'];
                            final allowEncryption = rawAllowEncryption is bool
                                ? rawAllowEncryption
                                : true;
                            final isEncryptedOnCloud =
                                attachment.isOnCloud &&
                                attachment.data is SnCloudFile &&
                                DriveE2eeFileEnvelope.isEncryptedFile(
                                  attachment.data as SnCloudFile,
                                );
                            final shouldEncrypt =
                                widget.encryptedUpload || isEncryptedOnCloud;
                            final encryptionBlocked =
                                shouldEncrypt && !allowEncryption;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (shouldEncrypt) ...[
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: encryptionBlocked
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.errorContainer
                                          : Theme.of(
                                              context,
                                            ).colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          encryptionBlocked
                                              ? Symbols.warning
                                              : Symbols.lock,
                                          size: 18,
                                          color: encryptionBlocked
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.error
                                              : Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer,
                                        ),
                                        const Gap(8),
                                        Expanded(
                                          child: Text(
                                            encryptionBlocked
                                                ? 'Encrypted upload blocked by selected pool policy.'
                                                : 'Encrypted upload enabled.',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: encryptionBlocked
                                                      ? Theme.of(
                                                          context,
                                                        ).colorScheme.error
                                                      : Theme.of(context)
                                                            .colorScheme
                                                            .onPrimaryContainer,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Gap(12),
                                ],
                                if (hasIssues) ...[
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.errorContainer,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Symbols.warning,
                                              size: 18,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.error,
                                            ),
                                            const Gap(8),
                                            Text(
                                              'uploadConstraints'.tr(),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    color: Theme.of(
                                                      context,
                                                    ).colorScheme.error,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          ],
                                        ),
                                        if (fileSizeExceeded) ...[
                                          const Gap(4),
                                          Text(
                                            'fileSizeExceeded'.tr(
                                              args: [
                                                _formatFileSize(maxFileSize),
                                              ],
                                            ),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.error,
                                                ),
                                          ),
                                        ],
                                        if (!typeAccepted) ...[
                                          const Gap(4),
                                          Text(
                                            'fileTypeNotAccepted'.tr(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.error,
                                                ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const Gap(12),
                                ],
                                Row(
                                  spacing: 6,
                                  children: [
                                    const Icon(
                                      Symbols.account_balance_wallet,
                                      size: 18,
                                    ),
                                    Expanded(
                                      child: Text(
                                        'quotaCostInfo'.tr(
                                          args: [
                                            _formatQuotaCost(
                                              fileSize,
                                              selectedPool,
                                            ),
                                          ],
                                        ),
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                      ).fontSize(13),
                                    ),
                                  ],
                                ).padding(horizontal: 4),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                if (!wide) ...[const Gap(16), previewSection],
              ],
            ),
          );

          return Column(
            children: [
              Expanded(
                child: wide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(flex: 2, child: previewContent),
                          const Gap(12),
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                right: 16,
                                top: 40,
                              ),
                              child: settingsContent,
                            ),
                          ),
                        ],
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: settingsContent,
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Symbols.close),
                      label: Text('cancel').tr(),
                    ),
                    const Gap(8),
                    TextButton.icon(
                      onPressed: () => _confirmUpload(),
                      icon: const Icon(Symbols.upload),
                      label: Text('upload').tr(),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<AttachmentUploadConfig?> _getUploadConfig() async {
    final attachment =
        widget.attachments?[widget.index] ??
        widget.state!.attachments.value[widget.index];
    final fileSize = await _getFileSize(attachment);

    if (fileSize == null) return null;

    // Get the selected pool to check constraints
    final pools = await widget.container.read(poolsProvider.future);
    final selectedPool = pools.firstWhere((p) => p.id == selectedPoolId);

    // Check constraints
    final maxFileSize = selectedPool.policyConfig?['max_file_size'] as int?;
    final fileSizeExceeded = maxFileSize != null && fileSize > maxFileSize;

    final acceptTypes = (selectedPool.policyConfig?['accept_types'] as List?)
        ?.cast<String>();
    final mimeType =
        attachment.data.mimeType ??
        ComposeLogic.getMimeTypeFromFileType(attachment.type);
    final typeAccepted = _isMimeTypeAccepted(mimeType, acceptTypes);

    final hasConstraints = fileSizeExceeded || !typeAccepted;
    final rawAllowEncryption =
        selectedPool.policyConfig?['allow_encryption'] ??
        selectedPool.policyConfig?['allowEncryption'];
    final allowEncryption = rawAllowEncryption is bool
        ? rawAllowEncryption
        : true;
    final isEncryptedOnCloud =
        attachment.isOnCloud &&
        attachment.data is SnCloudFile &&
        DriveE2eeFileEnvelope.isEncryptedFile(attachment.data as SnCloudFile);
    final shouldEncrypt = widget.encryptedUpload || isEncryptedOnCloud;
    final encryptionBlocked = shouldEncrypt && !allowEncryption;

    return AttachmentUploadConfig(
      poolId: selectedPoolId!,
      hasConstraints: hasConstraints || encryptionBlocked,
      encryptedUpload: widget.encryptedUpload,
      imageCompressionEnabled: imageCompressionEnabled,
      imageCompressionQuality: imageCompressionQuality,
    );
  }

  Future<void> _confirmUpload() async {
    final config = await _getUploadConfig();
    if (config != null && mounted) {
      widget.onConfirm(config);
    }
  }

  Future<int?> _getFileSize(UniversalFile attachment) async {
    if (attachment.data is XFile) {
      try {
        return await (attachment.data as XFile).length();
      } catch (e) {
        return null;
      }
    } else if (attachment.data is IDisplayableCloudFile) {
      return (attachment.data as IDisplayableCloudFile).size;
    } else if (attachment.data is SnCloudFile) {
      return (attachment.data as SnCloudFile).size;
    } else if (attachment.data is List<int>) {
      return (attachment.data as List<int>).length;
    } else if (attachment.data is Uint8List) {
      return (attachment.data as Uint8List).length;
    }
    return null;
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes >= 1073741824) {
      return '${(bytes / 1073741824).toStringAsFixed(1)} GB';
    } else if (bytes >= 1048576) {
      return '${(bytes / 1048576).toStringAsFixed(1)} MB';
    } else if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '$bytes bytes';
    }
  }

  String _formatQuotaCost(int fileSize, SnFilePool pool) {
    final costMultiplier = pool.billingConfig?['cost_multiplier'] ?? 1.0;
    final quotaCost = ((fileSize / 1024 / 1024) * costMultiplier).round();
    return _formatNumber(quotaCost);
  }

  bool _isMimeTypeAccepted(String mimeType, List<String>? acceptTypes) {
    if (acceptTypes == null || acceptTypes.isEmpty) return true;
    return acceptTypes.any((type) {
      if (type.endsWith('/*')) {
        final mainType = type.substring(0, type.length - 2);
        return mimeType.startsWith('$mainType/');
      } else {
        return mimeType == type;
      }
    });
  }
}
