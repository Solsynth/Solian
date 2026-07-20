import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/core/server_compatibility.dart';
import 'package:material_symbols_icons/symbols.dart';

const _kTilePadding = EdgeInsets.only(left: 24, right: 16);

class ServerCapabilitiesPreview extends HookConsumerWidget {
  final String serverUrl;

  const ServerCapabilitiesPreview({super.key, required this.serverUrl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refreshNonce = useState(0);
    final metadataResponse = useFuture(
      useMemoized(
        () => ref
            .read(solarNetworkClientProvider)
            .dio
            .get<Map<String, dynamic>>(
              '/meta',
              options: Options(validateStatus: (_) => true),
            ),
        [serverUrl, refreshNonce.value],
      ),
    );
    final healthResponse = useFuture(
      useMemoized(
        () => ref
            .read(solarNetworkClientProvider)
            .dio
            .get<Map<String, dynamic>>(
              '/health',
              options: Options(validateStatus: (_) => true),
            ),
        [serverUrl, refreshNonce.value],
      ),
    );

    final metadata = metadataResponse.data?.data;
    final health = healthResponse.data?.data;
    final compatibility = metadata == null
        ? null
        : ServerCompatibility.fromMetadata(metadata);
    final services = _parseServices(health?['status']);
    final downServices = services.values.where((service) => !service.isHealthy);
    final isLoading =
        metadataResponse.connectionState == ConnectionState.waiting ||
        healthResponse.connectionState == ConnectionState.waiting;
    final isHealthy = health?['aggregated'] == true && health?['ready'] == true;
    final subtitle = isLoading
        ? 'settingsServerCapabilitiesLoading'.tr()
        : metadata == null && health == null
        ? 'settingsServerCapabilitiesUnavailable'.tr()
        : [
            if (compatibility?.isCompatible == true)
              'settingsServerCapabilitiesCompatible'.tr()
            else if (compatibility != null)
              'settingsServerCapabilitiesIncompatible'.tr(),
            if (health != null)
              isHealthy
                  ? 'settingsServerServicesHealthy'.tr()
                  : 'settingsServerServicesDown'.tr(
                      args: ['${downServices.length}'],
                    ),
          ].join(' · ');
    final icon = compatibility?.isCompatible == true && isHealthy
        ? Symbols.check_circle
        : compatibility == null && health == null
        ? Symbols.sync_problem
        : Symbols.error;
    final color = compatibility?.isCompatible == true && isHealthy
        ? Theme.of(context).colorScheme.primary
        : compatibility == null && health == null
        ? Theme.of(context).colorScheme.onSurfaceVariant
        : Theme.of(context).colorScheme.error;

    return ListTile(
      minLeadingWidth: 48,
      contentPadding: _kTilePadding,
      leading: Icon(icon, color: color),
      title: Text('settingsServerCapabilities').tr(),
      subtitle: Text(subtitle),
      trailing: IconButton(
        tooltip: 'settingsServerCapabilitiesRefresh'.tr(),
        icon: const Icon(Symbols.refresh),
        onPressed: () => refreshNonce.value++,
      ),
      onTap: metadata == null && health == null
          ? null
          : () => showModalBottomSheet<void>(
              context: context,
              useSafeArea: true,
              builder: (_) => _ServerCapabilitiesSheet(
                metadata: metadata,
                compatibility: compatibility,
                health: health,
              ),
            ),
    );
  }
}

class _ServerCapabilitiesSheet extends StatelessWidget {
  final Map<String, dynamic>? metadata;
  final ServerCompatibility? compatibility;
  final Map<String, dynamic>? health;

  const _ServerCapabilitiesSheet({
    required this.metadata,
    required this.compatibility,
    required this.health,
  });

