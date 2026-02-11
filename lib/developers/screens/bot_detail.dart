import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/developers/screens/bot_keys.dart';
import 'package:island/developers/screens/edit_bot.dart';
import 'package:island/developers/models/bot.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/response.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

@RoutePage()
class DeveloperBotDetailScreen extends HookConsumerWidget {
  final String pubName;
  final String projectId;
  final String botId;

  const DeveloperBotDetailScreen({
    super.key,
    required this.pubName,
    required this.projectId,
    required this.botId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabController = useTabController(initialLength: 2);
    final botData = ref.watch(botProvider(pubName, projectId, botId));

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(
        leading: const PageBackButton(backTo: '/developers'),
        title: Text(botData.value?.account.nick ?? 'botDetails'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Symbols.edit),
            onPressed: botData.value == null
                ? null
                : () {
                    context.router.push(
                      DeveloperBotEditRoute(
                        pubName: pubName,
                        projectId: projectId,
                        id: botId,
                      ),
                    );
                  },
          ),
        ],
        bottom: TabBar(
          controller: tabController,
          tabs: [
            Tab(
              child: Text(
                'overview'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).appBarTheme.foregroundColor!,
                ),
              ),
            ),
            Tab(
              child: Text(
                'keys'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).appBarTheme.foregroundColor!,
                ),
              ),
            ),
          ],
        ),
      ),
      body: botData.when(
        data: (bot) {
          if (bot == null) {
            return Center(child: Text('botNotFound'.tr()));
          }
          return TabBarView(
            controller: tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: _BotOverview(bot: bot),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: BotKeysScreen(
                    publisherName: pubName,
                    projectId: projectId,
                    botId: botId,
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => ResponseErrorWidget(
          error: err,
          onRetry: () => ref.invalidate(botProvider(pubName, projectId, botId)),
        ),
      ),
    );
  }
}

class _BotOverview extends StatelessWidget {
  final Bot bot;
  const _BotOverview({required this.bot});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 7,
            child: Stack(
              clipBehavior: Clip.none,
              fit: StackFit.expand,
              children: [
                Container(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  child: bot.account.profile.background != null
                      ? CloudFileWidget(
                          item: bot.account.profile.background!,
                          fit: BoxFit.cover,
                        )
                      : const SizedBox.shrink(),
                ),
                Positioned(
                  left: 20,
                  bottom: -32,
                  child: ProfilePictureWidget(
                    file: bot.account.profile.picture,
                    radius: 40,
                    fallbackIcon: Symbols.smart_toy,
                  ),
                ),
              ],
            ),
          ).padding(bottom: 32),
          ListTile(title: Text('name'.tr()), subtitle: Text(bot.account.name)),
          ListTile(
            title: Text('nickname'.tr()),
            subtitle: Text(bot.account.nick),
          ),
          ListTile(title: Text('slug'.tr()), subtitle: Text(bot.slug)),
          if (bot.account.profile.bio.isNotEmpty)
            ListTile(
              title: Text('bio'.tr()),
              subtitle: Text(bot.account.profile.bio),
            ),
        ],
      ).padding(bottom: 24),
    );
  }
}
