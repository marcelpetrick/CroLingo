import 'package:crolingo/domain/course/course.dart';
import 'package:crolingo/domain/learning/answer_grader.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const exercise = Exercise(
    id: 'hello',
    type: ExerciseType.translation,
    prompt: 'Hallo',
    acceptedAnswers: ['Dobar dan!'],
    explanation: 'Greeting',
    conceptIds: ['hello'],
    pairs: [],
    tiles: [],
  );

  test('accepts casing and harmless whitespace differences', () {
    final result = AnswerGrader.grade(exercise, '  DOBAR   DAN! ');
    expect(result.isCorrect, isTrue);
    expect(result.correction, 'Dobar dan!');
  });

  test('does not remove punctuation or Croatian characters', () {
    expect(AnswerGrader.grade(exercise, 'Dobar dan').isCorrect, isFalse);
    expect(AnswerGrader.grade(exercise, 'Dobar dán!').isCorrect, isFalse);
  });

  test('normalizes canonically equivalent Unicode input', () {
    const croatian = Exercise(
      id: 'croatian',
      type: ExerciseType.translation,
      prompt: 'Croatian',
      acceptedAnswers: ['Č'],
      explanation: 'Character',
      conceptIds: ['character'],
      pairs: [],
      tiles: [],
    );
    expect(AnswerGrader.grade(croatian, 'C\u030C').isCorrect, isTrue);
  });
}
