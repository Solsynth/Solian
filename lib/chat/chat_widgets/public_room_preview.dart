import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:gap/gap.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:island/chat/chat_widgets/message_item.dart";
import "package:island/chat/messages_notifier.dart";
import "package:island/data/message.dart";
import "package:island/chat/chat_models/chat.dart";
import "package:island/chat/chat_pod/chat_room.dart";
import "package:island/core/network.dart";
import "package:island/core/services/responsive.dart";
import "package:island/shared/widgets/alert.dart";
import "package:island/shared/widgets/app_scaffold.dart";
import "package:island/drive/drive_widgets/cloud_files.dart";
import "package:island/shared/widgets/response.dart";
import "package:material_symbols_icons/material_symbols_icons.dart";
import "package:styled_widget/styled_widget.dart";
import "package:super_sliver_list/super_sliver_list.dart";
import "package:material_symbols_icons/symbols.dart";

class PublicRoomPreview extends HookConsumerWidget {
  final String id;
  final SnChatRoom room;

  const PublicRoomPreview({super.key, required this.id, required this.room});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(messagesProvider(id));
    final messagesNotifier = ref.read(messagesProvider(id).notifier);
    final scrollController = useScrollController();

    final listController = useMemoized(() => ListController(), []);

    var isLoading = false;

    // Add scroll listener for pagination
    useEffect(() {
      void onScroll() {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
          if (isLoading) return;
          isLoading = true;
          messagesNotifier.loadMore().then((_) => isLoading = false);
        }
      }

      scrollController.addListener(onScroll);
      return () => scrollController.removeListener(onScroll);
    }, [scrollController]);

    Widget chatMessageListWidget(List<LocalChatMessage> messageList) =>
        SuperListView.builder(
          listController: listController,
          padding: EdgeInsets.symmetric(vertical: 16),
          controller: scrollController,
          reverse: true, // Show newest messages at the bottom
          itemCount: messageList.length,
          findChildIndexCallback: (key) {
            final valueKey = key as ValueKey;
            final messageId = valueKey.value as String;
            return messageList.indexWhere((m) => m.id == messageId);
          },
          extentEstimation: (_, _) => 40,
          itemBuilder: (context, index) {
            final message = messageList[index];
            final nextMessage = index < messageList.length - 1
                ? messageList[index + 1]
                : null;
            final isLastInGroup =
                nextMessage == null ||
                nextMessage.senderId != message.senderId ||
                nextMessage.createdAt
                        .difference(message.createdAt)
                        .inMinutes
                        .abs() >
                    3;

            return MessageItem(
              message: message,
              isCurrentUser: false, // User is not a member, so not current user
              onAction: null, // No actions allowed in preview mode
              onJump: (_) {}, // No jump functionality in preview
              progress: null,
              showAvatar: isLastInGroup,
            );
          },
        );

    final compactHeader = isWideScreen(context);

    Widget comfortHeaderWidget() => Column(
      spacing: 4,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 26,
          width: 26,
          child: (room.type == 1 && room.picture == null)
              ? SplitAvatarWidget(
                  files: room.members!
                      .map((e) => e.account.profile.picture)
                      .toList(),
                )
              : room.picture != null
              ? ProfilePictureWidget(
                  file: room.picture,
                  fallbackIcon: Symbols.chat,
                )
              : CircleAvatar(
                  child: Text(
                    room.name![0].toUpperCase(),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
        ),
        Text(
          (room.type == 1 && room.name == null)
              ? room.members!.map((e) => e.account.nick).join(', ')
              : room.name!,
        ).fontSize(15),
      ],
    );

    Widget compactHeaderWidget() => Row(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 26,
          width: 26,
          child: (room.type == 1 && room.picture == null)
              ? SplitAvatarWidget(
                  files: room.members!
                      .map((e) => e.account.profile.picture)
                      .toList(),
                )
              : room.picture != null
              ? ProfilePictureWidget(
                  file: room.picture,
                  fallbackIcon: Symbols.chat,
                )
              : CircleAvatar(
                  child: Text(
                    room.name![0].toUpperCase(),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
        ),
        Text(
          (room.type == 1 && room.name == null)
              ? room.members!.map((e) => e.account.nick).join(', ')
              : room.name!,
        ).fontSize(19),
      ],
    );

    return AppScaffold(
      appBar: AppBar(
        leading: !compactHeader ? const Center(child: PageBackButton()) : null,
        automaticallyImplyLeading: false,
        toolbarHeight: compactHeader ? null : 64,
        title: compactHeader ? compactHeaderWidget() : comfortHeaderWidget(),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              context.pushNamed('chatDetail', pathParameters: {'id': id});
            },
          ),
          const Gap(8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: messages.when(
              data: (messageList) => messageList.isEmpty
                  ? Center(child: Text('No messages yet'.tr()))
                  : chatMessageListWidget(messageList),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => ResponseErrorWidget(
                error: error,
                onRetry: () => messagesNotifier.loadInitial(),
              ),
            ),
          ),
          // Join button at the bottom for public rooms
          Container(
            padding: const EdgeInsets.all(16),
            child: FilledButton.tonalIcon(
              onPressed: () async {
                try {
                  showLoadingModal(context);
                  final apiClient = ref.read(apiClientProvider);
                  await apiClient.post('/messager/chat/${room.id}/members/me');
                  ref.invalidate(chatRoomIdentityProvider(id));
                } catch (err) {
                  showErrorAlert(err);
                } finally {
                  if (context.mounted) hideLoadingModal(context);
                }
              },
              label: Text('chatJoin').tr(),
              icon: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
