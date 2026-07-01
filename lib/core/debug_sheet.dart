import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/progression_ws.dart';
import 'package:island/accounts/widgets/friend_status_toast.dart';
import 'package:island/core/database.dart';
import 'package:island/core/notification.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/update_service.dart';
import 'package:island/core/services/notify.dart' as local_notify;
import 'package:island/drive/drive_service.dart';
import 'package:island/e2ee/mls_engine.dart';
import 'package:island/e2ee/mls_storage.dart';
import 'package:island/e2ee/mls_client.dart';
import 'package:island/e2ee/key_package_popup.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/core/widgets/content/network_status_sheet.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:island/core/config.dart';
import 'package:island/chat/pods/native_call_bridge.dart';
import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:island/shared/widgets/app_onboarding_sheet.dart';
import 'package:island/shared/widgets/app_wrapper.dart';
import 'package:island/core/widgets/draggable_log_overlay.dart';
import 'package:island/main.dart';
import 'package:island/route.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/tasks/app_task.dart';
import 'package:island/tasks/tasks_notifier.dart';

import 'package:solar_network_sdk/solar_network_sdk.dart';

SnAccount _createTestAccount({
  required String id,
  required String name,
  String? nick,
}) {
  return SnAccount(
    id: id,
    name: name,
    nick: nick ?? name,
    language: 'en',
    isSuperuser: false,
    automatedId: null,
    profile: SnAccountProfile(
      id: 'profile-$id',
      experience: 0,
      level: 1,
      levelingProgress: 0.0,
      picture: null,
      background: null,
      verification: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      deletedAt: null,
    ),
    perkSubscription: null,
    badges: [],
    contacts: [],
    activatedAt: DateTime.now(),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    deletedAt: null,
  );
}

OverlayEntry? _debugOverlayEntry;

final _debugOverlayStateProvider =
    NotifierProvider<_DebugOverlayStateNotifier, _DebugOverlayState>(
      _DebugOverlayStateNotifier.new,
    );

class _DebugOverlayState {
  final Offset position;
  final Size size;
  final bool isCollapsed;

  const _DebugOverlayState({
    this.position = const Offset(16, 80),
    this.size = const Size(360, 580),
    this.isCollapsed = false,
  });

  _DebugOverlayState copyWith({
    Offset? position,
    Size? size,
    bool? isCollapsed,
  }) {
    return _DebugOverlayState(
      position: position ?? this.position,
      size: size ?? this.size,
      isCollapsed: isCollapsed ?? this.isCollapsed,
    );
  }
}

class _DebugOverlayStateNotifier extends Notifier<_DebugOverlayState> {
  @override
  _DebugOverlayState build() => const _DebugOverlayState();

  void updatePosition(Offset delta) {
    state = state.copyWith(
      position: Offset(
        state.position.dx + delta.dx,
        state.position.dy + delta.dy,
      ),
    );
  }

  void setPosition(Offset position) {
    state = state.copyWith(position: position);
  }

  void updateSize(Size delta) {
    const minWidth = 280.0;
    const minHeight = 300.0;
    const maxWidth = 600.0;
    const maxHeight = 800.0;

    final newWidth = (state.size.width + delta.width).clamp(minWidth, maxWidth);
    final newHeight = (state.size.height + delta.height).clamp(
      minHeight,
      maxHeight,
    );
    state = state.copyWith(size: Size(newWidth, newHeight));
  }

  void setCollapsed(bool value) {
    state = state.copyWith(isCollapsed: value);
  }
}

void showDebugOverlay() {
  if (_debugOverlayEntry != null) return;

  final state = _container.read(_debugOverlayStateProvider);
  _debugOverlayEntry = OverlayEntry(
    builder: (context) => _DraggableDebugPanel(
      initialPosition: state.position,
      initialSize: state.size,
      initialCollapsed: state.isCollapsed,
    ),
  );
  globalOverlay.currentState?.insert(_debugOverlayEntry!);
}

void hideDebugOverlay() {
  _debugOverlayEntry?.remove();
  _debugOverlayEntry = null;
}

void toggleDebugOverlay(WidgetRef ref) {
  if (!ref.read(developerModeProvider)) {
    Logger.root.info('[DeveloperMode] Blocked debug overlay toggle');
    return;
  }
  if (_debugOverlayEntry != null) {
    hideDebugOverlay();
  } else {
    showDebugOverlay();
  }
}

final ProviderContainer _container = ProviderContainer();

Future<void> _showSetTokenDialog(BuildContext context, WidgetRef ref) async {
  final TextEditingController controller = TextEditingController();
  final prefs = ref.read(sharedPreferencesProvider);

  return showDialog<void>(
    context: ref.read(routerProvider).navigatorKey.currentState!.context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Set access token'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter access token',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
          autofocus: true,
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Set'),
            onPressed: () async {
              final token = controller.text.trim();
              if (token.isNotEmpty) {
                await setToken(prefs, token);
                ref.invalidate(tokenProvider);
                final navigatorContext = context;
                if (navigatorContext.mounted) {
                  Navigator.of(navigatorContext).pop();
                }
              }
            },
          ),
        ],
      );
    },
  );
}

Future<String?> _promptForRoomId(BuildContext context, String title) async {
  final TextEditingController controller = TextEditingController();

  return showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Room ID for $title'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter chat room ID',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
          autofocus: true,
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Start'),
            onPressed: () {
              final roomId = controller.text.trim();
              if (roomId.isNotEmpty) {
                Navigator.of(context).pop(roomId);
              }
            },
          ),
        ],
      );
    },
  );
}

