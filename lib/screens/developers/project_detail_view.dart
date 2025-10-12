import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/dev_project.dart';
import 'package:island/screens/developers/apps.dart';
import 'package:island/screens/developers/bots.dart';
import 'package:island/services/responsive.dart';

class ProjectDetailView extends HookConsumerWidget {
  final String publisherName;
  final DevProject project;
  final VoidCallback onBackToHub;

  const ProjectDetailView({
    super.key,
    required this.publisherName,
    required this.project,
    required this.onBackToHub,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabController = useTabController(initialLength: 2);

    final isWide = isWideScreen(context);

    if (isWide) {
      return Row(
        spacing: 8,
        children: [
          Card(
            margin: const EdgeInsets.only(left: 16, bottom: 16, top: 12),
            child: Transform.translate(
              offset: const Offset(0, -56),
              child: NavigationRail(
                extended: isWiderScreen(context),
                scrollable: true,
                labelType:
                    isWiderScreen(context)
                        ? null
                        : NavigationRailLabelType.selected,
                backgroundColor: Colors.transparent,
                selectedIndex: tabController.index,
                onDestinationSelected:
                    (index) => tabController.animateTo(index),
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.apps),
                    label: Text('customApps'.tr()),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.smart_toy),
                    label: Text('bots'.tr()),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                CustomAppsScreen(
                  publisherName: publisherName,
                  projectId: project.id,
                ),
                BotsScreen(publisherName: publisherName, projectId: project.id),
              ],
            ),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          TabBar(
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
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                CustomAppsScreen(
                  publisherName: publisherName,
                  projectId: project.id,
                ),
                BotsScreen(publisherName: publisherName, projectId: project.id),
              ],
            ),
          ),
        ],
      );
    }
  }
}
