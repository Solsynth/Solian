import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/custom_app.dart';
import 'package:island/pods/network.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/response.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'apps.g.dart';

@riverpod
Future<List<CustomApp>> customApps(Ref ref, String publisherName) async {
  final client = ref.watch(apiClientProvider);
  final resp = await client.get('/developers/$publisherName/apps');
  return resp.data.map((e) => CustomApp.fromJson(e)).cast<CustomApp>().toList();
}

class CustomAppsScreen extends HookConsumerWidget {
  final String publisherName;
  const CustomAppsScreen({super.key, required this.publisherName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apps = ref.watch(customAppsProvider(publisherName));

    return AppScaffold(
      appBar: AppBar(title: Text('customApps').tr()),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Symbols.add),
        onPressed: () {
          context.push('/developers/$publisherName/apps/new');
        },
      ),
      body: apps.when(
        data: (data) {
          if (data.isEmpty) {
            return Center(child: Text('noCustomApps').tr());
          }
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final app = data[index];
              return ListTile(
                title: Text(app.name),
                subtitle: Text(app.slug),
                onTap: () {
                  context.push('/developers/$publisherName/apps/${app.id}');
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (err, stack) => ResponseErrorWidget(
              error: err,
              onRetry: () => ref.invalidate(customAppsProvider(publisherName)),
            ),
      ),
    );
  }
}
