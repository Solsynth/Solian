import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Tracks download progress for an [ImageProvider] while a quality switch
/// (compressed ↔ original) is in flight.
class ImageQualityLoadState {
  final bool isLoading;
  final double? progress;
  final VoidCallback beginLoad;

  const ImageQualityLoadState({
    required this.isLoading,
    required this.progress,
    required this.beginLoad,
  });
}

/// Call from a HookWidget. [provider] should already reflect the target quality
/// after the caller flips `showOriginal`.
ImageQualityLoadState useImageQualityLoad({
  required ImageProvider provider,
  required bool showOriginal,
  Object? reloadToken,
}) {
  final isLoading = useState(false);
  final progress = useState<double?>(null);

  useEffect(() {
    if (!isLoading.value) return null;

    final stream = provider.resolve(const ImageConfiguration());
    var completed = false;

    void complete() {
      if (completed) return;
      completed = true;
      isLoading.value = false;
      progress.value = null;
    }

    final listener = ImageStreamListener(
      (ImageInfo info, bool synchronousCall) => complete(),
      onChunk: (ImageChunkEvent event) {
        final total = event.expectedTotalBytes;
        if (total != null && total > 0) {
          progress.value = (event.cumulativeBytesLoaded / total).clamp(
            0.0,
            1.0,
          );
        } else {
          progress.value = null;
        }
      },
      onError: (Object exception, StackTrace? stackTrace) => complete(),
    );

    stream.addListener(listener);
    return () => stream.removeListener(listener);
  }, [isLoading.value, showOriginal, reloadToken]);

  return ImageQualityLoadState(
    isLoading: isLoading.value,
    progress: progress.value,
    beginLoad: () {
      isLoading.value = true;
      progress.value = null;
    },
  );
}

/// Full-width progress track pinned to the top content edge.
///
/// Slides in/out like [ChatSyncIndicator]. Determinate progress is tweened
/// for smooth updates. When [avoidTopSafeArea] is true (fullscreen viewers),
/// the bar sits just under the status bar / notch.
class ImageQualityProgressBar extends HookWidget {
  final bool isLoading;
  final double? progress;
  final bool loadingOriginal;
  final bool avoidTopSafeArea;

  static const double thickness = 6;

  const ImageQualityProgressBar({
    super.key,
    required this.isLoading,
    required this.progress,
    // Kept for call-site compatibility; label no longer shown.
    required this.loadingOriginal,
    this.avoidTopSafeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    final visibility = useAnimationController(
      duration: const Duration(milliseconds: 280),
    );
    final progressAnim = useAnimationController(
      duration: const Duration(milliseconds: 200),
    );

    final shownProgress = useState<double?>(null);
    final tweenFrom = useRef(0.0);
    final tweenTo = useRef(0.0);

    useEffect(() {
      if (isLoading) {
        visibility.forward();
      } else {
        visibility.reverse();
      }
      return null;
    }, [isLoading]);

    useEffect(() {
      // Keep the last determinate value while sliding out so the bar doesn't
      // flip to an indeterminate spinner mid-exit.
      if (!isLoading) return null;

      if (progress == null) {
        shownProgress.value = null;
        progressAnim.stop();
        return null;
      }

      final next = progress!.clamp(0.0, 1.0);
      final current = shownProgress.value ?? 0.0;
      if ((current - next).abs() < 0.001) {
        shownProgress.value = next;
        return null;
      }

      tweenFrom.value = current;
      tweenTo.value = next;
      progressAnim
        ..value = 0
        ..forward();
      return null;
    }, [progress, isLoading]);

    useEffect(() {
      void listener() {
        final t = Curves.easeOutCubic.transform(progressAnim.value);
        shownProgress.value =
            tweenFrom.value + (tweenTo.value - tweenFrom.value) * t;
      }

      progressAnim.addListener(listener);
      return () => progressAnim.removeListener(listener);
    }, [progressAnim]);

    final visibilityT = useAnimation(
      CurvedAnimation(parent: visibility, curve: Curves.easeOutCubic),
    );

    if (!isLoading && visibility.isDismissed) {
      return const SizedBox.shrink();
    }

    final topInset =
        avoidTopSafeArea ? MediaQuery.paddingOf(context).top : 0.0;

    final bar = SizedBox(
      width: double.infinity,
      height: thickness,
      child: LinearProgressIndicator(
        value: shownProgress.value,
        minHeight: thickness,
        borderRadius: BorderRadius.zero,
        backgroundColor: Colors.white.withValues(alpha: 0.22),
        color: Colors.white,
        stopIndicatorColor: Colors.transparent,
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (topInset > 0) SizedBox(height: topInset),
        ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: visibilityT.clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0, (visibilityT - 1) * thickness),
              child: bar,
            ),
          ),
        ),
      ],
    );
  }
}
