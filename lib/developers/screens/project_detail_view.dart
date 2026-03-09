import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/developers/screens/apps.dart';
import 'package:island/developers/screens/bots.dart';
import 'package:island/developers/models/dev_project.dart';
import 'package:styled_widget/styled_widget.dart';

class ProjectDetailView extends HookConsumerWidget {
  final String publisherName;
  final SnDevProject project;
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

    return Column(
      children: [
        Container(
          color: Theme.of(context).colorScheme.surface,
          child: TabBar(
            dividerColor: Colors.transparent,
            controller: tabController,
            tabs: [
              Tab(child: Text('customApps'.tr(), textAlign: TextAlign.center)),
              Tab(child: Text('bots'.tr(), textAlign: TextAlign.center)),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: [
              DeveloperAppListScreen(
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
