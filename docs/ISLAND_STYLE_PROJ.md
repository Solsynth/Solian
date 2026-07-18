# Scaffolding an Island-style Flutter project

This guide describes the structural and UI patterns used by Island when starting a new Flutter application. It is a reference, not a requirement to copy all Island services, integrations, or product-specific features.

## Start with the foundation package

Use `island_ui_foundation` from this repository as a Git dependency when a project needs Island's desktop window frame, responsive helpers, overlays, sheets, and shared UI primitives.

```yaml
dependencies:
  island_ui_foundation:
    git:
      url: https://src.solsynth.dev/SoSYS/Solian.git
      path: packages/island_ui_foundation
```

The foundation package depends on `flutter_hooks` and `hooks_riverpod`. Add those to the application as direct dependencies as well. A desktop application should also depend directly on the same `window_manager` Git revision used by the foundation package.

## Bootstrap the desktop window

Initialize the Flutter binding, then initialize `window_manager` only on desktop platforms. Configure a hidden native title bar before rendering the app. `DesktopWindowFrame` then supplies the draggable title bar and platform window buttons.

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (DesktopWindowFrame.isPlatformDesktop) {
    await windowManager.ensureInitialized();
    const options = WindowOptions(
      size: Size(1180, 760),
      minimumSize: Size(720, 520),
      center: true,
      titleBarStyle: TitleBarStyle.hidden,
      windowButtonVisibility: true,
    );
    await windowManager.waitUntilReadyToShow(options, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(const ProviderScope(child: App()));
}
```

Refer to `lib/main.dart` and `lib/shared/widgets/app_scaffold.dart` for Island's production bootstrap and window shell.

## Wrap the routed application once

Put `DesktopWindowFrame` around the routed content in the `MaterialApp.router` builder. Do not recreate window chrome on each page.

```dart
MaterialApp.router(
  routerConfig: appRouter.config(),
  builder: (context, child) => DesktopWindowFrame(
    isDesktopPlatform: DesktopWindowFrame.isPlatformDesktop,
    title: const Text('Application name'),
    child: child ?? const SizedBox.shrink(),
  ),
)
```

Use an application-specific wrapper widget when overlays, command palettes, lifecycle behavior, or global keyboard handlers are needed. Island's `WindowScaffold` is the reference implementation.

## Build main navigation with nested routes

Island's `TabsScreen` uses `AutoTabsRouter` rather than holding a selected tab index in local widget state. Model each major workspace as a child route, declare those children in the root router, then switch through the `TabsRouter` supplied by `AutoTabsRouter`.

```dart
@RoutePage()
class WorkspacePage extends StatelessWidget {
  const WorkspacePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      routes: const [HomeRoute(), ActivityRoute()],
      builder: (context, child) {
        final tabs = AutoTabsRouter.of(context);
        return NavigationShell(
          selectedIndex: tabs.activeIndex,
          onSelected: tabs.setActiveIndex,
          child: child,
        );
      },
    );
  }
}
```

On wide layouts, use a transparent `NavigationRail` beside an inset content surface. On narrow layouts, use a compact Material `NavigationBar`. Island uses the `isWideScreen` threshold from `island_ui_foundation` (768 logical pixels). See `lib/misc/tabs_screen.dart` for the complete responsive shell.

## Keep the visual language quiet

- Use Material 3 components and the active color scheme.
- Keep desktop navigation restrained: a rail and content surface are usually enough.
- Use 4/8/12/16/24/32 spacing increments.
- Prefer subtle surface contrast and 1px dividers over shadows, gradients, glow, or glass effects.
- Keep corner radii modest (typically 8–12px) and use them sparingly.
- Avoid adding an app bar to every tab if the window frame and primary navigation already establish context.
- Reserve overlays, drawers, sheets, and attention modals for real interactions; use the foundation widgets rather than inventing replacements.

## Route generation and checks

Use `@RoutePage()` and the generated AutoRoute configuration. Import the generated route library where route classes need to be instantiated; do not edit generated files.

```sh
dart format lib test
dart run build_runner build
flutter analyze
flutter test
```

For examples of an end-to-end Island shell, start with `lib/shared/widgets/app_scaffold.dart` and `lib/misc/tabs_screen.dart`, then follow their route declarations in `lib/route.dart`.
