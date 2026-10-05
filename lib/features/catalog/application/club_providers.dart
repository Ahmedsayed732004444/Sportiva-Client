import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/catalog_models.dart';
import '../data/catalog_repository.dart';

final clubProvider = FutureProvider.autoDispose.family<ClubDetails, String>(
  (ref, id) => ref.read(catalogRepositoryProvider).club(id),
);

final clubCourtsProvider = FutureProvider.autoDispose.family<List<CourtListItem>, String>(
  (ref, id) => ref.read(catalogRepositoryProvider).courtsOfClub(id),
);

final clubReviewsProvider = FutureProvider.autoDispose.family<List<ReviewItem>, String>(
  (ref, id) => ref.read(catalogRepositoryProvider).clubReviews(id),
);
