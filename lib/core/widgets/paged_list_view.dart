import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../paging/paged_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'state_views.dart';

// A list screen body for any PagedController: first-load spinner, empty and error states, pull to refresh, and
// the next page loading as you reach the end.
class PagedListView<T> extends ConsumerWidget {
  const PagedListView({
    super.key,
    required this.state,
    required this.actions,
    required this.itemBuilder,
    this.emptyMessage,
    this.emptyIcon = Icons.inbox_outlined,
    this.separator,
    this.header,
    this.padding = const EdgeInsets.all(AppSpacing.s),
  });

  final ProviderListenable<PagedState<T>> state;
  final ProviderListenable<PagedActions> actions;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final String? emptyMessage;
  final IconData emptyIcon;
  final Widget? separator;
  // Shown above the items (a profile's details above its posts); the empty state then shows under it.
  final Widget? header;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(this.state);
    final controller = ref.read(actions);

    final header = this.header;
    if (header == null) {
      if (state.isFirstLoad) return const LoadingView();
      if (state.error != null && state.items.isEmpty) {
        return ErrorView(error: state.error!, onRetry: controller.loadMore);
      }
      if (state.isEmpty) return EmptyView(message: emptyMessage, icon: emptyIcon);
    }

    final shown = header == null ? 0 : 1;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: controller.refresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: (scroll) {
          if (scroll.metrics.extentAfter < 300) controller.loadMore();
          return false;
        },
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: padding,
          itemCount: state.items.length + 1 + shown,
          separatorBuilder: (_, index) => index >= shown && index - shown < state.items.length - 1
              ? (separator ?? const SizedBox.shrink())
              : const SizedBox.shrink(),
          itemBuilder: (context, index) {
            if (index < shown) return header!;
            final item = index - shown;
            if (item < state.items.length) return itemBuilder(context, state.items[item]);
            if (state.error != null) return ErrorView(error: state.error!, onRetry: controller.loadMore);
            if (state.isFirstLoad) return const Padding(padding: EdgeInsets.all(AppSpacing.l), child: LoadingView());
            if (state.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(AppSpacing.l),
                child: EmptyView(message: emptyMessage, icon: emptyIcon),
              );
            }
            return state.hasMore
                ? const Padding(padding: EdgeInsets.all(AppSpacing.s), child: LoadingView())
                : const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