  @override
  Widget build(BuildContext context) {
    final serverCapabilities = _parseCapabilities(metadata?['capabilities']);
    final apiRevision = metadata?['api_revision'];
    final minimumRevision = metadata?['minimum_revision'];
    final services = _parseServices(health?['status']);
    final downServices = Map<String, _ServiceHealth>.fromEntries(
      services.entries.where((entry) => !entry.value.isHealthy),
    );

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, controller) => ListView(
        controller: controller,
        children: [
          if (metadata != null)
            ListTile(
              title: Text('settingsServerCapabilities').tr(),
              subtitle: Text(
                'settingsServerCapabilitiesProtocol'.tr(
                  args: [
                    '$apiRevision',
                    '$minimumRevision',
                    '$kSupportedServerApiRevision',
                  ],
                ),
              ),
              trailing: Icon(
                compatibility!.isCompatible
                    ? Symbols.check_circle
                    : Symbols.error,
                color: compatibility!.isCompatible
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.error,
              ),
            ),
          if (health != null)
            _ServicesSection(
              title: 'settingsServerServices'.tr(),
              services: services,
              isHealthy:
                  health!['aggregated'] == true && health!['ready'] == true,
            ),
          if (downServices.isNotEmpty)
            _ServicesSection(
              title: 'settingsServerServicesDown'.tr(
                args: ['${downServices.length}'],
              ),
              services: downServices,
              isHealthy: false,
              initiallyExpanded: true,
            ),
          const Divider(),
          _CapabilitiesSection(
            title: 'settingsClientCapabilities'.tr(),
            capabilities: {
              for (final entry in kClientSupportedCapabilities.entries)
                entry.key: _CapabilityInfo(
                  enabled: true,
                  revision: entry.value,
                ),
            },
          ),
          const Divider(),
          _CapabilitiesSection(
            title: 'settingsServerProvidedCapabilities'.tr(),
            capabilities: serverCapabilities,
          ),
        ],
      ),
    );
  }
}

class _CapabilitiesSection extends StatelessWidget {
  final String title;
  final Map<String, _CapabilityInfo> capabilities;

  const _CapabilitiesSection({required this.title, required this.capabilities});

  @override
  Widget build(BuildContext context) {
    final entries = capabilities.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return ExpansionTile(
      title: Text(title),
      subtitle: Text(
        'settingsServerCapabilitiesCount'.tr(args: ['${entries.length}']),
      ),
      children: [
        for (final entry in entries)
          ListTile(
            dense: true,
            title: Text(entry.key),
            leading: Icon(
              entry.value.enabled ? Symbols.check : Symbols.block,
              color: entry.value.enabled
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.error,
            ),
            trailing: Text('r${entry.value.revision ?? 0}'),
          ),
      ],
    );
  }
}

class _CapabilityInfo {
  final bool enabled;
  final int? revision;

  const _CapabilityInfo({required this.enabled, this.revision});
}

class _ServiceHealth {
  final bool isHealthy;
  final String? lastChecked;

  const _ServiceHealth({required this.isHealthy, this.lastChecked});
}

class _ServicesSection extends StatelessWidget {
  final String title;
  final Map<String, _ServiceHealth> services;
  final bool isHealthy;
  final bool initiallyExpanded;

  const _ServicesSection({
    required this.title,
    required this.services,
    required this.isHealthy,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final entries = services.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return ExpansionTile(
      initiallyExpanded: initiallyExpanded,
      title: Text(title),
      subtitle: Text(
        'settingsServerCapabilitiesCount'.tr(args: ['${entries.length}']),
      ),
      leading: Icon(
        isHealthy ? Symbols.check_circle : Symbols.error,
        color: isHealthy
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.error,
      ),
      children: [
        for (final entry in entries)
          ListTile(
            dense: true,
            title: Text(entry.key),
            subtitle: entry.value.lastChecked == null
                ? null
                : Text(entry.value.lastChecked!),
            leading: Icon(
              entry.value.isHealthy ? Symbols.check : Symbols.error,
              color: entry.value.isHealthy
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.error,
            ),
          ),
      ],
    );
  }
}

Map<String, _CapabilityInfo> _parseCapabilities(Object? rawCapabilities) {
  if (rawCapabilities is! Map) return const {};
  return {
    for (final entry in rawCapabilities.entries)
      if (entry.key is String && entry.value is Map)
        entry.key as String: _CapabilityInfo(
          enabled: (entry.value as Map)['enabled'] == true,
          revision: (entry.value as Map)['revision'] as int?,
        ),
  };
}

Map<String, _ServiceHealth> _parseServices(Object? rawServices) {
  if (rawServices is! Map) return const {};
  return {
    for (final entry in rawServices.entries)
      if (entry.key is String && entry.value is Map)
        entry.key as String: _ServiceHealth(
          isHealthy: (entry.value as Map)['is_healthy'] == true,
          lastChecked: (entry.value as Map)['last_checked'] as String?,
        ),
  };
}
