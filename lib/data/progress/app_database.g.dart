// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AttemptEntriesTable extends AttemptEntries
    with TableInfo<$AttemptEntriesTable, AttemptEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttemptEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _lessonIdMeta = const VerificationMeta(
    'lessonId',
  );
  @override
  late final GeneratedColumn<String> lessonId = GeneratedColumn<String>(
    'lesson_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _submittedAnswerMeta = const VerificationMeta(
    'submittedAnswer',
  );
  @override
  late final GeneratedColumn<String> submittedAnswer = GeneratedColumn<String>(
    'submitted_answer',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _correctMeta = const VerificationMeta(
    'correct',
  );
  @override
  late final GeneratedColumn<bool> correct = GeneratedColumn<bool>(
    'correct',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("correct" IN (0, 1))',
    ),
  );
  static const VerificationMeta _incorrectBeforeMeta = const VerificationMeta(
    'incorrectBefore',
  );
  @override
  late final GeneratedColumn<int> incorrectBefore = GeneratedColumn<int>(
    'incorrect_before',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    lessonId,
    exerciseId,
    submittedAnswer,
    correct,
    incorrectBefore,
    occurredAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attempt_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<AttemptEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('lesson_id')) {
      context.handle(
        _lessonIdMeta,
        lessonId.isAcceptableOrUnknown(data['lesson_id']!, _lessonIdMeta),
      );
    } else if (isInserting) {
      context.missing(_lessonIdMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('submitted_answer')) {
      context.handle(
        _submittedAnswerMeta,
        submittedAnswer.isAcceptableOrUnknown(
          data['submitted_answer']!,
          _submittedAnswerMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_submittedAnswerMeta);
    }
    if (data.containsKey('correct')) {
      context.handle(
        _correctMeta,
        correct.isAcceptableOrUnknown(data['correct']!, _correctMeta),
      );
    } else if (isInserting) {
      context.missing(_correctMeta);
    }
    if (data.containsKey('incorrect_before')) {
      context.handle(
        _incorrectBeforeMeta,
        incorrectBefore.isAcceptableOrUnknown(
          data['incorrect_before']!,
          _incorrectBeforeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_incorrectBeforeMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AttemptEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttemptEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      lessonId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lesson_id'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      )!,
      submittedAnswer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}submitted_answer'],
      )!,
      correct: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}correct'],
      )!,
      incorrectBefore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}incorrect_before'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
    );
  }

  @override
  $AttemptEntriesTable createAlias(String alias) {
    return $AttemptEntriesTable(attachedDatabase, alias);
  }
}

class AttemptEntry extends DataClass implements Insertable<AttemptEntry> {
  /// Local monotonically increasing key.
  final int id;

  /// Stable lesson ID.
  final String lessonId;

  /// Stable exercise ID.
  final String exerciseId;

  /// Learner submission, kept only in app-private storage.
  final String submittedAnswer;

  /// Whether this attempt was accepted.
  final bool correct;

  /// Prior errors on this exercise.
  final int incorrectBefore;

