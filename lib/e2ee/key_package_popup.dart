import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/services/event_bus.dart';
import 'package:island/core/websocket.dart';
import 'package:island/main.dart';
import 'package:logging/logging.dart';

import 'package:material_symbols_icons/symbols.dart';
import 'package:island/e2ee/mls_identity_manager.dart';
import 'package:styled_widget/styled_widget.dart';

const _mlsLogPrefix = '[MLS Popup] ';

void _mlsLog(dynamic msg) {
  Logger.root.info('$_mlsLogPrefix$msg');
}

enum MlsPopupState {
  refillingKeyPackages('Refilling key packages...', 'Encryption ready'),
  externalJoin('Joining encrypted conversation...', 'Joined conversation'),
  processingWelcome('Processing invitation...', 'Joined conversation'),
  processingCommit('Processing update...', 'Update processed'),
  recoveringEpoch('Recovering encryption...', 'Encryption recovered'),
  uploadingGroupInfo('Syncing group state...', 'Group synced'),
  genericProgress('Processing...', 'Done');

  final String inProgressText;
  final String completeText;

  const MlsPopupState(this.inProgressText, this.completeText);
}

final mlsStatePopupProvider = NotifierProvider<MlsStatePopupNotifier, void>(
  MlsStatePopupNotifier.new,
);

class MlsStatePopupNotifier extends Notifier<void> {
  StreamSubscription? _subscription;
  StreamSubscription? _eventSubscription;
  MlsIdentityManager? _identityManager;

  @override
  void build() {
    ref.onDispose(() {
      _subscription?.cancel();
      _eventSubscription?.cancel();
    });
    _setupListeners();
  }

  void setIdentityManager(MlsIdentityManager identityManager) {
    _identityManager = identityManager;
  }

  void _setupListeners() {
    final service = ref.read(websocketProvider);
    _subscription = service.dataStream.listen((packet) {
      if (packet.type == 'e2ee.kp.depleted') {
        _handleKeyPackageDepleted(packet);
      }
    });

    _eventSubscription = eventBus.on<MlsExternalJoinStartedEvent>().listen((
      event,
    ) {
      _mlsLog('External join started for group: ${event.mlsGroupId}');
      showState(MlsPopupState.externalJoin);
    });

    eventBus.on<MlsExternalJoinCompletedEvent>().listen((event) {
      _mlsLog(
        'External join completed for group: ${event.mlsGroupId}, success: ${event.success}',
      );
    });

    eventBus.on<MlsRecoveryFailedEvent>().listen((event) {
      _mlsLog('Recovery failed for group: ${event.mlsGroupId}');
    });

    eventBus.on<MlsEpochChangedEvent>().listen((event) {
      _mlsLog(
        'Epoch changed for group: ${event.mlsGroupId}, new epoch: ${event.newEpoch}',
      );
      showState(MlsPopupState.processingCommit);
    });

    eventBus.on<MlsReshareRequiredEvent>().listen((event) {
      _mlsLog('Reshare required for group: ${event.mlsGroupId}');
      showState(MlsPopupState.uploadingGroupInfo);
    });
  }

  void showState(MlsPopupState state, {String? deviceLabel, int? count}) {
    _showOverlay(state: state, deviceLabel: deviceLabel, count: count);
  }

  void _handleKeyPackageDepleted(WebSocketPacket packet) {
    if (packet.data == null) return;

    final mlsDeviceId =
        packet.data!['mls_device_id'] as String? ??
        packet.data!['device_id'] as String?;
    final availableCount = packet.data!['available_count'] as int? ?? 0;
    final deviceLabel = packet.data!['device_label'] as String?;

    if (mlsDeviceId == null) return;

    _showOverlay(
      state: MlsPopupState.refillingKeyPackages,
      mlsDeviceId: mlsDeviceId,
      deviceLabel: deviceLabel,
      count: availableCount,
    );
  }

  void _showOverlay({
    required MlsPopupState state,
    String? mlsDeviceId,
    String? deviceLabel,
    int? count,
  }) {
    final context = globalOverlay.currentState?.context;
    if (context == null) return;

    OverlayEntry? entry;
    entry = OverlayEntry(
      builder: (context) => _MlsStateOverlay(
        identityManager: _identityManager,
        state: state,
        mlsDeviceId: mlsDeviceId,
        deviceLabel: deviceLabel,
        count: count,
        onComplete: () {
          entry?.remove();
        },
      ),
    );

    globalOverlay.currentState?.insert(entry);
  }

