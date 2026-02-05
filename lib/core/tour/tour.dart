import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/services/tour.dart';

const List<String> kStartTours = ['technical_review_intro'];

class TourTriggerWidget extends HookConsumerWidget {
  final Widget child;
  const TourTriggerWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tourStatus = ref.watch(tourStatusProvider.notifier);

    useEffect(() {
      Future(() async {
        for (final tour in kStartTours) {
          final widget = await tourStatus.showTour(tour);
          if (widget != null) {
            if (!context.mounted) return;
            await showModalBottomSheet(
              isScrollControlled: true,
              useRootNavigator: true,
              context: context,
              builder: (context) => widget,
            );
          }
        }
      });
      return null;
    }, [tourStatus]);

    return child;
  }
}
