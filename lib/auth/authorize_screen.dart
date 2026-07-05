import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/auth/models/authorize_client_info.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher_string.dart';

@RoutePage()
class AuthorizeScreen extends ConsumerStatefulWidget {
  final String? clientId;
  final String? redirectUri;
  final String? scope;
  final String? state;
  final String? responseType;
  final String? userCode;

  const AuthorizeScreen({
    super.key,
    this.clientId,
    this.redirectUri,
    this.scope,
    this.state,
    this.responseType,
    this.userCode,
  });

  @override
  ConsumerState<AuthorizeScreen> createState() => _AuthorizeScreenState();
}

class _AuthorizeScreenState extends ConsumerState<AuthorizeScreen> {
  AuthorizeClientInfo? _clientInfo;
  bool _loading = true;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadClientInfo();
  }

  bool get _isDeviceCode => widget.userCode != null && widget.userCode!.isNotEmpty;

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
      if (_isDeviceCode) {
        final deviceResp = await dio.get(
          '/auth/open/device/code/${Uri.encodeComponent(widget.userCode!)}',
        );
        final deviceData = Map<String, dynamic>.from(deviceResp.data as Map);
        final clientId = deviceData['clientId'] as String?;
        if (clientId == null) {
          setState(() {
            _error = 'Invalid device code';
            _loading = false;
          });
          return;
        }
        final resp = await dio.get('/auth/open/authorize', queryParameters: {
          'client_id': clientId,
        });
        setState(() {
          _clientInfo = AuthorizeClientInfo.fromJson(
            Map<String, dynamic>.from(resp.data as Map),
          );
          _loading = false;
        });
      } else {
        final resp = await dio.get(
          '/auth/open/authorize',
          queryParameters: _queryParams,
        );
        setState(() {
          _clientInfo = AuthorizeClientInfo.fromJson(
            Map<String, dynamic>.from(resp.data as Map),
          );
          _loading = false;
        });
      }
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
      if (_isDeviceCode) {
        final action = authorize ? 'approve' : 'decline';
        await dio.post(
          '/auth/open/device/code/${Uri.encodeComponent(widget.userCode!)}/$action',
        );
        if (mounted) Navigator.of(context).pop();
      } else {
        final body = Map<String, String>.from(_queryParams);
        body['authorize'] = authorize.toString();
        final resp = await dio.post(
          '/auth/open/authorize',
          data: body,
          options: Options(contentType: 'application/x-www-form-urlencoded'),
        );
        final data = Map<String, dynamic>.from(resp.data as Map);
        final redirectUri = _readStringFrom(data, const [
          'redirectUri',
          'redirect_uri',
        ]);
        if (redirectUri != null && redirectUri.isNotEmpty) {
          await launchUrlString(
            redirectUri,
            mode: LaunchMode.externalApplication,
          );
        }
        if (mounted) Navigator.of(context).pop();
      }
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

  String? _readStringFrom(Map<String, dynamic>? source, List<String> keys) {
    if (source == null) return null;
    for (final key in keys) {
      final value = source[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }

  Widget _buildDecisionPanel({
    required String clientName,
    required String? clientPicture,
    required String? homeUri,
    required List<String> scopes,
  }) {
    return Column(
      children: [
        if (_isDeviceCode && widget.userCode != null)
          _DeviceCodeBanner(userCode: widget.userCode!),
        if (_isDeviceCode && widget.userCode != null) const Gap(16),
        _AuthorizeDecisionPanel(
          clientName: clientName,
          clientPicture: clientPicture,
          homeUri: homeUri,
          scopes: scopes,
          error: _error,
          submitting: _submitting,
          onApprove: () => _submitDecision(true),
          onDeny: () => _submitDecision(false),
        ),
      ],
    );
  }

  String? _fileUrl(String? id) {
    if (id == null || id.isEmpty) return null;
    final serverUrl = ref.read(serverUrlProvider);
    return '$serverUrl/drive/files/$id';
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userInfoProvider).value;
    final clientName = _clientInfo?.clientName ?? 'Unknown App';
    final homeUri = _clientInfo?.homeUri;
    final description = _clientInfo?.description;
    final scopes = _clientInfo?.scopes ?? const <String>[];
    final clientPicture = _fileUrl(_clientInfo?.picture?.id);
    final userPicture = _fileUrl(user?.profile.picture?.id);
    final useTwoPaneLayout = context.isTwoPaneScreen;
    final pagePadding = context.responsivePagePadding;
    final sectionGap = context.responsiveSectionGap;

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(
        leading: const AutoLeadingButton(),
        title: Text(
          _isDeviceCode ? 'deviceAuthTitle' : 'authorizeAppTitle',
        ).tr(),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _clientInfo == null
          ? _AuthorizeLoadFailedState(error: _error)
          : LayoutBuilder(
              builder: (context, constraints) {
                final content = useTwoPaneLayout
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 11,
                            child: _AuthorizeIntroPanel(
                              user: user,
                              userPicture: userPicture,
                              clientName: clientName,
                              description: description,
                              sectionGap: sectionGap,
                            ),
                          ),
                          Gap(sectionGap),
                          Expanded(
                            flex: 10,
                            child: _buildDecisionPanel(
                              clientName: clientName,
                              clientPicture: clientPicture,
                              homeUri: homeUri,
                              scopes: scopes,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _AuthorizeIntroPanel(
                            user: user,
                            userPicture: userPicture,
                            clientName: clientName,
                            description: description,
                            sectionGap: sectionGap,
                          ),
                          Gap(sectionGap),
                          _buildDecisionPanel(
                            clientName: clientName,
                            clientPicture: clientPicture,
                            homeUri: homeUri,
                            scopes: scopes,
                          ),
                        ],
                      );

                return SingleChildScrollView(
                  padding: EdgeInsets.all(pagePadding),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - pagePadding * 2,
                      ),
                      child: Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: useTwoPaneLayout ? 1100 : null,
                          child: IntrinsicHeight(child: content),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _AuthorizeLoadFailedState extends StatelessWidget {
  final String? error;

  const _AuthorizeLoadFailedState({required this.error});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.responsivePagePadding),
        child: Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: colorScheme.errorContainer,
                  child: Icon(
                    Symbols.error,
                    color: colorScheme.onErrorContainer,
                    size: 30,
                  ),
                ),
                const Gap(16),
                Text(
                  'authorizeAppFailedTitle'.tr(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Gap(8),
                Text(
                  error ?? 'authorizeAppFailedDescription'.tr(),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthorizeIntroPanel extends StatelessWidget {
  final dynamic user;
  final String? userPicture;
  final String clientName;
  final String? description;
  final double sectionGap;

  const _AuthorizeIntroPanel({
    required this.user,
    required this.userPicture,
    required this.clientName,
    required this.description,
    required this.sectionGap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: EdgeInsets.all(context.isDesktopScreen ? 28 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                Symbols.shield_lock,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            Gap(sectionGap),
            Text(
              'authorizeAppGrantAccess'.tr(),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const Gap(10),
            Text(
              'authorizeAppReviewHint'.tr(args: [clientName]),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (description != null) ...[
              const Gap(16),
              Text(
                description!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            Gap(sectionGap),
            if (user != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: userPicture != null
                          ? NetworkImage(userPicture!)
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
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Gap(2),
                          Text(
                            '@${user.name}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AuthorizeDecisionPanel extends StatelessWidget {
  final String clientName;
  final String? clientPicture;
  final String? homeUri;
  final List<String> scopes;
  final String? error;
  final bool submitting;
  final VoidCallback onApprove;
  final VoidCallback onDeny;

  const _AuthorizeDecisionPanel({
    required this.clientName,
    required this.clientPicture,
    required this.homeUri,
    required this.scopes,
    required this.error,
    required this.submitting,
    required this.onApprove,
    required this.onDeny,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final wideButtons = !context.isCompactScreen;

    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: EdgeInsets.all(context.isDesktopScreen ? 28 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundImage: clientPicture != null
                      ? NetworkImage(clientPicture!)
                      : null,
                  child: clientPicture == null
                      ? const Icon(Symbols.extension, size: 28)
                      : null,
                ),
                const Gap(14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        clientName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        'authorizeAppWantsAccess'.tr(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (homeUri != null) ...[
              const Gap(12),
              Text(
                homeUri!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
            ],
            const Gap(20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Symbols.shield,
                        size: 18,
                        color: colorScheme.primary,
                      ),
                      const Gap(8),
                      Text(
                        'authorizeAppRequestedPermissions'.tr(),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const Gap(12),
                  if (scopes.isEmpty)
                    Text(
                      'authorizeAppNoScopes'.tr(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    )
                  else
                    ...scopes.map(
                      (scope) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              scope == '*'
                                  ? Symbols.warning
                                  : Symbols.check_circle,
                              size: 18,
                              color: scope == '*'
                                  ? Colors.orange
                                  : Colors.green,
                            ),
                            const Gap(8),
                            Expanded(
                              child: Text(
                                _humanizeScope(scope).tr(),
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
            if (error != null) ...[
              const Gap(16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(Symbols.error, color: colorScheme.onErrorContainer),
                    const Gap(8),
                    Expanded(
                      child: Text(
                        error!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const Gap(20),
            if (wideButtons)
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: submitting ? null : onApprove,
                      icon: submitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Symbols.check),
                      label: Text('authorizeAppApprove').tr(),
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: submitting ? null : onDeny,
                      icon: const Icon(Symbols.close),
                      label: Text('authorizeAppDeny').tr(),
                    ),
                  ),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton.icon(
                    onPressed: submitting ? null : onApprove,
                    icon: submitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Symbols.check),
                    label: Text('authorizeAppApprove').tr(),
                  ),
                  const Gap(12),
                  OutlinedButton.icon(
                    onPressed: submitting ? null : onDeny,
                    icon: const Icon(Symbols.close),
                    label: Text('authorizeAppDeny').tr(),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _DeviceCodeBanner extends StatelessWidget {
  final String userCode;

  const _DeviceCodeBanner({required this.userCode});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.primaryContainer.withOpacity(0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colorScheme.primary.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Symbols.phonelink, size: 20, color: colorScheme.primary),
                const Gap(8),
                Text(
                  'deviceAuthCode'.tr(),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const Gap(12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Text(
                userCode,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 4,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _humanizeScope(String scope) {
  switch (scope) {
    case 'account.connections':
      return 'authorizeScopeAccountConnections';
    case 'posts.create':
      return 'authorizeScopePostsCreate';
    case 'posts.react':
      return 'authorizeScopePostsReact';
    case 'posts.create.blog':
      return 'authorizeScopePostsCreateBlog';
    case 'notifications.push':
      return 'authorizeScopeNotificationsPush';
    case 'openid':
      return 'authorizeScopeOpenId';
    case 'profile':
      return 'authorizeScopeProfile';
    case 'email':
      return 'authorizeScopeEmail';
    case 'offline_access':
      return 'authorizeScopeOfflineAccess';
    case '*':
      return 'authorizeScopeAll';
    default:
      return scope;
  }
}
