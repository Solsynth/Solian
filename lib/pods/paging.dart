import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';

abstract class PaginationController<T> {
  int? get totalCount;
  int get fetchedCount;

  bool get fetchedAll;
  bool get isLoading;
  bool get isReloading;
  bool get hasMore;
  set hasMore(bool value);
  String? get cursor;
  set cursor(String? value);

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
  int get fetchedCount => isReloading ? 0 : state.value?.length ?? 0;

  @override
  bool get fetchedAll =>
      !hasMore || (totalCount != null && fetchedCount >= totalCount!);

  @override
  bool isLoading = false;

  @override
  bool isReloading = false;

  @override
  bool hasMore = true;

  @override
  String? cursor;

  @override
  FutureOr<List<T>> build() async {
    cursor = null;
    return fetch();
  }

  @override
  Future<void> refresh() async {
    isLoading = true;
    isReloading = true;
    totalCount = null;
    hasMore = true;
    cursor = null;
    state = AsyncLoading<List<T>>();

    final newState = await AsyncValue.guard<List<T>>(() async {
      return await fetch();
    });
    isReloading = false;
    isLoading = false;
    state = newState;
  }

  @override
  Future<void> fetchFurther() async {
    if (fetchedAll) return;
    if (isLoading) return;

    isLoading = true;
    state = AsyncLoading<List<T>>();

    final newState = await AsyncValue.guard<List<T>>(() async {
      final elements = await fetch();
      return [...?state.value, ...elements];
    });

    isLoading = false;
    state = newState;
  }
}

mixin AsyncPaginationFilter<F, T> on AsyncPaginationController<T>
    implements PaginationFiltered<F> {
  @override
  Future<void> applyFilter(F filter) async {
    if (currentFilter == filter) return;
    // Reset the data
    isReloading = true;
    isLoading = true;
    totalCount = null;
    hasMore = true;
    cursor = null;
    state = AsyncLoading<List<T>>();
    currentFilter = filter;

    final newState = await AsyncValue.guard<List<T>>(() async {
      return await fetch();
    });
    isLoading = false;
    isReloading = false;
    state = newState;
  }
}
