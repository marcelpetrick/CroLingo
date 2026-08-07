import 'dart:convert';

import 'package:crolingo/domain/review/review_scheduler.dart';
import 'package:fsrs/fsrs.dart';

/// FSRS adapter using default weights and 90% desired retention.
class FsrsReviewScheduler implements ReviewScheduler {
  /// Creates a deterministic scheduler suitable for reproducible local state.
  FsrsReviewScheduler()
    // Retention stays explicit because it is a product-level learning setting.
    // ignore: avoid_redundant_argument_values
    : _scheduler = Scheduler(desiredRetention: 0.9, enableFuzzing: false);

  final Scheduler _scheduler;

  @override
  ReviewSchedule review({
    required String? previousState,
    required int priorIncorrectAttempts,
    required DateTime reviewedAt,
  }) {
    final card = previousState == null
        ? Card(cardId: 1, due: reviewedAt.toUtc())
        : Card.fromMap(
            (jsonDecode(previousState) as Map<String, Object?>).cast(),
          );
    final rating = switch (priorIncorrectAttempts) {
      0 => Rating.good,
      1 => Rating.hard,
      _ => Rating.again,
    };
    final result = _scheduler.reviewCard(
      card,
      rating,
      reviewDateTime: reviewedAt.toUtc(),
    );
    return ReviewSchedule(
      state: jsonEncode(result.card.toMap()),
      due: result.card.due.toUtc(),
    );
  }
}
