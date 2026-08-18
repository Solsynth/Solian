import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Structured drive list filters — no key:value advanced-search syntax.
@immutable
class DriveFileFilters {
  /// `null` = all, `true` = folders only, `false` = files only.
  final bool? isFolder;

  /// High-level media kind mapped to `content_type` prefixes.
  final DriveMediaKind? mediaKind;

  final String? extension;
  final DateTime? createdAfter;
  final DateTime? createdBefore;
  final String order;
  final bool orderDesc;

  const DriveFileFilters({
    this.isFolder,
    this.mediaKind,
    this.extension,
    this.createdAfter,
    this.createdBefore,
    this.order = 'date',
    this.orderDesc = true,
  });

  static const empty = DriveFileFilters();

  /// Filters that count toward the badge (excludes default sort).
  int get activeCount {
    return [
      isFolder != null,
      mediaKind != null,
      extension != null && extension!.trim().isNotEmpty,
      createdAfter != null,
      createdBefore != null,
    ].where((v) => v).length;
  }

  bool get hasActiveFilters => activeCount > 0;

  String? get contentTypeParam => switch (mediaKind) {
    DriveMediaKind.image => 'image/',
    DriveMediaKind.video => 'video/',
    DriveMediaKind.audio => 'audio/',
    DriveMediaKind.document => 'application/',
    null => null,
  };

  String? get extensionParam {
    final raw = extension?.trim();
    if (raw == null || raw.isEmpty) return null;
    return raw.startsWith('.') ? raw.substring(1) : raw;
  }

  String? get createdAfterParam => createdAfter == null
      ? null
      : DateFormat('yyyy-MM-dd').format(createdAfter!);

  String? get createdBeforeParam => createdBefore == null
      ? null
      : DateFormat('yyyy-MM-dd').format(createdBefore!);

