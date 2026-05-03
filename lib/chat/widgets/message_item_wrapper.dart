import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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
  final bool isLastInGroup;
  final bool showBubbleAvatar;
  final bool isSelectionMode;
  final Set<String> selectedMessages;
  final AsyncValue<SnChatMember?> chatIdentity;
  final VoidCallback toggleSelectionMode;
  final Function(String) toggleMessageSelection;
  final Function(String, LocalChatMessage) onMessageAction;
  final Function(String) onJump;
  final Map<String, Map<int, double?>> attachmentProgress;
  final bool disableAnimation;
  final DateTime roomOpenTime;

  const MessageItemWrapper({
    super.key,
    required this.message,
    required this.index,
    required this.isLastInGroup,
    this.showBubbleAvatar = true,
    required this.isSelectionMode,
    required this.selectedMessages,
    required this.chatIdentity,
    required this.toggleSelectionMode,
    required this.toggleMessageSelection,
    required this.onMessageAction,
    required this.onJump,
    required this.attachmentProgress,
    required this.disableAnimation,
    required this.roomOpenTime,
  });

  Widget _buildContent(BuildContext context, SnChatMember? identity) {
    final isSelected = selectedMessages.contains(message.id);
    final isCurrentUser = identity?.id == message.senderId;

    return GestureDetector(
      onLongPress: () {
        if (!isSelectionMode) {
          toggleSelectionMode();
          toggleMessageSelection(message.id);
        }
      },
      onTap: () {
        if (isSelectionMode) {
          toggleMessageSelection(message.id);
        }
      },
      child: Container(
        color: isSelected
            ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
            : null,
        child: Stack(
          children: [
            MessageItem(
              // If animation is disabled, we might want to pass a key to maintain state?
              // But here we are inside the wrapper.
              key: ValueKey('item-${message.id}'),
              message: message,
              isCurrentUser: isCurrentUser,
              onAction: isSelectionMode
                  ? null
                  : (action) => onMessageAction(action, message),
              onJump: onJump,
              progress: attachmentProgress[message.id],
              showAvatar: isLastInGroup,
              showBubbleAvatar: showBubbleAvatar,
              isSelectionMode: isSelectionMode,
              isSelected: isSelected,
              onToggleSelection: toggleMessageSelection,
              onEnterSelectionMode: () {
                if (!isSelectionMode) toggleSelectionMode();
              },
            ),
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    size: 12,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
          ],
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
    // Animation logic
    final animatedMessages = ref.watch(animatedMessagesProvider);
    final isNewMessage = message.createdAt.isAfter(roomOpenTime);
    final hasAnimated = animatedMessages.contains(message.id);

    // Only animate if:
    // 1. Animation is enabled
    // 2. Message is new (created after room open)
    // 3. Has not animated yet
    final shouldAnimate = !disableAnimation && isNewMessage && !hasAnimated;

    final child = chatIdentity.when(
      skipError: true,
      data: (identity) => _buildContent(context, identity),
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
            ref.read(animatedMessagesProvider.notifier).addMessage(message.id);
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
