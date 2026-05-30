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

class WebdavToken {
  final String id;
  final String label;
  final String? token; // Only available at creation time
  final DateTime createdAt;

  WebdavToken({
    required this.id,
    required this.label,
    this.token,
    required this.createdAt,
  });

  factory WebdavToken.fromJson(Map<String, dynamic> json) {
    return WebdavToken(
      id: json['id'] as String,
      label: json['label'] as String,
      token: json['token'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

@riverpod
Future<List<WebdavToken>> webdavTokens(Ref ref) async {
  final client = ref.read(apiClientProvider);
  final response = await client.get('/drive/webdav/tokens');
  return (response.data as List)
      .map((e) => WebdavToken.fromJson(e as Map<String, dynamic>))
      .toList();
}

class WebdavSettingsSheet extends ConsumerWidget {
  const WebdavSettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokensAsync = ref.watch(webdavTokensProvider);

    return SheetScaffold(
      titleText: 'webdavSettings'.tr(),
      heightFactor: 0.7,
      actions: [
        IconButton(
          icon: const Icon(Symbols.add),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => const WebdavTokenCreateSheet(),
            ).then((value) {
              if (value == true) {
                ref.invalidate(webdavTokensProvider);
              }
            });
          },
        ),
      ],
      child: tokensAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('error'.tr())),
        data: (tokens) => tokens.isEmpty
            ? _buildEmptyState(context)
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
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
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Symbols.key_off,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'webdavTokensEmpty'.tr(),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'webdavTokensEmptyHint'.tr(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ).padding(horizontal: 32),
        ],
      ),
    );
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
      subtitle: Text(
        'webdavTokenCreated'.tr(args: [dateStr]),
        style: TextStyle(
          fontSize: 12,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: IconButton(
        icon: Icon(Symbols.delete, color: theme.colorScheme.error, size: 20),
        onPressed: onRevoke,
      ),
    );
  }
}

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
          Container(
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
                  'webdavTokenLabel'.tr(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  token.label,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'webdavTokenValue'.tr(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
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
                          token.token!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontFamily: 'monospace',
                            fontSize: 13,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Symbols.copy_all, size: 18),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: token.token!));
                          showSnackBar('copied'.tr());
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
