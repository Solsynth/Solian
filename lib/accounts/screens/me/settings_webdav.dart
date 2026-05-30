import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';

part 'settings_webdav.g.dart';

// --- Models ---

class WebdavToken {
  final String id;
  final String label;
  final String? secret;
  final DateTime createdAt;

  WebdavToken({
    required this.id,
    required this.label,
    this.secret,
    required this.createdAt,
  });

  factory WebdavToken.fromJson(Map<String, dynamic> json) {
    return WebdavToken(
      id: json['id'] as String,
      label: json['label'] as String,
      secret: json['secret'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class S3Token {
  final String id;
  final String label;
  final String? poolId;
  final String? accessKey;
  final String? secretKey;
  final DateTime createdAt;

  S3Token({
    required this.id,
    required this.label,
    this.poolId,
    this.accessKey,
    this.secretKey,
    required this.createdAt,
  });

  factory S3Token.fromJson(Map<String, dynamic> json) {
    return S3Token(
      id: json['id'] as String,
      label: json['label'] as String,
      poolId: json['pool_id'] as String?,
      accessKey: json['access_key'] as String?,
      secretKey: json['secret_key'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class StoragePool {
  final String id;
  final String name;
  final String? description;
  final StoragePoolConfig? storageConfig;
  final DateTime createdAt;

  StoragePool({
    required this.id,
    required this.name,
    this.description,
    this.storageConfig,
    required this.createdAt,
  });

  factory StoragePool.fromJson(Map<String, dynamic> json) {
    return StoragePool(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      storageConfig: json['storage_config'] != null
          ? StoragePoolConfig.fromJson(
              json['storage_config'] as Map<String, dynamic>,
            )
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class StoragePoolConfig {
  final String? endpoint;
  final String? bucket;
  final bool enableSsl;

  StoragePoolConfig({this.endpoint, this.bucket, this.enableSsl = false});

  factory StoragePoolConfig.fromJson(Map<String, dynamic> json) {
    return StoragePoolConfig(
      endpoint: json['endpoint'] as String?,
      bucket: json['bucket'] as String?,
      enableSsl: json['enable_ssl'] as bool? ?? false,
    );
  }
}

// --- Providers ---

@riverpod
Future<List<WebdavToken>> webdavTokens(Ref ref) async {
  final client = ref.read(apiClientProvider);
  final response = await client.get('/drive/webdav/tokens');
  return (response.data as List)
      .map((e) => WebdavToken.fromJson(e as Map<String, dynamic>))
      .toList();
}

@riverpod
Future<List<S3Token>> s3Tokens(Ref ref) async {
  final client = ref.read(apiClientProvider);
  final response = await client.get('/drive/s3/tokens');
  return (response.data as List)
      .map((e) => S3Token.fromJson(e as Map<String, dynamic>))
      .toList();
}

@riverpod
Future<List<StoragePool>> myStoragePools(Ref ref) async {
  final client = ref.read(apiClientProvider);
  final response = await client.get('/drive/pools/me');
  return (response.data as List)
      .map((e) => StoragePool.fromJson(e as Map<String, dynamic>))
      .toList();
}

// --- Main Tab View ---

class StorageSettingsSheet extends ConsumerStatefulWidget {
  const StorageSettingsSheet({super.key});

  @override
  ConsumerState<StorageSettingsSheet> createState() =>
      _StorageSettingsSheetState();
}

class _StorageSettingsSheetState extends ConsumerState<StorageSettingsSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SheetScaffold(
      titleText: 'storageSettings'.tr(),
      heightFactor: 0.8,
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: 'webdavTab'.tr()),
              Tab(text: 's3Tab'.tr()),
              Tab(text: 'poolsTab'.tr()),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_WebdavTokensTab(), _S3TokensTab(), _PoolsTab()],
            ),
          ),
        ],
      ),
    );
  }
}

// --- WebDAV Tokens Tab ---

class _WebdavTokensTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokensAsync = ref.watch(webdavTokensProvider);

    return Stack(
      children: [
        tokensAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('error'.tr())),
          data: (tokens) => tokens.isEmpty
              ? _buildEmptyState(
                  context,
                  icon: Symbols.key_off,
                  title: 'webdavTokensEmpty',
                  hint: 'webdavTokensEmptyHint',
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: tokens.length,
                  itemBuilder: (context, index) {
                    final token = tokens[index];
                    return _WebdavTokenTile(
                      token: token,
                      onRevoke: () => _revokeToken(context, ref, token),
                    );
                  },
                ),
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: () => _createToken(context, ref),
            child: const Icon(Symbols.add),
          ),
        ),
      ],
    );
  }

  void _createToken(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const WebdavTokenCreateSheet(),
    ).then((value) {
      if (value == true) {
        ref.invalidate(webdavTokensProvider);
      }
    });
  }

  Future<void> _revokeToken(
    BuildContext context,
    WidgetRef ref,
    WebdavToken token,
  ) async {
    final confirm = await showConfirmAlert(
      'webdavTokenRevokeHint'.tr(),
      'webdavTokenRevoke'.tr(),
      isDanger: true,
    );
    if (!confirm || !context.mounted) return;

    try {
      showLoadingModal(context);
      final client = ref.read(apiClientProvider);
      await client.delete('/drive/webdav/tokens/${token.id}');
      ref.invalidate(webdavTokensProvider);
      if (context.mounted) {
        hideLoadingModal(context);
        showSnackBar('webdavTokenRevoked'.tr());
      }
    } catch (err) {
      if (context.mounted) hideLoadingModal(context);
      showErrorAlert(err);
    }
  }
}

