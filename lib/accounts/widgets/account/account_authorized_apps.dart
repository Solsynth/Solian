import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/models/authorized_app.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/time.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/extended_refresh_indicator.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/shared/widgets/response.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'account_authorized_apps.g.dart';

@riverpod
Future<List<AuthorizedApp>> authorizedApps(Ref ref) async {
  final padlockApi = ref.watch(solarNetworkClientProvider).padlock;
  final response = await padlockApi.getAuthorizedApps();
  return response.map(AuthorizedApp.fromJson).toList();
}

class _AuthorizedAppCard extends StatelessWidget {
  final AuthorizedApp app;
  final Function(String) deauthorize;
  final VoidCallback? onEditScopes;

  const _AuthorizedAppCard({
    required this.app,
    required this.deauthorize,
    this.onEditScopes,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final lastUsedAt = app.lastUsedAt;
    final typeIcon = _typeIcon(app.type);
    final hasBackground = app.background != null;
    final textShadow = _textShadow(hasBackground);

    final card = Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              if (hasBackground)
                Positioned.fill(
                  child: CloudImageWidget(
                    file: app.background,
                    aspectRatio: 16 / 9,
                    noBlurhash: true,
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
                          Colors.black.withOpacity(0.08),
                          Colors.black.withOpacity(0.35),
                        ],
                      ),
                    ),
                  ),
                ),
              Align(
                alignment: hasBackground
                    ? Alignment.bottomLeft
                    : Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      app.picture != null
                          ? ProfilePictureWidget(
                              file: app.picture,
                              radius: 24,
                              borderRadius: 14,
                              fallbackIcon: typeIcon,
                            )
                          : Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                typeIcon,
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                      Gap(12),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              app.appName ?? app.appSlug ?? 'unknownApp'.tr(),
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(shadows: textShadow),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if ((app.appDescription ?? '').isNotEmpty)
                              Text(
                                app.appDescription!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: hasBackground
                                          ? Colors.white.withOpacity(0.9)
                                          : colorScheme.onSurfaceVariant,
                                      shadows: textShadow,
                                    ),
                              ),
                            Text(
                              lastUsedAt != null
                                  ? 'lastActiveAt'.tr(
                                      args: [_formatDate(lastUsedAt)],
                                    )
                                  : 'neverUsed'.tr(),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: hasBackground
                                        ? Colors.white.withOpacity(0.82)
                                        : colorScheme.onSurfaceVariant,
                                    shadows: textShadow,
                                  ),
                            ),
                            if (app.scopes.isNotEmpty) ...[
                              Gap(6),
                              GestureDetector(
                                onTap: onEditScopes,
                                child: Wrap(
                                  spacing: 4,
                                  runSpacing: 2,
                                  children: app.scopes.map((scope) {
                                    return Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: hasBackground
                                            ? Colors.white.withOpacity(0.15)
                                            : colorScheme.secondaryContainer,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        scope,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              color: hasBackground
                                                  ? Colors.white
                                                  : colorScheme
                                                        .onSecondaryContainer,
                                              shadows: textShadow,
                                            ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.logout,
                          color: hasBackground ? Colors.white : null,
                          shadows: textShadow,
                        ),
                        tooltip: 'deauthorize'.tr(),
                        onPressed: () => deauthorize(app.id),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (hasBackground) {
      return AspectRatio(aspectRatio: 16 / 9, child: card);
    }

    return card;
  }

  IconData _typeIcon(int type) {
    switch (type) {
      case 0:
        return Icons.security;
      default:
        return Icons.connecting_airports;
    }
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      return dt.toLocal().formatSystem();
    } catch (_) {
      return isoDate;
    }
  }

  List<Shadow>? _textShadow(bool enabled) {
    if (!enabled) return null;
    return const [
      Shadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, 2)),
    ];
  }
}

class AccountAuthorizedAppsSheet extends HookConsumerWidget {
  const AccountAuthorizedAppsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apps = ref.watch(authorizedAppsProvider);

