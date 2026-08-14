import 'package:crolingo/domain/course/course.dart';
import 'package:crolingo/domain/learning/answer_grader.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const exercise = Exercise(
    id: 'hello',
    type: ExerciseType.translation,
    masteryDimension: MasteryDimension.germanToCroatian,
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

  test('accepts an answer whose punctuation differs', () {
    // A learner who omits the exclamation mark knew the word.
    expect(AnswerGrader.grade(exercise, 'Dobar dan').isCorrect, isTrue);
    expect(AnswerGrader.grade(exercise, 'Dobar dan?!').isCorrect, isTrue);
    expect(AnswerGrader.grade(exercise, '«Dobar dan.»').isCorrect, isTrue);
  });

  test('folds the apostrophe German learners drop', () {
    const german = Exercise(
      id: 'german',
      type: ExerciseType.translation,
      masteryDimension: MasteryDimension.croatianToGerman,
      prompt: 'Kako si?',
      acceptedAnswers: ["Wie geht's?"],
      explanation: 'Question',
      conceptIds: ['how'],
      pairs: [],
      tiles: [],
    );
    expect(AnswerGrader.grade(german, 'Wie gehts').isCorrect, isTrue);
    expect(AnswerGrader.grade(german, 'Wie geht’s?').isCorrect, isTrue);
  });

  test('still separates letters that carry meaning', () {
    // Tolerating punctuation must not slide into tolerating spelling.
    expect(AnswerGrader.grade(exercise, 'Dobar dán!').isCorrect, isFalse);
    expect(AnswerGrader.grade(exercise, 'Dobar-dan').isCorrect, isFalse);
  });

  test('never accepts an answer that normalizes to nothing', () {
    const punctuationOnly = Exercise(
      id: 'punctuation',
      type: ExerciseType.translation,
      masteryDimension: MasteryDimension.germanToCroatian,
      prompt: 'Prompt',
      acceptedAnswers: ['!'],
      explanation: 'Explanation',
      conceptIds: ['punctuation'],
      pairs: [],
      tiles: [],
    );
    // Content like this is rejected by the validator, but the grader must not
    // depend on that to keep an empty submission from passing.
    expect(AnswerGrader.grade(punctuationOnly, '').isCorrect, isFalse);
    expect(AnswerGrader.grade(punctuationOnly, '  ?? ').isCorrect, isFalse);
  });

  test('normalizes canonically equivalent Unicode input', () {
    const croatian = Exercise(
      id: 'croatian',
      type: ExerciseType.translation,
      masteryDimension: MasteryDimension.germanToCroatian,
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
