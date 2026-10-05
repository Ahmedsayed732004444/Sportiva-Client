import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/paging/paged_controller.dart';
import '../../../core/paging/paged_result.dart';
import '../data/review_models.dart';
import '../data/review_repository.dart';

class WrittenReviewsController extends PagedController<MyReview> {
  @override
  Future<PagedResult<MyReview>> fetch(int page) => ref.read(reviewRepositoryProvider).written(page);
}

class ReceivedReviewsController extends PagedController<MyReview> {
  @override
  Future<PagedResult<MyReview>> fetch(int page) => ref.read(reviewRepositoryProvider).received(page);
}

final writtenReviewsProvider = AutoDisposeNotifierProvider<WrittenReviewsController, PagedState<MyReview>>(
  WrittenReviewsController.new,
);
final receivedReviewsProvider = AutoDisposeNotifierProvider<ReceivedReviewsController, PagedState<MyReview>>(
  ReceivedReviewsController.new,
);
