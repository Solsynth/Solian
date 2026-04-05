import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:styled_widget/styled_widget.dart';

part 'account_picker.g.dart';

@riverpod
Future<List<SnAccount>> searchAccounts(Ref ref, {required String query}) async {
  if (query.isEmpty) {
    return [];
  }

  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.get(
    '/passport/accounts/search',
    queryParameters: {'query': query},
  );

  return response.data!
      .map((json) => SnAccount.fromJson(json))
      .cast<SnAccount>()
      .toList();
}

class AccountPickerSheet extends HookConsumerWidget {
  const AccountPickerSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final debouncedQuery = useState<String>('');
    final debounceTimer = useRef<Timer?>(null);
    const debounceDuration = Duration(milliseconds: 300);

    void onSearchChanged(String query) {
      debounceTimer.value?.cancel();
      debounceTimer.value = Timer(debounceDuration, () {
        debouncedQuery.value = query;
      });
    }

    return SheetScaffold(
      showHeader: false,
      heightFactor: 0.6,
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: MediaQuery.of(context).padding.top + 16,
          bottom: 8,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: SearchBar(
                    controller: searchController,
                    onChanged: onSearchChanged,
                    hintText: 'searchAccounts'.tr(),
                    elevation: WidgetStatePropertyAll(2),
                    leading: Icon(
                      Symbols.search,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurface,
                    ).padding(horizontal: 16),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    Symbols.close,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  onPressed: () => Navigator.pop(context),
                  style: IconButton.styleFrom(minimumSize: const Size(36, 36)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  final searchResult = ref.watch(
                    searchAccountsProvider(query: debouncedQuery.value),
                  );

                  return searchResult.when(
                    data: (accounts) => ListView.builder(
                      itemCount: accounts.length,
                      itemBuilder: (context, index) {
                        final account = accounts[index];
                        return ListTile(
                          leading: ProfilePictureWidget(
                            file: account.profile.picture,
                          ),
                          title: Text(account.nick),
                          subtitle: Text('@${account.name}'),
                          onTap: () => Navigator.of(context).pop(account),
                        );
                      },
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) =>
                        Center(child: Text('Error: $error')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