// --- S3 Tokens Tab ---

class _S3TokensTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokensAsync = ref.watch(s3TokensProvider);

    return Stack(
      children: [
        tokensAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('error'.tr())),
          data: (tokens) => tokens.isEmpty
              ? _buildEmptyState(
                  context,
                  icon: Symbols.cloud_off,
                  title: 's3TokensEmpty',
                  hint: 's3TokensEmptyHint',
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: tokens.length,
                  itemBuilder: (context, index) {
                    final token = tokens[index];
                    return _S3TokenTile(
                      token: token,
                      onDelete: () => _deleteToken(context, ref, token),
                    );
                  },
                ),
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: () => _createToken(context, ref),
            child: const Icon(Symbols.add),
          ),
        ),
      ],
    );
  }

  void _createToken(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const S3TokenCreateSheet(),
    ).then((value) {
      if (value == true) {
        ref.invalidate(s3TokensProvider);
      }
    });
  }

  Future<void> _deleteToken(
    BuildContext context,
    WidgetRef ref,
    S3Token token,
  ) async {
    final confirm = await showConfirmAlert(
      's3TokenDeleteHint'.tr(),
      's3TokenDelete'.tr(),
      isDanger: true,
    );
    if (!confirm || !context.mounted) return;

    try {
      showLoadingModal(context);
      final client = ref.read(apiClientProvider);
      await client.delete('/drive/s3/tokens/${token.id}');
      ref.invalidate(s3TokensProvider);
      if (context.mounted) {
        hideLoadingModal(context);
        showSnackBar('s3TokenDeleted'.tr());
      }
    } catch (err) {
      if (context.mounted) hideLoadingModal(context);
      showErrorAlert(err);
    }
  }
}

// --- Pools Tab ---

class _PoolsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final poolsAsync = ref.watch(myStoragePoolsProvider);

    return Stack(
      children: [
        poolsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('error'.tr())),
          data: (pools) => pools.isEmpty
              ? _buildEmptyState(
                  context,
                  icon: Symbols.folder_off,
                  title: 'poolsEmpty',
                  hint: 'poolsEmptyHint',
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: pools.length,
                  itemBuilder: (context, index) {
                    final pool = pools[index];
                    return _PoolTile(
                      pool: pool,
                      onTap: () => _editPool(context, ref, pool),
                      onDelete: () => _deletePool(context, ref, pool),
                    );
                  },
                ),
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: () => _createPool(context, ref),
            child: const Icon(Symbols.add),
          ),
        ),
      ],
    );
  }

  void _createPool(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const PoolFormSheet(),
    ).then((value) {
      if (value == true) {
        ref.invalidate(myStoragePoolsProvider);
      }
    });
  }

  void _editPool(BuildContext context, WidgetRef ref, StoragePool pool) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => PoolFormSheet(pool: pool),
    ).then((value) {
      if (value == true) {
        ref.invalidate(myStoragePoolsProvider);
      }
    });
  }

  Future<void> _deletePool(
    BuildContext context,
    WidgetRef ref,
    StoragePool pool,
  ) async {
    final confirm = await showConfirmAlert(
      'poolDeleteHint'.tr(),
      'poolDelete'.tr(),
      isDanger: true,
    );
    if (!confirm || !context.mounted) return;

    try {
      showLoadingModal(context);
      final client = ref.read(apiClientProvider);
      await client.delete('/drive/pools/${pool.id}');
      ref.invalidate(myStoragePoolsProvider);
      if (context.mounted) {
        hideLoadingModal(context);
        showSnackBar('poolDeleted'.tr());
      }
    } catch (err) {
      if (context.mounted) hideLoadingModal(context);
      showErrorAlert(err);
    }
  }
}

