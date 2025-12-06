import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';

abstract class PaginationController<T> {
  int? get totalCount;
  int get fetchedCount;

  bool get fetchedAll;
  bool get isLoading;

  FutureOr<List<T>> fetch();

  Future<void> refresh();

  Future<void> fetchFurther();
}

abstract class PaginationFiltered<F> {
  late F currentFilter;

  Future<void> applyFilter(F filter);
}

mixin AsyncPaginationController<T> on AsyncNotifier<List<T>>
    implements PaginationController<T> {
  @override
  int? totalCount;

  @override
  int get fetchedCount => state.value?.length ?? 0;

  @override
  bool get fetchedAll => totalCount != null && fetchedCount >= totalCount!;

  @override
  bool isLoading = false;

  @override
  FutureOr<List<T>> build() async => fetch();

  @override
  Future<void> refresh() async {
    isLoading = true;
    totalCount = null;
    state = AsyncData<List<T>>([]);

    final newState = await AsyncValue.guard<List<T>>(() async {
      return await fetch();
    });
    state = newState;
    isLoading = false;
  }

  @override
  Future<void> fetchFurther() async {
    if (fetchedAll) return;

    isLoading = true;
    state = AsyncLoading<List<T>>();

    final newState = await AsyncValue.guard<List<T>>(() async {
      final elements = await fetch();
      return [...?state.value, ...elements];
    });

    state = newState;
    isLoading = false;
  }
}

mixin AsyncPaginationFilter<F, T> on AsyncPaginationController<T>
    implements PaginationFiltered<F> {
  @override
  Future<void> applyFilter(F filter) async {
    if (currentFilter == filter) return;
    // Reset the data
    isLoading = true;
    totalCount = null;
    state = AsyncData<List<T>>([]);
    currentFilter = filter;

    final newState = await AsyncValue.guard<List<T>>(() async {
      return await fetch();
    });
    state = newState;
    isLoading = false;
  }
}
