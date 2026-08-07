/// Stored scheduler state and the next UTC review time.
class ReviewSchedule {
  /// Creates a review schedule.
  const ReviewSchedule({required this.state, required this.due});

  /// Opaque serialized scheduler state.
  final String state;

  /// Next UTC review time.
  final DateTime due;
}

/// Replaceable spaced-repetition scheduler boundary.
// The boundary intentionally has one operation so algorithms remain swappable.
// ignore: one_member_abstracts
abstract interface class ReviewScheduler {
  /// Applies one eventually-correct exercise result.
  ReviewSchedule review({
    required String? previousState,
    required int priorIncorrectAttempts,
    required DateTime reviewedAt,
  });
}