// --- Shared Widgets ---

Widget _buildEmptyState(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String hint,
}) {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 48, color: Theme.of(context).colorScheme.outline),
        const SizedBox(height: 16),
        Text(
          title.tr(),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          hint.tr(),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
          textAlign: TextAlign.center,
        ).padding(horizontal: 32),
      ],
    ),
  );
}

class _WebdavTokenTile extends StatelessWidget {
  final WebdavToken token;
  final VoidCallback onRevoke;

  const _WebdavTokenTile({required this.token, required this.onRevoke});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = DateFormat.yMMMd().format(token.createdAt);

    return ListTile(
      minLeadingWidth: 48,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primaryContainer,
        child: const Icon(Symbols.key, size: 18),
      ),
      title: Text(token.label),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            token.id,
            style: TextStyle(
              fontSize: 11,
              fontFamily: 'monospace',
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            'webdavTokenCreatedOn'.tr(args: [dateStr]),
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      trailing: IconButton(
        icon: Icon(Symbols.delete, color: theme.colorScheme.error, size: 20),
        onPressed: onRevoke,
      ),
    );
  }
}

class _S3TokenTile extends StatelessWidget {
  final S3Token token;
  final VoidCallback onDelete;

  const _S3TokenTile({required this.token, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = DateFormat.yMMMd().format(token.createdAt);

    return ListTile(
      minLeadingWidth: 48,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.tertiaryContainer,
        child: const Icon(Symbols.cloud, size: 18),
      ),
      title: Text(token.label),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (token.poolId != null)
            Text(
              's3TokenPoolRestricted'.tr(),
              style: TextStyle(fontSize: 11, color: theme.colorScheme.tertiary),
            ),
          Text(
            's3TokenCreatedOn'.tr(args: [dateStr]),
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      trailing: IconButton(
        icon: Icon(Symbols.delete, color: theme.colorScheme.error, size: 20),
        onPressed: onDelete,
      ),
    );
  }
}

class _PoolTile extends StatelessWidget {
  final StoragePool pool;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _PoolTile({
    required this.pool,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      minLeadingWidth: 48,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.secondaryContainer,
        child: const Icon(Symbols.folder_special, size: 18),
      ),
      title: Text(pool.name),
      subtitle: pool.description != null
          ? Text(
              pool.description!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (pool.storageConfig?.endpoint != null)
            Icon(Symbols.cloud, size: 16, color: theme.colorScheme.outline),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              Symbols.delete,
              color: theme.colorScheme.error,
              size: 20,
            ),
            onPressed: onDelete,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}

// --- Create/Edit Sheets ---

class WebdavTokenCreateSheet extends ConsumerStatefulWidget {
  const WebdavTokenCreateSheet({super.key});

  @override
  ConsumerState<WebdavTokenCreateSheet> createState() =>
      _WebdavTokenCreateSheetState();
}

class _WebdavTokenCreateSheetState
    extends ConsumerState<WebdavTokenCreateSheet> {
  final _labelController = TextEditingController();
  bool _isLoading = false;
  WebdavToken? _createdToken;

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_createdToken != null) {
      return _buildTokenCreatedView();
    }

