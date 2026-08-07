import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// Every submitted answer, including retries.
class AttemptEntries extends Table {
  /// Local monotonically increasing key.
  IntColumn get id => integer().autoIncrement()();

  /// Stable lesson ID.
  TextColumn get lessonId => text()();

  /// Stable exercise ID.
  TextColumn get exerciseId => text()();

  /// Learner submission, kept only in app-private storage.
  TextColumn get submittedAnswer => text()();

  /// Whether this attempt was accepted.
  BoolColumn get correct => boolean()();

  /// Prior errors on this exercise.
  IntColumn get incorrectBefore => integer()();

  /// UTC attempt time.
  DateTimeColumn get occurredAt => dateTime()();
}

/// Latest resumable state for each lesson.
class LessonProgressEntries extends Table {
  /// Stable lesson ID.
  TextColumn get lessonId => text()();

  /// Exercise to resume.
  IntColumn get exerciseIndex => integer()();

  /// XP earned in this lesson.
  IntColumn get xp => integer()();

  /// UTC completion time.
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {lessonId};
}

/// Distinct local calendar dates on which XP was earned.
class StudyDayEntries extends Table {
  /// ISO local date in `yyyy-MM-dd` form.
  TextColumn get dayKey => text()();

  /// XP earned on this date.
  IntColumn get xp => integer()();

  @override
  Set<Column<Object>> get primaryKey => {dayKey};
}

/// Extensible application preferences retained across app upgrades.
class AppSettingEntries extends Table {
  /// Stable preference key.
  TextColumn get key => text()();

  /// Version-independent serialized scalar value.
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

/// App-private SQLite database shared by Android and Linux.
@DriftDatabase(
  tables: [
    AttemptEntries,
    LessonProgressEntries,
    StudyDayEntries,
    AppSettingEntries,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Opens the production database, or an injected executor for tests.
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'crolingo'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(appSettingEntries);
      }
    },
  );
}
