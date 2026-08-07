import 'package:crolingo/domain/progress/streak_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('calculates active and longest local-day streaks', () {
    final streaks = StreakCalculator.calculate(
      ['2026-07-01', '2026-07-02', '2026-08-05', '2026-08-06'],
      DateTime(2026, 8, 7, 23),
    );
    expect(streaks.current, 2);
    expect(streaks.longest, 2);
  });

  test('expires current streak after missing a full day', () {
    final streaks = StreakCalculator.calculate(
      ['2026-08-01', '2026-08-02', '2026-08-03'],
      DateTime(2026, 8, 7),
    );
    expect(streaks.current, 0);
    expect(streaks.longest, 3);
  });

  test('handles no study days', () {
    final streaks = StreakCalculator.calculate([], DateTime(2026, 8, 7));
    expect(streaks.current, 0);
    expect(streaks.longest, 0);
  });
}
