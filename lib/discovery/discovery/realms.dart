import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/realms/realms_widgets/realm/realm_list.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'dart:async';

class DiscoveryRealmsScreen extends HookConsumerWidget {
  const DiscoveryRealmsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Timer? debounceTimer;
    final searchController = useTextEditingController();
    final currentQuery = useState<String?>(null);

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(title: Text('discoverRealms'.tr())),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverGap(88),
              SliverRealmList(
                query: currentQuery.value,
                key: ValueKey(currentQuery.value),
              ),
              SliverGap(MediaQuery.of(context).padding.bottom + 16),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SearchBar(
                elevation: WidgetStateProperty.all(4),
                controller: searchController,
                hintText: 'search'.tr(),
                leading: const Icon(Icons.search),
                padding: WidgetStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: 24),
                ),
                onChanged: (value) {
                  if (debounceTimer?.isActive ?? false) {
                    debounceTimer?.cancel();
                  }
                  debounceTimer = Timer(const Duration(milliseconds: 300), () {
                    if (currentQuery.value != value) {
                      currentQuery.value = value;
                    }
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
