import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:island_ui_foundation/island_ui_foundation.dart';

/// Pure chroma-key green for video compositing.
const kChromaKeyGreen = Color(0xFF00FF00);

/// Extra time for enter/exit animation after the content duration ends.
const _kOverlayAnimationBuffer = Duration(milliseconds: 600);

final GlobalKey<OverlayState> globalOverlay = GlobalKey<OverlayState>();
final GlobalKey<NavigatorState> globalNavigatorKey =
    GlobalKey<NavigatorState>();

void main() {
  runApp(const StageApp());
}

class StageApp extends StatelessWidget {
  const StageApp({super.key});

  @override
  Widget build(BuildContext context) {
    IslandUIFoundation.configureOverlay(globalOverlay);
    IslandUIFoundation.configureNavigator(globalNavigatorKey);

    return MaterialApp(
      title: 'Island Stage',
      debugShowCheckedModeBanner: false,
      navigatorKey: globalNavigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      builder: (context, child) {
        return Overlay(
          key: globalOverlay,
          initialEntries: [
            OverlayEntry(
              builder: (_) => child ?? const SizedBox.shrink(),
            ),
          ],
        );
      },
      home: const StageHome(),
    );
  }
}

enum StageClipKind { snackBar, styledSnackBar, notification }

class StageIconOption {
  const StageIconOption({required this.label, this.icon});

  final String label;
  final IconData? icon;
}

/// Icons useful for short product/UI video clips.
const kStageIconOptions = <StageIconOption>[
  StageIconOption(label: 'None'),
  StageIconOption(label: 'Check', icon: Icons.check_circle_outline),
  StageIconOption(label: 'Info', icon: Icons.info_outline),
  StageIconOption(label: 'Warning', icon: Icons.warning_amber_rounded),
  StageIconOption(label: 'Error', icon: Icons.error_outline),
  StageIconOption(label: 'Notif', icon: Icons.notifications_outlined),
  StageIconOption(label: 'Mail', icon: Icons.mail_outline),
  StageIconOption(label: 'Chat', icon: Icons.chat_bubble_outline),
  StageIconOption(label: 'Person', icon: Icons.person_outline),
  StageIconOption(label: 'Cloud', icon: Icons.cloud_done_outlined),
  StageIconOption(label: 'Download', icon: Icons.download_done),
  StageIconOption(label: 'Upload', icon: Icons.upload_outlined),
  StageIconOption(label: 'Favorite', icon: Icons.favorite_border),
  StageIconOption(label: 'Star', icon: Icons.star_border),
  StageIconOption(label: 'Schedule', icon: Icons.schedule),
  StageIconOption(label: 'Lock', icon: Icons.lock_outline),
  StageIconOption(label: 'Sync', icon: Icons.sync),
  StageIconOption(label: 'Copy', icon: Icons.content_copy),
  StageIconOption(label: 'Delete', icon: Icons.delete_outline),
  StageIconOption(label: 'Add', icon: Icons.add_circle_outline),
  StageIconOption(label: 'Send', icon: Icons.send_outlined),
  StageIconOption(label: 'Link', icon: Icons.link),
  StageIconOption(label: 'Photo', icon: Icons.photo_outlined),
  StageIconOption(label: 'Mic', icon: Icons.mic_none),
];

/// Minimal [OverlayNotificationItem] for stage clips.
class StageNotificationItem implements OverlayNotificationItem {
  StageNotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.duration,
    this.icon,
    this.dismissed = false,
  });

  @override
  final String id;

  final String title;
  final String body;
  final IconData? icon;

  @override
  final Duration duration;

  @override
  final bool dismissed;

  StageNotificationItem copyWith({bool? dismissed}) {
    return StageNotificationItem(
      id: id,
      title: title,
      body: body,
      duration: duration,
      icon: icon,
      dismissed: dismissed ?? this.dismissed,
    );
  }
}

class StageHome extends StatefulWidget {
  const StageHome({super.key});

  @override
  State<StageHome> createState() => _StageHomeState();
}

class _StageHomeState extends State<StageHome> {
  // --- Config ---
  StageClipKind _kind = StageClipKind.snackBar;
  int _padSeconds = 1;
  double _durationSeconds = 2.5;
  int _iconIndex = 1; // Check

