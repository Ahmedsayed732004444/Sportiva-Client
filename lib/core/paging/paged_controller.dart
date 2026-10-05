import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_exception.dart';
import 'paged_result.dart';

class PagedState<T> {
  const PagedState({this.items = const [], this.page = 0, this.hasMore = true, this.isLoading = false, this.error});

  final List<T> items;
  final int page;
  final bool hasMore;
  final bool isLoading;
  final ApiException? error;

  bool get isEmpty => items.isEmpty && !isLoading && error == null && !hasMore;
  bool get isFirstLoad => items.isEmpty && isLoading;

  PagedState<T> copyWith({
    List<T>? items,
    int? page,
    bool? hasMore,
    bool? isLoading,
    ApiException? error,
    bool clearError = false,
  }) => PagedState(
    items: items ?? this.items,
    page: page ?? this.page,
    hasMore: hasMore ?? this.hasMore,
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : error ?? this.error,
  );
}

// What a list screen needs from its controller.
abstract interface class PagedActions {
  Future<void> loadMore();
  Future<void> refresh();
}

// Loads the page after the current one, keeping what is already there; any failure ends up in the state's error.
Future<PagedState<T>> loadNextPage<T>(PagedState<T> current, Future<PagedResult<T>> Function(int page) fetch) async {
  try {
    final next = current.page + 1;
    final result = await fetch(next);
    return current.copyWith(
      items: [...current.items, ...result.items],
      page: next,
      hasMore: result.hasMore,
      isLoading: false,
    );
  } on ApiException catch (e) {
    return current.copyWith(isLoading: false, error: e);
  } on Object {
    // Whatever went wrong, the screen must leave the spinner and offer a retry.
    return current.copyWith(isLoading: false, error: const ApiException(kind: ApiErrorKind.unknown));
  }
}

// The base of every list screen's controller: loads page after page, refreshes, and keeps errors in the state.
abstract class PagedController<T> extends AutoDisposeNotifier<PagedState<T>> implements PagedActions {
  Future<PagedResult<T>> fetch(int page);

  @override
  PagedState<T> build() {
    Future.microtask(loadMore);
    return PagedState<T>();
  }

  @override
  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true, clearError: true);
    state = await loadNextPage(state, fetch);
  }

  @override
  Future<void> refresh() async {
    state = PagedState<T>();
    await loadMore();
  }

  void replaceWhere(bool Function(T) test, T Function(T) update) =>
      state = state.copyWith(items: [for (final item in state.items) test(item) ? update(item) : item]);

  void removeWhere(bool Function(T) test) =>
      state = state.copyWith(items: state.items.where((item) => !test(item)).toList());

  void prepend(T item) => state = state.copyWith(items: [item, ...state.items]);
}

// The same, for lists that depend on an argument (the comments of one post, the followers of one user).
abstract class PagedFamilyController<T, A> extends AutoDisposeFamilyNotifier<PagedState<T>, A> implements PagedActions {
  Future<PagedResult<T>> fetch(int page);

  @override
  PagedState<T> build(A arg) {
    Future.microtask(loadMore);
    return PagedState<T>();
  }

  @override
  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true, clearError: true);
    state = await loadNextPage(state, fetch);
  }

  @override
  Future<void> refresh() async {
    state = PagedState<T>();
    await loadMore();
  }

  void replaceWhere(bool Function(T) test, T Function(T) update) =>
      state = state.copyWith(items: [for (final item in state.items) test(item) ? update(item) : item]);

  void removeWhere(bool Function(T) test) =>
      state = state.copyWith(items: state.items.where((item) => !test(item)).toList());

  void prepend(T item) => state = state.copyWith(items: [item, ...state.items]);
}
