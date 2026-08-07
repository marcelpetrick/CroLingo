/// One offline Croatian course.
class Course {
  /// Creates a course.
  const Course({
    required this.id,
    required this.title,
    required this.units,
    required this.concepts,
  });

  /// Parses a course from validated JSON.
  factory Course.fromJson(Map<String, Object?> json) => Course(
    id: _string(json, 'id'),
    title: _string(json, 'title'),
    units: _maps(json, 'units').map(CourseUnit.fromJson).toList(),
    concepts: _maps(json, 'concepts').map(Concept.fromJson).toList(),
  );

  /// Stable identifier.
  final String id;

  /// German display title.
  final String title;

  /// Ordered course units.
  final List<CourseUnit> units;

  /// Learning concepts referenced by exercises.
  final List<Concept> concepts;
}

/// A themed group of lessons.
class CourseUnit {
  /// Creates a course unit.
  const CourseUnit({
    required this.id,
    required this.title,
    required this.description,
    required this.lessons,
  });

  /// Parses a unit from JSON.
  factory CourseUnit.fromJson(Map<String, Object?> json) => CourseUnit(
    id: _string(json, 'id'),
    title: _string(json, 'title'),
    description: _string(json, 'description'),
    lessons: _maps(json, 'lessons').map(Lesson.fromJson).toList(),
  );

  /// Stable identifier.
  final String id;

  /// German display title.
  final String title;

  /// German learning goal.
  final String description;

  /// Ordered lessons.
  final List<Lesson> lessons;
}

/// A short, replayable learning session.
class Lesson {
  /// Creates a lesson.
  const Lesson({
    required this.id,
    required this.title,
    required this.exercises,
  });

  /// Parses a lesson from JSON.
  factory Lesson.fromJson(Map<String, Object?> json) => Lesson(
    id: _string(json, 'id'),
    title: _string(json, 'title'),
    exercises: _maps(json, 'exercises').map(Exercise.fromJson).toList(),
  );

  /// Stable identifier.
  final String id;

  /// German display title.
  final String title;

  /// Ordered exercise definitions.
  final List<Exercise> exercises;
}

/// Supported text exercise families.
enum ExerciseType {
  /// Connect Croatian and German words.
  matching,

  /// Type a translation in either direction.
  translation,

  /// Complete a sentence fragment.
  fillBlank,

  /// Arrange word tiles into a Croatian sentence.
  sentence,
}

/// Learning ability measured by an exercise.
enum MasteryDimension {
  /// Recognize Croatian and German forms as a pair.
  recognition,

  /// Recall Croatian from a German prompt.
  germanToCroatian,

  /// Recall German from a Croatian prompt.
  croatianToGerman,

  /// Produce a complete Croatian sentence.
  sentenceProduction,

  /// Apply vocabulary or grammar in context.
  grammarApplication,
}

/// One gradable text exercise.
class Exercise {
  /// Creates an exercise.
  const Exercise({
    required this.id,
    required this.type,
    required this.masteryDimension,
    required this.prompt,
    required this.acceptedAnswers,
    required this.explanation,
    required this.conceptIds,
    required this.pairs,
    required this.tiles,
  });

  /// Parses an exercise from JSON.
  factory Exercise.fromJson(Map<String, Object?> json) => Exercise(
    id: _string(json, 'id'),
    type: ExerciseType.values.byName(_string(json, 'type')),
    masteryDimension: MasteryDimension.values.byName(
      _string(json, 'masteryDimension'),
    ),
    prompt: _string(json, 'prompt'),
    acceptedAnswers: _strings(json, 'acceptedAnswers'),
    explanation: _string(json, 'explanation'),
    conceptIds: _strings(json, 'conceptIds'),
    pairs: _maps(json, 'pairs').map(WordPair.fromJson).toList(),
    tiles: _strings(json, 'tiles'),
  );

  /// Stable identifier.
  final String id;

  /// Rendering and grading family.
  final ExerciseType type;

  /// Fine-grained learning ability practiced by this exercise.
  final MasteryDimension masteryDimension;

  /// German instruction or source sentence.
  final String prompt;

  /// Strict accepted answers. The first is the displayed correction.
  final List<String> acceptedAnswers;

  /// Concise German feedback shown after grading.
  final String explanation;

  /// Concepts practiced by this exercise.
  final List<String> conceptIds;

  /// Matching items, empty for other exercise types.
  final List<WordPair> pairs;

  /// Sentence tiles, empty for other exercise types.
  final List<String> tiles;
}

/// One Croatian/German matching pair.
class WordPair {
  /// Creates a pair.
  const WordPair({required this.croatian, required this.german});

  /// Parses a pair from JSON.
  factory WordPair.fromJson(Map<String, Object?> json) => WordPair(
    croatian: _string(json, 'croatian'),
    german: _string(json, 'german'),
  );

  /// Croatian value.
  final String croatian;

  /// German value.
  final String german;
}

/// A vocabulary or grammar concept.
class Concept {
  /// Creates a concept.
  const Concept({
    required this.id,
    required this.croatian,
    required this.german,
  });

  /// Parses a concept from JSON.
  factory Concept.fromJson(Map<String, Object?> json) => Concept(
    id: _string(json, 'id'),
    croatian: _string(json, 'croatian'),
    german: _string(json, 'german'),
  );

  /// Stable identifier.
  final String id;

  /// Croatian form.
  final String croatian;

  /// German meaning.
  final String german;
}

String _string(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('$key must be a non-empty string');
  }
  return value;
}

List<String> _strings(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! List<Object?> || value.any((item) => item is! String)) {
    throw FormatException('$key must be a string list');
  }
  return value.cast<String>();
}

List<Map<String, Object?>> _maps(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! List<Object?> ||
      value.any((item) => item is! Map<String, Object?>)) {
    throw FormatException('$key must be an object list');
  }
  return value.cast<Map<String, Object?>>();
}