  final _messageController = TextEditingController(
    text: 'Something happened',
  );
  final _titleController = TextEditingController(text: 'Island');
  final _bodyController = TextEditingController(
    text: 'You have a new update ready to review.',
  );
  final _actionController = TextEditingController(text: 'OK');
  bool _includeAction = false;

  // --- Playback ---
  bool _recording = false;
  final List<StageNotificationItem> _notifications = [];
  Completer<void>? _notificationSettled;
  int _notificationSeq = 0;
  int _playGeneration = 0;

  IconData? get _selectedIcon => kStageIconOptions[_iconIndex].icon;

  @override
  void dispose() {
    _playGeneration++;
    _messageController.dispose();
    _titleController.dispose();
    _bodyController.dispose();
    _actionController.dispose();
    super.dispose();
  }

  Duration get _contentDuration => Duration(
    milliseconds: (_durationSeconds * 1000).round(),
  );

  Duration get _padDuration => Duration(seconds: _padSeconds);

  Future<void> _playClip() async {
    if (_recording) return;

    final generation = ++_playGeneration;
    final pad = _padDuration;
    final contentDuration = _contentDuration;
    final kind = _kind;
    final message = _messageController.text.trim();
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    final actionLabel = _actionController.text.trim();
    final includeAction = _includeAction && actionLabel.isNotEmpty;
    final icon = _selectedIcon;

    setState(() {
      _recording = true;
      _notifications.clear();
    });

    try {
      // Lead-in: pure green, no chrome.
      await Future<void>.delayed(pad);
      if (!mounted || generation != _playGeneration) return;

      switch (kind) {
        case StageClipKind.snackBar:
          // Plain snackbar has no icon API; use styled when an icon is set.
          if (icon != null) {
            showStyledSnackBar(
              message: message.isEmpty ? ' ' : message,
              icon: icon,
              duration: contentDuration,
              noVibrate: true,
              action: includeAction
                  ? SnackBarAction(label: actionLabel, onPressed: () {})
                  : null,
            );
          } else {
            showSnackBar(
              message.isEmpty ? ' ' : message,
              duration: contentDuration,
              noVibrate: true,
              action: includeAction
                  ? SnackBarAction(label: actionLabel, onPressed: () {})
                  : null,
            );
          }
          await Future<void>.delayed(
            contentDuration + _kOverlayAnimationBuffer,
          );
        case StageClipKind.styledSnackBar:
          showStyledSnackBar(
            title: title.isEmpty ? null : title,
            message: message.isEmpty ? ' ' : message,
            icon: icon,
            duration: contentDuration,
            noVibrate: true,
            action: includeAction
                ? SnackBarAction(label: actionLabel, onPressed: () {})
                : null,
          );
          await Future<void>.delayed(
            contentDuration + _kOverlayAnimationBuffer,
          );
        case StageClipKind.notification:
          final settled = Completer<void>();
          _notificationSettled = settled;
          final id = 'stage_notification_${_notificationSeq++}';
          setState(() {
            _notifications.add(
              StageNotificationItem(
                id: id,
                title: title.isEmpty ? 'Notification' : title,
                body: body,
                icon: icon,
                duration: contentDuration,
              ),
            );
          });
          // Fallback if dismiss/remove never fires.
          unawaited(
            Future<void>.delayed(
              contentDuration +
                  _kOverlayAnimationBuffer +
                  const Duration(seconds: 1),
            ).then((_) {
              if (!settled.isCompleted) settled.complete();
            }),
          );
          await settled.future;
      }

      if (!mounted || generation != _playGeneration) return;

      // Lead-out: pure green after the clip is gone.
      await Future<void>.delayed(pad);
    } finally {
      if (mounted && generation == _playGeneration) {
        setState(() {
          _recording = false;
          _notifications.clear();
          _notificationSettled = null;
        });
      }
    }
  }

  void _dismissNotification(StageNotificationItem item) {
    final index = _notifications.indexWhere((n) => n.id == item.id);
    if (index < 0) return;
    setState(() {
      _notifications[index] = _notifications[index].copyWith(dismissed: true);
    });
  }

