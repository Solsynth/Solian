import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher_string.dart';

const _scopeLabels = <String, String>{
  'openid': 'Read your Solarpass profile',
  'profile': 'Read your public profile information',
  'email': 'Read your email address',
  'offline_access': "Access your account when you're not logged in",
  '*': 'Full access: this app can do anything as you',
};

@RoutePage()
class AuthorizeScreen extends ConsumerStatefulWidget {
  final String? clientId;
  final String? redirectUri;
  final String? scope;
  final String? state;
  final String? responseType;

  const AuthorizeScreen({
    super.key,
    this.clientId,
    this.redirectUri,
    this.scope,
    this.state,
    this.responseType,
  });

  @override
  ConsumerState<AuthorizeScreen> createState() => _AuthorizeScreenState();
}

class _AuthorizeScreenState extends ConsumerState<AuthorizeScreen> {
  Map<String, dynamic>? _clientInfo;
  bool _loading = true;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadClientInfo();
  }

  Map<String, String> get _queryParams => {
    if (widget.clientId != null) 'client_id': widget.clientId!,
    if (widget.redirectUri != null) 'redirect_uri': widget.redirectUri!,
    if (widget.scope != null) 'scope': widget.scope!,
    if (widget.state != null) 'state': widget.state!,
    if (widget.responseType != null) 'response_type': widget.responseType!,
  };

  Future<void> _loadClientInfo() async {
    try {
      final dio = ref.read(padlockApiClientProvider);
      final resp = await dio.get(
        '/auth/open/authorize',
        queryParameters: _queryParams,
      );
      setState(() {
        _clientInfo = Map<String, dynamic>.from(resp.data as Map);
        _loading = false;
      });
    } on DioException catch (e) {
      setState(() {
        _error = e.response?.data?.toString() ?? e.message ?? 'Failed to load';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _submitDecision(bool authorize) async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final dio = ref.read(padlockApiClientProvider);
      final body = Map<String, String>.from(_queryParams);
      body['authorize'] = authorize.toString();
      final resp = await dio.post(
        '/auth/open/authorize',
        data: body,
        options: Options(contentType: 'application/x-www-form-urlencoded'),
      );
      final data = Map<String, dynamic>.from(resp.data as Map);
      final redirectUri = data['redirectUri'] as String?;
      if (redirectUri != null && redirectUri.isNotEmpty) {
        await launchUrlString(redirectUri, mode: LaunchMode.externalApplication);
      }
      if (mounted) Navigator.of(context).pop();
    } on DioException catch (e) {
      setState(() {
        _error = e.response?.data?.toString() ?? e.message ?? 'Failed';
        _submitting = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _submitting = false;
      });
    }
  }

  String? _fileUrl(Map<String, dynamic>? obj) {
    final id = obj?['id'] as String?;
    if (id == null || id.isEmpty) return null;
    final serverUrl = ref.read(serverUrlProvider);
    return '$serverUrl/drive/files/$id';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(userInfoProvider).value;
    final clientName = _clientInfo?['clientName'] as String? ?? 'Unknown App';
    final scopes = (_clientInfo?['scopes'] as List?)?.cast<String>() ?? [];
    final clientPicture = _fileUrl(
      _clientInfo?['picture'] as Map<String, dynamic>?,
    );
    final userPicture = _fileUrl(user?.profile.picture?.toJson());

    return AppScaffold(
      appBar: AppBar(
        leading: const AutoLeadingButton(),
        title: const Text('Authorize App'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // User account card
                  if (user != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundImage: userPicture != null
                                  ? NetworkImage(userPicture)
                                  : null,
                              child: userPicture == null
                                  ? const Icon(Symbols.person)
                                  : null,
                            ),
                            const Gap(12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.nick.isNotEmpty ? user.nick : user.name,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '@${user.name}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const Gap(24),

                  // Client info
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundImage: clientPicture != null
                            ? NetworkImage(clientPicture)
                            : null,
                        child: clientPicture == null
                            ? const Icon(Symbols.extension, size: 28)
                            : null,
                      ),
                      const Gap(12),
                      Text(
                        clientName,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'wants access to your account',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const Gap(24),

                  // Permissions
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Symbols.shield,
                                size: 18,
                                color: theme.colorScheme.primary,
                              ),
                              const Gap(8),
                              Text(
                                'Requested permissions',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const Gap(12),
                          if (scopes.isEmpty)
                            Text(
                              'No explicit scopes provided.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            )
                          else
                            ...scopes.map(
                              (s) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      s == '*'
                                          ? Symbols.warning
                                          : Symbols.check_circle,
                                      size: 18,
                                      color: s == '*'
                                          ? Colors.orange
                                          : Colors.green,
                                    ),
                                    const Gap(8),
                                    Expanded(
                                      child: Text(
                                        _scopeLabels[s] ?? s,
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const Gap(16),

                  // Error
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Card(
                        color: theme.colorScheme.errorContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Icon(
                                Symbols.error,
                                color: theme.colorScheme.onErrorContainer,
                              ),
                              const Gap(8),
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: TextStyle(
                                    color: theme.colorScheme.onErrorContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _submitting
                              ? null
                              : () => _submitDecision(true),
                          icon: _submitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Symbols.check),
                          label: const Text('Authorize'),
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _submitting
                              ? null
                              : () => _submitDecision(false),
                          icon: const Icon(Symbols.close),
                          label: const Text('Deny'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
