import 'package:crolingo/data/progress/app_database.dart';
import 'package:crolingo/data/progress/drift_progress_repository.dart';
import 'package:crolingo/domain/progress/progress_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late DriftProgressRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = DriftProgressRepository(database);
  });

  tearDown(() => database.close());

  test('records every answer attempt in UTC', () async {
    await repository.recordAttempt(
      lessonId: 'begrussen',
      exerciseId: 'hello',
      submittedAnswer: 'Bok!',
      correct: true,
      incorrectBefore: 1,
      occurredAt: DateTime.parse('2026-08-07T10:00:00+02:00'),
    );

    final rows = await database.select(database.attemptEntries).get();
    expect(rows, hasLength(1));
    expect(rows.single.lessonId, 'begrussen');
    expect(rows.single.incorrectBefore, 1);
    expect(rows.single.occurredAt.toUtc(), DateTime.utc(2026, 8, 7, 8));
  });

  test('upserts resumable progress and aggregates local stats', () async {
    await repository.saveLessonProgress(
      const LessonProgress(
        lessonId: 'begrussen',
        exerciseIndex: 2,
        xp: 18,
        completedAt: null,
      ),
    );
    await repository.saveLessonProgress(
      LessonProgress(
        lessonId: 'begrussen',
        exerciseIndex: 3,
        xp: 48,
        completedAt: DateTime.utc(2026, 8, 7, 8),
      ),
    );
    await repository.saveLessonProgress(
      LessonProgress(
        lessonId: 'vorstellen',
        exerciseIndex: 3,
        xp: 50,
        completedAt: DateTime.utc(2026, 8, 7, 9),
      ),
    );

    final progress = await repository.loadLessonProgress();
    final stats = await repository.loadStats();
    expect(progress, hasLength(2));
    expect(progress.first.completedAt, isNotNull);
    expect(stats.totalXp, 98);
    expect(stats.completedLessons, 2);
    expect(stats.studyDays, 1);
  });
}
