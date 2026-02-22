import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/chat/pods/chat_room.dart';
import 'package:island/chat/messages_notifier.dart';
import 'package:island/data/message.dart';
import 'package:island/talker.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

class RoomScrollManager {
  final ScrollController scrollController;
  final ListController listController;
  final ValueNotifier<double> bottomGradientOpacity;
  bool isScrollingToMessage;
  final void Function({
    required String messageId,
    required List<LocalChatMessage> messageList,
  })
  scrollToMessage;

  RoomScrollManager({
    required this.scrollController,
    required this.listController,
    required this.bottomGradientOpacity,
    required this.scrollToMessage,
    this.isScrollingToMessage = false,
  });
}

RoomScrollManager useRoomScrollManager(
  WidgetRef ref,
  String roomId,
  Future<int> Function(String) jumpToMessage,
  AsyncValue<List<LocalChatMessage>> messagesAsync,
) {
  final scrollController = useScrollController();
  final listController = useMemoized(() => ListController(), []);
  final bottomGradientOpacity = useState(ValueNotifier<double>(0.0));

  final isLoadingRef = useRef(false);
  final autoFillPassesRef = useRef(0);
  final autoFillInProgressRef = useRef(false);
  final lastAutoFillMessageCountRef = useRef<int?>(null);
  const int kMaxAutoFillPasses = 12;
  var isScrollingToMessage = false;
  final messagesNotifier = ref.read(messagesProvider(roomId).notifier);
  final flashingMessagesNotifier = ref.read(flashingMessagesProvider.notifier);

  void performScrollAnimation({required int index, required String messageId}) {
    flashingMessagesNotifier.update((set) => set.union({messageId}));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          listController.animateToItem(
            index: index,
            scrollController: scrollController,
            alignment: 0.5,
            duration: (estimatedDistance) => Duration(
              milliseconds: (estimatedDistance * 0.5).clamp(200, 800).toInt(),
            ),
            curve: (estimatedDistance) => Curves.easeOutCubic,
          );

          Future.delayed(const Duration(milliseconds: 800), () {
            isScrollingToMessage = false;
          });
        } catch (e) {
          isScrollingToMessage = false;
        }
      });
    });
  }

  void scrollToMessageWrapper({
    required String messageId,
    required List<LocalChatMessage> messageList,
  }) {
    if (isScrollingToMessage) return;
    isScrollingToMessage = true;

    final messageIndex = messageList.indexWhere((m) => m.id == messageId);

    if (messageIndex == -1) {
      jumpToMessage(messageId).then((index) {
        if (index != -1) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            performScrollAnimation(index: index, messageId: messageId);
          });
        } else {
          isScrollingToMessage = false;
        }
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        performScrollAnimation(index: messageIndex, messageId: messageId);
      });
    }
  }

  useEffect(() {
    void onScroll() {
      messagesAsync.when(
        data: (messageList) {
          if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 200) {
            talker.log(
              'Room scroll reached pagination threshold '
              '(roomId=$roomId, pixels=${scrollController.position.pixels}, '
              'max=${scrollController.position.maxScrollExtent}, '
              'isLoading=${isLoadingRef.value}, localCount=${messageList.length})',
            );
            if (!isLoadingRef.value) {
              isLoadingRef.value = true;
              talker.log('Room scroll triggering loadMore (roomId=$roomId)');
              messagesNotifier.loadMore().whenComplete(() {
                isLoadingRef.value = false;
              });
            }
          }

          final pixels = scrollController.position.pixels;
          bottomGradientOpacity.value.value = (pixels / 500.0).clamp(0.0, 1.0);
        },
        loading: () {},
        error: (_, _) {},
      );
    }

    scrollController.addListener(onScroll);
    return () => scrollController.removeListener(onScroll);
  }, [scrollController, messagesAsync]);

  useEffect(() {
    final items = messagesAsync.asData?.value;
    if (items == null) return null;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!scrollController.hasClients) return;
      if (isLoadingRef.value || autoFillInProgressRef.value) return;

      final position = scrollController.position;
      final isScrollable = position.maxScrollExtent > 0;
      if (isScrollable) {
        autoFillPassesRef.value = 0;
        lastAutoFillMessageCountRef.value = null;
        return;
      }

      if (autoFillPassesRef.value >= kMaxAutoFillPasses) return;

      final itemCount = items.length;
      if (lastAutoFillMessageCountRef.value == itemCount) {
        // Previous autofill pass did not add messages, stop retrying.
        return;
      }

      autoFillInProgressRef.value = true;
      autoFillPassesRef.value += 1;
      lastAutoFillMessageCountRef.value = itemCount;

      talker.log(
        'Room auto-fill triggering loadMore '
        '(roomId=$roomId, pass=${autoFillPassesRef.value}, count=$itemCount)',
      );

      await messagesNotifier.loadMore();
      autoFillInProgressRef.value = false;
    });

    return null;
  }, [messagesAsync.asData?.value.length, scrollController]);

  return RoomScrollManager(
    scrollController: scrollController,
    listController: listController,
    bottomGradientOpacity: bottomGradientOpacity.value,
    scrollToMessage: scrollToMessageWrapper,
    isScrollingToMessage: isScrollingToMessage,
  );
}
