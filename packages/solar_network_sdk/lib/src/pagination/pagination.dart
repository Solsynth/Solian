import 'dart:async';

import 'package:riverpod/riverpod.dart';

class PaginationState<T> {
  final List<T> items;
  final bool isLoading;
  final bool isReloading;
  final int? totalCount;
  final bool hasMore;
  final String? cursor;

  const PaginationState({
    required this.items,
    required this.isLoading,
    required this.isReloading,
    required this.totalCount,
    required this.hasMore,
    required this.cursor,
  });

  PaginationState<T> copyWith({
    List<T>? items,
    bool? isLoading,
    bool? isReloading,
    int? totalCount,
    bool? hasMore,
    String? cursor,
  }) {
    return PaginationState<T>(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isReloading: isReloading ?? this.isReloading,
      totalCount: totalCount ?? this.totalCount,
      hasMore: hasMore ?? this.hasMore,
      cursor: cursor ?? this.cursor,
    );
  }
}

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

mixin AsyncPaginationController<T> on AsyncNotifier<PaginationState<T>>
    implements PaginationController<T> {
  @override
  int? totalCount;

  /// Whether refresh discards the current items while loading.
  ///
  /// Defaults to false so refreshes can keep showing existing data.
  bool get clearOnRefresh => false;

  @override
  int get fetchedCount =>
      state.value?.isReloading == true ? 0 : state.value?.items.length ?? 0;

  @override
  bool get fetchedAll =>
      !(state.value?.hasMore ?? true) ||
      ((state.value?.totalCount != null &&
          fetchedCount >= state.value!.totalCount!));

  @override
  bool get isLoading => state.value?.isLoading ?? false;

  @override
  bool get isReloading => state.value?.isReloading ?? false;

  @override
  bool get hasMore => state.value?.hasMore ?? true;

  @override
  String? get cursor => state.value?.cursor;

  @override
  set hasMore(bool value) {
    if (state is AsyncData) {
      state = AsyncData((state as AsyncData).value.copyWith(hasMore: value));
    }
  }

  @override
  set cursor(String? value) {
    if (state is AsyncData) {
      state = AsyncData((state as AsyncData).value.copyWith(cursor: value));
    }
  }

  @override
  FutureOr<PaginationState<T>> build() async {
    final items = await fetch();
    return PaginationState(
      items: items,
      isLoading: false,
      isReloading: false,
      totalCount: totalCount,
      hasMore: hasMore,
      cursor: cursor,
    );
  }

  @override
  Future<void> refresh() async {
    final currentState = state.value;
    if (clearOnRefresh) {
      totalCount = null;
    }
    state = AsyncData(
      PaginationState(
        items: clearOnRefresh ? const [] : currentState?.items ?? const [],
        isLoading: true,
        isReloading: true,
        totalCount: clearOnRefresh ? null : currentState?.totalCount,
        hasMore: true,
        cursor: null,
      ),
    );

    try {
      final newItems = await fetch();

      if (!ref.mounted) return;
      final resolvedTotal = totalCount;
      final more = resolvedTotal == null
          ? newItems.isNotEmpty
          : newItems.length < resolvedTotal;
      state = AsyncData(
        PaginationState(
          items: newItems,
          isLoading: false,
          isReloading: false,
          totalCount: resolvedTotal,
          hasMore: more,
          cursor: cursor,
        ),
      );
    } catch (error, stackTrace) {
      if (!ref.mounted) return;
      state = AsyncError(error, stackTrace);
    }
  }

  @override
  Future<void> fetchFurther() async {
    if (fetchedAll) return;
    if (isLoading) return;

    state = AsyncData(state.value!.copyWith(isLoading: true));

    try {
      final newItems = await fetch();

      if (!ref.mounted) return;
      final combined = [...state.value!.items, ...newItems];
      final resolvedTotal = totalCount ?? state.value!.totalCount;
      final more = newItems.isEmpty
          ? false
          : resolvedTotal == null
          ? true
          : combined.length < resolvedTotal;
      state = AsyncData(
        state.value!.copyWith(
          items: combined,
          isLoading: false,
          totalCount: resolvedTotal,
          hasMore: more,
        ),
      );
    } catch (error, stackTrace) {
      if (!ref.mounted) return;
      // Keep previously loaded pages; surface the error only if we had none.
      if (state.value?.items.isEmpty ?? true) {
        state = AsyncError(error, stackTrace);
      } else {
        state = AsyncData(state.value!.copyWith(isLoading: false));
      }
    }
  }
}

mixin AsyncPaginationFilter<F, T> on AsyncPaginationController<T>
    implements PaginationFiltered<F> {
  @override
  Future<void> applyFilter(F filter) async {
    if (currentFilter == filter) return;

    state = AsyncData(
      PaginationState(
        items: [],
        isLoading: true,
        isReloading: true,
        totalCount: null,
        hasMore: true,
        cursor: null,
      ),
    );
    currentFilter = filter;

    final newItems = await fetch();

    if (!ref.mounted) return;
    state = AsyncData(
      PaginationState(
        items: newItems,
        isLoading: false,
        isReloading: false,
        totalCount: totalCount,
        hasMore: hasMore,
        cursor: cursor,
      ),
    );
  }
}
