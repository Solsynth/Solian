import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_symbols_icons/symbols.dart';

class HoverScrollableList extends HookWidget {
  final double height;
  final double? itemExtent;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final EdgeInsetsGeometry? padding;
  final double spacing;

  const HoverScrollableList({
    super.key,
    required this.height,
    this.itemExtent,
    required this.itemCount,
    required this.itemBuilder,
    this.padding,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    final controller = useScrollController();
    final isHovered = useState(false);
    final canScrollLeft = useState(false);
    final canScrollRight = useState(false);

    void updateScrollState() {
      if (!controller.hasClients) {
        canScrollLeft.value = false;
        canScrollRight.value = false;
        return;
      }

      final position = controller.position;
      canScrollLeft.value = position.pixels > 0;
      canScrollRight.value = position.pixels < position.maxScrollExtent;
    }

    useEffect(() {
      void listener() => updateScrollState();

      controller.addListener(listener);
      WidgetsBinding.instance.addPostFrameCallback((_) => updateScrollState());

      return () => controller.removeListener(listener);
    }, [controller, itemCount, padding]);

    Future<void> scrollBy(double direction) async {
      if (!controller.hasClients) return;
      final position = controller.position;
      final delta = math.max(position.viewportDimension * 0.8, 240.0);
      final target = (position.pixels + delta * direction).clamp(
        0.0,
        position.maxScrollExtent,
      );
      await controller.animateTo(
        target,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    }

    final scrollBehavior = ScrollConfiguration.of(context).copyWith(
      dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.trackpad},
    );

    return SizedBox(
      height: height,
      child: MouseRegion(
        onEnter: (_) => isHovered.value = true,
        onExit: (_) => isHovered.value = false,
        child: Stack(
          children: [
            Positioned.fill(
              child: ScrollConfiguration(
                behavior: scrollBehavior,
                child: ListView.separated(
                  controller: controller,
                  scrollDirection: Axis.horizontal,
                  padding: padding,
                  itemCount: itemCount,
                  itemBuilder: (context, index) {
                    final child = itemBuilder(context, index);
                    return itemExtent == null
                        ? child
                        : SizedBox(width: itemExtent, child: child);
                  },
                  separatorBuilder: (_, _) => SizedBox(width: spacing),
                ),
              ),
            ),
            Positioned(
              left: 12,
              top: 0,
              bottom: 0,
              child: Center(
                child: _HoverScrollArrowButton(
                  icon: Symbols.chevron_left,
                  isVisible: isHovered.value && canScrollLeft.value,
                  hiddenOffset: const Offset(-0.4, 0),
                  onTap: () => scrollBy(-1),
                ),
              ),
            ),
            Positioned(
              right: 12,
              top: 0,
              bottom: 0,
              child: Center(
                child: _HoverScrollArrowButton(
                  icon: Symbols.chevron_right,
                  isVisible: isHovered.value && canScrollRight.value,
                  hiddenOffset: const Offset(0.4, 0),
                  onTap: () => scrollBy(1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HoverScrollArrowButton extends StatelessWidget {
  final IconData icon;
  final bool isVisible;
  final Offset hiddenOffset;
  final VoidCallback onTap;

  const _HoverScrollArrowButton({
    required this.icon,
    required this.isVisible,
    required this.hiddenOffset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !isVisible,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        offset: isVisible ? Offset.zero : hiddenOffset,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          opacity: isVisible ? 1 : 0,
          child: Material(
            color: Colors.black45,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: SizedBox(
                width: 40,
                height: 40,
                child: Icon(icon, color: Colors.white, size: 20),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
