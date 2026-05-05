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

    return SheetScaffold(
      showHeader: false,
      heightFactor: 0.56,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
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
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(right: 104),
                child: Text(
                  _descriptionKey.tr(),
                  style: GoogleFonts.notoSerifSc(fontSize: 14),
                ),
              ),
              const SizedBox(height: 24),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 60, right: 88),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        uri.toString(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 8,
                    child: IgnorePointer(
                      child: Image.asset(
                        'assets/images/michan/link-hint.png',
                        height: 220,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
              if (result.blockReason != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isBlocked
                        ? scheme.errorContainer
                        : scheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(8),
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
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: uri.toString()));
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
  State<_LongPressProceedButton> createState() => _LongPressProceedButtonState();
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
