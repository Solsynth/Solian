import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/plugins/models/plugin_install_preview.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';

/// Shows a [SheetScaffold] preview of a plugin (permissions + metadata)
/// and returns `true` if the user confirms install.
///
/// Conflict handling:
/// - **upgrade** (newer version): override install is allowed directly
/// - **same / downgrade / unknown**: user must acknowledge override
Future<bool> showPluginInstallPreviewSheet(
  BuildContext context, {
  required PluginInstallPreview preview,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => PluginInstallPreviewSheet(preview: preview),
  );
  return result == true;
}

class PluginInstallPreviewSheet extends HookConsumerWidget {
  final PluginInstallPreview preview;

  const PluginInstallPreviewSheet({super.key, required this.preview});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final overrideAck = useState(false);

    final canConfirm = !preview.requiresOverrideAck || overrideAck.value;

    final (actionLabel, actionIcon, title) = switch (preview.conflict) {
      PluginInstallConflict.upgrade => (
        'pluginMarketplaceUpdate'.tr(),
        Symbols.upgrade,
        'pluginInstallPreviewUpdateTitle'.tr(
          namedArgs: {'name': preview.name},
        ),
      ),
      PluginInstallConflict.sameVersion => (
        'pluginInstallPreviewReplace'.tr(),
        Symbols.swap_horiz,
        'pluginInstallPreviewConflictTitle'.tr(
          namedArgs: {'name': preview.name},
        ),
      ),
      PluginInstallConflict.downgrade => (
        'pluginInstallPreviewDowngrade'.tr(),
        Symbols.history,
        'pluginInstallPreviewConflictTitle'.tr(
          namedArgs: {'name': preview.name},
        ),
      ),
      PluginInstallConflict.unknown => (
        'pluginInstallPreviewReplace'.tr(),
        Symbols.warning,
        'pluginInstallPreviewConflictTitle'.tr(
          namedArgs: {'name': preview.name},
        ),
      ),
      PluginInstallConflict.none => (
        'pluginMarketplaceInstall'.tr(),
        Symbols.download,
        'pluginInstallPreviewTitle'.tr(namedArgs: {'name': preview.name}),
      ),
    };

