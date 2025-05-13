import 'package:auto_route/annotations.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/post.dart';
import 'package:island/pods/network.dart';
import 'package:island/widgets/account/status.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:island/widgets/post/post_list.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';

part 'pub_profile.g.dart';

@riverpod
Future<SnPublisher> publisher(Ref ref, String uname) async {
  final apiClient = ref.watch(apiClientProvider);
  final resp = await apiClient.get("/publishers/$uname");
  return SnPublisher.fromJson(resp.data);
}

@RoutePage()
class PublisherProfileScreen extends HookConsumerWidget {
  final String name;
  const PublisherProfileScreen({
    super.key,
    @PathParam("name") required this.name,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final publisher = ref.watch(publisherProvider(name));

    final iconShadow = Shadow(
      color: Colors.black54,
      blurRadius: 5.0,
      offset: Offset(1.0, 1.0),
    );

    return publisher.when(
      data:
          (data) => AppScaffold(
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 180,
                  pinned: true,
                  leading: PageBackButton(shadows: [iconShadow]),
                  flexibleSpace: FlexibleSpaceBar(
                    background:
                        data.backgroundId != null
                            ? CloudImageWidget(fileId: data.backgroundId!)
                            : Container(
                              color:
                                  Theme.of(context).appBarTheme.backgroundColor,
                            ),
                    title: Text(
                      data.nick,
                      style: TextStyle(
                        color: Theme.of(context).appBarTheme.foregroundColor,
                        shadows: [iconShadow],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 20,
                    children: [
                      ProfilePictureWidget(fileId: data.pictureId!, radius: 32),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              spacing: 6,
                              children: [
                                Text(data.nick).fontSize(20),
                                Text(
                                  '@${data.name}',
                                ).fontSize(14).opacity(0.85),
                              ],
                            ),
                            if (data.publisherType == 0)
                              AccountStatusWidget(
                                uname: name,
                                padding: EdgeInsets.zero,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ).padding(horizontal: 24, top: 24, bottom: 24),
                ),
                // if (data.badges.isNotEmpty)
                //   SliverToBoxAdapter(
                //     child: BadgeList(
                //       badges: data.badges,
                //     ).padding(horizontal: 24, bottom: 24),
                //   )
                // else
                //   const Gap(16),
                SliverToBoxAdapter(child: const Divider(height: 1)),
                if (data.bio.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [Text('bio').tr().bold(), Text(data.bio)],
                    ).padding(horizontal: 24, top: 24),
                  ),
                if (data.bio.isNotEmpty)
                  SliverToBoxAdapter(
                    child: const Divider(height: 1).padding(top: 24),
                  ),
                SliverPostList(pubName: name),
                SliverGap(MediaQuery.of(context).padding.bottom + 16),
              ],
            ),
          ),
      error:
          (error, stackTrace) => AppScaffold(
            appBar: AppBar(leading: const PageBackButton()),
            body: Center(child: Text(error.toString())),
          ),
      loading:
          () => AppScaffold(
            appBar: AppBar(leading: const PageBackButton()),
            body: Center(child: CircularProgressIndicator()),
          ),
    );
  }
}
