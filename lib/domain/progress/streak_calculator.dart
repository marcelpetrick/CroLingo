/// Current and historical study streak lengths.
class Streaks {
  /// Creates streak values.
  const Streaks({required this.current, required this.longest});

  /// Active streak ending today or yesterday.
  final int current;

  /// Longest historical streak.
  final int longest;
}

/// Pure calendar-day streak calculation.
abstract final class StreakCalculator {
  /// Calculates streaks from local ISO dates at [today].
  static Streaks calculate(Iterable<String> dayKeys, DateTime today) {
    final days = dayKeys.map(DateTime.parse).toSet().toList()..sort();
    if (days.isEmpty) return const Streaks(current: 0, longest: 0);

    var longest = 1;
    var run = 1;
    for (var index = 1; index < days.length; index++) {
      if (days[index].difference(days[index - 1]).inDays == 1) {
        run++;
        if (run > longest) longest = run;
      } else {
        run = 1;
      }
    }

    final localToday = DateTime(today.year, today.month, today.day);
    final gap = localToday.difference(days.last).inDays;
    return Streaks(
      current: gap == 0 || gap == 1 ? run : 0,
      longest: longest,
    );
  }
}