  void _removeNotification(StageNotificationItem item) {
    setState(() {
      _notifications.removeWhere((n) => n.id == item.id);
    });
    final settled = _notificationSettled;
    if (settled != null && !settled.isCompleted && _notifications.isEmpty) {
      settled.complete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: kChromaKeyGreen),
          if (!_recording)
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: _StageConfigPanel(
                      kind: _kind,
                      padSeconds: _padSeconds,
                      durationSeconds: _durationSeconds,
                      iconIndex: _iconIndex,
                      messageController: _messageController,
                      titleController: _titleController,
                      bodyController: _bodyController,
                      actionController: _actionController,
                      includeAction: _includeAction,
                      onKindChanged: (value) => setState(() => _kind = value),
                      onPadSecondsChanged: (value) =>
                          setState(() => _padSeconds = value),
                      onDurationSecondsChanged: (value) =>
                          setState(() => _durationSeconds = value),
                      onIconIndexChanged: (value) =>
                          setState(() => _iconIndex = value),
                      onIncludeActionChanged: (value) =>
                          setState(() => _includeAction = value),
                      onPlay: _playClip,
                    ),
                  ),
                ),
              ),
            ),
          NotificationOverlay<StageNotificationItem>(
            items: _notifications,
            itemBuilder: (context, item, onDismiss, isDesktop, progress) {
              return _StageNotificationContent(
                item: item,
                onDismiss: onDismiss,
                isDesktop: isDesktop,
                progress: progress,
              );
            },
            onDismiss: _dismissNotification,
            onRemove: _removeNotification,
          ),
        ],
      ),
    );
  }
}

class _StageConfigPanel extends StatelessWidget {
  const _StageConfigPanel({
    required this.kind,
    required this.padSeconds,
    required this.durationSeconds,
    required this.iconIndex,
    required this.messageController,
    required this.titleController,
    required this.bodyController,
    required this.actionController,
    required this.includeAction,
    required this.onKindChanged,
    required this.onPadSecondsChanged,
    required this.onDurationSecondsChanged,
    required this.onIconIndexChanged,
    required this.onIncludeActionChanged,
    required this.onPlay,
  });

  final StageClipKind kind;
  final int padSeconds;
  final double durationSeconds;
  final int iconIndex;
  final TextEditingController messageController;
  final TextEditingController titleController;
  final TextEditingController bodyController;
  final TextEditingController actionController;
  final bool includeAction;
  final ValueChanged<StageClipKind> onKindChanged;
  final ValueChanged<int> onPadSecondsChanged;
  final ValueChanged<double> onDurationSecondsChanged;
  final ValueChanged<int> onIconIndexChanged;
  final ValueChanged<bool> onIncludeActionChanged;
  final VoidCallback onPlay;

  bool get _isSnackBar =>
      kind == StageClipKind.snackBar || kind == StageClipKind.styledSnackBar;

  bool get _showTitle =>
      kind == StageClipKind.styledSnackBar ||
      kind == StageClipKind.notification;

  bool get _showBody => kind == StageClipKind.notification;

  bool get _showMessage => _isSnackBar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedIcon = kStageIconOptions[iconIndex];

