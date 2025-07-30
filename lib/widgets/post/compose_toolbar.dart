import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../models/post.dart';
import '../../models/file.dart';
import '../../services/compose_storage_db.dart';
import '../../widgets/post/draft_manager.dart';

class ComposeToolbar extends StatelessWidget {
  final WidgetRef ref;
  final BuildContext context;
  final ColorScheme colorScheme;
  final SnPost? originalPost;
  final bool isEmpty;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController contentController;
  final ValueNotifier<int> visibility;
  final ValueNotifier<List<UniversalFile>> attachments;

  const ComposeToolbar({
    super.key,
    required this.ref,
    required this.context,
    required this.colorScheme,
    required this.isEmpty,
    required this.titleController,
    required this.descriptionController,
    required this.contentController,
    required this.visibility,
    required this.attachments,
    this.originalPost,
  });

  void _pickPhotoMedia() {
    // TODO: Implement photo picking logic
  }

  void _pickVideoMedia() {
    // TODO: Implement video picking logic
  }

  void _linkAttachment() {
    // TODO: Implement link attachment logic
  }

  void _saveDraft() {
    // TODO: Implement draft saving logic
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Row(
            children: [
              IconButton(
                onPressed: _pickPhotoMedia,
                tooltip: 'addPhoto'.tr(),
                icon: const Icon(Symbols.add_a_photo),
                color: colorScheme.primary,
              ),
              IconButton(
                onPressed: _pickVideoMedia,
                tooltip: 'addVideo'.tr(),
                icon: const Icon(Symbols.videocam),
                color: colorScheme.primary,
              ),
              IconButton(
                onPressed: _linkAttachment,
                icon: const Icon(Symbols.attach_file),
                tooltip: 'linkAttachment'.tr(),
                color: colorScheme.primary,
              ),
              const Spacer(),
              if (originalPost == null && isEmpty)
                IconButton(
                  icon: const Icon(Symbols.draft),
                  color: colorScheme.primary,
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder:
                          (context) => DraftManagerSheet(
                            onDraftSelected: (draftId) {
                              final draft =
                                  ref.read(
                                    composeStorageNotifierProvider,
                                  )[draftId];
                              if (draft != null) {
                                titleController.text = draft.title ?? '';
                                descriptionController.text =
                                    draft.description ?? '';
                                contentController.text = draft.content ?? '';
                                visibility.value = draft.visibility;
                              }
                            },
                          ),
                    );
                  },
                  tooltip: 'drafts'.tr(),
                )
              else if (originalPost == null)
                IconButton(
                  icon: const Icon(Symbols.save),
                  color: colorScheme.primary,
                  onPressed: _saveDraft,
                  tooltip: 'saveDraft'.tr(),
                ),
            ],
          ).padding(
            bottom: MediaQuery.of(context).padding.bottom + 16,
            horizontal: 16,
            top: 8,
          ),
        ),
      ),
    );
  }
}