  DriveFileFilters copyWith({
    bool? isFolder,
    bool clearIsFolder = false,
    DriveMediaKind? mediaKind,
    bool clearMediaKind = false,
    String? extension,
    bool clearExtension = false,
    DateTime? createdAfter,
    bool clearCreatedAfter = false,
    DateTime? createdBefore,
    bool clearCreatedBefore = false,
    String? order,
    bool? orderDesc,
  }) {
    return DriveFileFilters(
      isFolder: clearIsFolder ? null : (isFolder ?? this.isFolder),
      mediaKind: clearMediaKind ? null : (mediaKind ?? this.mediaKind),
      extension: clearExtension ? null : (extension ?? this.extension),
      createdAfter: clearCreatedAfter
          ? null
          : (createdAfter ?? this.createdAfter),
      createdBefore: clearCreatedBefore
          ? null
          : (createdBefore ?? this.createdBefore),
      order: order ?? this.order,
      orderDesc: orderDesc ?? this.orderDesc,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriveFileFilters &&
          isFolder == other.isFolder &&
          mediaKind == other.mediaKind &&
          extension == other.extension &&
          createdAfter == other.createdAfter &&
          createdBefore == other.createdBefore &&
          order == other.order &&
          orderDesc == other.orderDesc;

  @override
  int get hashCode => Object.hash(
    isFolder,
    mediaKind,
    extension,
    createdAfter,
    createdBefore,
    order,
    orderDesc,
  );
}

enum DriveMediaKind { image, video, audio, document }

class DriveFilterBar extends HookWidget {
  final DriveFileFilters filters;
  final ValueChanged<DriveFileFilters> onChanged;
  final Future<void> Function() onRefresh;
  final bool enabled;

  const DriveFilterBar({
    super.key,
    required this.filters,
    required this.onChanged,
    required this.onRefresh,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final showAdvanced = useState(filters.hasActiveFilters);
    final extensionController = useTextEditingController(
      text: filters.extension ?? '',
    );

    useEffect(() {
      final next = filters.extension ?? '';
      if (extensionController.text != next) {
        extensionController.text = next;
      }
      return null;
    }, [filters.extension]);

    Future<void> pickDate({required bool isStart}) async {
      final current = isStart ? filters.createdAfter : filters.createdBefore;
      final picked = await showDatePicker(
        context: context,
        initialDate: current ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime.now().add(const Duration(days: 365)),
      );
      if (picked == null) return;
      onChanged(
        isStart
            ? filters.copyWith(createdAfter: picked)
            : filters.copyWith(createdBefore: picked),
      );
    }

    void resetFilters() {
      extensionController.clear();
      onChanged(
        DriveFileFilters(order: filters.order, orderDesc: filters.orderDesc),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Card.outlined(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _KindFilterChip(
                    isFolder: filters.isFolder,
                    enabled: enabled,
                    onSelected: (value) {
                      onChanged(
                        value == null
                            ? filters.copyWith(clearIsFolder: true)
                            : filters.copyWith(isFolder: value),
                      );
                    },
                  ),
                  _MediaKindChip(
                    value: filters.mediaKind,
                    enabled: enabled,
                    onSelected: (value) {
                      onChanged(
                        value == null
                            ? filters.copyWith(clearMediaKind: true)
                            : filters.copyWith(mediaKind: value),
                      );
                    },
                  ),
                  _FilterChipButton(
                    icon: Symbols.refresh,
                    label: 'refresh'.tr(),
                    emphasized: false,
                    enabled: enabled,
                    onTap: onRefresh,
                  ),
                ],
              ),
              const Gap(8),
              Material(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: enabled
                      ? () => showAdvanced.value = !showAdvanced.value
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Symbols.tune,
                            size: 18,
                            color: colorScheme.onSecondaryContainer,
                          ),
                        ),
                        const Gap(8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'advancedFilters'.tr(),
                                style: theme.textTheme.labelLarge,
                              ),
                              Text(
                                'driveFilterDescription'.tr(),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (filters.activeCount > 0) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              filters.activeCount.toString(),
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: colorScheme.onPrimaryContainer,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const Gap(6),
                        ],
                        Icon(
                          showAdvanced.value
                              ? Symbols.expand_less
                              : Symbols.expand_more,
                          size: 20,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLow,
                      border: Border.all(
                        color: colorScheme.outlineVariant.withOpacity(0.5),
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                key: ValueKey('sort-${filters.order}'),
                                decoration: InputDecoration(
                                  labelText: 'sortBy'.tr(),
                                  isDense: true,
                                  prefixIcon: const Icon(
                                    Symbols.sort,
                                    size: 18,
                                  ),
                                ),
                                initialValue: filters.order,
                                items: [
                                  DropdownMenuItem(
                                    value: 'date',
                                    child: Text('date'.tr()),
                                  ),
                                  DropdownMenuItem(
                                    value: 'name',
                                    child: Text('fileName'.tr()),
                                  ),
                                  DropdownMenuItem(
                                    value: 'size',
                                    child: Text('fileSize'.tr()),
                                  ),
                                ],
                                onChanged: enabled
                                    ? (value) {
                                        if (value == null) return;
                                        onChanged(
                                          filters.copyWith(order: value),
                                        );
                                      }
                                    : null,
                              ),
                            ),
                            const Gap(8),
                            Expanded(
                              child: DropdownButtonFormField<bool>(
                                key: ValueKey('order-${filters.orderDesc}'),
                                decoration: InputDecoration(
                                  labelText: 'order'.tr(),
                                  isDense: true,
                                ),
                                initialValue: filters.orderDesc,
                                items: [
                                  DropdownMenuItem(
                                    value: true,
                                    child: Text('descending'.tr()),
                                  ),
                                  DropdownMenuItem(
                                    value: false,
                                    child: Text('ascending'.tr()),
                                  ),
                                ],
                                onChanged: enabled
                                    ? (value) {
                                        onChanged(
                                          filters.copyWith(
                                            orderDesc: value ?? true,
                                          ),
                                        );
                                      }
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        const Gap(8),
                        Row(
                          children: [
                            Expanded(
                              child: _DateFieldButton(
                                label: 'fromDate'.tr(),
                                value: filters.createdAfter,
                                enabled: enabled,
                                onTap: () => pickDate(isStart: true),
                                onClear: filters.createdAfter == null
                                    ? null
                                    : () => onChanged(
                                        filters.copyWith(
                                          clearCreatedAfter: true,
                                        ),
                                      ),
                              ),
                            ),
                            const Gap(8),
                            Expanded(
                              child: _DateFieldButton(
                                label: 'toDate'.tr(),
                                value: filters.createdBefore,
                                enabled: enabled,
                                onTap: () => pickDate(isStart: false),
                                onClear: filters.createdBefore == null
                                    ? null
                                    : () => onChanged(
                                        filters.copyWith(
                                          clearCreatedBefore: true,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                        const Gap(8),
                        TextField(
                          controller: extensionController,
                          enabled: enabled,
                          decoration: InputDecoration(
                            labelText: 'driveFilterExtension'.tr(),
                            hintText: 'png, pdf, zip…',
                            isDense: true,
                            prefixIcon: const Icon(Symbols.extension, size: 18),
                            suffixIcon: (filters.extension?.isNotEmpty ?? false)
                                ? IconButton(
                                    visualDensity: const VisualDensity(
                                      horizontal: -4,
                                      vertical: -4,
                                    ),
                                    icon: const Icon(Symbols.close, size: 18),
                                    onPressed: enabled
                                        ? () {
                                            extensionController.clear();
                                            onChanged(
                                              filters.copyWith(
                                                clearExtension: true,
                                              ),
                                            );
                                          }
                                        : null,
                                  )
                                : null,
                          ),
                          onChanged: (value) {
                            final trimmed = value.trim();
                            onChanged(
                              trimmed.isEmpty
                                  ? filters.copyWith(clearExtension: true)
                                  : filters.copyWith(extension: trimmed),
                            );
                          },
                        ),
                        if (filters.hasActiveFilters) ...[
                          const Gap(6),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: enabled ? resetFilters : null,
                              icon: const Icon(Symbols.restart_alt),
                              label: Text('clear'.tr()),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                crossFadeState: showAdvanced.value
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 180),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool emphasized;
  final bool enabled;
  final VoidCallback onTap;

  const _FilterChipButton({
    required this.icon,
    required this.label,
    required this.emphasized,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foreground = emphasized
        ? colorScheme.onSecondaryContainer
        : colorScheme.onSurfaceVariant;

    return Material(
      color: emphasized
          ? colorScheme.secondaryContainer
          : colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: foreground),
              const Gap(6),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: emphasized
                      ? colorScheme.onSecondaryContainer
                      : colorScheme.onSurface,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KindFilterChip extends StatelessWidget {
  final bool? isFolder;
  final bool enabled;
  final ValueChanged<bool?> onSelected;

  const _KindFilterChip({
    required this.isFolder,
    required this.enabled,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final label = switch (isFolder) {
      true => 'folder'.tr(),
      false => 'files'.tr(),
      null => 'all'.tr(),
    };

    // PopupMenuButton considers a null result a dismissed menu and does not
    // call onSelected, so use an explicit option for the unfiltered state.
    return PopupMenuButton<_KindFilterOption>(
      enabled: enabled,
      initialValue: switch (isFolder) {
        true => _KindFilterOption.folders,
        false => _KindFilterOption.files,
        null => _KindFilterOption.all,
      },
      tooltip: 'type'.tr(),
      onSelected: (option) => onSelected(switch (option) {
        _KindFilterOption.all => null,
        _KindFilterOption.folders => true,
        _KindFilterOption.files => false,
      }),
      itemBuilder: (context) => [
        PopupMenuItem(value: _KindFilterOption.all, child: Text('all'.tr())),
        PopupMenuItem(
          value: _KindFilterOption.folders,
          child: Text('folder'.tr()),
        ),
        PopupMenuItem(
          value: _KindFilterOption.files,
          child: Text('files'.tr()),
        ),
      ],
      child: Material(
        color: isFolder != null
            ? colorScheme.secondaryContainer
            : colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Symbols.category,
                size: 16,
                color: isFolder != null
                    ? colorScheme.onSecondaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
              const Gap(6),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: isFolder != null
                      ? colorScheme.onSecondaryContainer
                      : colorScheme.onSurface,
                  fontSize: 12,
                ),
              ),
              const Gap(6),
              Icon(
                Symbols.expand_more,
                size: 16,
                color: isFolder != null
                    ? colorScheme.onSecondaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _KindFilterOption { all, folders, files }

class _MediaKindChip extends StatelessWidget {
  final DriveMediaKind? value;
  final bool enabled;
  final ValueChanged<DriveMediaKind?> onSelected;

  const _MediaKindChip({
    required this.value,
    required this.enabled,
    required this.onSelected,
  });

  String _label(DriveMediaKind? kind) => switch (kind) {
    DriveMediaKind.image => 'driveFilterImages'.tr(),
    DriveMediaKind.video => 'driveFilterVideos'.tr(),
    DriveMediaKind.audio => 'driveFilterAudio'.tr(),
    DriveMediaKind.document => 'driveFilterDocuments'.tr(),
    null => 'mimeType'.tr(),
  };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final active = value != null;

    return PopupMenuButton<_MediaKindFilterOption>(
      enabled: enabled,
      initialValue: switch (value) {
        DriveMediaKind.image => _MediaKindFilterOption.image,
        DriveMediaKind.video => _MediaKindFilterOption.video,
        DriveMediaKind.audio => _MediaKindFilterOption.audio,
        DriveMediaKind.document => _MediaKindFilterOption.document,
        null => _MediaKindFilterOption.all,
      },
      tooltip: 'mimeType'.tr(),
      onSelected: (option) => onSelected(switch (option) {
        _MediaKindFilterOption.all => null,
        _MediaKindFilterOption.image => DriveMediaKind.image,
        _MediaKindFilterOption.video => DriveMediaKind.video,
        _MediaKindFilterOption.audio => DriveMediaKind.audio,
        _MediaKindFilterOption.document => DriveMediaKind.document,
      }),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: _MediaKindFilterOption.all,
          child: Text('all'.tr()),
        ),
        PopupMenuItem(
          value: _MediaKindFilterOption.image,
          child: Text('driveFilterImages'.tr()),
        ),
        PopupMenuItem(
          value: _MediaKindFilterOption.video,
          child: Text('driveFilterVideos'.tr()),
        ),
        PopupMenuItem(
          value: _MediaKindFilterOption.audio,
          child: Text('driveFilterAudio'.tr()),
        ),
        PopupMenuItem(
          value: _MediaKindFilterOption.document,
          child: Text('driveFilterDocuments'.tr()),
        ),
      ],
      child: Material(
        color: active
            ? colorScheme.secondaryContainer
            : colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Symbols.perm_media,
                size: 16,
                color: active
                    ? colorScheme.onSecondaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
              const Gap(6),
              Text(
                _label(value),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: active
                      ? colorScheme.onSecondaryContainer
                      : colorScheme.onSurface,
                  fontSize: 12,
                ),
              ),
              const Gap(6),
              Icon(
                Symbols.expand_more,
                size: 16,
                color: active
                    ? colorScheme.onSecondaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _MediaKindFilterOption { all, image, video, audio, document }

class _DateFieldButton extends StatelessWidget {
  final String label;
  final DateTime? value;
  final bool enabled;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _DateFieldButton({
    required this.label,
    required this.value,
    required this.enabled,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final formatted = value != null
        ? DateFormat('yyyy-MM-dd').format(value!)
        : 'selectDate'.tr();

    return Material(
      color: colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                    const Gap(2),
                    Text(
                      formatted,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: value != null
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (onClear != null)
                IconButton(
                  icon: const Icon(Symbols.close, size: 18),
                  visualDensity: const VisualDensity(
                    horizontal: -4,
                    vertical: -4,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 28,
                    minHeight: 28,
                  ),
                  onPressed: enabled ? onClear : null,
                )
              else
                Icon(
                  Symbols.calendar_today,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
