import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/accounts/widgets/account/account_name.dart';
import 'package:island/auth/models/authorize_client_info.dart';
import 'package:island/auth/public_app.dart';
import 'package:island/auth/web_auth/web_auth_app_info.dart';
import 'package:island/auth/widgets/auth_consent.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:solar_network_foundation/solar_network_foundation.dart';
import 'package:url_launcher/url_launcher_string.dart';

@RoutePage()
class AuthorizeScreen extends ConsumerStatefulWidget {
  final String? clientId;
  final String? redirectUri;
  final String? scope;
  final String? state;
  final String? responseType;
  final String? codeChallenge;
  final String? codeChallengeMethod;
  final String? userCode;

  const AuthorizeScreen({
    super.key,
    this.clientId,
    this.redirectUri,
    this.scope,
    this.state,
    this.responseType,
    this.codeChallenge,
    this.codeChallengeMethod,
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

  bool get _isDeviceCode =>
      widget.userCode != null && widget.userCode!.isNotEmpty;

  Map<String, String> get _queryParams => {
    if (widget.clientId != null) 'client_id': widget.clientId!,
    if (widget.redirectUri != null) 'redirect_uri': widget.redirectUri!,
    if (widget.scope != null) 'scope': widget.scope!,
    if (widget.state != null) 'state': widget.state!,
    if (widget.responseType != null) 'response_type': widget.responseType!,
    if (widget.codeChallenge != null) 'code_challenge': widget.codeChallenge!,
    if (widget.codeChallengeMethod != null)
      'code_challenge_method': widget.codeChallengeMethod!,
  };

  Future<void> _loadClientInfo() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final dio = ref.read(stargateApiClientProvider);
      if (_isDeviceCode) {
        final deviceResp = await dio.get(
          '/auth/open/device/code/${Uri.encodeComponent(widget.userCode!)}',
        );
        final deviceData = Map<String, dynamic>.from(deviceResp.data as Map);
        final clientId = deviceData['client_id'] as String?;
        if (clientId == null || clientId.isEmpty) {
          setState(() {
            _error = 'Invalid device code';
            _loading = false;
          });
          return;
        }
        final resp = await dio.get(
          '/auth/open/authorize',
          queryParameters: {'client_id': clientId},
        );
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
      final dio = ref.read(stargateApiClientProvider);
      if (_isDeviceCode) {
        final action = authorize ? 'approve' : 'decline';
        // Approving a device binds it to this session, so Stargate demands an
        // elevation grant first. The shared flow prompts on
        // AUTH_SUDO_REQUIRED and replays the decision exactly once.
        await withSudoRetry(
          context,
          ref,
          () => dio.post(
            '/auth/open/device/code/${Uri.encodeComponent(widget.userCode!)}/$action',
          ),
          onBeforePrompt: () {
            if (mounted) setState(() => _submitting = false);
          },
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
        // Backing out of the elevation prompt rethrows the original refusal;
        // say the decision was cancelled instead of quoting the 403 body.
        _error = isSudoRequired(e)
            ? 'sudoNotCompleted'.tr()
            : e.response?.data?.toString() ?? e.message ?? 'Failed';
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

    // Provenance shown beside the app name: developer, verification mark and
    // home page, exactly as the web consent page renders `AppOwnerInfo`.
    final clientId = _clientInfo?.clientId;
    final profile = clientId == null
        ? null
        : ref.watch(publicAppProvider(clientId)).value;

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(
        leading: const AutoLeadingButton(),
        title: Text(
          _isDeviceCode
              ? 'accountQrDeviceAuthApprovalTitle'
              : 'authorizeAppTitle',
        ).tr(),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _clientInfo == null
          ? _AuthorizeLoadFailedState(error: _error, onRetry: _loadClientInfo)
          : _AuthorizeBody(
              user: user,
              userPicture: userPicture,
              clientName: clientName,
              clientPicture: clientPicture,
              description: description,
              homeUri: homeUri,
              scopes: scopes,
              profile: profile,
              deviceCode: _isDeviceCode ? widget.userCode! : null,
              error: _error,
              submitting: _submitting,
              onApprove: () => _submitDecision(true),
              onDeny: () => _submitDecision(false),
            ),
    );
  }
}

/// Lays out the request as one quiet column, or splits it by concern on wide
/// screens: who is asking (intro) beside what they get (permissions).
class _AuthorizeBody extends StatelessWidget {
  final dynamic user;
  final String? userPicture;
  final String clientName;
  final String? clientPicture;
  final String? description;
  final String? homeUri;
  final List<String> scopes;
  final WebAuthAppInfo? profile;
  final String? deviceCode;
  final String? error;
  final bool submitting;
  final VoidCallback onApprove;
  final VoidCallback onDeny;

  const _AuthorizeBody({
    required this.user,
    required this.userPicture,
    required this.clientName,
    required this.clientPicture,
    required this.description,
    required this.homeUri,
    required this.scopes,
    required this.profile,
    required this.deviceCode,
    required this.error,
    required this.submitting,
    required this.onApprove,
    required this.onDeny,
  });

  @override
  Widget build(BuildContext context) {
    final twoPane = context.isTwoPaneScreen;
    final pagePadding = context.responsivePagePadding;
    final sectionGap = context.responsiveSectionGap;

    return LayoutBuilder(
      builder: (context, constraints) {
        final intro = _AuthorizeIntro(
          user: user,
          userPicture: userPicture,
          clientName: clientName,
          clientPicture: clientPicture,
          description: description,
          homeUri: homeUri,
          profile: profile,
          deviceCode: deviceCode,
          sectionGap: sectionGap,
        );
        final decision = _AuthorizePermissions(
          clientName: clientName,
          scopes: scopes,
          error: error,
          submitting: submitting,
          onApprove: onApprove,
          onDeny: onDeny,
        );

        final content = twoPane
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 11, child: intro),
                  Gap(sectionGap),
                  Expanded(flex: 10, child: decision),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  intro,
                  Gap(sectionGap),
                  decision,
                ],
              );

        return SingleChildScrollView(
          padding: EdgeInsets.all(pagePadding),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - pagePadding * 2,
                maxWidth: twoPane ? 1040 : 520,
              ),
              child: Align(
                alignment: Alignment.center,
                child: IntrinsicHeight(child: content),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AuthorizeIntro extends StatelessWidget {
  final dynamic user;
  final String? userPicture;
  final String clientName;
  final String? clientPicture;
  final String? description;
  final String? homeUri;
  final WebAuthAppInfo? profile;
  final String? deviceCode;
  final double sectionGap;

  const _AuthorizeIntro({
    required this.user,
    required this.userPicture,
    required this.clientName,
    required this.clientPicture,
    required this.description,
    required this.homeUri,
    required this.profile,
    required this.deviceCode,
    required this.sectionGap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final publisher = profile?.project.developer.publisher;
    final resolvedHomeUri =
        profile?.links['home_page'] ?? profile?.links['homePage'] ?? homeUri;
    final resolvedDescription = (profile?.description.trim() ?? '').isNotEmpty
        ? profile!.description
        : description;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (deviceCode != null) ...[
          AuthUserCodeCard(userCode: deviceCode!),
          Gap(sectionGap),
        ],
        Text(
          'authorizeAppGrantAccess'.tr(),
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        const Gap(28),
        _GrantHeader(
          userPicture: userPicture,
          clientPicture: clientPicture,
        ),
        const Gap(28),
        Row(
          children: [
            Flexible(
              child: Text(
                profile?.name.trim().isNotEmpty == true
                    ? profile!.name
                    : clientName,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (profile?.verification != null) ...[
              const Gap(4),
              VerificationMark(mark: profile!.verification!),
            ],
          ],
        ),
        const Gap(4),
        Text(
          'authorizeAppWantsAccess'.tr(),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        AppOwnerInfo(
          publisherName: publisher?.nick.trim().isNotEmpty == true
              ? publisher!.nick
              : publisher?.name,
          publisherPicture: publisher?.picture,
          publisherVerification: publisher?.verification,
          homeUri: resolvedHomeUri,
        ),
        if (resolvedDescription != null &&
            resolvedDescription.trim().isNotEmpty) ...[
          const Gap(16),
          Text(
            resolvedDescription,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ],
        const Spacer(),
        const Gap(24),
        if (user != null)
          Row(
            children: [
              CircleAvatar(
                radius: 10,
                backgroundImage: userPicture != null
                    ? NetworkImage(userPicture!)
                    : null,
                backgroundColor: colorScheme.surfaceContainerHighest,
                child: userPicture == null
                    ? Icon(
                        Symbols.person,
                        size: 12,
                        color: colorScheme.onSurfaceVariant,
                      )
                    : null,
              ),
              const Gap(8),
              Flexible(
                child: Text(
                  '${user.nick.isNotEmpty ? user.nick : user.name} · @${user.name}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

/// The signature of this screen: your account and the requesting app, joined
/// by a bare hairline. No containers, no icons — the connection itself.
class _GrantHeader extends StatelessWidget {
  final String? userPicture;
  final String? clientPicture;

  const _GrantHeader({required this.userPicture, required this.clientPicture});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 52,
      child: Row(
        children: [
          _RequestAvatar(imageUrl: userPicture, fallbackIcon: Symbols.person),
          Expanded(
            child: Container(height: 1, color: colorScheme.outlineVariant),
          ),
          _RequestAvatar(
            imageUrl: clientPicture,
            fallbackIcon: Symbols.extension,
            emphasized: true,
          ),
        ],
      ),
    );
  }
}

class _RequestAvatar extends StatelessWidget {
  final String? imageUrl;
  final IconData fallbackIcon;
  final bool emphasized;

  const _RequestAvatar({
    required this.imageUrl,
    required this.fallbackIcon,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        right: emphasized ? 0 : 12,
        left: emphasized ? 12 : 0,
      ),
      child: CircleAvatar(
        radius: emphasized ? 26 : 22,
        backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
        backgroundColor: colorScheme.surfaceContainerHighest,
        child: imageUrl == null
            ? Icon(
                fallbackIcon,
                size: emphasized ? 26 : 22,
                color: colorScheme.onSurfaceVariant,
              )
            : null,
      ),
    );
  }
}

class _AuthorizePermissions extends StatelessWidget {
  final String clientName;
  final List<String> scopes;
  final String? error;
  final bool submitting;
  final VoidCallback onApprove;
  final VoidCallback onDeny;

  const _AuthorizePermissions({
    required this.clientName,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'authorizeAppRequestedPermissions'.tr(),
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const Gap(6),
        Text(
          'authorizeAppReviewHint'.tr(args: [clientName]),
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        const Gap(16),
        AuthScopeList(scopes: scopes),
        if (error != null) ...[
          const Gap(16),
          AuthInlineError(message: error),
        ],
        const Spacer(),
        const Gap(32),
        FilledButton(
          onPressed: submitting ? null : onApprove,
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          child: submitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text('authorizeAppApprove'.tr()),
        ),
        const Gap(4),
        TextButton(
          onPressed: submitting ? null : onDeny,
          child: Text('authorizeAppDeny'.tr()),
        ),
      ],
    );
  }
}

class _AuthorizeLoadFailedState extends StatelessWidget {
  final String? error;
  final VoidCallback onRetry;

  const _AuthorizeLoadFailedState({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.responsivePagePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Symbols.error_outline,
              size: 40,
              color: colorScheme.onSurfaceVariant,
            ),
            const Gap(16),
            Text(
              'authorizeAppFailedTitle'.tr(),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Gap(8),
            Text(
              error ?? 'authorizeAppFailedDescription'.tr(),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const Gap(24),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Symbols.refresh, size: 18),
              label: Text('retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