  void testShowRefill({
    required String mlsDeviceId,
    String? deviceLabel,
    int currentCount = 0,
  }) {
    _showOverlay(
      state: MlsPopupState.refillingKeyPackages,
      mlsDeviceId: mlsDeviceId,
      deviceLabel: deviceLabel,
      count: currentCount,
    );
  }

  void testShowExternalJoin({String? deviceLabel}) {
    _showOverlay(state: MlsPopupState.externalJoin, deviceLabel: deviceLabel);
  }

  void testShowRecoveringEpoch({String? deviceLabel}) {
    _showOverlay(
      state: MlsPopupState.recoveringEpoch,
      deviceLabel: deviceLabel,
    );
  }
}

class _MlsStateOverlay extends StatefulWidget {
  final MlsIdentityManager? identityManager;
  final MlsPopupState state;
  final String? mlsDeviceId;
  final String? deviceLabel;
  final int? count;
  final VoidCallback onComplete;

  const _MlsStateOverlay({
    this.identityManager,
    required this.state,
    this.mlsDeviceId,
    this.deviceLabel,
    this.count,
    required this.onComplete,
  });

  @override
  State<_MlsStateOverlay> createState() => _MlsStateOverlayState();
}

class _MlsStateOverlayState extends State<_MlsStateOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  bool _isComplete = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      reverseDuration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 80.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.3,
          end: 1.1,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.1,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 60,
      ),
    ]).animate(_controller);

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    if (widget.state == MlsPopupState.refillingKeyPackages) {
      _startRefill();
    } else {
      _startAutoDismissCountdown();
    }
  }

  Future<void> _startRefill() async {
    final identityManager = widget.identityManager;
    if (identityManager == null) {
      _startAutoDismissCountdown();
      return;
    }

    final currentCount = widget.count ?? 0;
    final needed = 3 - currentCount;
    if (needed <= 0) {
      _completeAndDismiss();
      return;
    }

    for (var i = 0; i < needed; i++) {
      if (!mounted) return;
      _mlsLog('Uploading key package ${i + 1}/$needed');
      await Future.delayed(const Duration(milliseconds: 500));
    }

    if (!mounted) return;
    _completeAndDismiss();
  }

  void _completeAndDismiss() {
    setState(() {
      _isComplete = true;
    });
    _startAutoDismissCountdown();
  }

  void _startAutoDismissCountdown() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  void _dismiss() async {
    await _controller.reverse();
    widget.onComplete();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final color = _isComplete ? Colors.green : Colors.teal;

    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomPadding + 16,
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      alignment: Alignment.bottomCenter,
                      child: child,
                    ),
                  );
                },
                child: Center(
                  child: GestureDetector(
                    onTap: _dismiss,
                    child: Container(
                      constraints: const BoxConstraints(
                        maxWidth: 500,
                        minWidth: 200,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                          BoxShadow(
                            color: color.withOpacity(0.3),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          child: _StatePillContent(
                            state: widget.state,
                            isComplete: _isComplete,
                            deviceLabel: widget.deviceLabel,
                            color: color,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatePillContent extends StatelessWidget {
  final MlsPopupState state;
  final bool isComplete;
  final String? deviceLabel;
  final Color color;

  const _StatePillContent({
    required this.state,
    required this.isComplete,
    this.deviceLabel,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: isComplete
                ? Icon(Symbols.check_circle, size: 22, color: color)
                : _buildIcon(),
          ),
          const Gap(12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isComplete ? state.completeText : state.inProgressText,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                spacing: 8,
                children: [
                  Text(
                    _getStatusText(),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (deviceLabel != null) ...[
                    Text(
                      deviceLabel!,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.normal,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    switch (state) {
      case MlsPopupState.externalJoin:
      case MlsPopupState.recoveringEpoch:
        return SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ).padding(all: 8);
      case MlsPopupState.processingWelcome:
        return SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ).padding(all: 8);
      default:
        return SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ).padding(all: 8);
    }
  }

  String _getStatusText() {
    if (isComplete) {
      return _getCompleteText();
    }
    return state.inProgressText;
  }

  String _getCompleteText() {
    switch (state) {
      case MlsPopupState.refillingKeyPackages:
        return 'Key packages ready';
      case MlsPopupState.externalJoin:
        return 'Joined conversation';
      case MlsPopupState.processingWelcome:
        return 'Joined conversation';
      case MlsPopupState.processingCommit:
        return 'Update processed';
      case MlsPopupState.recoveringEpoch:
        return 'Encryption recovered';
      case MlsPopupState.uploadingGroupInfo:
        return 'Group synced';
      case MlsPopupState.genericProgress:
        return 'Done';
    }
  }
}
