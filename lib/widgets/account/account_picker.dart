import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/user.dart';
import 'package:island/pods/network.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'account_picker.g.dart';

@riverpod
Future<List<SnAccount>> searchAccounts(Ref ref, {required String query}) async {
  if (query.isEmpty) {
    return [];
  }

  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.get(
    '/id/accounts/search',
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
    final debounceTimer = useState<Timer?>(null);

    void onSearchChanged(String query) {
      debounceTimer.value?.cancel();
      debounceTimer.value = Timer(const Duration(milliseconds: 300), () {
        ref.read(searchAccountsProvider(query: query));
      });
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.4,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'Search accounts...',
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
              ),
              autofocus: true,
              onTapOutside:
                  (_) => FocusManager.instance.primaryFocus?.unfocus(),
            ),
          ),
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final searchResult = ref.watch(
                  searchAccountsProvider(query: searchController.text),
                );

                return searchResult.when(
                  data:
                      (accounts) => ListView.builder(
                        itemCount: accounts.length,
                        itemBuilder: (context, index) {
                          final account = accounts[index];
                          return ListTile(
                            leading: ProfilePictureWidget(
                              fileId: account.profile.picture?.id,
                            ),
                            title: Text(account.nick),
                            subtitle: Text('@${account.name}'),
                            onTap: () => Navigator.of(context).pop(account),
                          );
                        },
                      ),
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Error: $error')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
