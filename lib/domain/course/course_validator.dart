import 'package:crolingo/domain/course/course.dart';

/// Semantic validator for bundled course content.
abstract final class CourseValidator {
  /// Returns all validation failures without stopping at the first one.
  static List<String> validate(Course course) {
    final errors = <String>[];
    final ids = <String>{};
    final conceptIds = course.concepts.map((concept) => concept.id).toSet();
    final exposures = {for (final id in conceptIds) id: 0};
    final recallDirections = {
      for (final id in conceptIds) id: <MasteryDimension>{},
    };

    void addId(String id, String kind) {
      if (!ids.add(id)) errors.add('Duplicate $kind id: $id');
    }

    addId(course.id, 'course');
    if (course.units.isEmpty) errors.add('Course has no units');
    for (final concept in course.concepts) {
      addId(concept.id, 'concept');
    }
    for (final unit in course.units) {
      addId(unit.id, 'unit');
      if (unit.lessons.isEmpty) errors.add('Unit ${unit.id} has no lessons');
      for (final lesson in unit.lessons) {
        addId(lesson.id, 'lesson');
        if (lesson.exercises.isEmpty) {
          errors.add('Lesson ${lesson.id} has no exercises');
        }
        for (final exercise in lesson.exercises) {
          addId(exercise.id, 'exercise');
          if (exercise.acceptedAnswers.isEmpty) {
            errors.add('Exercise ${exercise.id} has no accepted answer');
          }
          if (exercise.type == ExerciseType.matching &&
              exercise.pairs.length < 2) {
            errors.add('Matching exercise ${exercise.id} needs two pairs');
          }
          if (exercise.type == ExerciseType.sentence &&
              exercise.tiles.length < 2) {
            errors.add('Sentence exercise ${exercise.id} needs two tiles');
          }
          final expectedDimension = switch (exercise.type) {
            ExerciseType.matching => MasteryDimension.recognition,
            ExerciseType.fillBlank => MasteryDimension.grammarApplication,
            ExerciseType.sentence => MasteryDimension.sentenceProduction,
            ExerciseType.translation => null,
          };
          if (expectedDimension != null &&
              exercise.masteryDimension != expectedDimension) {
            errors.add(
              'Exercise ${exercise.id} has incompatible mastery dimension',
            );
          }
          if (exercise.type == ExerciseType.translation &&
              exercise.masteryDimension != MasteryDimension.germanToCroatian &&
              exercise.masteryDimension != MasteryDimension.croatianToGerman) {
            errors.add(
              'Translation ${exercise.id} needs a recall direction',
            );
          }
          for (final conceptId in exercise.conceptIds) {
            if (!conceptIds.contains(conceptId)) {
              errors.add('Exercise ${exercise.id} references $conceptId');
            } else {
              exposures[conceptId] = exposures[conceptId]! + 1;
              if (exercise.masteryDimension ==
                      MasteryDimension.germanToCroatian ||
                  exercise.masteryDimension ==
                      MasteryDimension.croatianToGerman) {
                recallDirections[conceptId]!.add(exercise.masteryDimension);
              }
            }
          }
        }
      }
    }
    for (final entry in exposures.entries) {
      if (entry.value < 3) {
        errors.add('Concept ${entry.key} has only ${entry.value} exposures');
      }
      if (!recallDirections[entry.key]!.contains(
        MasteryDimension.germanToCroatian,
      )) {
        errors.add('Concept ${entry.key} lacks German-to-Croatian recall');
      }
      if (!recallDirections[entry.key]!.contains(
        MasteryDimension.croatianToGerman,
      )) {
        errors.add('Concept ${entry.key} lacks Croatian-to-German recall');
      }
    }
    return errors;
  }
}
