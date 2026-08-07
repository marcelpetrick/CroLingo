import 'dart:convert';

import 'package:crolingo/data/review/fsrs_review_scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uses retry history to choose deterministic FSRS ratings', () {
    final scheduler = FsrsReviewScheduler();
    final reviewedAt = DateTime.utc(2026, 8, 7, 10);
    final good = scheduler.review(
      previousState: null,
      priorIncorrectAttempts: 0,
      reviewedAt: reviewedAt,
    );
    final hard = scheduler.review(
      previousState: null,
      priorIncorrectAttempts: 1,
      reviewedAt: reviewedAt,
    );
    final again = scheduler.review(
      previousState: null,
      priorIncorrectAttempts: 2,
      reviewedAt: reviewedAt,
    );

    expect(again.due.isBefore(hard.due), isTrue);
    expect(hard.due.isBefore(good.due), isTrue);
    expect(good.due.isUtc, isTrue);
    expect(jsonDecode(good.state), isA<Map<String, Object?>>());
  });

  test('continues from serialized card state', () {
    final scheduler = FsrsReviewScheduler();
    final first = scheduler.review(
      previousState: null,
      priorIncorrectAttempts: 0,
      reviewedAt: DateTime.utc(2026, 8, 7, 10),
    );
    final second = scheduler.review(
      previousState: first.state,
      priorIncorrectAttempts: 0,
      reviewedAt: first.due,
    );
    expect(second.state, isNot(first.state));
    expect(second.due.isAfter(first.due), isTrue);
  });
}