void _startDebugProgressTask(WidgetRef ref) {
  final tasks = ref.read(tasksProvider.notifier);
  final taskId = tasks.addTask(
    title: 'Debug upload task',
    type: AppTaskType.driveUpload,
    status: AppTaskStatus.inProgress,
    metadata: {
      'fileSize': 16 * 1024 * 1024,
      'totalChunks': 8,
      'uploadedChunks': 0,
      'transmissionProgress': 0.0,
    },
  );

  Future<void>(() async {
    for (var i = 1; i <= 5; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 650));
      tasks.updateTask(
        taskId,
        status: AppTaskStatus.inProgress,
        progress: i / 5,
        statusMessage: 'Uploading debug payload ${i * 20}%',
        metadata: {
          'fileSize': 16 * 1024 * 1024,
          'totalChunks': 8,
          'uploadedChunks': (i * 8 / 5).round(),
          'transmissionProgress': i / 5,
        },
      );
    }
    tasks.updateTask(
      taskId,
      status: AppTaskStatus.completed,
      progress: 1,
      statusMessage: 'Debug upload completed',
      metadata: {
        'fileSize': 16 * 1024 * 1024,
        'totalChunks': 8,
        'uploadedChunks': 8,
        'transmissionProgress': 1.0,
      },
    );
  });
}

void _addDebugSuccessTask(WidgetRef ref) {
  final tasks = ref.read(tasksProvider.notifier);
  final taskId = tasks.addTask(
    title: 'Debug completed task',
    type: AppTaskType.postPublish,
    status: AppTaskStatus.inProgress,
  );
  tasks.updateTask(
    taskId,
    status: AppTaskStatus.completed,
    progress: 1,
    statusMessage: 'Debug task finished',
  );
}

void _addDebugFailedTask(WidgetRef ref) {
  final tasks = ref.read(tasksProvider.notifier);
  final taskId = tasks.addTask(
    title: 'Debug failed task',
    type: AppTaskType.driveDownload,
    status: AppTaskStatus.inProgress,
  );
  tasks.updateTask(
    taskId,
    status: AppTaskStatus.failed,
    progress: 0.62,
    statusMessage: 'Debug download failed',
    errorMessage: 'Injected failure for overlay testing.',
    metadata: {
      'totalBytes': 20 * 1024 * 1024,
      'downloadedBytes': (20 * 1024 * 1024 * 0.62).round(),
    },
  );
}

class _DraggableDebugPanel extends ConsumerStatefulWidget {
  final Offset initialPosition;
  final Size initialSize;
  final bool initialCollapsed;

  const _DraggableDebugPanel({
    required this.initialPosition,
    required this.initialSize,
    required this.initialCollapsed,
  });

  @override
  ConsumerState<_DraggableDebugPanel> createState() =>
      _DraggableDebugPanelState();
}

