import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:island/creators/publication_site.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

class SiteConfigForm extends HookWidget {
  final SnPublicationSiteConfig? initialConfig;
  final ValueChanged<SnPublicationSiteConfig> onChanged;

  const SiteConfigForm({
    super.key,
    this.initialConfig,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final styleOverrideController = useTextEditingController(
      text: initialConfig?.styleOverride,
    );
    final navItems = useState<List<SnPublicationSiteNavItems>>(
      initialConfig?.navItems ?? [],
    );

    useEffect(() {
      void listener() {
        onChanged(
          SnPublicationSiteConfig(
            styleOverride: styleOverrideController.text,
            navItems: navItems.value,
          ),
        );
      }

      styleOverrideController.addListener(listener);
      return () => styleOverrideController.removeListener(listener);
    }, [styleOverrideController, navItems.value]);

    return Card(
      margin: EdgeInsets.zero,
      child: ExpansionTile(
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        title: Text('siteConfig'.tr()),
        children: [
          Column(
            spacing: 8,
            children: [
              TextFormField(
                controller: styleOverrideController,
                decoration: InputDecoration(
                  labelText: 'siteConfigStyleOverride'.tr(),
                  hintText: "You can paste your CSS here...",
                  alignLabelWithHint: true,
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                minLines: 3,
                maxLines: null,
              ).padding(bottom: 8),
              Row(
                children: [
                  Text('siteConfigNavItems'.tr()).bold(),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      navItems.value = [
                        ...navItems.value,
                        const SnPublicationSiteNavItems(label: '', href: ''),
                      ];
                      // Trigger update manually as list mutation doesn't trigger controller listener
                      onChanged(
                        SnPublicationSiteConfig(
                          styleOverride: styleOverrideController.text,
                          navItems: navItems.value,
                        ),
                      );
                    },
                    icon: const Icon(Symbols.add),
                    label: Text('siteConfigAddNavItem'.tr()),
                  ),
                ],
              ).padding(bottom: 4),
              if (navItems.value.isEmpty)
                Text('dataEmpty'.tr()).center().padding(vertical: 20),
              ...navItems.value.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    spacing: 12,
                    children: [
                      TextFormField(
                        initialValue: item.label,
                        decoration: InputDecoration(
                          labelText: 'siteConfigNavItemLabel'.tr(),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        onChanged: (value) {
                          final newItems = [...navItems.value];
                          newItems[index] = item.copyWith(label: value);
                          navItems.value = newItems;
                          onChanged(
                            SnPublicationSiteConfig(
                              styleOverride: styleOverrideController.text,
                              navItems: newItems,
                            ),
                          );
                        },
                      ),
                      TextFormField(
                        initialValue: item.href,
                        decoration: InputDecoration(
                          labelText: 'siteConfigNavItemHref'.tr(),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        onChanged: (value) {
                          final newItems = [...navItems.value];
                          newItems[index] = item.copyWith(href: value);
                          navItems.value = newItems;
                          onChanged(
                            SnPublicationSiteConfig(
                              styleOverride: styleOverrideController.text,
                              navItems: newItems,
                            ),
                          );
                        },
                      ),
                      TextButton.icon(
                        onPressed: () {
                          final newItems = [...navItems.value];
                          newItems.removeAt(index);
                          navItems.value = newItems;
                          onChanged(
                            SnPublicationSiteConfig(
                              styleOverride: styleOverrideController.text,
                              navItems: newItems,
                            ),
                          );
                        },
                        icon: const Icon(Symbols.delete),
                        label: Text('delete'.tr()),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ).alignment(Alignment.centerRight),
                    ],
                  ).padding(horizontal: 16, vertical: 20),
                );
              }),
            ],
          ).padding(all: 16),
        ],
      ),
    );
  }
}
