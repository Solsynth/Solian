import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/chat/pods/chat_room_state.dart';
import 'package:island/chat/widgets/message_item.dart';
import 'package:island/data/message.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

final animatedMessagesProvider = NotifierProvider.autoDispose(
  AnimatedMessagesNotifier.new,
);

class AnimatedMessagesNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    return {};
  }

  void addMessage(String messageId) {
    state = {...state, messageId};
  }
}

class MessageItemWrapper extends HookConsumerWidget {
  final LocalChatMessage message;
  final int index;
  final String roomId;
  final bool isLastInGroup;
  final bool showBubbleAvatar;
  final bool showColumnAvatar;
  final AsyncValue<SnChatMember?> chatIdentity;
  final VoidCallback toggleSelectionMode;
  final Function(String) toggleMessageSelection;
  final Function(String, LocalChatMessage) onMessageAction;
  final Function(String) onJump;
  final bool disableAnimation;
  final DateTime roomOpenTime;

  const MessageItemWrapper({
    super.key,
    required this.message,
    required this.index,
    required this.roomId,
    required this.isLastInGroup,
    this.showBubbleAvatar = true,
    this.showColumnAvatar = true,
    required this.chatIdentity,
    required this.toggleSelectionMode,
    required this.toggleMessageSelection,
    required this.onMessageAction,
    required this.onJump,
    required this.disableAnimation,
    required this.roomOpenTime,
  });

  Widget _buildContent(
    BuildContext context,
    SnChatMember? identity, {
    required bool isSelectionMode,
    required bool isSelected,
    required Map<int, double?>? progress,
  }) {
    final stableMessageKey = message.clientMessageId ?? message.id;
    final isCurrentUser = identity?.id == message.senderId;
    final colorScheme = Theme.of(context).colorScheme;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final animDuration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 200);

    final messageItem = MessageItem(
      key: ValueKey('item-$stableMessageKey'),
      message: message,
      isCurrentUser: isCurrentUser,
      onAction: isSelectionMode
          ? null
          : (action) => onMessageAction(action, message),
      onJump: onJump,
      progress: progress,
      showAvatar: isLastInGroup,
      showBubbleAvatar: showBubbleAvatar,
      showColumnAvatar: showColumnAvatar,
      isSelectionMode: isSelectionMode,
      isSelected: isSelected,
      onToggleSelection: toggleMessageSelection,
      onEnterSelectionMode: () {
        if (!isSelectionMode) toggleSelectionMode();
      },
    );

    return AnimatedContainer(
      duration: animDuration,
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: isSelected
            ? colorScheme.primary.withValues(alpha: 0.10)
            : colorScheme.surface.withValues(alpha: 0),
        border: Border(
          left: BorderSide(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            width: 3,
          ),
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: isSelectionMode
              ? () => toggleMessageSelection(message.id)
              : null,
          splashColor: colorScheme.primary.withValues(alpha: 0.08),
          highlightColor: colorScheme.primary.withValues(alpha: 0.04),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AnimatedSize(
                duration: animDuration,
                curve: Curves.easeOutCubic,
                alignment: Alignment.centerLeft,
                child: isSelectionMode
                    ? Padding(
                        padding: const EdgeInsets.only(left: 10, right: 2),
                        child: _SelectionIndicator(isSelected: isSelected),
                      )
                    : const SizedBox(width: 0, height: 28),
              ),
              Expanded(
                child: IgnorePointer(
                  ignoring: isSelectionMode,
                  child: messageItem,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return MessageItem(
      message: message,
      isCurrentUser: false,
      onAction: null,
      progress: null,
      showAvatar: false,
      onJump: (_) {},
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (message.type == 'messages.sync.finalize' ||
        message.type == 'messages.sync.links') {
      return const SizedBox.shrink();
    }

    // Animation logic
    final animatedMessages = ref.watch(animatedMessagesProvider);
    final isSelectionMode = ref.watch(
      chatRoomStateProvider(roomId).select((state) => state.isSelectionMode),
    );
    final isSelected = ref.watch(
      chatRoomStateProvider(
        roomId,
      ).select((state) => state.selectedMessageIds.contains(message.id)),
    );
    final progress = ref.watch(
      chatRoomStateProvider(
        roomId,
      ).select((state) => state.attachmentProgress[message.id]),
    );
    final stableMessageKey = message.clientMessageId ?? message.id;
    final isNewMessage = message.createdAt.isAfter(roomOpenTime);
    final hasAnimated = animatedMessages.contains(stableMessageKey);

    // Only animate if:
    // 1. Animation is enabled
    // 2. Message is new (created after room open)
    // 3. Has not animated yet
    final shouldAnimate = !disableAnimation && isNewMessage && !hasAnimated;

    final child = chatIdentity.when(
      skipError: true,
      data: (identity) => _buildContent(
        context,
        identity,
        isSelectionMode: isSelectionMode,
        isSelected: isSelected,
        progress: progress,
      ),
      loading: () => _buildLoading(),
      error: (_, _) => const SizedBox.shrink(),
    );

    final controller = useAnimationController(
      duration: Duration(milliseconds: 400 + (index % 5) * 50),
    );

    final hasStarted = useState(false);

    useEffect(() {
      if (shouldAnimate && !hasStarted.value) {
        hasStarted.value = true;
        controller.forward().then((_) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref
                .read(animatedMessagesProvider.notifier)
                .addMessage(stableMessageKey);
          });
        });
      }
      return null;
    }, [shouldAnimate]);

    if (!shouldAnimate) {
      return child;
    }

    final curvedAnimation = useMemoized(
      () => CurvedAnimation(parent: controller, curve: Curves.easeOutQuart),
      [controller],
    );

    final sizeAnimation = useMemoized(
      () => Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation),
      [curvedAnimation],
    );

    final slideAnimation = useMemoized(
      () => Tween<Offset>(
        begin: const Offset(0, 0.12),
        end: Offset.zero,
      ).animate(curvedAnimation),
      [curvedAnimation],
    );

    final fadeAnimation = useMemoized(
      () => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: const Interval(0.1, 1.0, curve: Curves.easeOut),
        ),
      ),
      [controller],
    );

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) => FadeTransition(
        opacity: fadeAnimation,
        child: SizeTransition(
          axis: Axis.vertical,
          sizeFactor: sizeAnimation,
          child: SlideTransition(position: slideAnimation, child: child),
        ),
      ),
      child: child,
    );
  }
}

class _SelectionIndicator extends StatelessWidget {
  final bool isSelected;

  const _SelectionIndicator({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return AnimatedContainer(
      duration: reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? colorScheme.primary : Colors.transparent,
        border: Border.all(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.outline.withValues(alpha: 0.7),
          width: 2,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.28),
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                ),
              ]
            : null,
      ),
      child: AnimatedScale(
        scale: isSelected ? 1 : 0.6,
        duration: reduceMotion
            ? Duration.zero
            : const Duration(milliseconds: 160),
        curve: Curves.easeOutBack,
        child: AnimatedOpacity(
          opacity: isSelected ? 1 : 0,
          duration: reduceMotion
              ? Duration.zero
              : const Duration(milliseconds: 120),
          child: Icon(
            Icons.check_rounded,
            size: 14,
            color: colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }
}