    return SheetScaffold(
      titleText: title,
      heightFactor: 0.85,
      actions: [
        FilledButton.icon(
          onPressed: canConfirm ? () => Navigator.of(context).pop(true) : null,
          icon: Icon(actionIcon, size: 18),
          label: Text(actionLabel),
          style: FilledButton.styleFrom(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            backgroundColor: preview.requiresOverrideAck && canConfirm
                ? cs.error
                : null,
            foregroundColor: preview.requiresOverrideAck && canConfirm
                ? cs.onError
                : null,
          ),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        children: [
          // Header card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PreviewIcon(preview: preview, size: 56),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        preview.name,
                        style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        [
                          if (preview.displayAttribution.isNotEmpty)
                            preview.displayAttribution,
                          'v${preview.version}',
                          if (preview.isInstalled &&
                              preview.installedVersion != null)
                            'pluginInstallPreviewInstalledVersion'.tr(
                              namedArgs: {
                                'version': preview.installedVersion!,
                              },
                            ),
                        ].where((s) => s.isNotEmpty).join(' · '),
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      if (preview.sourceHint != null &&
                          preview.sourceHint!.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          preview.sourceHint!,
                          style: tt.labelSmall?.copyWith(
                            color: cs.outline,
                            fontFamily: 'monospace',
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Conflict / version banners
          if (preview.conflict == PluginInstallConflict.upgrade) ...[
            const SizedBox(height: 12),
            _InfoBanner(
              icon: Symbols.upgrade,
              color: cs.primaryContainer,
              foreground: cs.onPrimaryContainer,
              text: 'pluginInstallPreviewUpgradeBanner'.tr(
                namedArgs: {
                  'from': preview.installedVersion ?? '?',
                  'to': preview.version,
                  'id': preview.id,
                },
              ),
            ),
          ] else if (preview.requiresOverrideAck) ...[
            const SizedBox(height: 12),
            _InfoBanner(
              icon: Symbols.warning,
              color: cs.errorContainer,
              foreground: cs.onErrorContainer,
              text: switch (preview.conflict) {
                PluginInstallConflict.sameVersion =>
                  'pluginInstallPreviewSameVersionBanner'.tr(
                    namedArgs: {
                      'version': preview.version,
                      'id': preview.id,
                      'name': preview.installedName ?? preview.name,
                    },
                  ),
                PluginInstallConflict.downgrade =>
                  'pluginInstallPreviewDowngradeBanner'.tr(
                    namedArgs: {
                      'from': preview.installedVersion ?? '?',
                      'to': preview.version,
                      'id': preview.id,
                    },
                  ),
                _ => 'pluginInstallPreviewUnknownConflictBanner'.tr(
                  namedArgs: {
                    'id': preview.id,
                    'installed': preview.installedVersion ?? '?',
                    'incoming': preview.version,
                  },
                ),
              },
            ),
            const SizedBox(height: 12),
            Material(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              child: CheckboxListTile(
                value: overrideAck.value,
                onChanged: (v) => overrideAck.value = v ?? false,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                title: Text(
                  'pluginInstallPreviewOverrideAck'.tr(),
                  style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  'pluginInstallPreviewOverrideAckHint'.tr(
                    namedArgs: {'id': preview.id},
                  ),
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ),
            ),
          ],

          // Description
          if (preview.description.trim().isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              'pluginInstallPreviewAbout'.tr(),
              style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(preview.description, style: tt.bodyMedium),
          ],

          // Details
          const SizedBox(height: 20),
          Text(
            'pluginInstallPreviewDetails'.tr(),
            style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _DetailRow(label: 'pluginInstallPreviewId'.tr(), value: preview.id),
          _DetailRow(
            label: 'pluginInstallPreviewVersion'.tr(),
            value: preview.version,
          ),
          if (preview.isInstalled && preview.installedVersion != null)
            _DetailRow(
              label: 'pluginInstallPreviewInstalledLabel'.tr(),
              value: 'v${preview.installedVersion}',
            ),
          if (preview.displayAttribution.isNotEmpty)
            _DetailRow(
              label: 'pluginInstallPreviewAuthor'.tr(),
              value: preview.displayAttribution,
            ),
          _DetailRow(
            label: 'pluginInstallPreviewEntry'.tr(),
            value: preview.entry,
          ),
          _DetailRow(
            label: 'pluginInstallPreviewBackground'.tr(),
            value: preview.background
                ? 'pluginInstallPreviewYes'.tr()
                : 'pluginInstallPreviewNo'.tr(),
          ),
          if (preview.packageSize != null)
            _DetailRow(
              label: 'pluginInstallPreviewPackageSize'.tr(),
              value: _formatBytes(preview.packageSize!),
            ),
          if (preview.packageSha256 != null &&
              preview.packageSha256!.trim().isNotEmpty)
            _DetailRow(
              label: 'pluginInstallPreviewChecksum'.tr(),
              value: _shortHash(preview.packageSha256!),
              mono: true,
            ),
          if (preview.homepage != null &&
              preview.homepage!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () async {
                  final uri = Uri.tryParse(preview.homepage!);
                  if (uri != null) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                icon: const Icon(Symbols.open_in_new, size: 18),
                label: Text('pluginMarketplaceHomepage'.tr()),
              ),
            ),
          ],

          // Permissions
          const SizedBox(height: 20),
          Text(
            'pluginInstallPreviewPermissions'.tr(),
            style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'pluginInstallPreviewPermissionsHint'.tr(),
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 10),
          if (preview.permissions.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Text(
                'pluginInstallPreviewNoPermissions'.tr(),
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
            )
          else
            ...preview.permissions.map(
              (key) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _PermissionTile(permissionKey: key),
              ),
            ),

          const SizedBox(height: 12),
          Text(
            'pluginInstallPreviewFooter'.tr(),
            style: tt.labelSmall?.copyWith(color: cs.outline),
          ),
        ],
      ),
    );
  }

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  static String _shortHash(String hash) {
    final h = hash.trim();
    if (h.length <= 16) return h;
    return '${h.substring(0, 8)}…${h.substring(h.length - 8)}';
  }
}

// ---------------------------------------------------------------------------

class _PreviewIcon extends StatelessWidget {
  final PluginInstallPreview preview;
  final double size;

  const _PreviewIcon({required this.preview, required this.size});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(size * 0.22);

    if (preview.icon != null) {
      return ClipRRect(
        borderRadius: radius,
        child: SizedBox(
          width: size,
          height: size,
          child: CloudImageWidget(
            file: preview.icon,
            noBlurhash: true,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: radius,
      ),
      alignment: Alignment.center,
      child: Icon(
        Symbols.extension,
        size: size * 0.48,
        color: cs.onPrimaryContainer,
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color foreground;
  final String text;

  const _InfoBanner({
    required this.icon,
    required this.color,
    required this.foreground,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: foreground),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool mono;

  const _DetailRow({
    required this.label,
    required this.value,
    this.mono = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: tt.bodySmall?.copyWith(
                fontFamily: mono ? 'monospace' : null,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  final String permissionKey;

  const _PermissionTile({required this.permissionKey});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final meta = PluginPermissionInfo.known[permissionKey];
    final title = meta?.$1.tr() ?? permissionKey;
    final description = meta?.$2.tr();
    final icon = _iconFor(permissionKey);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: cs.secondaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 18, color: cs.onSecondaryContainer),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (description != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  permissionKey,
                  style: tt.labelSmall?.copyWith(
                    color: cs.outline,
                    fontFamily: 'monospace',
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(String key) {
    return switch (key) {
      'eventsSubscribe' => Symbols.sensors,
      'commandsRegister' => Symbols.terminal,
      'uiRender' => Symbols.widgets,
      'networkInternet' => Symbols.public,
      'solarNetworkApi' => Symbols.cloud,
      'websocketSubscribe' => Symbols.sensors,
      'websocketSend' => Symbols.send,
      'sdkPostsRead' => Symbols.article,
      'sdkPostsCreate' => Symbols.edit_note,
      'sdkChatRead' => Symbols.chat,
      'sdkChatSend' => Symbols.send,
      'sdkDriveRead' => Symbols.folder_open,
      'sdkDriveWrite' => Symbols.upload_file,
      'sdkUserRead' => Symbols.person,
      'notify' => Symbols.notifications,
      'tasksSchedule' => Symbols.schedule,
      _ => Symbols.lock,
    };
  }
}
