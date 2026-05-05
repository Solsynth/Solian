import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:island/core/network/domain_trust.dart';
import 'package:material_symbols_icons/symbols.dart';

class BlockedImagePlaceholder extends StatelessWidget {
  final Uri uri;
  final DomainTrustResult result;
  final VoidCallback onProceed;

  const BlockedImagePlaceholder({
    super.key,
    required this.uri,
    required this.result,
    required this.onProceed,
  });

  @override
  Widget build(BuildContext context) {
    final isBlocked = result.trustLevel == DomainTrustLevel.blocked;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      constraints: const BoxConstraints(minHeight: 180),
      decoration: BoxDecoration(
        color: isBlocked
            ? scheme.errorContainer.withOpacity(0.35)
            : scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isBlocked
              ? scheme.error.withOpacity(0.35)
              : scheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isBlocked ? Symbols.privacy_tip : Symbols.travel_explore,
                  color: isBlocked ? scheme.error : scheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'domainTrustTitle'.tr(),
                    style: GoogleFonts.notoSerifSc(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isBlocked ? scheme.error : scheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isBlocked
                  ? 'domainUntrustLoadImageDescription'.tr()
                  : 'domainTrustLoadImageDescription'.tr(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (result.blockReason != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${'domainTrustReason'.tr()}: ${result.blockReason}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 50, right: 80),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          uri.host,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                            color: scheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      isBlocked
                          ? _InlineLongPressButton(
                              label: 'domainTrustLongPressLoadImage'.tr(),
                              onCompleted: onProceed,
                            )
                          : TextButton.icon(
                              onPressed: onProceed,
                              icon: const Icon(Symbols.image, size: 16),
                              label: Text('domainTrustLoadImage'.tr()),
                              style: TextButton.styleFrom(
                                foregroundColor: scheme.primary,
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                    ],
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: IgnorePointer(
                    child: Image.asset(
                      'assets/images/michan/link-hint.png',
                      height: 132,
                      fit: BoxFit.contain,
                    ),
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

class _InlineLongPressButton extends StatefulWidget {
  final String label;
  final VoidCallback onCompleted;

  const _InlineLongPressButton({
    required this.label,
    required this.onCompleted,
  });

  @override
  State<_InlineLongPressButton> createState() => _InlineLongPressButtonState();
}

class _InlineLongPressButtonState extends State<_InlineLongPressButton> {
  bool _holding = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onLongPressStart: (_) => setState(() => _holding = true),
      onLongPressEnd: (_) {
        setState(() => _holding = false);
        widget.onCompleted();
      },
      onLongPressCancel: () => setState(() => _holding = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: _holding ? scheme.error : scheme.errorContainer,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          widget.label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: _holding ? scheme.onError : scheme.error,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
