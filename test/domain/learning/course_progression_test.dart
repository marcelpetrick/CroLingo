import 'package:crolingo/domain/course/course.dart';
import 'package:crolingo/domain/learning/course_progression.dart';
import 'package:crolingo/domain/progress/progress_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('starts with the first authored lesson', () {
    final position = CourseProgression.next(_course, []);

    expect(position?.lesson.id, 'one');
    expect(position?.unitNumber, 1);
    expect(position?.lessonNumber, 1);
    expect(position?.isResuming, isFalse);
  });

  test('resumes an incomplete durable checkpoint', () {
    final position = CourseProgression.next(_course, [
      _progress('one', completed: false),
    ]);

    expect(position?.lesson.id, 'one');
    expect(position?.isResuming, isTrue);
  });

  test('continues across the unit boundary', () {
    final position = CourseProgression.next(_course, [
      _progress('one'),
      _progress('two'),
    ]);

    expect(position?.lesson.id, 'three');
    expect(position?.unitNumber, 2);
    expect(position?.lessonNumber, 1);
  });

  test('reports a completed course', () {
    final position = CourseProgression.next(_course, [
      _progress('one'),
      _progress('two'),
      _progress('three'),
    ]);

    expect(position, isNull);
  });
}

LessonProgress _progress(String lessonId, {bool completed = true}) =>
    LessonProgress(
      lessonId: lessonId,
      exerciseIndex: 1,
      xp: 20,
      completedAt: completed ? DateTime.utc(2026, 8, 7) : null,
    );

const _course = Course(
  id: 'course',
  title: 'Course',
  concepts: [],
  units: [
    CourseUnit(
      id: 'first',
      title: 'First',
      description: 'First unit',
      lessons: [
        Lesson(id: 'one', title: 'One', exercises: []),
        Lesson(id: 'two', title: 'Two', exercises: []),
      ],
    ),
    CourseUnit(
      id: 'second',
      title: 'Second',
      description: 'Second unit',
      lessons: [Lesson(id: 'three', title: 'Three', exercises: [])],
    ),
  ],
);
