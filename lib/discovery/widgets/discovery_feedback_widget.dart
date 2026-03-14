import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/discovery/discovery_feedback_service.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:easy_localization/easy_localization.dart';

class DiscoveryFeedbackWidget extends HookConsumerWidget {
  final String kind;
  final String referenceId;
  final bool showNotInterested;
  final bool showBackground;
  final VoidCallback? onFeedbackSubmitted;

  const DiscoveryFeedbackWidget({
    super.key,
    required this.kind,
    required this.referenceId,
    this.showNotInterested = true,
    this.showBackground = true,
    this.onFeedbackSubmitted,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedbackGiven = useState<DiscoveryFeedbackValue?>(null);
    final isLoading = useState(false);
    final isUninterested = useState(false);

    final submitFeedback = useCallback((DiscoveryFeedbackValue feedback) async {
      if (isLoading.value) return;

      isLoading.value = true;

      try {
        final service = ref.read(discoveryFeedbackServiceProvider);
        final feedbackKind = _mapKindToFeedbackKind(kind);

        await service.submitFeedback(
          kind: feedbackKind,
          referenceId: referenceId,
          feedback: feedback,
        );

        feedbackGiven.value = feedback;
        onFeedbackSubmitted?.call();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to submit feedback').tr(),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } finally {
        isLoading.value = false;
      }
    }, [kind, referenceId, onFeedbackSubmitted]);

    final toggleUninterested = useCallback(() async {
      if (isLoading.value) return;

      isLoading.value = true;

      try {
        final service = ref.read(discoveryFeedbackServiceProvider);

        if (isUninterested.value) {
          await service.removeUninterested(
            kind: kind,
            referenceId: referenceId,
          );
          isUninterested.value = false;
        } else {
          await service.markUninterested(kind: kind, referenceId: referenceId);
          isUninterested.value = true;
          onFeedbackSubmitted?.call();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update preference').tr(),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } finally {
        isLoading.value = false;
      }
    }, [kind, referenceId, onFeedbackSubmitted]);

    final colorScheme = Theme.of(context).colorScheme;

    final actionsWidget = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _FeedbackButton(
          icon: Symbols.thumb_up,
          isSelected: feedbackGiven.value == DiscoveryFeedbackValue.positive,
          isLoading: isLoading.value,
          onPressed: () => submitFeedback(DiscoveryFeedbackValue.positive),
          tooltip: 'Show more like this'.tr(),
          color: colorScheme.primary,
        ),
        const Gap(4),
        _FeedbackButton(
          icon: Symbols.thumb_down,
          isSelected: feedbackGiven.value == DiscoveryFeedbackValue.negative,
          isLoading: isLoading.value,
          onPressed: () => submitFeedback(DiscoveryFeedbackValue.negative),
          tooltip: 'Show less like this'.tr(),
          color: colorScheme.error,
        ),
        if (showNotInterested) ...[
          const Gap(8),
          _FeedbackButton(
            icon: Symbols.hide_source,
            isSelected: isUninterested.value,
            isLoading: isLoading.value,
            onPressed: toggleUninterested,
            tooltip: 'Not interested'.tr(),
            color: colorScheme.onSurfaceVariant,
          ),
        ],
      ],
    );

    if (!showBackground) return actionsWidget;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: actionsWidget,
    );
  }

  DiscoveryFeedbackKind _mapKindToFeedbackKind(String kind) {
    switch (kind.toLowerCase()) {
      case 'publisher':
        return DiscoveryFeedbackKind.publisher;
      case 'tag':
        return DiscoveryFeedbackKind.tag;
      case 'category':
        return DiscoveryFeedbackKind.category;
      case 'post':
      case 'realm':
      case 'account':
      case 'article':
      default:
        return DiscoveryFeedbackKind.post;
    }
  }
}

class _FeedbackButton extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final bool isLoading;
  final VoidCallback onPressed;
  final String tooltip;
  final Color? color;

  const _FeedbackButton({
    required this.icon,
    required this.isSelected,
    required this.isLoading,
    required this.onPressed,
    required this.tooltip,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: isSelected
            ? (color ?? colorScheme.primary).withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: isLoading
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: color ?? colorScheme.onSurfaceVariant,
                    ),
                  )
                : Icon(
                    icon,
                    size: 18,
                    fill: isSelected ? 1 : 0,
                    color: isSelected
                        ? (color ?? colorScheme.primary)
                        : colorScheme.onSurfaceVariant,
                  ),
          ),
        ),
      ),
    );
  }
}
