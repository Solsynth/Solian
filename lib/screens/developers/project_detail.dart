
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/screens/developers/apps.dart';
import 'package:island/screens/developers/bots.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';

class ProjectDetailScreen extends HookConsumerWidget {
  final String publisherName;
  final String projectId;

  const ProjectDetailScreen({
    super.key,
    required this.publisherName,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: AppScaffold(
        appBar: AppBar(
          title: Text('projectDetails').tr(),
          actions: [
            IconButton(
              icon: const Icon(Symbols.add),
              onPressed: () {
                // Get current tab index
                final tabController = DefaultTabController.of(context);
                final index = tabController.index;
                if (index == 0) {
                  context.pushNamed(
                    'developerAppNew',
                    pathParameters: {
                      'name': publisherName,
                      'projectId': projectId
                    },
                  );
                } else {
                  context.pushNamed(
                    'developerBotNew',
                    pathParameters: {
                      'name': publisherName,
                      'projectId': projectId
                    },
                  );
                }
              },
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: 'customApps'.tr()),
              Tab(text: 'bots'.tr()),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            CustomAppsScreen(publisherName: publisherName, projectId: projectId),
            BotsScreen(publisherName: publisherName, projectId: projectId),
          ],
        ),
      ),
    );
  }
}
