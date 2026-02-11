import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/developers/screens/hub.dart';
import 'package:island/developers/models/dev_project.dart';
import 'package:island/core/network.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/response.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';

part 'edit_project.g.dart';

@riverpod
Future<DevProject?> devProject(Ref ref, String pubName, String id) async {
  final client = ref.watch(apiClientProvider);
  final resp = await client.get('/develop/developers/$pubName/projects/$id');
  return DevProject.fromJson(resp.data);
}

@RoutePage()
class DeveloperProjectEditScreen extends HookConsumerWidget {
  final String pubName;
  final String? id;
  const DeveloperProjectEditScreen({super.key, required this.pubName, this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isNew = id == null;
    final projectData = isNew
        ? null
        : ref.watch(devProjectProvider(pubName, id!));

    final formKey = useMemoized(() => GlobalKey<FormState>());
    final submitting = useState(false);

    final nameController = useTextEditingController();
    final slugController = useTextEditingController();
    final descriptionController = useTextEditingController();

    useEffect(() {
      if (projectData?.value != null) {
        nameController.text = projectData!.value!.name;
        slugController.text = projectData.value!.slug;
        descriptionController.text = projectData.value!.description ?? '';
      }
      return null;
    }, [projectData]);

    void performAction() async {
      final client = ref.read(apiClientProvider);
      final data = {
        'name': nameController.text,
        'slug': slugController.text,
        'description': descriptionController.text,
      };
      if (isNew) {
        await client.post('/develop/developers/$pubName/projects', data: data);
      } else {
        await client.put(
          '/develop/developers/$pubName/projects/$id',
          data: data,
        );
      }
      ref.invalidate(devProjectsProvider(pubName));
      if (context.mounted) {
        context.pop();
      }
    }

    return AppScaffold(
      appBar: AppBar(
        leading: const PageBackButton(backTo: '/developers'),
        title: Text(isNew ? 'createProject'.tr() : 'editProject'.tr()),
      ),
      body: projectData == null && !isNew
          ? const Center(child: CircularProgressIndicator())
          : projectData?.hasError == true && !isNew
          ? ResponseErrorWidget(
              error: projectData!.error,
              onRetry: () => ref.invalidate(devProjectProvider(pubName, id!)),
            )
          : SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'name'.tr()),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: slugController,
                      decoration: InputDecoration(
                        labelText: 'slug'.tr(),
                        helperText: 'slugHint'.tr(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'description'.tr(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: submitting.value ? null : performAction,
                        label: Text('saveChanges'.tr()),
                        icon: const Icon(Symbols.save),
                      ),
                    ),
                  ],
                ).padding(all: 24),
              ),
            ),
    );
  }
}
