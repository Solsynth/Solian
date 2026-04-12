import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/main.dart';
import 'package:island/shared/widgets/responsive_sidebar.dart';
import 'package:island/thoughts/screens/think.dart';
import 'package:island/thoughts/widgets/billing_status_handler.dart';
import 'package:island/thoughts/widgets/thought_chat_notifier.dart';
import 'package:island/thoughts/widgets/thought_shared.dart';
import 'package:island/thoughts/widgets/thought_sidebar.dart';
import 'package:material_symbols_icons/symbols.dart';

OverlayEntry? _thoughtOverlayEntry;

final _thoughtOverlayStateProvider =
    NotifierProvider<_ThoughtOverlayStateNotifier, _ThoughtOverlayState>(
      _ThoughtOverlayStateNotifier.new,
    );

class _ThoughtOverlayState {
  final Offset position;
  final Size size;

  const _ThoughtOverlayState({
    this.position = const Offset(8, 80),
    this.size = const Size(480, 640),
  });

  _ThoughtOverlayState copyWith({Offset? position, Size? size}) {
    return _ThoughtOverlayState(
      position: position ?? this.position,
      size: size ?? this.size,
    );
  }
}

class _ThoughtOverlayStateNotifier extends Notifier<_ThoughtOverlayState> {
  @override
  _ThoughtOverlayState build() => const _ThoughtOverlayState();

  void updatePosition(Offset delta) {
    state = state.copyWith(
      position: Offset(
        state.position.dx + delta.dx,
        state.position.dy + delta.dy,
      ),
    );
  }

  void updateSize(Size delta) {
    const minWidth = 360.0;
    const minHeight = 400.0;
    const maxWidth = 600.0;
    const maxHeight = 800.0;

    final newWidth = (state.size.width + delta.width).clamp(minWidth, maxWidth);
    final newHeight = (state.size.height + delta.height).clamp(
      minHeight,
      maxHeight,
    );
    state = state.copyWith(size: Size(newWidth, newHeight));
  }

  void setPosition(Offset position) {
    state = state.copyWith(position: position);
  }
}

void showThoughtOverlay({
  String? initialMessage,
  List<Map<String, dynamic>> attachedMessages = const [],
  List<String> attachedPosts = const [],
}) {
  if (_thoughtOverlayEntry != null) {
    _thoughtOverlayEntry?.markNeedsBuild();
    return;
  }

  final state = _overlayContainer.read(_thoughtOverlayStateProvider);
  _thoughtOverlayEntry = OverlayEntry(
    builder: (context) => _ThoughtOverlayPanel(
      initialPosition: state.position,
      initialSize: state.size,
      initialMessage: initialMessage,
      attachedMessages: attachedMessages,
      attachedPosts: attachedPosts,
    ),
  );
  globalOverlay.currentState?.insert(_thoughtOverlayEntry!);
}

void hideThoughtOverlay() {
  _thoughtOverlayEntry?.remove();
  _thoughtOverlayEntry = null;
}

void toggleThoughtOverlay({
  String? initialMessage,
  List<Map<String, dynamic>> attachedMessages = const [],
  List<String> attachedPosts = const [],
}) {
  if (_thoughtOverlayEntry != null) {
    hideThoughtOverlay();
  } else {
    showThoughtOverlay(
      initialMessage: initialMessage,
      attachedMessages: attachedMessages,
      attachedPosts: attachedPosts,
    );
  }
}

final ProviderContainer _overlayContainer = ProviderContainer();

class ThoughtSheet extends HookConsumerWidget {
  final String? initialMessage;
  final List<Map<String, dynamic>> attachedMessages;
  final List<String> attachedPosts;

  const ThoughtSheet({
    super.key,
    this.initialMessage,
    this.attachedMessages = const [],
    this.attachedPosts = const [],
  });

  static Future<void> show(
    BuildContext context, {
    String? initialMessage,
    List<Map<String, dynamic>> attachedMessages = const [],
    List<String> attachedPosts = const [],
  }) {
    final isWide = isWideScreen(context);

    if (isWide) {
      showThoughtOverlay(
        initialMessage: initialMessage,
        attachedMessages: attachedMessages,
        attachedPosts: attachedPosts,
      );
      return Future.value();
    } else {
      return showDialog(
        context: context,
        useRootNavigator: true,
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.6),
        builder: (context) => ThoughtSheet(
          initialMessage: initialMessage,
          attachedMessages: attachedMessages,
          attachedPosts: attachedPosts,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(thoughtAvailableStausProvider);
    final showSidebar = useState(false);

    final args = ThoughtChatArgs(
      initialMessage: initialMessage,
      attachedMessages: attachedMessages,
      attachedPosts: attachedPosts,
    );

    final chatState = ref.watch(thoughtChatProvider(args));
    final chatNotifier = ref.read(thoughtChatProvider(args).notifier);

    void refreshStatus() => ref.invalidate(thoughtAvailableStausProvider);

    void startNewConversation() {
      chatNotifier.clearChat();
      showSidebar.value = false;
    }

    void toggleSidebar() => showSidebar.value = !showSidebar.value;
    void closeSidebar() => showSidebar.value = false;

    void handleServiceChanged(String serviceId) {
      final previousServiceId = chatState.selectedServiceId;
      if (serviceId == previousServiceId) {
        return;
      }

      chatNotifier.clearChat(selectedServiceId: serviceId);
      showSidebar.value = false;

      if (serviceId == 'michan') {
        chatNotifier.loadMichanCanonicalThread();
      }
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
      child: Scaffold(
        appBar: AppBar(
          title: Text(chatState.currentTopic ?? 'aiThought'.tr()),
          leading: IconButton(
            icon: const Icon(Symbols.close),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'close'.tr(),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(52),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: ServiceSelector(
                  services: chatState.services,
                  selectedServiceId: chatState.selectedServiceId,
                  onServiceChanged: handleServiceChanged,
                  isStreaming: chatState.isStreaming,
                  isDisabled: statusAsync.value == false,
                ),
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Symbols.add),
              onPressed: startNewConversation,
              tooltip: 'newConversation'.tr(),
            ),
            IconButton(
              icon: const Icon(Symbols.history),
              onPressed: toggleSidebar,
              tooltip: 'conversations'.tr(),
            ),
            const Gap(8),
          ],
        ),
        body: ResponsiveSidebar(
          showSidebar: showSidebar,
          sidebarWidth: 320,
          sidebarContent: ThoughtSidebar(
            selectedSequenceId: chatState.sequenceId,
            onClose: closeSidebar,
          ),
          mainContent: BillingStatusHandler(
            statusAsync: statusAsync,
            onRefreshStatus: refreshStatus,
            child: ThoughtChatInterface(
              initialMessage: initialMessage,
              attachedMessages: attachedMessages,
              attachedPosts: attachedPosts,
              isDisabled: statusAsync.value == false,
            ),
          ),
        ),
      ),
    );
  }
}

