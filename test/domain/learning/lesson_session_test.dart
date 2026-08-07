import 'package:crolingo/domain/course/course.dart';
import 'package:crolingo/domain/learning/lesson_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const exercise = Exercise(
    id: 'hello',
    type: ExerciseType.translation,
    masteryDimension: MasteryDimension.germanToCroatian,
    prompt: 'Hallo',
    acceptedAnswers: ['Bok!'],
    explanation: 'Greeting',
    conceptIds: ['hello'],
    pairs: [],
    tiles: [],
  );
  const lesson = Lesson(
    id: 'lesson',
    title: 'Lesson',
    exercises: [exercise],
  );

  test('requires eventual correctness and rewards a clean answer', () {
    final session = LessonSession(lesson)..submit('Bok!');
    expect(session.state.grade?.isCorrect, isTrue);
    expect(session.state.xp, 10);

    session.continueAfterCorrect();
    expect(session.state.isComplete, isTrue);
    expect(session.state.xp, 20);
  });

  test('allows unlimited retries and reduces task XP', () {
    final session = LessonSession(lesson)..submit('wrong');
    expect(session.state.incorrectAttempts, 1);
    expect(session.state.xp, 0);

    session.retry();
    expect(session.state.grade, isNull);
    session
      ..submit('still wrong')
      ..retry()
      ..submit('Bok!');
    expect(session.state.xp, 6);
  });

  test('ignores actions that are invalid in the current state', () {
    final session = LessonSession(lesson)
      ..retry()
      ..continueAfterCorrect();
    expect(session.state, const TypeMatcher<LessonSessionState>());
    session
      ..submit('Bok!')
      ..submit('Bok!');
    expect(session.state.xp, 10);
  });

  test('resumes a bounded stored checkpoint', () {
    final session = LessonSession.resume(lesson, index: 99, xp: 22);
    expect(session.state.index, 0);
    expect(session.state.xp, 22);
    expect(session.state.grade, isNull);
  });
}
