import 'package:crolingo/data/progress/app_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;

  setUp(() => database = AppDatabase(NativeDatabase.memory()));
  tearDown(() => database.close());

  test('creates every table the app stores learning data in', () async {
    final tables = await database
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' "
          'ORDER BY name',
        )
        .map((row) => row.read<String>('name'))
        .get();

    expect(
      tables,
      containsAll([
        'app_setting_entries',
        'attempt_entries',
        'lesson_progress_entries',
        'study_day_entries',
      ]),
    );
  });

  test('round-trips one attempt with its grading context', () async {
    final occurredAt = DateTime.utc(2026, 8, 9, 10, 30);
    await database
        .into(database.attemptEntries)
        .insert(
          AttemptEntriesCompanion.insert(
            lessonId: 'hallo',
            exerciseId: 'hallo-1',
            submittedAnswer: 'Bok!',
            correct: true,
            incorrectBefore: 2,
            occurredAt: occurredAt,
          ),
        );

    final rows = await database.select(database.attemptEntries).get();

    expect(rows, hasLength(1));
    final row = rows.single;
    expect(row.id, isPositive);
    expect(row.lessonId, 'hallo');
    expect(row.exerciseId, 'hallo-1');
    expect(row.submittedAnswer, 'Bok!');
    expect(row.correct, isTrue);
    expect(row.incorrectBefore, 2);
    // Drift returns a local-flavoured DateTime, so compare instants.
    expect(row.occurredAt.isAtSameMomentAs(occurredAt), isTrue);
  });

  test('keeps one resumable checkpoint per lesson', () async {
    Future<void> save(int index, DateTime? completedAt) => database
        .into(database.lessonProgressEntries)
        .insertOnConflictUpdate(
          LessonProgressEntriesCompanion.insert(
            lessonId: 'hallo',
            exerciseIndex: index,
            xp: index * 10,
            completedAt: Value(completedAt),
          ),
        );

    await save(1, null);
    await save(3, DateTime.utc(2026, 8, 9));

    final rows = await database.select(database.lessonProgressEntries).get();

    expect(rows, hasLength(1), reason: 'lessonId is the primary key');
    expect(rows.single.exerciseIndex, 3);
    expect(rows.single.xp, 30);
    expect(
      rows.single.completedAt!.isAtSameMomentAs(DateTime.utc(2026, 8, 9)),
      isTrue,
    );
  });

  test('accumulates one row per local study day', () async {
    await database
        .into(database.studyDayEntries)
        .insert(StudyDayEntriesCompanion.insert(dayKey: '2026-08-08', xp: 20));
    await database
        .into(database.studyDayEntries)
        .insertOnConflictUpdate(
          StudyDayEntriesCompanion.insert(dayKey: '2026-08-08', xp: 35),
        );
    await database
        .into(database.studyDayEntries)
        .insert(StudyDayEntriesCompanion.insert(dayKey: '2026-08-09', xp: 10));

    final rows = await database.select(database.studyDayEntries).get()
      ..sort((left, right) => left.dayKey.compareTo(right.dayKey));

    expect(rows.map((row) => row.dayKey), ['2026-08-08', '2026-08-09']);
    expect(rows.first.xp, 35);
  });

  test('stores preferences as opaque key/value pairs', () async {
    await database
        .into(database.appSettingEntries)
        .insert(
          AppSettingEntriesCompanion.insert(
            key: 'theme_variant',
            value: 'midnight',
          ),
        );

    final row = await database.select(database.appSettingEntries).getSingle();

    expect(row.key, 'theme_variant');
    expect(row.value, 'midnight');
  });

  test('declares the shipped schema version', () {
    // A change here needs a matching forward migration, so it is pinned.
    expect(database.schemaVersion, 2);
  });

  test('adds the settings table when upgrading an older install', () async {
    final upgraded = AppDatabase(NativeDatabase.memory());
    addTearDown(upgraded.close);
    final migrator = Migrator(upgraded);

    // Simulate the schema before settings existed, then run the upgrade.
    await upgraded.customStatement('DROP TABLE app_setting_entries');
    await upgraded.migration.onUpgrade(migrator, 1, 2);

    await upgraded
        .into(upgraded.appSettingEntries)
        .insert(AppSettingEntriesCompanion.insert(key: 'k', value: 'v'));
    expect(
      await upgraded.select(upgraded.appSettingEntries).getSingle(),
      isA<AppSettingEntry>(),
    );
  });

  test('creates everything from scratch on a fresh install', () async {
    final fresh = AppDatabase(NativeDatabase.memory());
    addTearDown(fresh.close);

    await fresh.migration.onCreate(Migrator(fresh));

    expect(await fresh.select(fresh.attemptEntries).get(), isEmpty);
  });
}
