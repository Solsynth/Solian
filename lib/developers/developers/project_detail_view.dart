import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/developers/developers/apps.dart';
import 'package:island/developers/developers/bots.dart';
import 'package:island/developers/developers_models/dev_project.dart';
import 'package:island/core/services/responsive.dart';
import 'package:styled_widget/styled_widget.dart';

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
    final currentDest = useState(0);

    useEffect(() {
      tabController.addListener(() {
        if (tabController.indexIsChanging) {
          currentDest.value = tabController.index;
        }
      });
      return null;
    });

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
                labelType: isWiderScreen(context)
                    ? null
                    : NavigationRailLabelType.selected,
                backgroundColor: Colors.transparent,
                selectedIndex: currentDest.value,
                onDestinationSelected: (index) =>
                    tabController.animateTo(index),
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
                leading: Container(
                  width: isWiderScreen(context) ? 256 : 80,
                  padding: const EdgeInsets.only(
                    left: 24,
                    right: 24,
                    bottom: 8,
                    top: 2,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.12),
                      ),
                    ),
                  ),
                  child: Row(
                    spacing: 8,
                    children: [
                      IconButton(
                        onPressed: onBackToHub,
                        icon: const Icon(Icons.arrow_back),
                        iconSize: 16,
                        visualDensity: VisualDensity.compact,
                      ),
                      if (isWiderScreen(context))
                        Expanded(child: Text("backToHub").tr()),
                    ],
                  ),
                ),
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
          const Gap(4),
        ],
      );
    } else {
      return Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.surface,
            child: TabBar(
              dividerColor: Colors.transparent,
              controller: tabController,
              tabs: [
                Tab(
                  child: Text('customApps'.tr(), textAlign: TextAlign.center),
                ),
                Tab(child: Text('bots'.tr(), textAlign: TextAlign.center)),
              ],
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
            ).padding(horizontal: 8),
          ),
        ],
      );
    }
  }
}