    return Material(
      color: theme.colorScheme.surfaceContainerHigh,
      elevation: 6,
      shadowColor: Colors.black54,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Island Stage',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Configure a clip, then record pure green + overlay.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            Text('Clip type', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            SegmentedButton<StageClipKind>(
              segments: const [
                ButtonSegment(
                  value: StageClipKind.snackBar,
                  label: Text('SnackBar'),
                  icon: Icon(Icons.crop_16_9, size: 18),
                ),
                ButtonSegment(
                  value: StageClipKind.styledSnackBar,
                  label: Text('Styled'),
                  icon: Icon(Icons.auto_awesome, size: 18),
                ),
                ButtonSegment(
                  value: StageClipKind.notification,
                  label: Text('Notif'),
                  icon: Icon(Icons.notifications_outlined, size: 18),
                ),
              ],
              selected: {kind},
              onSelectionChanged: (selection) {
                if (selection.isNotEmpty) onKindChanged(selection.first);
              },
            ),
            const SizedBox(height: 20),
            Text('Lead-in / lead-out', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 1, label: Text('1 second')),
                ButtonSegment(value: 3, label: Text('3 seconds')),
              ],
              selected: {padSeconds},
              onSelectionChanged: (selection) {
                if (selection.isNotEmpty) onPadSecondsChanged(selection.first);
              },
            ),
            const SizedBox(height: 4),
            Text(
              'Green only before and after the overlay animation.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text('Duration', style: theme.textTheme.labelLarge),
                const Spacer(),
                Text(
                  '${durationSeconds.toStringAsFixed(1)}s',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            Slider(
              value: durationSeconds,
              min: 1,
              max: 8,
              divisions: 14,
              label: '${durationSeconds.toStringAsFixed(1)}s',
              onChanged: onDurationSecondsChanged,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Icon', style: theme.textTheme.labelLarge),
                const Spacer(),
                Text(
                  selectedIcon.label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _StageIconPicker(
              selectedIndex: iconIndex,
              onSelected: onIconIndexChanged,
            ),
            const SizedBox(height: 16),
            if (_showTitle) ...[
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
            ],
            if (_showMessage) ...[
              TextField(
                controller: messageController,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                maxLines: 2,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
            ],
            if (_showBody) ...[
              TextField(
                controller: bodyController,
                decoration: const InputDecoration(
                  labelText: 'Body',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                maxLines: 3,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 12),
            ],
            if (_isSnackBar) ...[
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Action button'),
                value: includeAction,
                onChanged: onIncludeActionChanged,
              ),
              if (includeAction) ...[
                TextField(
                  controller: actionController,
                  decoration: const InputDecoration(
                    labelText: 'Action label',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  inputFormatters: [LengthLimitingTextInputFormatter(20)],
                ),
                const SizedBox(height: 12),
              ],
            ],
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: onPlay,
              icon: const Icon(Icons.fiber_manual_record),
              label: Text(
                'Record · ${padSeconds}s pad · ${durationSeconds.toStringAsFixed(1)}s clip',
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StageIconPicker extends StatelessWidget {
  const _StageIconPicker({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedColor = theme.colorScheme.primary;
    final unselectedColor = theme.colorScheme.onSurfaceVariant;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (var i = 0; i < kStageIconOptions.length; i++)
              _StageIconChip(
                option: kStageIconOptions[i],
                selected: i == selectedIndex,
                selectedColor: selectedColor,
                unselectedColor: unselectedColor,
                onTap: () => onSelected(i),
              ),
          ],
        ),
      ),
    );
  }
}

class _StageIconChip extends StatelessWidget {
  const _StageIconChip({
    required this.option,
    required this.selected,
    required this.selectedColor,
    required this.unselectedColor,
    required this.onTap,
  });

  final StageIconOption option;
  final bool selected;
  final Color selectedColor;
  final Color unselectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = selected ? selectedColor : unselectedColor;

    return Material(
      color: selected
          ? selectedColor.withValues(alpha: 0.16)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? selectedColor.withValues(alpha: 0.7)
                  : theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
            ),
          ),
          child: Tooltip(
            message: option.label,
            child: Center(
              child: option.icon == null
                  ? Text(
                      '∅',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : Icon(option.icon, color: foreground, size: 22),
            ),
          ),
        ),
      ),
    );
  }
}

class _StageNotificationContent extends StatelessWidget {
  const _StageNotificationContent({
    required this.item,
    required this.onDismiss,
    required this.isDesktop,
    required this.progress,
  });

  final StageNotificationItem item;
  final VoidCallback onDismiss;
  final bool isDesktop;
  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if ((details.primaryVelocity ?? 0) > 100) {
          onDismiss();
        }
      },
      onVerticalDragEnd: !isDesktop
          ? (details) {
              if ((details.primaryVelocity ?? 0) < -100) {
                onDismiss();
              }
            }
          : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.icon != null) ...[
                  Icon(
                    item.icon,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (item.body.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(item.body, style: theme.textTheme.bodyMedium),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  onPressed: onDismiss,
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          AnimatedBuilder(
            animation: progress,
            builder: (context, child) => LinearProgressIndicator(
              value: progress.value,
              minHeight: 2,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
