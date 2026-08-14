import 'package:crolingo/domain/course/course.dart';
import 'package:crolingo/domain/progress/progress_repository.dart';
import 'package:crolingo/domain/review/review_planner.dart';
import 'package:crolingo/domain/review/review_scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

Exercise _exercise({
  required String id,
  required MasteryDimension dimension,
  required List<String> conceptIds,
}) => Exercise(
  id: id,
  type: ExerciseType.translation,
  masteryDimension: dimension,
  prompt: 'Prompt',
  acceptedAnswers: const ['Answer'],
  explanation: 'Explanation',
  conceptIds: conceptIds,
  pairs: const [],
  tiles: const [],
);

Course _course(List<Exercise> exercises) => Course(
  id: 'course',
  title: 'Course',
  concepts: const [
    Concept(id: 'bok', croatian: 'Bok!', german: 'Hallo!'),
    Concept(id: 'hvala', croatian: 'Hvala.', german: 'Danke.'),
  ],
  units: [
    CourseUnit(
      id: 'unit',
      title: 'Unit',
      description: 'Description',
      lessons: [Lesson(id: 'lesson', title: 'Lesson', exercises: exercises)],
    ),
  ],
);

ExerciseAttempt _attempt(
  String exerciseId,
  DateTime at, {
  bool correct = true,
  int incorrectBefore = 0,
}) => ExerciseAttempt(
  exerciseId: exerciseId,
  correct: correct,
  incorrectBefore: incorrectBefore,
  occurredAt: at,
);

/// Schedules everything one day out, which keeps the assertions about keying
/// rather than about the FSRS implementation.
class _NextDayScheduler implements ReviewScheduler {
  /// Every state handed back to the scheduler, in call order. A continued
  /// schedule shows up here as a non-null second entry.
  final List<String?> seenPreviousStates = [];

  @override
  ReviewSchedule review({
    required String? previousState,
    required int priorIncorrectAttempts,
    required DateTime reviewedAt,
  }) {
    seenPreviousStates.add(previousState);
    return ReviewSchedule(
      state: '${previousState ?? ''}.',
      due: reviewedAt.add(const Duration(days: 1)),
    );
  }
}

void main() {
  final practised = DateTime.utc(2026, 8, 3);
  final later = DateTime.utc(2026, 8, 10);

  test('schedules each recall direction of a concept separately', () {
    final course = _course([
      _exercise(
        id: 'de-hr',
        dimension: MasteryDimension.germanToCroatian,
        conceptIds: ['bok'],
      ),
      _exercise(
        id: 'hr-de',
        dimension: MasteryDimension.croatianToGerman,
        conceptIds: ['bok'],
      ),
    ]);

    final due = ReviewPlanner.due(
      course: course,
      attempts: [_attempt('de-hr', practised), _attempt('hr-de', practised)],
      scheduler: _NextDayScheduler(),
      now: later,
    );

    // One word, two abilities, two independent schedules.
    expect(due, hasLength(2));
    expect(due.map((item) => item.conceptId).toSet(), {'bok'});
    expect(due.map((item) => item.dimension).toSet(), {
      MasteryDimension.germanToCroatian,
      MasteryDimension.croatianToGerman,
    });
  });

  test('credits every concept an exercise practises', () {
    final course = _course([
      _exercise(
        id: 'pair',
        dimension: MasteryDimension.recognition,
        conceptIds: ['bok', 'hvala'],
      ),
    ]);

    final due = ReviewPlanner.due(
      course: course,
      attempts: [_attempt('pair', practised)],
      scheduler: _NextDayScheduler(),
      now: later,
    );

    expect(due.map((item) => item.conceptId).toSet(), {'bok', 'hvala'});
  });

  test('carries memory across the exercises that share a concept', () {
    final course = _course([
      _exercise(
        id: 'first',
        dimension: MasteryDimension.germanToCroatian,
        conceptIds: ['bok'],
      ),
      _exercise(
        id: 'second',
        dimension: MasteryDimension.germanToCroatian,
        conceptIds: ['bok'],
      ),
    ]);
    final scheduler = _NextDayScheduler();

    final due = ReviewPlanner.due(
      course: course,
      attempts: [
        _attempt('first', practised),
        _attempt('second', practised.add(const Duration(days: 1))),
      ],
      scheduler: scheduler,
      now: later,
    );

    // A second exercise on a known word continues the same schedule instead
    // of starting a new one, which is the whole point of keying by concept.
    // Under the old exercise keying both calls would have started from null.
    expect(due, hasLength(1));
    expect(scheduler.seenPreviousStates, [null, '.']);
  });

  test('ignores incorrect attempts and unknown exercises', () {
    final course = _course([
      _exercise(
        id: 'known',
        dimension: MasteryDimension.germanToCroatian,
        conceptIds: ['bok'],
      ),
    ]);

    final due = ReviewPlanner.due(
      course: course,
      attempts: [
        _attempt('known', practised, correct: false),
        // Authored away since the attempt was stored; its concepts are no
        // longer knowable.
        _attempt('deleted', practised),
      ],
      scheduler: _NextDayScheduler(),
      now: later,
    );

    expect(due, isEmpty);
  });

  test('omits concepts that are not due yet', () {
    final course = _course([
      _exercise(
        id: 'known',
        dimension: MasteryDimension.germanToCroatian,
        conceptIds: ['bok'],
      ),
    ]);

    final due = ReviewPlanner.due(
      course: course,
      attempts: [_attempt('known', practised)],
      scheduler: _NextDayScheduler(),
      now: practised.add(const Duration(hours: 1)),
    );

    expect(due, isEmpty);
  });

  test('offers an exercise the learner has never seen first', () {
    final course = _course([
      _exercise(
        id: 'seen',
        dimension: MasteryDimension.germanToCroatian,
        conceptIds: ['bok'],
      ),
      _exercise(
        id: 'fresh',
        dimension: MasteryDimension.germanToCroatian,
        conceptIds: ['bok'],
      ),
    ]);

    final due = ReviewPlanner.due(
      course: course,
      attempts: [_attempt('seen', practised)],
      scheduler: _NextDayScheduler(),
      now: later,
    );

    expect(due.single.exerciseId, 'fresh');
  });

  test('otherwise offers the least recently practised exercise', () {
    final course = _course([
      _exercise(
        id: 'older',
        dimension: MasteryDimension.germanToCroatian,
        conceptIds: ['bok'],
      ),
      _exercise(
        id: 'newer',
        dimension: MasteryDimension.germanToCroatian,
        conceptIds: ['bok'],
      ),
    ]);

    final due = ReviewPlanner.due(
      course: course,
      attempts: [
        _attempt('newer', practised),
        _attempt('older', practised.subtract(const Duration(days: 3))),
      ],
      scheduler: _NextDayScheduler(),
      now: later,
    );

    expect(due.single.exerciseId, 'older');
  });

  test('returns the soonest due first and names the lesson to open', () {
    final course = _course([
      _exercise(
        id: 'early',
        dimension: MasteryDimension.germanToCroatian,
        conceptIds: ['bok'],
      ),
      _exercise(
        id: 'late',
        dimension: MasteryDimension.croatianToGerman,
        conceptIds: ['hvala'],
      ),
    ]);

    final due = ReviewPlanner.due(
      course: course,
      attempts: [
        _attempt('late', practised.add(const Duration(days: 2))),
        _attempt('early', practised),
      ],
      scheduler: _NextDayScheduler(),
      now: later,
    );

    expect(due.map((item) => item.conceptId).toList(), ['bok', 'hvala']);
    expect(due.every((item) => item.lessonId == 'lesson'), isTrue);
  });
}
