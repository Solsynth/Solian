import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/plugins/models/marketplace_plugin.dart';
import 'package:island/plugins/models/plugin_install_preview.dart';
import 'package:island/plugins/services/plugin_marketplace_service.dart';
import 'package:island/plugins/widgets/plugin_install_preview_sheet.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:island_plugin_foundation/island_plugin_foundation.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

// ---------------------------------------------------------------------------
// Pagination provider
// ---------------------------------------------------------------------------

final pluginMarketplaceProvider =
    AsyncNotifierProvider.autoDispose(PluginMarketplaceNotifier.new);

class PluginMarketplaceNotifier
    extends AsyncNotifier<PaginationState<MarketplacePlugin>>
    with
        AsyncPaginationController<MarketplacePlugin>,
        AsyncPaginationFilter<String?, MarketplacePlugin> {
  @override
  String? currentFilter;

  @override
  Future<List<MarketplacePlugin>> fetch() async {
    final client = ref.read(solarNetworkClientProvider);
    final service = PluginMarketplaceService(client.dio);
    final (items, total) = await service.listPlugins(
      take: PluginMarketplaceService.pageSize,
      offset: fetchedCount,
      search: currentFilter,
    );
    totalCount = total;
    return items;
  }
}

// ---------------------------------------------------------------------------
// Marketplace tab UI
// ---------------------------------------------------------------------------

class PluginMarketplaceTab extends HookConsumerWidget {
  const PluginMarketplaceTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final focusNode = useFocusNode();
    final debounceTimer = useState<Timer?>(null);
    final searchQuery = useState<String?>(null);

    final notifier = ref.watch(pluginMarketplaceProvider.notifier);
    final controller = useMemoized(() => PluginController.instance);
    useListenable(controller);

    useEffect(() {
      return () {
        debounceTimer.value?.cancel();
      };
    }, const []);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: SearchBar(
            controller: searchController,
            focusNode: focusNode,
            hintText: 'pluginMarketplaceSearch'.tr(),
            leading: const Icon(Symbols.search),
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 16),
            ),
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            trailing: [
              if (searchQuery.value != null && searchQuery.value!.isNotEmpty)
                IconButton.filledTonal(
                  icon: const Icon(Symbols.close),
                  onPressed: () {
                    searchQuery.value = null;
                    searchController.clear();
                    notifier.applyFilter(null);
                    focusNode.unfocus();
                  },
                  visualDensity: VisualDensity.compact,
                ),
            ],
            onChanged: (value) {
              debounceTimer.value?.cancel();
              debounceTimer.value = Timer(
                const Duration(milliseconds: 400),
                () {
                  final q = value.trim().isEmpty ? null : value.trim();
                  searchQuery.value = q;
                  notifier.applyFilter(q);
                },
              );
            },
            onSubmitted: (value) {
              final q = value.trim().isEmpty ? null : value.trim();
              searchQuery.value = q;
              notifier.applyFilter(q);
              focusNode.unfocus();
            },
          ),
        ),
        Expanded(
          child: PaginationList(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            provider: pluginMarketplaceProvider,
            notifier: pluginMarketplaceProvider.notifier,
            itemBuilder: (context, idx, plugin) => _MarketplacePluginTile(
              plugin: plugin,
              isInstalled: controller.plugins.containsKey(plugin.pluginId),
              installedVersion:
                  controller.plugins[plugin.pluginId]?.manifest.version,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Marketplace list tile
// ---------------------------------------------------------------------------

class _MarketplacePluginTile extends HookConsumerWidget {
  final MarketplacePlugin plugin;
  final bool isInstalled;
  final String? installedVersion;

  const _MarketplacePluginTile({
    required this.plugin,
    required this.isInstalled,
    this.installedVersion,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final installing = useState(false);

    final canInstall = plugin.hasInstallablePackage && !installing.value;
    final subtitle = [
      if (plugin.displayAuthor.isNotEmpty) plugin.displayAuthor,
      'v${plugin.version}',
      if (plugin.permissions.isNotEmpty)
        'pluginInstallPreviewPermissionCount'.plural(plugin.permissions.length),
      if (plugin.description != null && plugin.description!.trim().isNotEmpty)
        plugin.description!.trim(),
    ].join(' · ');

    Future<void> openPreviewAndInstall() async {
      if (!plugin.hasInstallablePackage || installing.value) return;

      final controller = PluginController.instance;
      final preview = PluginInstallPreview.fromMarketplaceWithController(
        plugin,
        controller,
      );

      // Newer version of an already-installed plugin: override after a quick
      // confirm is still shown in the preview (Update), no extra override ack.
      final confirmed = await showPluginInstallPreviewSheet(
        context,
        preview: preview,
      );
      if (!confirmed || !context.mounted) return;

      installing.value = true;
      try {
        final client = ref.read(solarNetworkClientProvider);
        final service = PluginMarketplaceService(client.dio);
        final ok = await service.installPlugin(plugin, controller);
        if (!context.mounted) return;
        final message = !ok
            ? 'pluginMarketplaceInstallFailed'.tr(
                namedArgs: {'name': plugin.name},
              )
            : switch (preview.conflict) {
                PluginInstallConflict.upgrade =>
                  'pluginMarketplaceUpdated'.tr(
                    namedArgs: {
                      'name': plugin.name,
                      'version': plugin.version,
                    },
                  ),
                _ => 'pluginMarketplaceInstalled'.tr(
                  namedArgs: {'name': plugin.name},
                ),
              };
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } finally {
        if (context.mounted) installing.value = false;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        color: cs.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.4)),
        ),
        child: InkWell(
          onTap: canInstall || isInstalled ? openPreviewAndInstall : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                _PluginIcon(plugin: plugin, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plugin.name,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (installing.value)
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else if (isInstalled)
                  FilledButton.tonal(
                    onPressed: canInstall ? openPreviewAndInstall : null,
                    style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: Text(
                      () {
                        final conflict =
                            PluginInstallPreview.resolveConflict(
                          incomingVersion: plugin.version,
                          installedVersion: installedVersion,
                        );
                        return switch (conflict) {
                          PluginInstallConflict.upgrade =>
                            'pluginMarketplaceUpdate'.tr(),
                          PluginInstallConflict.downgrade =>
                            'pluginInstallPreviewDowngrade'.tr(),
                          _ => 'pluginMarketplaceInstalledLabel'.tr(),
                        };
                      }(),
                    ),
                  )
                else
                  FilledButton(
                    onPressed: canInstall ? openPreviewAndInstall : null,
                    style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: Text('pluginMarketplaceInstall'.tr()),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PluginIcon extends StatelessWidget {
  final MarketplacePlugin plugin;
  final double size;

  const _PluginIcon({required this.plugin, required this.size});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(size * 0.25);

    if (plugin.icon != null) {
      return ClipRRect(
        borderRadius: radius,
        child: SizedBox(
          width: size,
          height: size,
          child: CloudImageWidget(
            file: plugin.icon,
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
        size: size * 0.5,
        color: cs.onPrimaryContainer,
      ),
    );
  }
}
