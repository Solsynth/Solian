import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:provider/provider.dart';
import 'package:relative_time/relative_time.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/types/news.dart';
import 'package:surface/widgets/dialog.dart';
import 'package:surface/widgets/html.dart';
import 'package:surface/widgets/navigation/app_scaffold.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher_string.dart';

class NewsDetailScreen extends StatefulWidget {
  final String hash;

  const NewsDetailScreen({super.key, required this.hash});

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  SnNewsArticle? _article;
  dom.Document? _articleFragment;

  Future<void> _fetchArticle() async {
    try {
      final sn = context.read<SnNetworkProvider>();
      final resp = await sn.client.get('/cgi/re/news/${widget.hash}');
      _article = SnNewsArticle.fromJson(resp.data);
      _articleFragment = parse(_article!.content);
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err).then((_) {
        if (!mounted) return;
        Navigator.pop(context);
      });
    } finally {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchArticle();
  }

  bool _isReadingFromReader = true;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        leading: const PageBackButton(),
        title: Text(_article?.title ?? 'loading'.tr()),
      ),
      body: Column(
        children: [
          MaterialBanner(
            dividerColor: Colors.transparent,
            leading: const Icon(Icons.info),
            content: Text(_isReadingFromReader
                ? 'newsReadingFromReader'.tr()
                : 'newsReadingFromOriginal'.tr()),
            actions: [
              TextButton(
                child: Text('newsReadingProviderSwap').tr(),
                onPressed: () {
                  setState(() => _isReadingFromReader = !_isReadingFromReader);
                },
              ),
            ],
          ),
          if (_articleFragment != null && _isReadingFromReader)
            Expanded(
              child: Container(
                constraints: BoxConstraints(maxWidth: 640),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      Text(_article!.title,
                          style: Theme.of(context).textTheme.titleLarge),
                      Builder(builder: (context) {
                        final htmlDescription = parse(_article!.description);
                        return Text(
                          htmlDescription.children
                              .map((ele) => ele.text.trim())
                              .join(),
                          style: Theme.of(context).textTheme.bodyMedium,
                        );
                      }),
                      Builder(builder: (context) {
                        final date =
                            _article!.publishedAt ?? _article!.createdAt;
                        return Row(
                          spacing: 2,
                          children: [
                            Text(DateFormat().format(date)).textStyle(
                                Theme.of(context).textTheme.bodySmall!),
                            Text(' · ')
                                .textStyle(
                                    Theme.of(context).textTheme.bodySmall!)
                                .bold(),
                            Text(RelativeTime(context).format(date)).textStyle(
                                Theme.of(context).textTheme.bodySmall!),
                          ],
                        ).opacity(0.75);
                      }),
                      Text('newsDisclaimer')
                          .tr()
                          .textStyle(Theme.of(context).textTheme.bodySmall!)
                          .opacity(0.75),
                      const Divider(),
                      ...parseHtmlToWidgets(
                          context, _articleFragment!.children),
                      const Divider(),
                      InkWell(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Reference from original website',
                              style: TextStyle(
                                  decoration: TextDecoration.underline),
                            ),
                            const Gap(4),
                            Icon(Icons.launch, size: 16),
                          ],
                        ).opacity(0.85),
                        onTap: () {
                          launchUrlString(_article!.url);
                        },
                      ),
                      Gap(MediaQuery.of(context).padding.bottom),
                    ],
                  ).padding(horizontal: 12, vertical: 16),
                ),
              ).center(),
            )
          else if (_article != null)
            Expanded(
              child: InAppWebView(
                key: GlobalKey(),
                initialUrlRequest: URLRequest(url: WebUri(_article!.url)),
              ),
            ),
        ],
      ),
    );
  }
}
