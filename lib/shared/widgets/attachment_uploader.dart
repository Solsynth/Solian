import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/drive/screens/file_pool.dart';
import 'package:island/core/widgets/content/attachment_preview.dart';
import 'package:island/drive/drive_service.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gap/gap.dart';
import 'package:island/posts/widgets/compose/compose_shared.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class AttachmentUploadConfig {
  final String poolId;
  final bool hasConstraints;
  final bool encryptedUpload;

  const AttachmentUploadConfig({
    required this.poolId,
    required this.hasConstraints,
    this.encryptedUpload = false,
  });
}

class AttachmentUploaderSheet extends StatefulWidget {
  final WidgetRef ref;
  final ComposeState? state;
  final List<UniversalFile>? attachments;
  final int index;
  final bool encryptedUpload;

  const AttachmentUploaderSheet({
    super.key,
    required this.ref,
    this.state,
    this.attachments,
    required this.index,
    this.encryptedUpload = false,
  }) : assert(
         state != null || attachments != null,
         'Either state or attachments must be provided',
       );

  @override
  State<AttachmentUploaderSheet> createState() =>
      _AttachmentUploaderSheetState();
}

class _AttachmentUploaderSheetState extends State<AttachmentUploaderSheet> {
  String? selectedPoolId;

  @override
  Widget build(BuildContext context) {
    final attachment =
        widget.attachments?[widget.index] ??
        widget.state!.attachments.value[widget.index];

    return SheetScaffold(
      titleText: 'uploadAttachment'.tr(),
      child: FutureBuilder<List<SnFilePool>>(
        future: widget.ref.read(poolsProvider.future),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('errorLoadingPools'.tr()));
          }
          final pools = snapshot.data!;
          selectedPoolId ??= resolveDefaultPoolId(
            widget.ref.read(appSettingsProvider),
            pools,
          );

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
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
                          border: const OutlineInputBorder(),
                          hintText: 'choosePool'.tr(),
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
                              selectedPool.policyConfig?['allow_encryption'] ??
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
                                            ? Theme.of(context).colorScheme.error
                                            : Theme.of(
                                                context,
                                              ).colorScheme.onPrimaryContainer,
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
                      const Gap(4),
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
    final pools = await widget.ref.read(poolsProvider.future);
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
    );
  }

  Future<void> _confirmUpload() async {
    final config = await _getUploadConfig();
    if (config != null && mounted) {
      Navigator.pop(context, config);
    }
  }

  Future<int?> _getFileSize(UniversalFile attachment) async {
    if (attachment.data is XFile) {
      try {
        return await (attachment.data as XFile).length();
      } catch (e) {
        return null;
      }
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
