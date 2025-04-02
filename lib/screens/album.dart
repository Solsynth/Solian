import 'package:dismissible_page/dismissible_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path/path.dart' show withoutExtension;
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/providers/userinfo.dart';
import 'package:surface/types/attachment.dart';
import 'package:surface/widgets/attachment/attachment_item.dart';
import 'package:surface/widgets/attachment/attachment_zoom.dart';
import 'package:surface/widgets/dialog.dart';
import 'package:surface/widgets/navigation/app_scaffold.dart';
import 'package:uuid/uuid.dart';
import 'package:very_good_infinite_list/very_good_infinite_list.dart';

class AlbumScreen extends StatefulWidget {
  const AlbumScreen({super.key});

  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  final ScrollController _scrollController = ScrollController();

  bool _isBusy = false;
  int? _totalCount;

  SnAttachmentBilling? _billing;

  final List<SnAttachment> _attachments = List.empty(growable: true);
  final List<String> _heroTags = List.empty(growable: true);

  Future<void> _fetchBillingStatus() async {
    try {
      final sn = context.read<SnNetworkProvider>();
      final resp = await sn.client.get('/cgi/uc/billing');
      final out = SnAttachmentBilling.fromJson(resp.data);
      setState(() => _billing = out);
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    }
  }

  Future<void> _fetchAttachments() async {
    setState(() => _isBusy = true);

    final ua = context.read<UserProvider>();

    const uuid = Uuid();

    try {
      final sn = context.read<SnNetworkProvider>();
      final resp = await sn.client.get('/cgi/uc/attachments', queryParameters: {
        'take': 10,
        'offset': _attachments.length,
        'author': ua.user?.name,
      });
      final attachments = List<SnAttachment>.from(
        resp.data['data']?.map((e) => SnAttachment.fromJson(e)) ?? [],
      );
      _attachments.addAll(attachments);
      _heroTags.addAll(_attachments.map((_) => uuid.v4()));

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
    _fetchBillingStatus();
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
      appBar: AppBar(
        leading: PageBackButton(),
        title: Text('screenAlbum').tr(),
      ),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: _billing?.includedRatio ?? 0,
                    strokeWidth: 8,
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainerHigh,
                  ),
                ).padding(all: 12),
                const Gap(24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('attachmentBillingUploaded').tr().bold(),
                      Text(
                        (_billing?.currentBytes ?? 0).formatBytes(decimals: 4),
                        style: GoogleFonts.robotoMono(),
                      ),
                      Text('attachmentBillingDiscount').tr().bold(),
                      Text(
                        '${(_billing?.discountFileSize ?? 0).formatBytes(decimals: 2)} · ${((_billing?.includedRatio ?? 0) * 100).toStringAsFixed(2)}%',
                        style: GoogleFonts.robotoMono(),
                      ),
                    ],
                  ),
                ),
                Tooltip(
                  message: 'attachmentBillingHint'.tr(),
                  child: IconButton(
                    icon: const Icon(Symbols.info),
                    onPressed: () {},
                  ),
                ),
              ],
            ).padding(horizontal: 24, vertical: 8),
          ).padding(horizontal: 8, top: 8),
          Expanded(
            child: InfiniteList(
              padding: EdgeInsets.only(top: 8),
              itemCount: _attachments.length,
              isLoading: _isBusy,
              hasReachedMax:
                  _totalCount != null && _attachments.length >= _totalCount!,
              onFetchData: _fetchAttachments,
              itemBuilder: (context, index) {
                final ele = _attachments[index];
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      child: AspectRatio(
                        aspectRatio: (ele.data['ratio'] ?? 1).toDouble(),
                        child: AttachmentItem(
                          data: ele,
                          heroTag: _heroTags[index],
                          onZoom: () {
                            context.pushTransparentRoute(
                              AttachmentZoomView(
                                data: [ele],
                              ),
                              backgroundColor: Colors.black.withOpacity(0.7),
                              rootNavigator: true,
                            );
                          },
                        ),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ele.name),
                              if (ele.alt != withoutExtension(ele.name))
                                Text(ele.alt),
                              Text(DateFormat().format(ele.createdAt)),
                              const Gap(4),
                              Text(ele.size.formatBytes()).fontSize(12),
                            ],
                          ).padding(horizontal: 16, vertical: 12),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 12, right: 12, top: 4),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Symbols.info),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) => AttachmentZoomDetailPopup(
                                  data: ele,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
              separatorBuilder: (_, __) => const Gap(8),
            ),
          )
        ],
      ),
    );
  }
}
