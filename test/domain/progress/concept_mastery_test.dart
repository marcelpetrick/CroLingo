import 'package:crolingo/domain/course/course.dart';
import 'package:crolingo/domain/progress/concept_mastery.dart';
import 'package:crolingo/domain/progress/progress_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const recognition = Exercise(
    id: 'recognize-bok',
    type: ExerciseType.matching,
    masteryDimension: MasteryDimension.recognition,
    prompt: 'Match',
    acceptedAnswers: ['done'],
    explanation: 'Bok means hello.',
    conceptIds: ['bok'],
    pairs: [],
    tiles: [],
  );
  const recall = Exercise(
    id: 'recall-bok',
    type: ExerciseType.translation,
    masteryDimension: MasteryDimension.germanToCroatian,
    prompt: 'Hallo',
    acceptedAnswers: ['Bok'],
    explanation: 'Bok means hello.',
    conceptIds: ['bok'],
    pairs: [],
    tiles: [],
  );
  const course = Course(
    id: 'course',
    title: 'Course',
    concepts: [Concept(id: 'bok', croatian: 'Bok!', german: 'Hallo!')],
    units: [
      CourseUnit(
        id: 'unit',
        title: 'Unit',
        description: 'Description',
        lessons: [
          Lesson(
            id: 'lesson',
            title: 'Lesson',
            exercises: [recognition, recall],
          ),
        ],
      ),
    ],
  );

  test('tracks dimensions and weights attempts by prior errors', () {
    final mastery = ConceptMasteryCalculator.calculate(course, [
      ExerciseAttempt(
        exerciseId: 'recognize-bok',
        correct: true,
        incorrectBefore: 0,
        occurredAt: DateTime.utc(2026, 8, 7),
      ),
      ExerciseAttempt(
        exerciseId: 'recall-bok',
        correct: false,
        incorrectBefore: 0,
        occurredAt: DateTime.utc(2026, 8, 7, 0, 1),
      ),
      ExerciseAttempt(
        exerciseId: 'recall-bok',
        correct: true,
        incorrectBefore: 2,
        occurredAt: DateTime.utc(2026, 8, 7, 0, 2),
      ),
    ]).single;

    expect(mastery.scores[MasteryDimension.recognition], 1);
    expect(mastery.scores[MasteryDimension.germanToCroatian], 0.33);
    expect(mastery.scores, isNot(contains(MasteryDimension.croatianToGerman)));
    expect(mastery.overall, closeTo(0.665, 0.001));
  });

  test('keeps unpracticed concepts visible with zero mastery', () {
    final mastery = ConceptMasteryCalculator.calculate(course, []).single;
    expect(mastery.scores, isEmpty);
    expect(mastery.overall, 0);
  });
}
