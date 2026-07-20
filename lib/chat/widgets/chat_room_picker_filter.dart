import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

enum ChatRoomPickerFilter { all, direct, group }

class ChatRoomPickerSearchBar extends StatelessWidget {
  const ChatRoomPickerSearchBar({super.key, required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: SearchBar(
        padding: WidgetStatePropertyAll(
          const EdgeInsets.symmetric(horizontal: 24),
        ),
        leading: const Icon(Symbols.search),
        hintText: 'search'.tr(),
        onChanged: onChanged,
      ),
    );
  }
}

class ChatRoomPickerFilterBar extends StatelessWidget {
  const ChatRoomPickerFilterBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final ChatRoomPickerFilter selected;
  final ValueChanged<ChatRoomPickerFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: SegmentedButton<ChatRoomPickerFilter>(
        segments: [
          ButtonSegment(
            value: ChatRoomPickerFilter.all,
            icon: const Icon(Symbols.forum),
            label: Text('chatTabAll'.tr()),
          ),
          ButtonSegment(
            value: ChatRoomPickerFilter.direct,
            icon: const Icon(Symbols.person),
            label: Text('chatTabDirect'.tr()),
          ),
          ButtonSegment(
            value: ChatRoomPickerFilter.group,
            icon: const Icon(Symbols.group),
            label: Text('chatTabGroup'.tr()),
          ),
        ],
        selected: {selected},
        showSelectedIcon: false,
        onSelectionChanged: (selection) => onSelected(selection.first),
      ),
    );
  }
}
