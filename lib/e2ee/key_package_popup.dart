import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/websocket.dart';
import 'package:island/main.dart';
import 'package:logging/logging.dart';

import 'package:material_symbols_icons/symbols.dart';
import 'package:island/e2ee/mls_identity_manager.dart';
import 'package:styled_widget/styled_widget.dart';

const _mlsLogPrefix = '[KP Popup] ';

void _mlsLog(dynamic msg) {
  Logger.root.info('$_mlsLogPrefix$msg');
}

final keyPackagePopupProvider = NotifierProvider<KeyPackagePopupNotifier, void>(
  KeyPackagePopupNotifier.new,
);

class KeyPackagePopupNotifier extends Notifier<void> {
  StreamSubscription? _subscription;
  MlsIdentityManager? _identityManager;

  @override
  void build() {
    ref.onDispose(() {
      _subscription?.cancel();
    });
    _setupListener();
  }

  void setIdentityManager(MlsIdentityManager identityManager) {
    _identityManager = identityManager;
  }

  void _setupListener() {
    final service = ref.read(websocketProvider);
    _subscription = service.dataStream.listen((packet) {
      if (packet.type == 'e2ee.kp.depleted') {
        _handleKeyPackageDepleted(packet);
      }
    });
  }

  void _handleKeyPackageDepleted(WebSocketPacket packet) {
    if (packet.data == null) return;

    final mlsDeviceId =
        packet.data!['mls_device_id'] as String? ??
        packet.data!['device_id'] as String?;
    final availableCount = packet.data!['available_count'] as int? ?? 0;
    final deviceLabel = packet.data!['device_label'] as String?;

    if (mlsDeviceId == null) return;

    _showRefillOverlay(
      mlsDeviceId: mlsDeviceId,
      deviceLabel: deviceLabel,
      currentCount: availableCount,
    );
  }

  void _showRefillOverlay({
    required String mlsDeviceId,
    String? deviceLabel,
    required int currentCount,
  }) {
    final context = globalOverlay.currentState?.context;
    if (context == null) return;

    OverlayEntry? entry;
    entry = OverlayEntry(
      builder: (context) => _KeyPackageRefillOverlay(
        identityManager: _identityManager,
        mlsDeviceId: mlsDeviceId,
        deviceLabel: deviceLabel,
        currentCount: currentCount,
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
    _showRefillOverlay(
      mlsDeviceId: mlsDeviceId,
      deviceLabel: deviceLabel,
      currentCount: currentCount,
    );
  }
}

class _KeyPackageRefillOverlay extends StatefulWidget {
  final MlsIdentityManager? identityManager;
  final String mlsDeviceId;
  final String? deviceLabel;
  final int currentCount;
  final VoidCallback onComplete;

  const _KeyPackageRefillOverlay({
    this.identityManager,
    required this.mlsDeviceId,
    this.deviceLabel,
    required this.currentCount,
    required this.onComplete,
  });

  @override
  State<_KeyPackageRefillOverlay> createState() =>
      _KeyPackageRefillOverlayState();
}

class _KeyPackageRefillOverlayState extends State<_KeyPackageRefillOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  static const int _minKeyPackagesRequired = 3;
  bool _isRefillComplete = false;
  int _uploadedCount = 0;
  int _totalToUpload = 0;
  bool _isRefilling = false;

  @override
  void initState() {
    super.initState();
    _totalToUpload = _minKeyPackagesRequired - widget.currentCount;
    if (_totalToUpload <= 0) {
      _totalToUpload = 0;
      _isRefillComplete = true;
    }

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

    if (!_isRefillComplete && !_isRefilling) {
      _startRefill(mock: widget.identityManager == null);
    } else {
      _startAutoDismissCountdown();
    }
  }

  Future<void> _startRefill({bool mock = false}) async {
    if (_totalToUpload <= 0) {
      _startAutoDismissCountdown();
      return;
    }

    _isRefilling = true;

    for (var i = 0; i < _totalToUpload; i++) {
      if (!mounted) return;

      setState(() {
        _uploadedCount = i + 1;
      });

      if (!mock && widget.identityManager != null) {
        try {
          final kp = await widget.identityManager!.generateKeyPackage();
          final kpBase64 = base64Encode(kp.keyPackageBytes);
          await widget.identityManager!.uploadKeyPackage(kpBase64);
          _mlsLog('Uploaded key package ${i + 1}/$_totalToUpload');
        } catch (e) {
          _mlsLog('Failed to upload key package ${i + 1}: $e');
        }
      } else {
        _mlsLog('Mock: uploaded key package ${i + 1}/$_totalToUpload');
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    if (!mounted) return;

    setState(() {
      _isRefillComplete = true;
      _isRefilling = false;
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
    final color = _isRefillComplete ? Colors.green : Colors.teal;

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
                          child: _RefillPillContent(
                            isComplete: _isRefillComplete,
                            deviceLabel: widget.deviceLabel,
                            uploadedCount: _uploadedCount,
                            totalToUpload: _totalToUpload,
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

class _RefillPillContent extends StatelessWidget {
  final bool isComplete;
  final String? deviceLabel;
  final int uploadedCount;
  final int totalToUpload;
  final Color color;

  const _RefillPillContent({
    required this.isComplete,
    this.deviceLabel,
    required this.uploadedCount,
    required this.totalToUpload,
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
                : CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(color),
                    padding: EdgeInsets.zero,
                  ).width(14).height(14).padding(all: 8),
          ),
          const Gap(12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isComplete ? 'Encryption ready' : 'Refilling key packages...',
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
                    isComplete
                        ? '${totalToUpload > 0 ? totalToUpload : 3} key packages ready'
                        : 'Uploading $uploadedCount/$totalToUpload',
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
}