    void deauthorizeApp(String id) async {
      final confirm = await showConfirmAlert(
        'authorizedAppDeauthorizeHint'.tr(),
        'deauthorize'.tr(),
        isDanger: true,
      );
      if (!confirm || !context.mounted) return;
      try {
        final padlockApi = ref.read(solarNetworkClientProvider).padlock;
        await padlockApi.deauthorizeApp(id);
        ref.invalidate(authorizedAppsProvider);
      } catch (err) {
        showErrorAlert(err);
      }
    }

    return SheetScaffold(
      titleText: 'authorizedApps'.tr(),
      child: apps.when(
        data: (data) => data.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.app_settings_alt,
                      size: 64,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    Gap(16),
                    Text(
                      'dataEmpty'.tr(),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
            : ExtendedRefreshIndicator(
                onRefresh: () =>
                    Future.sync(() => ref.invalidate(authorizedAppsProvider)),
                child: ListView.builder(
                  padding: EdgeInsets.only(bottom: 16, top: 8),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final app = data[index];
                    return _AuthorizedAppCard(
                      app: app,
                      deauthorize: deauthorizeApp,
                      onEditScopes: () async {
                        final result = await showModalBottomSheet<List<String>>(
                          context: context,
                          useSafeArea: true,
                          builder: (_) =>
                              _ScopesEditor(initialScopes: app.scopes),
                        );
                        if (result == null || !context.mounted) return;
                        showLoadingModal(context);
                        try {
                          await ref
                              .read(solarNetworkClientProvider)
                              .padlock
                              .authorizeAppScopes(app.id, result);
                          showSnackBar('scopesUpdated'.tr());
                          ref.invalidate(authorizedAppsProvider);
                        } catch (err) {
                          showErrorAlert(err);
                        }
                        if (context.mounted) hideLoadingModal(context);
                      },
                    );
                  },
                ),
              ),
        error: (err, _) => ResponseErrorWidget(
          error: err,
          onRetry: () => ref.invalidate(authorizedAppsProvider),
        ),
        loading: () => ResponseLoadingWidget(),
      ),
    );
  }
}

const _knownScopes = [
  'openid',
  'profile',
  'email',
  'address',
  'phone',
  'offline_access',
];

class _ScopesEditor extends StatefulWidget {
  final List<String> initialScopes;
  const _ScopesEditor({required this.initialScopes});

  @override
  State<_ScopesEditor> createState() => _ScopesEditorState();
}

class _ScopesEditorState extends State<_ScopesEditor> {
  late Set<String> _selectedScopes;
  final _customController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedScopes = widget.initialScopes.toSet();
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  void _addCustom() {
    final text = _customController.text.trim();
    if (text.isNotEmpty) {
      setState(() => _selectedScopes.add(text));
      _customController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SheetScaffold(
      titleText: 'Scopes',
      child: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final scope in _knownScopes)
                FilterChip(
                  label: Text(scope),
                  selected: _selectedScopes.contains(scope),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedScopes.add(scope);
                      } else {
                        _selectedScopes.remove(scope);
                      }
                    });
                  },
                ),
              for (final scope in _selectedScopes.difference(
                _knownScopes.toSet(),
              ))
                InputChip(
                  label: Text(scope),
                  onDeleted: () {
                    setState(() => _selectedScopes.remove(scope));
                  },
                ),
            ],
          ),
          Gap(12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _customController,
                  decoration: InputDecoration(
                    hintText: 'Add custom scope',
                  ),
                  onSubmitted: (_) => _addCustom(),
                ),
              ),
              Gap(8),
              IconButton(onPressed: _addCustom, icon: Icon(Icons.add)),
            ],
          ),
          Gap(16),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: () =>
                  Navigator.pop(context, _selectedScopes.toList()),
              child: Text('save'.tr()),
            ),
          ),
        ],
      ),
    );
  }
}
