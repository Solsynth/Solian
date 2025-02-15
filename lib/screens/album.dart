import 'package:dismissible_page/dismissible_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/providers/user_directory.dart';
import 'package:surface/types/attachment.dart';
import 'package:surface/widgets/app_bar_leading.dart';
import 'package:surface/widgets/attachment/attachment_zoom.dart';
import 'package:surface/widgets/attachment/attachment_item.dart';
import 'package:surface/widgets/dialog.dart';
import 'package:surface/widgets/navigation/app_scaffold.dart';
import 'package:uuid/uuid.dart';

class AlbumScreen extends StatefulWidget {
  const AlbumScreen({super.key});

  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  final ScrollController _scrollController = ScrollController();

  bool _isBusy = false;
  int? _totalCount;

  final List<SnAttachment> _attachments = List.empty(growable: true);
  final List<String> _heroTags = List.empty(growable: true);

  Future<void> _fetchAttachments() async {
    setState(() => _isBusy = true);

    const uuid = Uuid();

    try {
      final sn = context.read<SnNetworkProvider>();
      final ud = context.read<UserDirectoryProvider>();
      final resp = await sn.client.get('/cgi/uc/attachments', queryParameters: {
        'take': 10,
        'offset': _attachments.length,
      });
      final attachments = List<SnAttachment>.from(
        resp.data['data']?.map((e) => SnAttachment.fromJson(e)) ?? [],
      ).where((e) => e.mimetype.startsWith('image')).toList();
      _attachments.addAll(attachments);
      _heroTags.addAll(_attachments.map((_) => uuid.v4()));

      await ud.listAccount(attachments.map((e) => e.accountId).toSet());

      _totalCount = resp.data['count'] as int?;
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    } finally {
      setState(() => _isBusy = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchAttachments();
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge) {
        bool isTop = _scrollController.position.pixels == 0;
        if (!isTop && !_isBusy) {
          if (_totalCount == null || _attachments.length < _totalCount!) {
            _fetchAttachments();
          }
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            leading: AutoAppBarLeading(),
            title: Text('screenAlbum').tr(),
          ),
          SliverMasonryGrid.extent(
            childCount: _attachments.length,
            maxCrossAxisExtent: 320,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            itemBuilder: (context, idx) {
              final attachment = _attachments[idx];
              return GestureDetector(
                child: ClipRRect(
                  child: AspectRatio(
                    aspectRatio: attachment.metadata['ratio']?.toDouble() ?? 1,
                    child: AttachmentItem(
                      data: attachment,
                      heroTag: _heroTags[idx],
                    ),
                  ),
                ),
                onTap: () {
                  context.pushTransparentRoute(
                    AttachmentZoomView(
                      data: [attachment],
                      heroTags: [_heroTags[idx]],
                    ),
                    backgroundColor: Colors.black.withOpacity(0.7),
                    rootNavigator: true,
                  );
                },
              );
            },
          ),
          if (_isBusy)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: const CircularProgressIndicator(),
              ).center(),
            ),
        ],
      ),
    );
  }
}
