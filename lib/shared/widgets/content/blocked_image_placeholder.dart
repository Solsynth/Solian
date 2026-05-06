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
    final characterAsset = isBlocked
        ? 'assets/images/michan/link-warning.webp'
        : 'assets/images/michan/link-prompt.webp';

    return Container(
      constraints: const BoxConstraints(minHeight: 180),
      decoration: BoxDecoration(
        color: isBlocked
            ? scheme.errorContainer.withOpacity(0.35)
            : scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
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
                  borderRadius: BorderRadius.circular(8),
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
                  margin: const EdgeInsets.only(top: 50),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          uri.host,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
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
                  right: -60,
                  bottom: 32,
                  child: IgnorePointer(
                    child: Image.asset(
                      characterAsset,
                      height: 240,
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

class _InlineLongPressButtonState extends State<_InlineLongPressButton>
    with SingleTickerProviderStateMixin {
  static const _holdDuration = Duration(milliseconds: 900);

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _holdDuration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onCompleted();
          _controller.reset();
        }
      });
  }

  void _startHold() {
    if (_controller.isAnimating) return;
    _controller.forward(from: 0);
  }

  void _cancelHold() {
    if (_controller.isCompleted) return;
    _controller.stop();
    _controller.reset();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Listener(
      onPointerDown: (_) => _startHold(),
      onPointerUp: (_) => _cancelHold(),
      onPointerCancel: (_) => _cancelHold(),
      behavior: HitTestBehavior.opaque,
      child: GestureDetector(
        onLongPress: () {},
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final isHolding = _controller.value > 0;
            return ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: scheme.errorContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: child,
                  ),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: _controller.value,
                        child: Container(color: scheme.error),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      alignment: Alignment.center,
                      child: Text(
                        widget.label,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: isHolding ? scheme.onError : scheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          child: Text(
            widget.label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: scheme.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
