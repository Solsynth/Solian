import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
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
    final tabController = useTabController(initialLength: 2);

    return AppScaffold(
      appBar: AppBar(
        title: Text('projectDetails').tr(),
        actions: [
          IconButton(
            icon: const Icon(Symbols.add),
            onPressed: () {
              // Get current tab index
              final index = tabController.index;
              switch (index) {
                case 0:
                  context.pushNamed(
                    'developerAppNew',
                    pathParameters: {
                      'name': publisherName,
                      'projectId': projectId,
                    },
                  );
                  break;
                case 1:
                  context.pushNamed(
                    'developerBotNew',
                    pathParameters: {
                      'name': publisherName,
                      'projectId': projectId,
                    },
                  );
                  break;
              }
            },
          ),
          const Gap(8),
        ],
        bottom: TabBar(
          controller: tabController,
          tabs: [
            Tab(
              child: Text(
                'customApps'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).appBarTheme.foregroundColor!,
                ),
              ),
            ),
            Tab(
              child: Text(
                'bots'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).appBarTheme.foregroundColor!,
                ),
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          CustomAppsScreen(publisherName: publisherName, projectId: projectId),
          BotsScreen(publisherName: publisherName, projectId: projectId),
        ],
      ),
    );
  }
}