class _ThoughtOverlayPanel extends ConsumerStatefulWidget {
  final Offset initialPosition;
  final Size initialSize;
  final String? initialMessage;
  final List<Map<String, dynamic>> attachedMessages;
  final List<String> attachedPosts;

  const _ThoughtOverlayPanel({
    required this.initialPosition,
    required this.initialSize,
    this.initialMessage,
    this.attachedMessages = const [],
    this.attachedPosts = const [],
  });

  @override
  ConsumerState<_ThoughtOverlayPanel> createState() =>
      _ThoughtOverlayPanelState();
}

class _ThoughtOverlayPanelState extends ConsumerState<_ThoughtOverlayPanel>
    with SingleTickerProviderStateMixin {
  late Offset _position;
  late Size _size;
  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _position = widget.initialPosition;
    _size = widget.initialSize;
    _animController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );
    _animController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _isInitialized = true);
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    await _animController.reverse();
    if (mounted) {
      hideThoughtOverlay();
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final screenSize = MediaQuery.of(context).size;
    final overlayWidth = _size.width;
    final overlayHeight = _size.height;

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
        .read(_thoughtOverlayStateProvider.notifier)
        .updatePosition(details.delta);
  }

  void _onResizeUpdate(DragUpdateDetails details) {
    setState(() {
      final newWidth = (_size.width + details.delta.dx).clamp(360.0, 600.0);
      final newHeight = (_size.height + details.delta.dy).clamp(400.0, 800.0);
      _size = Size(newWidth, newHeight);
    });
  }

  void _onResizeEnd(DragEndDetails details) {
    ref
        .read(_thoughtOverlayStateProvider.notifier)
        .updateSize(Size(_size.width - 480, _size.height - 640));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showSidebar = useState(false);

    if (!_isInitialized) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        final slideOffset = _slideAnimation.value.dx * (_size.width + 16 * 2);
        return Transform.translate(
          offset: Offset(slideOffset, 0),
          child: child,
        );
      },
      child: Positioned(
        left: _position.dx,
        top: _position.dy,
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onPanUpdate: _onPanUpdate,
            child: SizedBox(
              width: _size.width,
              height: _size.height,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _buildPanelContainer(context, showSidebar),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: _buildResizeHandle(theme),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPanelContainer(
    BuildContext context,
    ValueNotifier<bool> showSidebar,
  ) {
    final theme = Theme.of(context);
    final statusAsync = ref.watch(thoughtAvailableStausProvider);

    final args = ThoughtChatArgs(
      initialMessage: widget.initialMessage,
      attachedMessages: widget.attachedMessages,
      attachedPosts: widget.attachedPosts,
    );

    final chatState = ref.watch(thoughtChatProvider(args));

    void closeSidebar() => showSidebar.value = false;
    void refreshStatus() => ref.invalidate(thoughtAvailableStausProvider);

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
        child: Column(
          children: [
            _buildHeader(context, chatState),
            Container(height: 1, color: theme.dividerColor),
            Expanded(
              child: ResponsiveSidebar(
                showSidebar: showSidebar,
                sidebarWidth: 280,
                sidebarContent: ThoughtSidebar(
                  selectedSequenceId: chatState.sequenceId,
                  onClose: closeSidebar,
                ),
                mainContent: BillingStatusHandler(
                  statusAsync: statusAsync,
                  onRefreshStatus: refreshStatus,
                  child: ThoughtChatInterface(
                    initialMessage: widget.initialMessage,
                    attachedMessages: widget.attachedMessages,
                    attachedPosts: widget.attachedPosts,
                    isDisabled: statusAsync.value == false,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic chatState) {
    final theme = Theme.of(context);

    return Container(
      height: 52,
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
          Icon(Symbols.psychology, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              chatState.currentTopic ?? 'aiThought'.tr(),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Symbols.close),
            onPressed: _dismiss,
            tooltip: 'close'.tr(),
            color: theme.colorScheme.onSurface,
          ),
        ],
      ),
    );
  }

  Widget _buildResizeHandle(ThemeData theme) {
    return GestureDetector(
      onPanUpdate: _onResizeUpdate,
      onPanEnd: _onResizeEnd,
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
        child: const Icon(
          Icons.drag_handle,
          size: 14,
          color: Color(0xFF9E9E9E),
        ),
      ),
    );
  }
}
