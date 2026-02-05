import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/developers/developers/app_secrets.dart';
import 'package:island/developers/developers/apps.dart';
import 'package:island/developers/developers_models/custom_app.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/drive/drive_widgets/cloud_files.dart';
import 'package:island/shared/widgets/response.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

class AppDetailScreen extends HookConsumerWidget {
  final String publisherName;
  final String projectId;
  final String appId;

  const AppDetailScreen({
    super.key,
    required this.publisherName,
    required this.projectId,
    required this.appId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabController = useTabController(initialLength: 2);
    final appData = ref.watch(
      customAppProvider(publisherName, projectId, appId),
    );

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(
        title: Text(appData.value?.name ?? 'appDetails'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Symbols.edit),
            onPressed: appData.value == null
                ? null
                : () {
                    context.pushNamed(
                      'developerAppEdit',
                      pathParameters: {
                        'name': publisherName,
                        'projectId': projectId,
                        'id': appId,
                      },
                    );
                  },
          ),
          const Gap(8),
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
                'secrets'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).appBarTheme.foregroundColor!,
                ),
              ),
            ),
          ],
        ),
      ),
      body: appData.when(
        data: (app) {
          return TabBarView(
            controller: tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: _AppOverview(app: app),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: AppSecretsScreen(
                    publisherName: publisherName,
                    projectId: projectId,
                    appId: appId,
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => ResponseErrorWidget(
          error: err,
          onRetry: () => ref.invalidate(
            customAppProvider(publisherName, projectId, appId),
          ),
        ),
      ),
    );
  }
}

class _AppOverview extends StatelessWidget {
  final CustomApp app;
  const _AppOverview({required this.app});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.zero,
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
                  child: app.background != null
                      ? CloudFileWidget(
                          item: app.background!,
                          fit: BoxFit.cover,
                        )
                      : const SizedBox.shrink(),
                ),
                Positioned(
                  left: 20,
                  bottom: -32,
                  child: ProfilePictureWidget(
                    file: app.picture,
                    radius: 40,
                    fallbackIcon: Symbols.apps,
                  ),
                ),
              ],
            ),
          ).padding(bottom: 32),
          ListTile(title: Text('name'.tr()), subtitle: Text(app.name)),
          ListTile(title: Text('slug'.tr()), subtitle: Text(app.slug)),
          if (app.description?.isNotEmpty ?? false)
            ListTile(
              title: Text('description'.tr()),
              subtitle: Text(app.description!),
            ),
        ],
      ).padding(bottom: 24),
    );
  }
}