class _DraggableDebugPanelState extends ConsumerState<_DraggableDebugPanel>
    with SingleTickerProviderStateMixin {
  late Offset _position;
  late Size _size;
  late bool _isCollapsed;
  late AnimationController _animController;
  late Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _position = widget.initialPosition;
    _size = widget.initialSize;
    _isCollapsed = widget.initialCollapsed;
    _animController = AnimationController(
      duration: const Duration(milliseconds: 280),
      vsync: this,
      value: _isCollapsed ? 0.0 : 1.0,
    );
    _expandAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _toggleCollapsed() {
    setState(() => _isCollapsed = !_isCollapsed);
    ref.read(_debugOverlayStateProvider.notifier).setCollapsed(_isCollapsed);
    if (_isCollapsed) {
      _animController.reverse();
    } else {
      _animController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    const collapsedWidth = 140.0;
    const collapsedHeight = 140.0;
    final currentWidth =
        collapsedWidth + (_size.width - collapsedWidth) * _expandAnim.value;
    final currentHeight =
        collapsedHeight + (_size.height - collapsedHeight) * _expandAnim.value;

    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onPanUpdate: (details) {
            final screenSize = MediaQuery.of(context).size;
            final overlayWidth = _isCollapsed ? collapsedWidth : _size.width;
            final overlayHeight = _isCollapsed ? collapsedHeight : _size.height;

            setState(() {
              _position = Offset(
                (_position.dx + details.delta.dx).clamp(
                  0,
                  screenSize.width - overlayWidth,
                ),
                (_position.dy + details.delta.dy).clamp(
                  0,
                  screenSize.height - overlayHeight,
                ),
              );
            });
            ref
                .read(_debugOverlayStateProvider.notifier)
                .updatePosition(details.delta);
          },
          child: AnimatedSize(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: currentWidth,
              height: currentHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _buildPanelContainer(context),
                  ),
                  if (!_isCollapsed) ...[
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: _buildResizeHandle(theme),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPanelContainer(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: _isCollapsed
            ? _buildCollapsedContent(context)
            : _buildExpandedContent(context),
      ),
    );
  }

  Widget _buildResizeHandle(ThemeData theme) {
    const minWidth = 280.0;
    const minHeight = 300.0;
    const maxWidth = 600.0;
    const maxHeight = 800.0;

    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          final newWidth = (_size.width + details.delta.dx).clamp(
            minWidth,
            maxWidth,
          );
          final newHeight = (_size.height + details.delta.dy).clamp(
            minHeight,
            maxHeight,
          );
          _size = Size(newWidth, newHeight);
        });
      },
      onPanEnd: (_) {
        ref
            .read(_debugOverlayStateProvider.notifier)
            .updateSize(Size(_size.width - 360, _size.height - 580));
      },
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Icon(
          Icons.drag_handle,
          size: 14,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildExpandedContent(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        Container(height: 1, color: Theme.of(context).dividerColor),
        Expanded(child: _buildContent(context)),
      ],
    );
  }

  Widget _buildCollapsedContent(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: _toggleCollapsed,
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Symbols.bug_report,
                color: theme.colorScheme.onPrimary,
                size: 24,
              ),
            ),
            const Gap(6),
            Text(
              'Debug',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(4),
            Icon(
              Icons.expand_more,
              size: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.surfaceContainerHighest.withOpacity(0.7),
            theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withOpacity(0.6),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Icon(Symbols.bug_report, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            'Debug',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          _HeaderButton(
            icon: _isCollapsed ? Symbols.open_in_full : Symbols.minimize,
            tooltip: _isCollapsed ? 'Expand' : 'Minimize',
            onTap: _toggleCollapsed,
          ),
          const SizedBox(width: 2),
          _HeaderButton(
            icon: Symbols.close,
            tooltip: 'Close',
            onTap: () {
              hideDebugOverlay();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 4),
      children: [
        _DebugItem(
          icon: Symbols.update,
          title: 'Force update',
          onTap: () async {
            final svc = UpdateService();
            showLoadingModal(context);
            final release = await svc.fetchLatestRelease();
            if (!context.mounted) return;
            hideLoadingModal(context);
            if (release != null) {
              await svc.showUpdateSheet(
                ref.read(routerProvider).navigatorKey.currentContext!,
                release,
              );
            } else {
              showInfoAlert(
                'Currently cannot get update from the GitHub.',
                'Unable to check for updates',
              );
            }
          },
        ),
        _DebugItem(
          icon: Symbols.slideshow,
          title: 'Show onboarding (new user)',
          onTap: () async {
            final info = await PackageInfo.fromPlatform();
            if (!context.mounted) return;
            await showAppOnboardingSheet(
              context,
              version: info.version,
              isFirstLaunch: true,
              suggestAuth: true,
            );
          },
        ),
        _DebugItem(
          icon: Symbols.slideshow,
          title: 'Show onboarding (old user)',
          onTap: () async {
            final info = await PackageInfo.fromPlatform();
            if (!context.mounted) return;
            await showAppOnboardingSheet(
              ref.read(routerProvider).navigatorKey.currentContext!,
              version: info.version,
              isFirstLaunch: false,
              suggestAuth: false,
            );
          },
        ),
        _DebugItem(
          icon: Symbols.splitscreen,
          title: 'Force show startup splash',
          onTap: () {
            ref.read(forcedStartupSplashProvider.notifier).setVisible(true);
          },
        ),
        _DebugItem(
          icon: Symbols.visibility_off,
          title: 'Hide startup splash',
          onTap: () {
            ref.read(forcedStartupSplashProvider.notifier).setVisible(false);
          },
        ),
        _DebugItem(
          icon: Symbols.check_circle,
          title: 'Show startup splash (after done)',
          onTap: () {
            ref
                .read(forcedStartupSplashProvider.notifier)
                .setVisible(true, afterDone: true);
          },
        ),
        _Divider(),
        _DebugItem(
          icon: Symbols.wifi,
          title: 'Connection status',
          onTap: () {
            showModalBottomSheet(
              context: ref.read(routerProvider).navigatorKey.currentContext!,
              isScrollControlled: true,
              builder: (context) => NetworkStatusSheet(),
            );
          },
        ),
        _DebugItem(
          icon: Symbols.terminal,
          title: 'Log Viewer',
          onTap: () {
            toggleLogOverlay();
          },
        ),
        _Divider(),
        _DebugItem(
          icon: Symbols.error,
          title: 'Test error alert',
          onTap: () {
            showErrorAlert(
              'This is a test error message for debugging purposes.',
            );
          },
        ),
        _DebugItem(
          icon: Symbols.info,
          title: 'Test info alert',
          onTap: () {
            showInfoAlert(
              'This is a test info message for debugging purposes.',
              'Test Alert',
            );
          },
        ),
        _DebugItem(
          icon: Symbols.storage,
          title: 'Test drive quota sheet',
          onTap: () async {
            await ref
                .read(driveFileUploaderProvider)
                .showQuotaExceededSheetPreview();
          },
        ),
        _DebugItem(
          icon: Symbols.chat_bubble,
          title: 'Test snackbar',
          onTap: () {
            showSnackBar('This is a test snackbar message.');
          },
        ),
        _DebugItem(
          icon: Symbols.notifications,
          title: 'Test notification overlay',
          onTap: () {
            final notification = SnNotification(
              createdAt: DateTime.now(),
              id: 'local_${DateTime.now().millisecondsSinceEpoch}',
              topic: 'local',
              title: 'Test Notification',
              subtitle: '',
              body: 'This is a test notification for debugging.',
              meta: const {},
              viewedAt: null,
              accountId: 'local',
            );
            ref.read(notificationStateProvider.notifier).add(notification);
          },
        ),
        _DebugItem(
          icon: Symbols.notifications_active,
          title: 'Test local notification',
          onTap: () {
            local_notify.showDebugLocalNotification(ref);
          },
        ),
        _DebugItem(
          icon: Symbols.progress_activity,
          title: 'Test task overlay progress',
          onTap: () {
            _startDebugProgressTask(ref);
          },
        ),
        _DebugItem(
          icon: Symbols.check_circle,
          title: 'Test task overlay success',
          onTap: () {
            _addDebugSuccessTask(ref);
          },
        ),
        _DebugItem(
          icon: Symbols.error,
          title: 'Test task overlay failure',
          onTap: () {
            _addDebugFailedTask(ref);
          },
        ),
        _Divider(),
        _DebugItem(
          icon: Symbols.person_add,
          title: 'Test friend online update',
          onTap: () {
            final event = FriendStatusChangeEvent(
              account: _createTestAccount(
                id: 'test-friend-1',
                name: 'alice',
                nick: 'Alice',
              ),
              status: SnAccountStatus(
                id: 'status-1',
                attitude: 2,
                isOnline: true,
                isCustomized: false,
                type: 0,
                label: '',
                symbol: null,
                meta: null,
                clearedAt: null,
                appIdentifier: null,
                isAutomated: false,
                accountId: 'test-friend-1',
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
                deletedAt: null,
              ),
              changeType: FriendStatusChangeType.online,
            );
            ref.read(notificationStateProvider.notifier).addFriendStatus(event);
          },
        ),
        _DebugItem(
          icon: Symbols.person_remove,
          title: 'Test friend offline update',
          onTap: () {
            final event = FriendStatusChangeEvent(
              account: _createTestAccount(
                id: 'test-friend-2',
                name: 'bob',
                nick: 'Bob',
              ),
              changeType: FriendStatusChangeType.offline,
            );
            ref.read(notificationStateProvider.notifier).addFriendStatus(event);
          },
        ),
        _DebugItem(
          icon: Symbols.sports_esports,
          title: 'Test friend gaming activity',
          onTap: () {
            final event = FriendStatusChangeEvent(
              account: _createTestAccount(
                id: 'test-friend-3',
                name: 'carol',
                nick: 'Carol',
              ),
              activities: [
                SnPresenceActivity(
                  id: 'activity-1',
                  type: 1,
                  manualId: 'steam',
                  title: 'Dyson Sphere Program',
                  subtitle: 'Playing Dyson Sphere Program',
                  caption: null,
                  titleUrl: null,
                  subtitleUrl: null,
                  smallImage: null,
                  largeImage: null,
                  meta: null,
                  leaseMinutes: 5,
                  leaseExpiresAt: DateTime.now().add(Duration(hours: 1)),
                  accountId: 'test-friend-3',
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                  deletedAt: null,
                ),
              ],
              changeType: FriendStatusChangeType.activityStarted,
            );
            ref.read(notificationStateProvider.notifier).addFriendStatus(event);
          },
        ),
        _DebugItem(
          icon: Symbols.music_note,
          title: 'Test friend music activity',
          onTap: () {
            final event = FriendStatusChangeEvent(
              account: _createTestAccount(
                id: 'test-friend-4',
                name: 'david',
                nick: 'David',
              ),
              activities: [
                SnPresenceActivity(
                  id: 'activity-2',
                  type: 2,
                  manualId: 'spotify',
                  title: 'Blinding Lights',
                  subtitle: 'The Weeknd - Blinding Lights',
                  caption: null,
                  titleUrl: null,
                  subtitleUrl: null,
                  smallImage: null,
                  largeImage: null,
                  meta: {'progress_ms': 120000, 'track_duration_ms': 200000},
                  leaseMinutes: 5,
                  leaseExpiresAt: DateTime.now().add(Duration(hours: 1)),
                  accountId: 'test-friend-4',
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                  deletedAt: null,
                ),
              ],
              changeType: FriendStatusChangeType.activityStarted,
            );
            ref.read(notificationStateProvider.notifier).addFriendStatus(event);
          },
        ),
        _DebugItem(
          icon: Symbols.do_not_disturb_on,
          title: 'Test friend busy status',
          onTap: () {
            final event = FriendStatusChangeEvent(
              account: _createTestAccount(
                id: 'test-friend-5',
                name: 'eve',
                nick: 'Eve',
              ),
              status: SnAccountStatus(
                id: 'status-2',
                attitude: 2,
                isOnline: true,
                isCustomized: true,
                type: 1,
                label: 'In a meeting',
                symbol: 'calendar',
                meta: null,
                clearedAt: null,
                appIdentifier: null,
                isAutomated: false,
                accountId: 'test-friend-5',
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
                deletedAt: null,
              ),
              changeType: FriendStatusChangeType.busy,
            );
            ref.read(notificationStateProvider.notifier).addFriendStatus(event);
          },
        ),
        _DebugItem(
          icon: Symbols.military_tech,
          title: 'Test achievement celebration',
          onTap: () {
            final notifier = ref.read(progressionWebSocketProvider.notifier);
            notifier.testShowCompletion(
              kind: 'achievement',
              title: 'First Post',
              reward: const SnProgressRewardDefinition(
                experience: 100,
                sourcePoints: 50,
              ),
            );
          },
        ),
        _DebugItem(
          icon: Symbols.assignment,
          title: 'Test quest completed',
          onTap: () {
            final notifier = ref.read(progressionWebSocketProvider.notifier);
            notifier.testShowCompletion(
              kind: 'quest',
              title: 'Daily Check-in',
              reward: const SnProgressRewardDefinition(experience: 50),
            );
          },
        ),
        _DebugItem(
          icon: Symbols.lock,
          title: 'Test key package depleted',
          onTap: () {
            final notifier = ref.read(mlsStatePopupProvider.notifier);
            notifier.testShowRefill(
              mlsDeviceId: 'test-device-123',
              deviceLabel: 'Test iPhone',
              currentCount: 1,
            );
          },
        ),
        _DebugItem(
          icon: Symbols.login,
          title: 'Test external join popup',
          onTap: () {
            final notifier = ref.read(mlsStatePopupProvider.notifier);
            notifier.testShowExternalJoin(deviceLabel: 'Test iPhone');
          },
        ),
        _DebugItem(
          icon: Symbols.sync,
          title: 'Test epoch recovery popup',
          onTap: () {
            final notifier = ref.read(mlsStatePopupProvider.notifier);
            notifier.testShowRecoveringEpoch(deviceLabel: 'Test iPhone');
          },
        ),
        _DebugItem(
          icon: Symbols.cloud,
          title: 'Test server WS packet',
          onTap: () async {
            try {
              final dio = ref.read(apiClientProvider);
              await dio.post(
                '/passport/admin/progression/test-ws-packet',
                queryParameters: {'kind': 'achievement'},
              );
              if (!context.mounted) return;
              showSnackBar('Server WS packet sent');
            } catch (e) {
              if (!context.mounted) return;
              showErrorAlert(e);
            }
          },
        ),
        _Divider(),
        _DebugItem(
          icon: Symbols.copy_all,
          title: 'Copy access token',
          onTap: () async {
            final tk = ref.watch(tokenProvider);
            Clipboard.setData(ClipboardData(text: tk!.token));
          },
        ),
        _DebugItem(
          icon: Symbols.edit,
          title: 'Set access token',
          onTap: () async {
            await _showSetTokenDialog(context, ref);
          },
        ),
        _DebugItem(
          icon: Symbols.refresh,
          title: 'Force refresh token',
          onTap: () async {
            try {
              await forceRefreshToken(
                prefs: ref.read(sharedPreferencesProvider),
                serverUrl: ref.read(serverUrlProvider),
              );
              if (!context.mounted) return;
              showSnackBar('Token refreshed');
            } on RefreshTokenExpiredException catch (e) {
              showErrorAlert(e.message);
            } catch (e) {
              if (!context.mounted) return;
              showErrorAlert(e);
            }
          },
        ),
        _Divider(),
        _DebugItem(
          icon: Symbols.delete,
          title: 'Reset database',
          onTap: () async {
            resetDatabase(ref);
          },
        ),
        _DebugItem(
          icon: Symbols.security,
          title: 'MLS Diagnostics',
          onTap: () async {
            try {
              showLoadingModal(context);

              final mlsClient = ref.read(mlsClientProvider);
              final mlsService = MlsEngineService.getInstance();
              final engine = await mlsService;

              final deviceId = await mlsClient.getDeviceId();
              final signerPub = await mlsClient.identityManager
                  .getSignerPublicKey();
              final kpCount = await mlsClient.identityManager
                  .getKeyPackageUploadCount();
              final accountId = await mlsClient.identityManager
                  .getCurrentAccountId();

              final info = StringBuffer();
              info.writeln('MLS Diagnostics');
              info.writeln('─' * 30);
              info.writeln('Engine Initialized: ${engine.isInitialized}');
              info.writeln('Device ID: ${deviceId ?? "null"}');
              info.writeln('Account ID: ${accountId ?? "null"}');
              final signerPubStr = base64Encode(signerPub);
              info.writeln(
                'Signer Public Key: ${signerPubStr.length > 20 ? "${signerPubStr.substring(0, 20)}..." : signerPubStr}',
              );
              info.writeln('Local KeyPackages: $kpCount');

              if (accountId != null) {
                final serverKps = await mlsClient.identityManager
                    .getDeviceKeyPackages(accountId);
                info.writeln('Server KeyPackages: ${serverKps.length}');
                for (final kp in serverKps) {
                  info.writeln(
                    '  Device: ${kp['device_id']}, KP: ${kp['key_package'] != null ? "yes" : "no"}',
                  );
                }
              }

              if (!context.mounted) return;
              hideLoadingModal(context);
              showInfoAlert(info.toString(), 'MLS Diagnostics');
            } catch (e) {
              if (!context.mounted) return;
              hideLoadingModal(context);
              showErrorAlert(e);
            }
          },
        ),
        _DebugItem(
          icon: Icons.delete_outline,
          title: 'Clear MLS storage',
          onTap: () async {
            final confirmed = await showConfirmAlert(
              'This will delete all MLS group states, credentials, and key packages. '
                  'You will need to re-register your device and re-bootstrap all groups.',
              'Clear MLS Storage?',
              isDanger: true,
            );
            if (confirmed == true) {
              final storage = MlsStorage();
              await storage.clearAll();
              MlsEngineService.resetInstance();
              showInfoAlert(
                'MLS storage cleared. Please restart the app.',
                'Done',
              );
            }
          },
        ),
        _DebugItem(
          icon: Symbols.mail,
          title: 'Fetch pending E2EE envelopes',
          onTap: () async {
            try {
              final mlsClient = ref.read(mlsClientProvider);
              await mlsClient.fetchAndProcessPendingEnvelopes();
              if (!context.mounted) return;
              showSnackBar('Pending envelopes processed');
            } catch (e) {
              if (!context.mounted) return;
              showErrorAlert(e);
            }
          },
        ),
        if (!kIsWeb && Platform.isIOS) ...[
          _Divider(),
          _DebugItem(
            icon: Symbols.call,
            title: '[CallKit] Fake Incoming Call',
            onTap: () async {
              try {
                final roomId = await _promptForRoomId(context, 'Incoming Call');
                if (roomId == null) return;
                await ref
                    .read(nativeCallBridgeProvider.notifier)
                    .showIncomingCall(roomId: roomId, callerName: 'Test User');
                if (!context.mounted) return;
                showSnackBar('Fake incoming call triggered for room: $roomId');
              } catch (e) {
                if (!context.mounted) return;
                showErrorAlert(e);
              }
            },
          ),
          _DebugItem(
            icon: Symbols.call_end,
            title: '[CallKit] Fake Outgoing Call',
            onTap: () async {
              try {
                final roomId = await _promptForRoomId(context, 'Outgoing Call');
                if (roomId == null) return;
                await ref
                    .read(nativeCallBridgeProvider.notifier)
                    .startOutgoingCall(
                      roomId: roomId,
                      callerName: 'Debug Call',
                    );
                if (!context.mounted) return;
                showSnackBar('Fake outgoing call triggered for room: $roomId');
              } catch (e) {
                if (!context.mounted) return;
                showErrorAlert(e);
              }
            },
          ),
          _DebugItem(
            icon: Symbols.copy_all,
            title: '[CallKit] Copy VoIP Token',
            onTap: () async {
              try {
                final token = await FlutterCallkitIncoming.getDevicePushTokenVoIP();
                if (token != null) {
                  await Clipboard.setData(ClipboardData(text: token));
                  if (!context.mounted) return;
                  showSnackBar('VoIP token copied');
                } else {
                  if (!context.mounted) return;
                  showSnackBar('No VoIP token available');
                }
              } catch (e) {
                if (!context.mounted) return;
                showErrorAlert(e);
              }
            },
          ),
        ],
        const Gap(8),
      ],
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final dynamic icon;
  final String tooltip;
  final VoidCallback onTap;

  const _HeaderButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 18,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _DebugItem extends StatelessWidget {
  final dynamic icon;
  final String title;
  final VoidCallback onTap;

  const _DebugItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Icon(
                Symbols.chevron_right,
                size: 18,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(height: 4);
  }
}

class DebugSheet extends HookConsumerWidget {
  const DebugSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SheetScaffold(
      titleText: 'Debug',
      heightFactor: 0.6,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Gap(4),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.progress_activity),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              title: const Text('Test task overlay progress'),
              onTap: () {
                _startDebugProgressTask(ref);
                Navigator.pop(context);
              },
            ),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.check_circle),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              title: const Text('Test task overlay success'),
              onTap: () {
                _addDebugSuccessTask(ref);
                Navigator.pop(context);
              },
            ),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.error),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              title: const Text('Test task overlay failure'),
              onTap: () {
                _addDebugFailedTask(ref);
                Navigator.pop(context);
              },
            ),
            const Divider(height: 8),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.update),
              trailing: const Icon(Symbols.chevron_right),
              title: Text('Force update'),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              onTap: () async {
                final svc = UpdateService();
                showLoadingModal(context);
                final release = await svc.fetchLatestRelease();
                if (!context.mounted) return;
                hideLoadingModal(context);
                if (release != null) {
                  await svc.showUpdateSheet(context, release);
                } else {
                  showInfoAlert(
                    'Currently cannot get update from the GitHub.',
                    'Unable to check for updates',
                  );
                }
              },
            ),
            const Divider(height: 8),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.slideshow),
              trailing: const Icon(Symbols.chevron_right),
              title: const Text('Show onboarding (new user)'),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              onTap: () async {
                final info = await PackageInfo.fromPlatform();
                if (!context.mounted) return;
                await showAppOnboardingSheet(
                  ref.read(routerProvider).navigatorKey.currentContext!,
                  version: info.version,
                  isFirstLaunch: true,
                  suggestAuth: true,
                );
              },
            ),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.slideshow),
              trailing: const Icon(Symbols.chevron_right),
              title: const Text('Show onboarding (old user)'),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              onTap: () async {
                final info = await PackageInfo.fromPlatform();
                if (!context.mounted) return;
                await showAppOnboardingSheet(
                  ref.read(routerProvider).navigatorKey.currentContext!,
                  version: info.version,
                  isFirstLaunch: false,
                  suggestAuth: false,
                );
              },
            ),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.splitscreen),
              trailing: const Icon(Symbols.chevron_right),
              title: const Text('Force show startup splash'),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              onTap: () {
                ref.read(forcedStartupSplashProvider.notifier).setVisible(true);
              },
            ),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.visibility_off),
              trailing: const Icon(Symbols.chevron_right),
              title: const Text('Hide startup splash'),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              onTap: () {
                ref
                    .read(forcedStartupSplashProvider.notifier)
                    .setVisible(false);
              },
            ),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.check_circle),
              trailing: const Icon(Symbols.chevron_right),
              title: const Text('Show startup splash (after done)'),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              onTap: () {
                ref
                    .read(forcedStartupSplashProvider.notifier)
                    .setVisible(true, afterDone: true);
              },
            ),
            const Divider(height: 8),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.wifi),
              trailing: const Icon(Symbols.chevron_right),
              title: Text('Connection status'),
              contentPadding: EdgeInsets.symmetric(horizontal: 24),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => NetworkStatusSheet(),
                );
              },
            ),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.terminal),
              trailing: const Icon(Symbols.chevron_right),
              title: const Text('Log Viewer'),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              onTap: () {
                toggleLogOverlay();
              },
            ),
            const Divider(height: 8),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.error),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              title: const Text('Test error alert'),
              onTap: () {
                showErrorAlert(
                  'This is a test error message for debugging purposes.',
                );
              },
            ),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.info),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              title: const Text('Test info alert'),
              onTap: () {
                showInfoAlert(
                  'This is a test info message for debugging purposes.',
                  'Test Alert',
                );
              },
            ),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.storage),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              title: const Text('Test drive quota sheet'),
              onTap: () async {
                await ref
                    .read(driveFileUploaderProvider)
                    .showQuotaExceededSheetPreview();
              },
            ),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.chat_bubble),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              title: const Text('Test snackbar'),
              onTap: () {
                showSnackBar('This is a test snackbar message.');
                Navigator.pop(context);
              },
            ),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.notifications),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              title: const Text('Test notification overlay'),
              onTap: () {
                final notification = SnNotification(
                  createdAt: DateTime.now(),
                  id: 'local_${DateTime.now().millisecondsSinceEpoch}',
                  topic: 'local',
                  title: 'Test Notification',
                  subtitle: '',
                  body: 'This is a test notification for debugging.',
                  meta: const {},
                  viewedAt: null,
                  accountId: 'local',
                );
                ref.read(notificationStateProvider.notifier).add(notification);
                Navigator.pop(context);
              },
            ),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.notifications_active),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              title: const Text('Test local notification'),
              onTap: () {
                local_notify.showDebugLocalNotification(ref);
                Navigator.pop(context);
              },
            ),
            const Divider(height: 8),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.person_add),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              title: const Text('Test friend online update'),
              onTap: () {
                final event = FriendStatusChangeEvent(
                  account: _createTestAccount(
                    id: 'test-friend-1',
                    name: 'alice',
                    nick: 'Alice',
                  ),
                  status: SnAccountStatus(
                    id: 'status-1',
                    attitude: 2,
                    isOnline: true,
                    isCustomized: false,
                    type: 0,
                    label: '',
                    symbol: null,
                    meta: null,
                    clearedAt: null,
                    appIdentifier: null,
                    isAutomated: false,
                    accountId: 'test-friend-1',
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                    deletedAt: null,
                  ),
                  changeType: FriendStatusChangeType.online,
                );
                ref
                    .read(notificationStateProvider.notifier)
                    .addFriendStatus(event);
              },
            ),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.person_remove),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              title: const Text('Test friend offline update'),
              onTap: () {
                final event = FriendStatusChangeEvent(
                  account: _createTestAccount(
                    id: 'test-friend-2',
                    name: 'bob',
                    nick: 'Bob',
                  ),
                  changeType: FriendStatusChangeType.offline,
                );
                ref
                    .read(notificationStateProvider.notifier)
                    .addFriendStatus(event);
              },
            ),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.sports_esports),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              title: const Text('Test friend gaming activity'),
              onTap: () {
                final event = FriendStatusChangeEvent(
                  account: _createTestAccount(
                    id: 'test-friend-3',
                    name: 'carol',
                    nick: 'Carol',
                  ),
                  activities: [
                    SnPresenceActivity(
                      id: 'activity-1',
                      type: 1,
                      manualId: 'steam',
                      title: 'Dyson Sphere Program',
                      subtitle: 'Playing Dyson Sphere Program',
                      caption: null,
                      titleUrl: null,
                      subtitleUrl: null,
                      smallImage: null,
                      largeImage: null,
                      meta: null,
                      leaseMinutes: 5,
                      leaseExpiresAt: DateTime.now().add(Duration(hours: 1)),
                      accountId: 'test-friend-3',
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                      deletedAt: null,
                    ),
                  ],
                  changeType: FriendStatusChangeType.activityStarted,
                );
                ref
                    .read(notificationStateProvider.notifier)
                    .addFriendStatus(event);
              },
            ),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.music_note),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              title: const Text('Test friend music activity'),
              onTap: () {
                final event = FriendStatusChangeEvent(
                  account: _createTestAccount(
                    id: 'test-friend-4',
                    name: 'david',
                    nick: 'David',
                  ),
                  activities: [
                    SnPresenceActivity(
                      id: 'activity-2',
                      type: 2,
                      manualId: 'spotify',
                      title: 'Blinding Lights',
                      subtitle: 'The Weeknd - Blinding Lights',
                      caption: null,
                      titleUrl: null,
                      subtitleUrl: null,
                      smallImage: null,
                      largeImage: null,
                      meta: {
                        'progress_ms': 120000,
                        'track_duration_ms': 200000,
                      },
                      leaseMinutes: 5,
                      leaseExpiresAt: DateTime.now().add(Duration(hours: 1)),
                      accountId: 'test-friend-4',
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                      deletedAt: null,
                    ),
                  ],
                  changeType: FriendStatusChangeType.activityStarted,
                );
                ref
                    .read(notificationStateProvider.notifier)
                    .addFriendStatus(event);
              },
            ),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.do_not_disturb_on),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              title: const Text('Test friend busy status'),
              onTap: () {
                final event = FriendStatusChangeEvent(
                  account: _createTestAccount(
                    id: 'test-friend-5',
                    name: 'eve',
                    nick: 'Eve',
                  ),
                  status: SnAccountStatus(
                    id: 'status-2',
                    attitude: 2,
                    isOnline: true,
                    isCustomized: true,
                    type: 1,
                    label: 'In a meeting',
                    symbol: 'calendar',
                    meta: null,
                    clearedAt: null,
                    appIdentifier: null,
                    isAutomated: false,
                    accountId: 'test-friend-5',
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                    deletedAt: null,
                  ),
                  changeType: FriendStatusChangeType.busy,
                );
                ref
                    .read(notificationStateProvider.notifier)
                    .addFriendStatus(event);
              },
            ),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.military_tech),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              title: const Text('Test achievement celebration'),
              onTap: () {
                final notifier = ref.read(
                  progressionWebSocketProvider.notifier,
                );
                notifier.testShowCompletion(
                  kind: 'achievement',
                  title: 'First Post',
                  reward: const SnProgressRewardDefinition(
                    experience: 100,
                    sourcePoints: 50,
                  ),
                );
              },
            ),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.assignment),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              title: const Text('Test quest completed'),
              onTap: () {
                final notifier = ref.read(
                  progressionWebSocketProvider.notifier,
                );
                notifier.testShowCompletion(
                  kind: 'quest',
                  title: 'Daily Check-in',
                  reward: const SnProgressRewardDefinition(experience: 50),
                );
              },
            ),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.lock),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              title: const Text('Test key package depleted'),
              onTap: () {
                final notifier = ref.read(mlsStatePopupProvider.notifier);
                notifier.testShowRefill(
                  mlsDeviceId: 'test-device-123',
                  deviceLabel: 'Test iPhone',
                  currentCount: 1,
                );
              },
            ),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.login),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              title: const Text('Test external join popup'),
              onTap: () {
                final notifier = ref.read(mlsStatePopupProvider.notifier);
                notifier.testShowExternalJoin(deviceLabel: 'Test iPhone');
              },
            ),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.sync),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              title: const Text('Test epoch recovery popup'),
              onTap: () {
                final notifier = ref.read(mlsStatePopupProvider.notifier);
                notifier.testShowRecoveringEpoch(deviceLabel: 'Test iPhone');
              },
            ),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.cloud),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              title: const Text('Test server WS packet'),
              onTap: () async {
                try {
                  final dio = ref.read(apiClientProvider);
                  await dio.post(
                    '/passport/admin/progression/test-ws-packet',
                    queryParameters: {'kind': 'achievement'},
                  );
                  if (!context.mounted) return;
                  showSnackBar('Server WS packet sent');
                } catch (e) {
                  if (!context.mounted) return;
                  showErrorAlert(e);
                }
              },
            ),
            const Divider(height: 8),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.copy_all),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: EdgeInsets.symmetric(horizontal: 24),
              title: Text('Copy access token'),
              onTap: () async {
                final tk = ref.watch(tokenProvider);
                Clipboard.setData(ClipboardData(text: tk!.token));
              },
            ),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.edit),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: EdgeInsets.symmetric(horizontal: 24),
              title: Text('Set access token'),
              onTap: () async {
                await _showSetTokenDialog(context, ref);
              },
            ),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.refresh),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: EdgeInsets.symmetric(horizontal: 24),
              title: Text('Force refresh token'),
              onTap: () async {
                try {
                  await forceRefreshToken(
                    prefs: ref.read(sharedPreferencesProvider),
                    serverUrl: ref.read(serverUrlProvider),
                  );
                  if (!context.mounted) return;
                  showSnackBar('Token refreshed');
                } on RefreshTokenExpiredException catch (e) {
                  showErrorAlert(e.message);
                } catch (e) {
                  if (!context.mounted) return;
                  showErrorAlert(e);
                }
              },
            ),
            const Divider(height: 8),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.delete),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: EdgeInsets.symmetric(horizontal: 24),
              title: Text('Reset database'),
              onTap: () async {
                resetDatabase(ref);
              },
            ),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.info),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              title: const Text('MLS Diagnostics'),
              onTap: () async {
                try {
                  showLoadingModal(context);

                  final mlsClient = ref.read(mlsClientProvider);
                  final mlsService = MlsEngineService.getInstance();
                  final engine = await mlsService;

                  final deviceId = await mlsClient.getDeviceId();
                  final signerPub = await mlsClient.identityManager
                      .getSignerPublicKey();
                  final kpCount = await mlsClient.identityManager
                      .getKeyPackageUploadCount();
                  final accountId = await mlsClient.identityManager
                      .getCurrentAccountId();

                  final info = StringBuffer();
                  info.writeln('MLS Diagnostics');
                  info.writeln('─' * 30);
                  info.writeln('Engine Initialized: ${engine.isInitialized}');
                  info.writeln('Device ID: ${deviceId ?? "null"}');
                  info.writeln('Account ID: ${accountId ?? "null"}');
                  final signerPubStr = base64Encode(signerPub);
                  info.writeln(
                    'Signer Public Key: ${signerPubStr.length > 20 ? "${signerPubStr.substring(0, 20)}..." : signerPubStr}',
                  );
                  info.writeln('Local KeyPackages: $kpCount');

                  if (accountId != null) {
                    final serverKps = await mlsClient.identityManager
                        .getDeviceKeyPackages(accountId);
                    info.writeln('Server KeyPackages: ${serverKps.length}');
                    for (final kp in serverKps) {
                      info.writeln(
                        '  Device: ${kp['device_id']}, KP: ${kp['key_package'] != null ? "yes" : "no"}',
                      );
                    }
                  }

                  if (!context.mounted) return;
                  hideLoadingModal(context);
                  showInfoAlert(info.toString(), 'MLS Diagnostics');
                } catch (e) {
                  if (!context.mounted) return;
                  hideLoadingModal(context);
                  showErrorAlert(e);
                }
              },
            ),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.security),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              title: const Text('Clear MLS storage'),
              onTap: () async {
                final confirmed = await showConfirmAlert(
                  'This will delete all MLS group states, credentials, and key packages. '
                      'You will need to re-register your device and re-bootstrap all groups.',
                  'Clear MLS Storage?',
                  isDanger: true,
                );
                if (confirmed == true) {
                  final mlsClient = ref.read(mlsClientProvider);
                  final accountId = await mlsClient.identityManager
                      .getCurrentAccountId();
                  final deviceId = await mlsClient.getDeviceId();

                  final storage = MlsStorage();
                  await storage.clearAll();
                  MlsEngineService.resetInstance();

                  if (deviceId != null) {
                    await storage.setDeviceId(deviceId);
                  }
                  if (accountId != null) {
                    await storage.setAccountId(accountId);
                  }

                  showInfoAlert(
                    'MLS storage cleared and device/account ID preserved. Please restart the app.',
                    'Done',
                  );
                }
              },
            ),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.mail),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              title: const Text('Fetch pending E2EE envelopes'),
              onTap: () async {
                try {
                  final mlsClient = ref.read(mlsClientProvider);
                  await mlsClient.fetchAndProcessPendingEnvelopes();
                  if (!context.mounted) return;
                  showSnackBar('Pending envelopes processed');
                } catch (e) {
                  if (!context.mounted) return;
                  showErrorAlert(e);
                }
              },
            ),
            const Divider(height: 8),
            if (!kIsWeb && Platform.isIOS) ...[
              ListTile(
                minTileHeight: 48,
                leading: const Icon(Symbols.call),
                trailing: const Icon(Symbols.chevron_right),
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                title: const Text('[CallKit] Fake Incoming Call'),
                onTap: () async {
                  try {
                    final roomId = await _promptForRoomId(
                      context,
                      'Incoming Call',
                    );
                    if (roomId == null) return;
                    await ref
                        .read(nativeCallBridgeProvider.notifier)
                        .showIncomingCall(
                          roomId: roomId,
                          callerName: 'Test User',
                        );
                    if (!context.mounted) return;
                    showSnackBar(
                      'Fake incoming call triggered for room: $roomId',
                    );
                  } catch (e) {
                    if (!context.mounted) return;
                    showErrorAlert(e);
                  }
                },
              ),
              ListTile(
                minTileHeight: 48,
                leading: const Icon(Symbols.call_end),
                trailing: const Icon(Symbols.chevron_right),
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                title: const Text('[CallKit] Fake Outgoing Call'),
                onTap: () async {
                  try {
                    final roomId = await _promptForRoomId(
                      context,
                      'Outgoing Call',
                    );
                    if (roomId == null) return;
                    await ref
                        .read(nativeCallBridgeProvider.notifier)
                        .startOutgoingCall(
                          roomId: roomId,
                          callerName: 'Debug Call',
                        );
                    if (!context.mounted) return;
                    showSnackBar(
                      'Fake outgoing call triggered for room: $roomId',
                    );
                  } catch (e) {
                    if (!context.mounted) return;
                    showErrorAlert(e);
                  }
                },
              ),
              ListTile(
                minTileHeight: 48,
                leading: const Icon(Symbols.copy_all),
                trailing: const Icon(Symbols.chevron_right),
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                title: const Text('[CallKit] Copy VoIP Token'),
                onTap: () async {
                  try {
                    final token = await FlutterCallkitIncoming.getDevicePushTokenVoIP();
                    if (token != null) {
                      await Clipboard.setData(ClipboardData(text: token));
                      if (!context.mounted) return;
                      showSnackBar('VoIP token copied');
                    } else {
                      if (!context.mounted) return;
                      showSnackBar('No VoIP token available');
                    }
                  } catch (e) {
                    if (!context.mounted) return;
                    showErrorAlert(e);
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
