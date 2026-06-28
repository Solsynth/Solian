import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:island/core/services/event_bus.dart';
import 'package:island/core/websocket.dart';
import 'package:island/main.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:logging/logging.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:island/e2ee/mls_identity_manager.dart';

const _mlsLogPrefix = '[MLS Popup] ';
const _mlsSnackBarKey = 'mls-state-popup';

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
  int _activeSerial = 0;

  @override
  void build() {
    ref.onDispose(() {
      _subscription?.cancel();
      _eventSubscription?.cancel();
      dismissSnackBar(_mlsSnackBarKey);
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
    _showSnackBarState(state: state, deviceLabel: deviceLabel, count: count);
  }

  void _handleKeyPackageDepleted(WebSocketPacket packet) {
    if (packet.data == null) return;

    final mlsDeviceId =
        packet.data!['mls_device_id'] as String? ??
        packet.data!['device_id'] as String?;
    final availableCount = packet.data!['available_count'] as int? ?? 0;
    final deviceLabel = packet.data!['device_label'] as String?;

    if (mlsDeviceId == null) return;

    _showSnackBarState(
      state: MlsPopupState.refillingKeyPackages,
      mlsDeviceId: mlsDeviceId,
      deviceLabel: deviceLabel,
      count: availableCount,
    );
  }

  void _showSnackBarState({
    required MlsPopupState state,
    String? mlsDeviceId,
    String? deviceLabel,
    int? count,
  }) {
    final context = globalOverlay.currentState?.context;
    if (context == null) return;

    final serial = ++_activeSerial;
    final isComplete = false;
    final accentColor = _resolveAccentColor(state, isComplete: isComplete);
    final containerColor = Color.alphaBlend(
      accentColor.withValues(alpha: 0.05),
      Theme.of(context).colorScheme.surfaceContainer,
    );

    showCustomSnackBar(
      entryKey: _mlsSnackBarKey,
      duration: state == MlsPopupState.refillingKeyPackages
          ? null
          : const Duration(seconds: 3),
      noVibrate: false,
      containerColor: containerColor,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      enableStackScale: false,
      builder: (context, dismiss) => _MlsStateSnackBarContent(
        state: state,
        isComplete: false,
        deviceLabel: deviceLabel,
      ),
    );

    if (state == MlsPopupState.refillingKeyPackages) {
      unawaited(
        _runRefillFlow(
          serial: serial,
          mlsDeviceId: mlsDeviceId,
          deviceLabel: deviceLabel,
          count: count,
        ),
      );
    }
  }

  Future<void> _runRefillFlow({
    required int serial,
    required String? mlsDeviceId,
    required String? deviceLabel,
    required int? count,
  }) async {
    final identityManager = _identityManager;
    if (identityManager == null) {
      _completeAndDismiss(
        serial: serial,
        state: MlsPopupState.refillingKeyPackages,
        deviceLabel: deviceLabel,
      );
      return;
    }

    final currentCount = count ?? 0;
    final needed = 3 - currentCount;
    if (needed <= 0) {
      _completeAndDismiss(
        serial: serial,
        state: MlsPopupState.refillingKeyPackages,
        deviceLabel: deviceLabel,
      );
      return;
    }

    for (var i = 0; i < needed; i++) {
      if (serial != _activeSerial) return;
      _mlsLog('Uploading key package ${i + 1}/$needed');
      await Future.delayed(const Duration(milliseconds: 500));
      if (serial != _activeSerial) return;
      if (mlsDeviceId != null) {
        _mlsLog('Refilling device: $mlsDeviceId');
      }
    }

    _completeAndDismiss(
      serial: serial,
      state: MlsPopupState.refillingKeyPackages,
      deviceLabel: deviceLabel,
    );
  }

  void _completeAndDismiss({
    required int serial,
    required MlsPopupState state,
    required String? deviceLabel,
  }) {
    if (serial != _activeSerial) return;

    final context = globalOverlay.currentState?.context;
    if (context == null) return;
    final accentColor = _resolveAccentColor(state, isComplete: true);
    final containerColor = Color.alphaBlend(
      accentColor.withValues(alpha: 0.05),
      Theme.of(context).colorScheme.surfaceContainer,
    );

    updateCustomSnackBar(
      entryKey: _mlsSnackBarKey,
      noVibrate: true,
      duration: const Duration(seconds: 3),
      containerColor: containerColor,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      enableStackScale: false,
      builder: (context, dismiss) => _MlsStateSnackBarContent(
        state: state,
        isComplete: true,
        deviceLabel: deviceLabel,
      ),
    );
  }

  Color _resolveAccentColor(MlsPopupState state, {required bool isComplete}) {
    if (isComplete) return Colors.green;
    switch (state) {
      case MlsPopupState.refillingKeyPackages:
      case MlsPopupState.uploadingGroupInfo:
        return Colors.teal;
      case MlsPopupState.externalJoin:
      case MlsPopupState.processingWelcome:
      case MlsPopupState.processingCommit:
      case MlsPopupState.recoveringEpoch:
      case MlsPopupState.genericProgress:
        return Colors.blue;
    }
  }

  void testShowRefill({
    required String mlsDeviceId,
    String? deviceLabel,
    int currentCount = 0,
  }) {
    _showSnackBarState(
      state: MlsPopupState.refillingKeyPackages,
      mlsDeviceId: mlsDeviceId,
      deviceLabel: deviceLabel,
      count: currentCount,
    );
  }

  void testShowExternalJoin({String? deviceLabel}) {
    _showSnackBarState(
      state: MlsPopupState.externalJoin,
      deviceLabel: deviceLabel,
    );
  }

  void testShowRecoveringEpoch({String? deviceLabel}) {
    _showSnackBarState(
      state: MlsPopupState.recoveringEpoch,
      deviceLabel: deviceLabel,
    );
  }
}

class _MlsStateSnackBarContent extends StatelessWidget {
  const _MlsStateSnackBarContent({
    required this.state,
    required this.isComplete,
    this.deviceLabel,
  });

  final MlsPopupState state;
  final bool isComplete;
  final String? deviceLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isComplete ? Colors.green : _resolveAccentColor();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: isComplete
                  ? Icon(Symbols.check_circle, size: 20, color: color)
                  : _buildProgressIcon(color),
            ),
          ),
          const Gap(12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _getStatusText(),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.1,
                ),
              ),
              const Gap(2),
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  Text(
                    _getCompleteText(),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  if (deviceLabel != null)
                    Text(
                      deviceLabel!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _resolveAccentColor() {
    switch (state) {
      case MlsPopupState.refillingKeyPackages:
      case MlsPopupState.uploadingGroupInfo:
        return Colors.teal;
      case MlsPopupState.externalJoin:
      case MlsPopupState.processingWelcome:
      case MlsPopupState.processingCommit:
      case MlsPopupState.recoveringEpoch:
      case MlsPopupState.genericProgress:
        return Colors.blue;
    }
  }

  Widget _buildProgressIcon(Color color) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation(color),
      ),
    );
  }

  String _getStatusText() {
    return isComplete ? state.completeText : state.inProgressText;
  }

  String _getCompleteText() {
    switch (state) {
      case MlsPopupState.refillingKeyPackages:
        return 'Key packages';
      case MlsPopupState.externalJoin:
      case MlsPopupState.processingWelcome:
        return 'Conversation';
      case MlsPopupState.processingCommit:
        return 'Update';
      case MlsPopupState.recoveringEpoch:
        return 'Encryption';
      case MlsPopupState.uploadingGroupInfo:
        return 'Group state';
      case MlsPopupState.genericProgress:
        return 'Process';
    }
  }
}
