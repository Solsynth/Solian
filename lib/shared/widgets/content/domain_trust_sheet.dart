import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:island/core/network/domain_trust.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';

enum DomainTrustAction { openLink, loadImage }

enum DomainTrustDecision { proceed, cancelled }

Future<DomainTrustDecision> showDomainTrustSheet(
  BuildContext context, {
  required Uri uri,
  required DomainTrustResult result,
  required DomainTrustAction action,
}) async {
  final decision = await showModalBottomSheet<DomainTrustDecision>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    builder: (context) =>
        DomainTrustSheet(uri: uri, result: result, action: action),
  );
  return decision ?? DomainTrustDecision.cancelled;
}

class DomainTrustSheet extends StatelessWidget {
  final Uri uri;
  final DomainTrustResult result;
  final DomainTrustAction action;

  const DomainTrustSheet({
    super.key,
    required this.uri,
    required this.result,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    final isBlocked = result.trustLevel == DomainTrustLevel.blocked;
    final scheme = Theme.of(context).colorScheme;
    final characterAsset = isBlocked
        ? 'assets/images/michan/link-warning.webp'
        : 'assets/images/michan/link-prompt.webp';
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 420;
    final characterHeight = isCompact ? 180.0 : 240.0;
    final contentRightPadding = isCompact ? 120.0 : 156.0;

    return SheetScaffold(
      showHeader: false,
      height: 320,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: isCompact ? -18 : -8,
            top: -(characterHeight * 0.48),
            child: IgnorePointer(
              child: Image.asset(
                characterAsset,
                height: characterHeight,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 28, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.only(right: contentRightPadding),
                  child: Row(
                    children: [
                      Icon(
                        isBlocked ? Symbols.warning : Symbols.verified_user,
                        color: isBlocked ? scheme.error : scheme.primary,
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'domainTrustTitle'.tr(),
                          style: GoogleFonts.notoSerifSc(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: EdgeInsets.only(right: contentRightPadding),
                  child: Text(
                    _descriptionKey.tr(),
                    style: GoogleFonts.notoSerifSc(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.fromLTRB(
                    12,
                    12,
                    isCompact ? 12 : contentRightPadding - 24,
                    12,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    uri.toString(),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (result.blockReason != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isBlocked
                          ? scheme.errorContainer
                          : scheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${'domainTrustReason'.tr()}: ${result.blockReason}',
                      style: TextStyle(
                        color: isBlocked
                            ? scheme.onErrorContainer
                            : scheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                isCompact
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: uri.toString()),
                              );
                              showSnackBar('copyToClipboard'.tr());
                            },
                            icon: const Icon(Symbols.content_copy),
                            label: Text('domainTrustCopyLink'.tr()),
                          ),
                          const SizedBox(height: 12),
                          isBlocked
                              ? _LongPressProceedButton(
                                  label: _ctaKey.tr(),
                                  onCompleted: () => Navigator.pop(
                                    context,
                                    DomainTrustDecision.proceed,
                                  ),
                                )
                              : FilledButton.icon(
                                  onPressed: () {
                                    Navigator.pop(
                                      context,
                                      DomainTrustDecision.proceed,
                                    );
                                  },
                                  icon: Icon(
                                    action == DomainTrustAction.openLink
                                        ? Symbols.open_in_new
                                        : Symbols.image,
                                  ),
                                  label: Text(_ctaKey.tr()),
                                ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(text: uri.toString()),
                                );
                                showSnackBar('copyToClipboard'.tr());
                              },
                              icon: const Icon(Symbols.content_copy),
                              label: Text('domainTrustCopyLink'.tr()),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: isBlocked
                                ? _LongPressProceedButton(
                                    label: _ctaKey.tr(),
                                    onCompleted: () => Navigator.pop(
                                      context,
                                      DomainTrustDecision.proceed,
                                    ),
                                  )
                                : FilledButton.icon(
                                    onPressed: () {
                                      Navigator.pop(
                                        context,
                                        DomainTrustDecision.proceed,
                                      );
                                    },
                                    icon: Icon(
                                      action == DomainTrustAction.openLink
                                          ? Symbols.open_in_new
                                          : Symbols.image,
                                    ),
                                    label: Text(_ctaKey.tr()),
                                  ),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String get _descriptionKey {
    if (result.trustLevel == DomainTrustLevel.blocked) {
      return action == DomainTrustAction.openLink
          ? 'domainUntrustOpenLinkDescription'
          : 'domainUntrustLoadImageDescription';
    }
    return action == DomainTrustAction.openLink
        ? 'domainTrustOpenLinkDescription'
        : 'domainTrustLoadImageDescription';
  }

  String get _ctaKey {
    if (result.trustLevel == DomainTrustLevel.blocked) {
      return action == DomainTrustAction.openLink
          ? 'domainTrustLongPressOpen'
          : 'domainTrustLongPressLoadImage';
    }
    return action == DomainTrustAction.openLink
        ? 'domainTrustOpenAnyway'
        : 'domainTrustLoadImage';
  }
}

class _LongPressProceedButton extends StatefulWidget {
  final String label;
  final VoidCallback onCompleted;

  const _LongPressProceedButton({
    required this.label,
    required this.onCompleted,
  });

  @override
  State<_LongPressProceedButton> createState() =>
      _LongPressProceedButtonState();
}

class _LongPressProceedButtonState extends State<_LongPressProceedButton> {
  static const _holdDuration = Duration(milliseconds: 900);

  Timer? _timer;
  bool _holding = false;

  void _startHold() {
    setState(() => _holding = true);
    _timer = Timer(_holdDuration, widget.onCompleted);
  }

  void _cancelHold() {
    _timer?.cancel();
    _timer = null;
    if (_holding && mounted) {
      setState(() => _holding = false);
    }
  }

  @override
  void dispose() {
    _cancelHold();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onLongPressStart: (_) => _startHold(),
      onLongPressEnd: (_) => _cancelHold(),
      onLongPressCancel: _cancelHold,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 40,
        decoration: BoxDecoration(
          color: _holding ? scheme.error : scheme.errorContainer,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: scheme.error.withOpacity(0.35)),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Symbols.touch_app,
              size: 18,
              color: _holding ? scheme.onError : scheme.error,
            ),
            const SizedBox(width: 8),
            Text(
              widget.label,
              style: TextStyle(
                color: _holding ? scheme.onError : scheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
