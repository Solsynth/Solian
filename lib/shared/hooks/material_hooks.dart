import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:material_ui/material_ui.dart' as material_ui;

material_ui.TabController useMaterialTabController({
  required int initialLength,
  Duration? animationDuration,
  TickerProvider? vsync,
  int initialIndex = 0,
  List<Object?>? keys,
}) {
  vsync ??= useSingleTickerProvider(keys: keys);

  return use(
    _MaterialTabControllerHook(
      vsync: vsync,
      length: initialLength,
      initialIndex: initialIndex,
      animationDuration: animationDuration,
      keys: keys,
    ),
  );
}

class _MaterialTabControllerHook
    extends Hook<material_ui.TabController> {
  const _MaterialTabControllerHook({
    required this.length,
    required this.vsync,
    required this.initialIndex,
    required this.animationDuration,
    super.keys,
  });

  final int length;
  final TickerProvider vsync;
  final int initialIndex;
  final Duration? animationDuration;

  @override
  HookState<material_ui.TabController, Hook<material_ui.TabController>>
  createState() => _MaterialTabControllerHookState();
}

class _MaterialTabControllerHookState extends HookState<
  material_ui.TabController,
  _MaterialTabControllerHook
> {
  late final controller = material_ui.TabController(
    length: hook.length,
    initialIndex: hook.initialIndex,
    animationDuration: hook.animationDuration,
    vsync: hook.vsync,
  );

  @override
  material_ui.TabController build(BuildContext context) => controller;

  @override
  void dispose() => controller.dispose();

  @override
  String get debugLabel => 'useMaterialTabController';
}

material_ui.CarouselController useMaterialCarouselController({
  int initialItem = 0,
  List<Object?>? keys,
}) {
  return use(
    _MaterialCarouselControllerHook(initialItem: initialItem, keys: keys),
  );
}

class _MaterialCarouselControllerHook
    extends Hook<material_ui.CarouselController> {
  const _MaterialCarouselControllerHook({
    required this.initialItem,
    super.keys,
  });

  final int initialItem;

  @override
  HookState<
    material_ui.CarouselController,
    Hook<material_ui.CarouselController>
  > createState() => _MaterialCarouselControllerHookState();
}

class _MaterialCarouselControllerHookState extends HookState<
  material_ui.CarouselController,
  _MaterialCarouselControllerHook
> {
  late final controller = material_ui.CarouselController(
    initialItem: hook.initialItem,
  );

  @override
  material_ui.CarouselController build(BuildContext context) => controller;

  @override
  void dispose() => controller.dispose();

  @override
  String get debugLabel => 'useMaterialCarouselController';
}