    return SheetScaffold(
      titleText: 'webdavTokenCreate'.tr(),
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'webdavTokenCreateDescription'.tr(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _labelController,
              decoration: InputDecoration(
                labelText: 'webdavTokenLabel'.tr(),
                hintText: 'webdavTokenLabelHint'.tr(),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isLoading ? null : _createToken,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text('create'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTokenCreatedView() {
    final theme = Theme.of(context);
    final token = _createdToken!;

    return SheetScaffold(
      titleText: 'webdavTokenCreated'.tr(),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Symbols.check_circle,
              size: 48,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'webdavTokenCreatedDescription'.tr(),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _TokenDisplayBox(
            label: 'webdavTokenId'.tr(),
            value: token.id,
          ),
          const SizedBox(height: 12),
          _TokenDisplayBox(label: 'webdavTokenValue'.tr(), value: token.secret!),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'webdavTokenSaveWarning'.tr(),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).pop(true),
                  icon: const Icon(Symbols.check),
                  label: Text('done'.tr()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createToken() async {
    final label = _labelController.text.trim();
    if (label.isEmpty) {
      showSnackBar('webdavTokenLabelRequired'.tr());
      return;
    }

    setState(() => _isLoading = true);

    try {
      final client = ref.read(apiClientProvider);
      final response = await client.post(
        '/drive/webdav/tokens',
        data: {'label': label},
      );
      final token = WebdavToken.fromJson(response.data as Map<String, dynamic>);

      if (mounted) {
        setState(() {
          _createdToken = token;
          _isLoading = false;
        });
      }
    } catch (err) {
      if (mounted) {
        setState(() => _isLoading = false);
        showErrorAlert(err);
      }
    }
  }
}

class S3TokenCreateSheet extends ConsumerStatefulWidget {
  const S3TokenCreateSheet({super.key});

  @override
  ConsumerState<S3TokenCreateSheet> createState() => _S3TokenCreateSheetState();
}

class _S3TokenCreateSheetState extends ConsumerState<S3TokenCreateSheet> {
  final _labelController = TextEditingController();
  String? _selectedPoolId;
  bool _isLoading = false;
  S3Token? _createdToken;

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_createdToken != null) {
      return _buildTokenCreatedView();
    }

    final poolsAsync = ref.watch(myStoragePoolsProvider);

    return SheetScaffold(
      titleText: 's3TokenCreate'.tr(),
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              's3TokenCreateDescription'.tr(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _labelController,
              decoration: InputDecoration(
                labelText: 's3TokenLabel'.tr(),
                hintText: 's3TokenLabelHint'.tr(),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            poolsAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (err, _) => const SizedBox.shrink(),
              data: (pools) => pools.isEmpty
                  ? const SizedBox.shrink()
                  : DropdownButtonFormField<String?>(
                      value: _selectedPoolId,
                      decoration: InputDecoration(
                        labelText: 's3TokenPoolRestriction'.tr(),
                        helperText: 's3TokenPoolRestrictionHint'.tr(),
                      ),
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text('s3TokenAllPools'.tr()),
                        ),
                        ...pools.map(
                          (pool) => DropdownMenuItem(
                            value: pool.id,
                            child: Text(pool.name),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedPoolId = value);
                      },
                    ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isLoading ? null : _createToken,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text('create'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTokenCreatedView() {
    final theme = Theme.of(context);
    final token = _createdToken!;

    return SheetScaffold(
      titleText: 's3TokenCreated'.tr(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Symbols.check_circle,
                size: 48,
                color: theme.colorScheme.onTertiaryContainer,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                's3TokenCreatedDescription'.tr(),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _TokenDisplayBox(
              label: 's3TokenAccessKey'.tr(),
              value: token.accessKey!,
            ),
            const SizedBox(height: 12),
            _TokenDisplayBox(
              label: 's3TokenSecretKey'.tr(),
              value: token.secretKey!,
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                's3TokenSaveWarning'.tr(),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(true),
                icon: const Icon(Symbols.check),
                label: Text('done'.tr()),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createToken() async {
    final label = _labelController.text.trim();
    if (label.isEmpty) {
      showSnackBar('s3TokenLabelRequired'.tr());
      return;
    }

    setState(() => _isLoading = true);

    try {
      final client = ref.read(apiClientProvider);
      final response = await client.post(
        '/drive/s3/tokens',
        data: {
          'label': label,
          if (_selectedPoolId != null) 'pool_id': _selectedPoolId,
        },
      );
      final token = S3Token.fromJson(response.data as Map<String, dynamic>);

      if (mounted) {
        setState(() {
          _createdToken = token;
          _isLoading = false;
        });
      }
    } catch (err) {
      if (mounted) {
        setState(() => _isLoading = false);
        showErrorAlert(err);
      }
    }
  }
}

class PoolFormSheet extends ConsumerStatefulWidget {
  final StoragePool? pool;

  const PoolFormSheet({super.key, this.pool});

  @override
  ConsumerState<PoolFormSheet> createState() => _PoolFormSheetState();
}

class _PoolFormSheetState extends ConsumerState<PoolFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _endpointController = TextEditingController();
  final _bucketController = TextEditingController();
  final _accessKeyController = TextEditingController();
  final _secretKeyController = TextEditingController();
  bool _enableSsl = true;
  bool _isLoading = false;

  bool get _isEditing => widget.pool != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final pool = widget.pool!;
      _nameController.text = pool.name;
      _descriptionController.text = pool.description ?? '';
      if (pool.storageConfig != null) {
        _endpointController.text = pool.storageConfig!.endpoint ?? '';
        _bucketController.text = pool.storageConfig!.bucket ?? '';
        _enableSsl = pool.storageConfig!.enableSsl;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _endpointController.dispose();
    _bucketController.dispose();
    _accessKeyController.dispose();
    _secretKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SheetScaffold(
      titleText: _isEditing ? 'poolEdit'.tr() : 'poolCreate'.tr(),
      heightFactor: 0.85,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _isEditing
                    ? 'poolEditDescription'.tr()
                    : 'poolCreateDescription'.tr(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'poolBasicInfo'.tr(),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'poolName'.tr(),
                  hintText: 'poolNameHint'.tr(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'fieldCannotBeEmpty'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'poolDescription'.tr(),
                  hintText: 'poolDescriptionHint'.tr(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              Text(
                'poolStorageConfig'.tr(),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'poolStorageConfigHint'.tr(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _endpointController,
                decoration: InputDecoration(
                  labelText: 'poolEndpoint'.tr(),
                  hintText: 'poolEndpointHint'.tr(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bucketController,
                decoration: InputDecoration(
                  labelText: 'poolBucket'.tr(),
                  hintText: 'poolBucketHint'.tr(),
                ),
              ),
              const SizedBox(height: 16),
              if (!_isEditing) ...[
                TextFormField(
                  controller: _accessKeyController,
                  decoration: InputDecoration(
                    labelText: 'poolAccessKey'.tr(),
                    hintText: 'poolAccessKeyHint'.tr(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _secretKeyController,
                  decoration: InputDecoration(
                    labelText: 'poolSecretKey'.tr(),
                    hintText: 'poolSecretKeyHint'.tr(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
              ],
              SwitchListTile(
                title: Text('poolEnableSsl'.tr()),
                subtitle: Text('poolEnableSslHint'.tr()).fontSize(12),
                value: _enableSsl,
                onChanged: (value) => setState(() => _enableSsl = value),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isLoading ? null : _savePool,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isEditing ? 'saveChanges'.tr() : 'create'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _savePool() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final client = ref.read(apiClientProvider);
      final data = {
        'name': _nameController.text.trim(),
        if (_descriptionController.text.trim().isNotEmpty)
          'description': _descriptionController.text.trim(),
        'storage_config': {
          if (_endpointController.text.trim().isNotEmpty)
            'endpoint': _endpointController.text.trim(),
          if (_bucketController.text.trim().isNotEmpty)
            'bucket': _bucketController.text.trim(),
          if (!_isEditing && _accessKeyController.text.trim().isNotEmpty)
            'secret_id': _accessKeyController.text.trim(),
          if (!_isEditing && _secretKeyController.text.trim().isNotEmpty)
            'secret_key': _secretKeyController.text.trim(),
          'enable_ssl': _enableSsl,
        },
      };

      if (_isEditing) {
        await client.patch('/drive/pools/${widget.pool!.id}', data: data);
      } else {
        await client.post('/drive/pools', data: data);
      }

      ref.invalidate(myStoragePoolsProvider);

      if (mounted) {
        Navigator.of(context).pop(true);
        showSnackBar(_isEditing ? 'poolUpdated'.tr() : 'poolCreated'.tr());
      }
    } catch (err) {
      if (mounted) {
        setState(() => _isLoading = false);
        showErrorAlert(err);
      }
    }
  }
}

class _TokenDisplayBox extends StatelessWidget {
  final String label;
  final String value;

  const _TokenDisplayBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SelectableText(
                    value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: 'monospace',
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                SizedBox(
                  width: 32,
                  height: 32,
                  child: IconButton(
                    icon: const Icon(Symbols.content_copy, size: 16),
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: value));
                      showSnackBar('copied'.tr());
                    },
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