  /// UTC attempt time.
  final DateTime occurredAt;
  const AttemptEntry({
    required this.id,
    required this.lessonId,
    required this.exerciseId,
    required this.submittedAnswer,
    required this.correct,
    required this.incorrectBefore,
    required this.occurredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['lesson_id'] = Variable<String>(lessonId);
    map['exercise_id'] = Variable<String>(exerciseId);
    map['submitted_answer'] = Variable<String>(submittedAnswer);
    map['correct'] = Variable<bool>(correct);
    map['incorrect_before'] = Variable<int>(incorrectBefore);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    return map;
  }

  AttemptEntriesCompanion toCompanion(bool nullToAbsent) {
    return AttemptEntriesCompanion(
      id: Value(id),
      lessonId: Value(lessonId),
      exerciseId: Value(exerciseId),
      submittedAnswer: Value(submittedAnswer),
      correct: Value(correct),
      incorrectBefore: Value(incorrectBefore),
      occurredAt: Value(occurredAt),
    );
  }

  factory AttemptEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttemptEntry(
      id: serializer.fromJson<int>(json['id']),
      lessonId: serializer.fromJson<String>(json['lessonId']),
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      submittedAnswer: serializer.fromJson<String>(json['submittedAnswer']),
      correct: serializer.fromJson<bool>(json['correct']),
      incorrectBefore: serializer.fromJson<int>(json['incorrectBefore']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'lessonId': serializer.toJson<String>(lessonId),
      'exerciseId': serializer.toJson<String>(exerciseId),
      'submittedAnswer': serializer.toJson<String>(submittedAnswer),
      'correct': serializer.toJson<bool>(correct),
      'incorrectBefore': serializer.toJson<int>(incorrectBefore),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
    };
  }

  AttemptEntry copyWith({
    int? id,
    String? lessonId,
    String? exerciseId,
    String? submittedAnswer,
    bool? correct,
    int? incorrectBefore,
    DateTime? occurredAt,
  }) => AttemptEntry(
    id: id ?? this.id,
    lessonId: lessonId ?? this.lessonId,
    exerciseId: exerciseId ?? this.exerciseId,
    submittedAnswer: submittedAnswer ?? this.submittedAnswer,
    correct: correct ?? this.correct,
    incorrectBefore: incorrectBefore ?? this.incorrectBefore,
    occurredAt: occurredAt ?? this.occurredAt,
  );
  AttemptEntry copyWithCompanion(AttemptEntriesCompanion data) {
    return AttemptEntry(
      id: data.id.present ? data.id.value : this.id,
      lessonId: data.lessonId.present ? data.lessonId.value : this.lessonId,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      submittedAnswer: data.submittedAnswer.present
          ? data.submittedAnswer.value
          : this.submittedAnswer,
      correct: data.correct.present ? data.correct.value : this.correct,
      incorrectBefore: data.incorrectBefore.present
          ? data.incorrectBefore.value
          : this.incorrectBefore,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttemptEntry(')
          ..write('id: $id, ')
          ..write('lessonId: $lessonId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('submittedAnswer: $submittedAnswer, ')
          ..write('correct: $correct, ')
          ..write('incorrectBefore: $incorrectBefore, ')
          ..write('occurredAt: $occurredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    lessonId,
    exerciseId,
    submittedAnswer,
    correct,
    incorrectBefore,
    occurredAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttemptEntry &&
          other.id == this.id &&
          other.lessonId == this.lessonId &&
          other.exerciseId == this.exerciseId &&
          other.submittedAnswer == this.submittedAnswer &&
          other.correct == this.correct &&
          other.incorrectBefore == this.incorrectBefore &&
          other.occurredAt == this.occurredAt);
}

class AttemptEntriesCompanion extends UpdateCompanion<AttemptEntry> {
  final Value<int> id;
  final Value<String> lessonId;
  final Value<String> exerciseId;
  final Value<String> submittedAnswer;
  final Value<bool> correct;
  final Value<int> incorrectBefore;
  final Value<DateTime> occurredAt;
  const AttemptEntriesCompanion({
    this.id = const Value.absent(),
    this.lessonId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.submittedAnswer = const Value.absent(),
    this.correct = const Value.absent(),
    this.incorrectBefore = const Value.absent(),
    this.occurredAt = const Value.absent(),
  });
  AttemptEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String lessonId,
    required String exerciseId,
    required String submittedAnswer,
    required bool correct,
    required int incorrectBefore,
    required DateTime occurredAt,
  }) : lessonId = Value(lessonId),
       exerciseId = Value(exerciseId),
       submittedAnswer = Value(submittedAnswer),
       correct = Value(correct),
       incorrectBefore = Value(incorrectBefore),
       occurredAt = Value(occurredAt);
  static Insertable<AttemptEntry> custom({
    Expression<int>? id,
    Expression<String>? lessonId,
    Expression<String>? exerciseId,
    Expression<String>? submittedAnswer,
    Expression<bool>? correct,
    Expression<int>? incorrectBefore,
    Expression<DateTime>? occurredAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lessonId != null) 'lesson_id': lessonId,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (submittedAnswer != null) 'submitted_answer': submittedAnswer,
      if (correct != null) 'correct': correct,
      if (incorrectBefore != null) 'incorrect_before': incorrectBefore,
      if (occurredAt != null) 'occurred_at': occurredAt,
    });
  }

  AttemptEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? lessonId,
    Value<String>? exerciseId,
    Value<String>? submittedAnswer,
    Value<bool>? correct,
    Value<int>? incorrectBefore,
    Value<DateTime>? occurredAt,
  }) {
    return AttemptEntriesCompanion(
      id: id ?? this.id,
      lessonId: lessonId ?? this.lessonId,
      exerciseId: exerciseId ?? this.exerciseId,
      submittedAnswer: submittedAnswer ?? this.submittedAnswer,
      correct: correct ?? this.correct,
      incorrectBefore: incorrectBefore ?? this.incorrectBefore,
      occurredAt: occurredAt ?? this.occurredAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (lessonId.present) {
      map['lesson_id'] = Variable<String>(lessonId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (submittedAnswer.present) {
      map['submitted_answer'] = Variable<String>(submittedAnswer.value);
    }
    if (correct.present) {
      map['correct'] = Variable<bool>(correct.value);
    }
    if (incorrectBefore.present) {
      map['incorrect_before'] = Variable<int>(incorrectBefore.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttemptEntriesCompanion(')
          ..write('id: $id, ')
          ..write('lessonId: $lessonId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('submittedAnswer: $submittedAnswer, ')
          ..write('correct: $correct, ')
          ..write('incorrectBefore: $incorrectBefore, ')
          ..write('occurredAt: $occurredAt')
          ..write(')'))
        .toString();
  }
}

class $LessonProgressEntriesTable extends LessonProgressEntries
    with TableInfo<$LessonProgressEntriesTable, LessonProgressEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LessonProgressEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _lessonIdMeta = const VerificationMeta(
    'lessonId',
  );
  @override
  late final GeneratedColumn<String> lessonId = GeneratedColumn<String>(
    'lesson_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exerciseIndexMeta = const VerificationMeta(
    'exerciseIndex',
  );
  @override
  late final GeneratedColumn<int> exerciseIndex = GeneratedColumn<int>(
    'exercise_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _xpMeta = const VerificationMeta('xp');
  @override
  late final GeneratedColumn<int> xp = GeneratedColumn<int>(
    'xp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    lessonId,
    exerciseIndex,
    xp,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lesson_progress_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<LessonProgressEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('lesson_id')) {
      context.handle(
        _lessonIdMeta,
        lessonId.isAcceptableOrUnknown(data['lesson_id']!, _lessonIdMeta),
      );
    } else if (isInserting) {
      context.missing(_lessonIdMeta);
    }
    if (data.containsKey('exercise_index')) {
      context.handle(
        _exerciseIndexMeta,
        exerciseIndex.isAcceptableOrUnknown(
          data['exercise_index']!,
          _exerciseIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_exerciseIndexMeta);
    }
    if (data.containsKey('xp')) {
      context.handle(_xpMeta, xp.isAcceptableOrUnknown(data['xp']!, _xpMeta));
    } else if (isInserting) {
      context.missing(_xpMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {lessonId};
  @override
  LessonProgressEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LessonProgressEntry(
      lessonId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lesson_id'],
      )!,
      exerciseIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exercise_index'],
      )!,
      xp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}xp'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
    );
  }

  @override
  $LessonProgressEntriesTable createAlias(String alias) {
    return $LessonProgressEntriesTable(attachedDatabase, alias);
  }
}

class LessonProgressEntry extends DataClass
    implements Insertable<LessonProgressEntry> {
  /// Stable lesson ID.
  final String lessonId;

  /// Exercise to resume.
  final int exerciseIndex;

  /// XP earned in this lesson.
  final int xp;

  /// UTC completion time.
  final DateTime? completedAt;
  const LessonProgressEntry({
    required this.lessonId,
    required this.exerciseIndex,
    required this.xp,
    this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['lesson_id'] = Variable<String>(lessonId);
    map['exercise_index'] = Variable<int>(exerciseIndex);
    map['xp'] = Variable<int>(xp);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  LessonProgressEntriesCompanion toCompanion(bool nullToAbsent) {
    return LessonProgressEntriesCompanion(
      lessonId: Value(lessonId),
      exerciseIndex: Value(exerciseIndex),
      xp: Value(xp),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory LessonProgressEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LessonProgressEntry(
      lessonId: serializer.fromJson<String>(json['lessonId']),
      exerciseIndex: serializer.fromJson<int>(json['exerciseIndex']),
      xp: serializer.fromJson<int>(json['xp']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'lessonId': serializer.toJson<String>(lessonId),
      'exerciseIndex': serializer.toJson<int>(exerciseIndex),
      'xp': serializer.toJson<int>(xp),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  LessonProgressEntry copyWith({
    String? lessonId,
    int? exerciseIndex,
    int? xp,
    Value<DateTime?> completedAt = const Value.absent(),
  }) => LessonProgressEntry(
    lessonId: lessonId ?? this.lessonId,
    exerciseIndex: exerciseIndex ?? this.exerciseIndex,
    xp: xp ?? this.xp,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
  );
  LessonProgressEntry copyWithCompanion(LessonProgressEntriesCompanion data) {
    return LessonProgressEntry(
      lessonId: data.lessonId.present ? data.lessonId.value : this.lessonId,
      exerciseIndex: data.exerciseIndex.present
          ? data.exerciseIndex.value
          : this.exerciseIndex,
      xp: data.xp.present ? data.xp.value : this.xp,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LessonProgressEntry(')
          ..write('lessonId: $lessonId, ')
          ..write('exerciseIndex: $exerciseIndex, ')
          ..write('xp: $xp, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(lessonId, exerciseIndex, xp, completedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LessonProgressEntry &&
          other.lessonId == this.lessonId &&
          other.exerciseIndex == this.exerciseIndex &&
          other.xp == this.xp &&
          other.completedAt == this.completedAt);
}

class LessonProgressEntriesCompanion
    extends UpdateCompanion<LessonProgressEntry> {
  final Value<String> lessonId;
  final Value<int> exerciseIndex;
  final Value<int> xp;
  final Value<DateTime?> completedAt;
  final Value<int> rowid;
  const LessonProgressEntriesCompanion({
    this.lessonId = const Value.absent(),
    this.exerciseIndex = const Value.absent(),
    this.xp = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LessonProgressEntriesCompanion.insert({
    required String lessonId,
    required int exerciseIndex,
    required int xp,
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : lessonId = Value(lessonId),
       exerciseIndex = Value(exerciseIndex),
       xp = Value(xp);
  static Insertable<LessonProgressEntry> custom({
    Expression<String>? lessonId,
    Expression<int>? exerciseIndex,
    Expression<int>? xp,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (lessonId != null) 'lesson_id': lessonId,
      if (exerciseIndex != null) 'exercise_index': exerciseIndex,
      if (xp != null) 'xp': xp,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LessonProgressEntriesCompanion copyWith({
    Value<String>? lessonId,
    Value<int>? exerciseIndex,
    Value<int>? xp,
    Value<DateTime?>? completedAt,
    Value<int>? rowid,
  }) {
    return LessonProgressEntriesCompanion(
      lessonId: lessonId ?? this.lessonId,
      exerciseIndex: exerciseIndex ?? this.exerciseIndex,
      xp: xp ?? this.xp,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (lessonId.present) {
      map['lesson_id'] = Variable<String>(lessonId.value);
    }
    if (exerciseIndex.present) {
      map['exercise_index'] = Variable<int>(exerciseIndex.value);
    }
    if (xp.present) {
      map['xp'] = Variable<int>(xp.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LessonProgressEntriesCompanion(')
          ..write('lessonId: $lessonId, ')
          ..write('exerciseIndex: $exerciseIndex, ')
          ..write('xp: $xp, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StudyDayEntriesTable extends StudyDayEntries
    with TableInfo<$StudyDayEntriesTable, StudyDayEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudyDayEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayKeyMeta = const VerificationMeta('dayKey');
  @override
  late final GeneratedColumn<String> dayKey = GeneratedColumn<String>(
    'day_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _xpMeta = const VerificationMeta('xp');
  @override
  late final GeneratedColumn<int> xp = GeneratedColumn<int>(
    'xp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [dayKey, xp];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'study_day_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<StudyDayEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day_key')) {
      context.handle(
        _dayKeyMeta,
        dayKey.isAcceptableOrUnknown(data['day_key']!, _dayKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_dayKeyMeta);
    }
    if (data.containsKey('xp')) {
      context.handle(_xpMeta, xp.isAcceptableOrUnknown(data['xp']!, _xpMeta));
    } else if (isInserting) {
      context.missing(_xpMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {dayKey};
  @override
  StudyDayEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StudyDayEntry(
      dayKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day_key'],
      )!,
      xp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}xp'],
      )!,
    );
  }

  @override
  $StudyDayEntriesTable createAlias(String alias) {
    return $StudyDayEntriesTable(attachedDatabase, alias);
  }
}

class StudyDayEntry extends DataClass implements Insertable<StudyDayEntry> {
  /// ISO local date in `yyyy-MM-dd` form.
  final String dayKey;

  /// XP earned on this date.
  final int xp;
  const StudyDayEntry({required this.dayKey, required this.xp});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day_key'] = Variable<String>(dayKey);
    map['xp'] = Variable<int>(xp);
    return map;
  }

  StudyDayEntriesCompanion toCompanion(bool nullToAbsent) {
    return StudyDayEntriesCompanion(dayKey: Value(dayKey), xp: Value(xp));
  }

  factory StudyDayEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StudyDayEntry(
      dayKey: serializer.fromJson<String>(json['dayKey']),
      xp: serializer.fromJson<int>(json['xp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'dayKey': serializer.toJson<String>(dayKey),
      'xp': serializer.toJson<int>(xp),
    };
  }

  StudyDayEntry copyWith({String? dayKey, int? xp}) =>
      StudyDayEntry(dayKey: dayKey ?? this.dayKey, xp: xp ?? this.xp);
  StudyDayEntry copyWithCompanion(StudyDayEntriesCompanion data) {
    return StudyDayEntry(
      dayKey: data.dayKey.present ? data.dayKey.value : this.dayKey,
      xp: data.xp.present ? data.xp.value : this.xp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StudyDayEntry(')
          ..write('dayKey: $dayKey, ')
          ..write('xp: $xp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(dayKey, xp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StudyDayEntry &&
          other.dayKey == this.dayKey &&
          other.xp == this.xp);
}

class StudyDayEntriesCompanion extends UpdateCompanion<StudyDayEntry> {
  final Value<String> dayKey;
  final Value<int> xp;
  final Value<int> rowid;
  const StudyDayEntriesCompanion({
    this.dayKey = const Value.absent(),
    this.xp = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StudyDayEntriesCompanion.insert({
    required String dayKey,
    required int xp,
    this.rowid = const Value.absent(),
  }) : dayKey = Value(dayKey),
       xp = Value(xp);
  static Insertable<StudyDayEntry> custom({
    Expression<String>? dayKey,
    Expression<int>? xp,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (dayKey != null) 'day_key': dayKey,
      if (xp != null) 'xp': xp,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StudyDayEntriesCompanion copyWith({
    Value<String>? dayKey,
    Value<int>? xp,
    Value<int>? rowid,
  }) {
    return StudyDayEntriesCompanion(
      dayKey: dayKey ?? this.dayKey,
      xp: xp ?? this.xp,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (dayKey.present) {
      map['day_key'] = Variable<String>(dayKey.value);
    }
    if (xp.present) {
      map['xp'] = Variable<int>(xp.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudyDayEntriesCompanion(')
          ..write('dayKey: $dayKey, ')
          ..write('xp: $xp, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AttemptEntriesTable attemptEntries = $AttemptEntriesTable(this);
  late final $LessonProgressEntriesTable lessonProgressEntries =
      $LessonProgressEntriesTable(this);
  late final $StudyDayEntriesTable studyDayEntries = $StudyDayEntriesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    attemptEntries,
    lessonProgressEntries,
    studyDayEntries,
  ];
}

typedef $$AttemptEntriesTableCreateCompanionBuilder =
    AttemptEntriesCompanion Function({
      Value<int> id,
      required String lessonId,
      required String exerciseId,
      required String submittedAnswer,
      required bool correct,
      required int incorrectBefore,
      required DateTime occurredAt,
    });
typedef $$AttemptEntriesTableUpdateCompanionBuilder =
    AttemptEntriesCompanion Function({
      Value<int> id,
      Value<String> lessonId,
      Value<String> exerciseId,
      Value<String> submittedAnswer,
      Value<bool> correct,
      Value<int> incorrectBefore,
      Value<DateTime> occurredAt,
    });

class $$AttemptEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $AttemptEntriesTable> {
  $$AttemptEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get submittedAnswer => $composableBuilder(
    column: $table.submittedAnswer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get correct => $composableBuilder(
    column: $table.correct,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get incorrectBefore => $composableBuilder(
    column: $table.incorrectBefore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AttemptEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $AttemptEntriesTable> {
  $$AttemptEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get submittedAnswer => $composableBuilder(
    column: $table.submittedAnswer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get correct => $composableBuilder(
    column: $table.correct,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get incorrectBefore => $composableBuilder(
    column: $table.incorrectBefore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AttemptEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttemptEntriesTable> {
  $$AttemptEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get lessonId =>
      $composableBuilder(column: $table.lessonId, builder: (column) => column);

  GeneratedColumn<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get submittedAnswer => $composableBuilder(
    column: $table.submittedAnswer,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get correct =>
      $composableBuilder(column: $table.correct, builder: (column) => column);

  GeneratedColumn<int> get incorrectBefore => $composableBuilder(
    column: $table.incorrectBefore,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );
}

class $$AttemptEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttemptEntriesTable,
          AttemptEntry,
          $$AttemptEntriesTableFilterComposer,
          $$AttemptEntriesTableOrderingComposer,
          $$AttemptEntriesTableAnnotationComposer,
          $$AttemptEntriesTableCreateCompanionBuilder,
          $$AttemptEntriesTableUpdateCompanionBuilder,
          (
            AttemptEntry,
            BaseReferences<_$AppDatabase, $AttemptEntriesTable, AttemptEntry>,
          ),
          AttemptEntry,
          PrefetchHooks Function()
        > {
  $$AttemptEntriesTableTableManager(
    _$AppDatabase db,
    $AttemptEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttemptEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttemptEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttemptEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> lessonId = const Value.absent(),
                Value<String> exerciseId = const Value.absent(),
                Value<String> submittedAnswer = const Value.absent(),
                Value<bool> correct = const Value.absent(),
                Value<int> incorrectBefore = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
              }) => AttemptEntriesCompanion(
                id: id,
                lessonId: lessonId,
                exerciseId: exerciseId,
                submittedAnswer: submittedAnswer,
                correct: correct,
                incorrectBefore: incorrectBefore,
                occurredAt: occurredAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String lessonId,
                required String exerciseId,
                required String submittedAnswer,
                required bool correct,
                required int incorrectBefore,
                required DateTime occurredAt,
              }) => AttemptEntriesCompanion.insert(
                id: id,
                lessonId: lessonId,
                exerciseId: exerciseId,
                submittedAnswer: submittedAnswer,
                correct: correct,
                incorrectBefore: incorrectBefore,
                occurredAt: occurredAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AttemptEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttemptEntriesTable,
      AttemptEntry,
      $$AttemptEntriesTableFilterComposer,
      $$AttemptEntriesTableOrderingComposer,
      $$AttemptEntriesTableAnnotationComposer,
      $$AttemptEntriesTableCreateCompanionBuilder,
      $$AttemptEntriesTableUpdateCompanionBuilder,
      (
        AttemptEntry,
        BaseReferences<_$AppDatabase, $AttemptEntriesTable, AttemptEntry>,
      ),
      AttemptEntry,
      PrefetchHooks Function()
    >;
typedef $$LessonProgressEntriesTableCreateCompanionBuilder =
    LessonProgressEntriesCompanion Function({
      required String lessonId,
      required int exerciseIndex,
      required int xp,
      Value<DateTime?> completedAt,
      Value<int> rowid,
    });
typedef $$LessonProgressEntriesTableUpdateCompanionBuilder =
    LessonProgressEntriesCompanion Function({
      Value<String> lessonId,
      Value<int> exerciseIndex,
      Value<int> xp,
      Value<DateTime?> completedAt,
      Value<int> rowid,
    });

class $$LessonProgressEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $LessonProgressEntriesTable> {
  $$LessonProgressEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get exerciseIndex => $composableBuilder(
    column: $table.exerciseIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get xp => $composableBuilder(
    column: $table.xp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LessonProgressEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $LessonProgressEntriesTable> {
  $$LessonProgressEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get exerciseIndex => $composableBuilder(
    column: $table.exerciseIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get xp => $composableBuilder(
    column: $table.xp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LessonProgressEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LessonProgressEntriesTable> {
  $$LessonProgressEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get lessonId =>
      $composableBuilder(column: $table.lessonId, builder: (column) => column);

  GeneratedColumn<int> get exerciseIndex => $composableBuilder(
    column: $table.exerciseIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get xp =>
      $composableBuilder(column: $table.xp, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );
}

class $$LessonProgressEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LessonProgressEntriesTable,
          LessonProgressEntry,
          $$LessonProgressEntriesTableFilterComposer,
          $$LessonProgressEntriesTableOrderingComposer,
          $$LessonProgressEntriesTableAnnotationComposer,
          $$LessonProgressEntriesTableCreateCompanionBuilder,
          $$LessonProgressEntriesTableUpdateCompanionBuilder,
          (
            LessonProgressEntry,
            BaseReferences<
              _$AppDatabase,
              $LessonProgressEntriesTable,
              LessonProgressEntry
            >,
          ),
          LessonProgressEntry,
          PrefetchHooks Function()
        > {
  $$LessonProgressEntriesTableTableManager(
    _$AppDatabase db,
    $LessonProgressEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LessonProgressEntriesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LessonProgressEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LessonProgressEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> lessonId = const Value.absent(),
                Value<int> exerciseIndex = const Value.absent(),
                Value<int> xp = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LessonProgressEntriesCompanion(
                lessonId: lessonId,
                exerciseIndex: exerciseIndex,
                xp: xp,
                completedAt: completedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String lessonId,
                required int exerciseIndex,
                required int xp,
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LessonProgressEntriesCompanion.insert(
                lessonId: lessonId,
                exerciseIndex: exerciseIndex,
                xp: xp,
                completedAt: completedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LessonProgressEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LessonProgressEntriesTable,
      LessonProgressEntry,
      $$LessonProgressEntriesTableFilterComposer,
      $$LessonProgressEntriesTableOrderingComposer,
      $$LessonProgressEntriesTableAnnotationComposer,
      $$LessonProgressEntriesTableCreateCompanionBuilder,
      $$LessonProgressEntriesTableUpdateCompanionBuilder,
      (
        LessonProgressEntry,
        BaseReferences<
          _$AppDatabase,
          $LessonProgressEntriesTable,
          LessonProgressEntry
        >,
      ),
      LessonProgressEntry,
      PrefetchHooks Function()
    >;
typedef $$StudyDayEntriesTableCreateCompanionBuilder =
    StudyDayEntriesCompanion Function({
      required String dayKey,
      required int xp,
      Value<int> rowid,
    });
typedef $$StudyDayEntriesTableUpdateCompanionBuilder =
    StudyDayEntriesCompanion Function({
      Value<String> dayKey,
      Value<int> xp,
      Value<int> rowid,
    });

class $$StudyDayEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $StudyDayEntriesTable> {
  $$StudyDayEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get dayKey => $composableBuilder(
    column: $table.dayKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get xp => $composableBuilder(
    column: $table.xp,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StudyDayEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $StudyDayEntriesTable> {
  $$StudyDayEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get dayKey => $composableBuilder(
    column: $table.dayKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get xp => $composableBuilder(
    column: $table.xp,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StudyDayEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $StudyDayEntriesTable> {
  $$StudyDayEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get dayKey =>
      $composableBuilder(column: $table.dayKey, builder: (column) => column);

  GeneratedColumn<int> get xp =>
      $composableBuilder(column: $table.xp, builder: (column) => column);
}

class $$StudyDayEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StudyDayEntriesTable,
          StudyDayEntry,
          $$StudyDayEntriesTableFilterComposer,
          $$StudyDayEntriesTableOrderingComposer,
          $$StudyDayEntriesTableAnnotationComposer,
          $$StudyDayEntriesTableCreateCompanionBuilder,
          $$StudyDayEntriesTableUpdateCompanionBuilder,
          (
            StudyDayEntry,
            BaseReferences<_$AppDatabase, $StudyDayEntriesTable, StudyDayEntry>,
          ),
          StudyDayEntry,
          PrefetchHooks Function()
        > {
  $$StudyDayEntriesTableTableManager(
    _$AppDatabase db,
    $StudyDayEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudyDayEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudyDayEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudyDayEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> dayKey = const Value.absent(),
                Value<int> xp = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StudyDayEntriesCompanion(
                dayKey: dayKey,
                xp: xp,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String dayKey,
                required int xp,
                Value<int> rowid = const Value.absent(),
              }) => StudyDayEntriesCompanion.insert(
                dayKey: dayKey,
                xp: xp,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StudyDayEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StudyDayEntriesTable,
      StudyDayEntry,
      $$StudyDayEntriesTableFilterComposer,
      $$StudyDayEntriesTableOrderingComposer,
      $$StudyDayEntriesTableAnnotationComposer,
      $$StudyDayEntriesTableCreateCompanionBuilder,
      $$StudyDayEntriesTableUpdateCompanionBuilder,
      (
        StudyDayEntry,
        BaseReferences<_$AppDatabase, $StudyDayEntriesTable, StudyDayEntry>,
      ),
      StudyDayEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AttemptEntriesTableTableManager get attemptEntries =>
      $$AttemptEntriesTableTableManager(_db, _db.attemptEntries);
  $$LessonProgressEntriesTableTableManager get lessonProgressEntries =>
      $$LessonProgressEntriesTableTableManager(_db, _db.lessonProgressEntries);
  $$StudyDayEntriesTableTableManager get studyDayEntries =>
      $$StudyDayEntriesTableTableManager(_db, _db.studyDayEntries);
}
