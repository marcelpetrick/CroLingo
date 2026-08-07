import 'dart:convert';
import 'dart:io';

import 'package:crolingo/domain/course/course.dart';
import 'package:crolingo/domain/course/course_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('bundled course', () {
    late Course course;

    setUpAll(() {
      final decoded =
          jsonDecode(
                File('assets/content/course_de_hr.json').readAsStringSync(),
              )
              as Map<String, Object?>;
      course = Course.fromJson(decoded);
    });

    test('contains two ordered beginner units', () {
      expect(course.id, 'de-hr-a1');
      expect(course.units, hasLength(2));
      expect(
        course.units.map((unit) => unit.id),
        ['erste-worte', 'begegnung-und-abschied'],
      );
      expect(course.units.expand((unit) => unit.lessons), hasLength(10));
      expect(
        course.units
            .expand((unit) => unit.lessons)
            .expand((lesson) => lesson.exercises),
        hasLength(70),
      );
      expect(course.concepts, hasLength(20));
      expect(
        course.units.last.lessons.map((lesson) => lesson.id),
        [
          'morgen-und-abschied',
          'bis-bald',
          'entschuldigung',
          'kennenlernen',
          'herkunft',
        ],
      );
    });

    test('passes semantic validation', () {
      expect(CourseValidator.validate(course), isEmpty);
    });
  });

  test('validator reports bad references and insufficient exposure', () {
    const exercise = Exercise(
      id: 'exercise',
      type: ExerciseType.translation,
      masteryDimension: MasteryDimension.germanToCroatian,
      prompt: 'Prompt',
      acceptedAnswers: ['Answer'],
      explanation: 'Explanation',
      conceptIds: ['missing'],
      pairs: [],
      tiles: [],
    );
    const course = Course(
      id: 'course',
      title: 'Course',
      concepts: [Concept(id: 'known', croatian: 'Bok', german: 'Hallo')],
      units: [
        CourseUnit(
          id: 'unit',
          title: 'Unit',
          description: 'Description',
          lessons: [
            Lesson(id: 'lesson', title: 'Lesson', exercises: [exercise]),
          ],
        ),
      ],
    );

    expect(
      CourseValidator.validate(course),
      containsAll([
        'Exercise exercise references missing',
        'Concept known has only 0 exposures',
        'Concept known lacks German-to-Croatian recall',
        'Concept known lacks Croatian-to-German recall',
      ]),
    );
  });
}
