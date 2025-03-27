import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/providers/userinfo.dart';
import 'package:surface/types/post.dart';
import 'package:surface/widgets/account/account_image.dart';
import 'package:surface/widgets/dialog.dart';
import 'package:surface/widgets/loading_indicator.dart';
import 'package:surface/widgets/navigation/app_scaffold.dart';

class PublisherScreen extends StatefulWidget {
  const PublisherScreen({super.key});

  @override
  State<PublisherScreen> createState() => _PublisherScreenState();
}

class _PublisherScreenState extends State<PublisherScreen> {
  bool _isBusy = false;

  final List<SnPublisher> _publishers = List<SnPublisher>.empty(growable: true);

  Future<void> _fetchPublishers() async {
    final sn = context.read<SnNetworkProvider>();
    final ua = context.read<UserProvider>();
    if (!ua.isAuthorized) return;

    setState(() => _isBusy = true);

    try {
      final resp = await sn.client.get('/cgi/co/publishers/me');
      final List<SnPublisher> out = List<SnPublisher>.from(
          resp.data?.map((e) => SnPublisher.fromJson(e)) ?? []);

      if (!mounted) return;

      _publishers.addAll(out);
    } catch (err) {
      context.showErrorDialog(err);
    } finally {
      setState(() => _isBusy = false);
    }
  }

  Future<void> _deletePublisher(SnPublisher publisher) async {
    final confirm = await context.showConfirmDialog(
      'publisherDelete'.tr(args: ['#${publisher.name}']),
      'publisherDeleteDescription'.tr(),
    );
    if (!confirm) return;

    if (!mounted) return;
    setState(() => _isBusy = true);

    try {
      await context
          .read<SnNetworkProvider>()
          .client
          .delete('/cgi/co/publishers/${publisher.name}');
      if (!mounted) return;
      context.showSnackbar('publisherDeleted'.tr(args: ['#${publisher.name}']));
      _publishers.remove(publisher);
      _fetchPublishers();
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
    _fetchPublishers();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      noBackground: true,
      appBar: AppBar(
        leading: const PageBackButton(),
        title: Text('screenAccountPublishers').tr(),
      ),
      body: Column(
        children: [
          ListTile(
            title: Text('publishersNew').tr(),
            subtitle: Text('publisherNewSubtitle').tr(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            leading: const Icon(Symbols.add_circle),
            onTap: () {
              GoRouter.of(context)
                  .pushNamed('accountPublisherNew')
                  .then((value) {
                if (value == true) {
                  _publishers.clear();
                  _fetchPublishers();
                }
              });
            },
          ),
          const Divider(height: 1),
          LoadingIndicator(isActive: _isBusy),
          Expanded(
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: RefreshIndicator(
                onRefresh: () {
                  _publishers.clear();
                  return _fetchPublishers();
                },
                child: ListView.builder(
                  itemCount: _publishers.length,
                  itemBuilder: (context, idx) {
                    final publisher = _publishers[idx];
                    return ListTile(
                      title: Text(publisher.nick),
                      subtitle: Text('@${publisher.name}'),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      leading: AccountImage(content: publisher.avatar),
                      trailing: PopupMenuButton(
                        itemBuilder: (BuildContext context) => [
                          PopupMenuItem(
                            child: Row(
                              children: [
                                const Icon(Symbols.edit),
                                const Gap(16),
                                Text('edit').tr(),
                              ],
                            ),
                            onTap: () {
                              GoRouter.of(context).pushNamed(
                                'accountPublisherEdit',
                                pathParameters: {
                                  'name': publisher.name,
                                },
                              ).then((value) {
                                if (value == true) {
                                  _publishers.clear();
                                  _fetchPublishers();
                                }
                              });
                            },
                          ),
                          PopupMenuItem(
                            child: Row(
                              children: [
                                const Icon(Symbols.delete),
                                const Gap(16),
                                Text('delete').tr(),
                              ],
                            ),
                            onTap: () {
                              _deletePublisher(publisher);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
