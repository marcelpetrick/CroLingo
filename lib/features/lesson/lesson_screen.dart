import 'dart:async';

import 'package:crolingo/core/theme/app_theme.dart';
import 'package:crolingo/core/widgets/speech_button.dart';
import 'package:crolingo/data/course/asset_course_repository.dart';
import 'package:crolingo/domain/audio/feedback_audio_service.dart';
import 'package:crolingo/domain/course/course.dart';
import 'package:crolingo/domain/learning/answer_grader.dart';
import 'package:crolingo/domain/learning/lesson_session.dart';
import 'package:crolingo/domain/progress/progress_repository.dart';
import 'package:crolingo/features/lesson/widgets/answer_feedback.dart';
import 'package:crolingo/features/lesson/widgets/exercise_answer.dart';
import 'package:crolingo/features/lesson/widgets/language_direction_header.dart';
import 'package:crolingo/features/lesson/widgets/lesson_header.dart';
import 'package:crolingo/features/lesson/widgets/matching_input.dart';
import 'package:crolingo/features/lesson/widgets/sentence_input.dart';
import 'package:crolingo/features/lesson/widgets/text_answer_input.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Interactive player for one bundled lesson.
class LessonScreen extends StatefulWidget {
  /// Creates a lesson player for a stable lesson ID.
  const new({
    required this.lessonId,
    this.reviewExerciseId,
    this.lesson,
    this.repository,
    this.feedbackAudioService,
    this.feedbackSoundsEnabled = true,
    super.key,
  });

  /// Lesson to load.
  final String lessonId;

  /// One exercise to practise without changing lesson-unlock progress.
  final String? reviewExerciseId;

  /// Optional preloaded lesson for deterministic hosts and tests.
  final Future<Lesson>? lesson;

  /// Local progress storage; omitted only by isolated widget tests.
  final ProgressRepository? repository;

  /// Optional sound boundary, injected by the application host.
  final FeedbackAudioService? feedbackAudioService;

  /// Current persistent sound preference.
  final bool feedbackSoundsEnabled;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  late final Future<_LessonPayload> _lesson = _loadPayload();

  Future<_LessonPayload> _loadPayload() async {
    final lesson = await (widget.lesson ?? _loadLesson());
    final reviewExerciseId = widget.reviewExerciseId;
    if (reviewExerciseId != null) {
      final exercise = lesson.exercises
          .where((item) => item.id == reviewExerciseId)
          .firstOrNull;
      if (exercise == null) {
        throw StateError('Unknown review exercise: $reviewExerciseId');
      }
      return _LessonPayload(
        Lesson(id: lesson.id, title: lesson.title, exercises: [exercise]),
        null,
        isReview: true,
      );
    }
    final allProgress = await widget.repository?.loadLessonProgress();
    final progress = allProgress
        ?.where((item) => item.lessonId == widget.lessonId)
        .firstOrNull;
    return _LessonPayload(lesson, progress, isReview: false);
  }

  Future<Lesson> _loadLesson() async {
    final course = await AssetCourseRepository().load();
    return course.units
        .expand((unit) => unit.lessons)
        .firstWhere((lesson) => lesson.id == widget.lessonId);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: FutureBuilder<_LessonPayload>(
        future: _lesson,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _LoadFailure(onClose: () => context.pop());
          }
          final payload = snapshot.data;
          if (payload == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return _LessonPlayer(
            lesson: payload.lesson,
            progress: payload.progress,
            isReview: payload.isReview,
            repository: widget.repository,
            feedbackAudioService: widget.feedbackAudioService,
            feedbackSoundsEnabled: widget.feedbackSoundsEnabled,
          );
        },
      ),
    ),
  );
}

class _LessonPlayer extends StatefulWidget {
  const new({
    required this.lesson,
    required this.progress,
    required this.isReview,
    required this.repository,
    required this.feedbackAudioService,
    required this.feedbackSoundsEnabled,
  });

  final Lesson lesson;
  final LessonProgress? progress;
  final bool isReview;
  final ProgressRepository? repository;
  final FeedbackAudioService? feedbackAudioService;
  final bool feedbackSoundsEnabled;

  @override
  State<_LessonPlayer> createState() => _LessonPlayerState();
}

class _LessonPlayerState extends State<_LessonPlayer> {
  late final LessonProgress? _completedProgress =
      widget.progress?.completedAt == null ? null : widget.progress;
  late final LessonSession _session =
      widget.progress == null || widget.progress!.completedAt != null
      ? LessonSession(widget.lesson)
      : LessonSession.resume(
          widget.lesson,
          index: widget.progress!.exerciseIndex,
          xp: widget.progress!.xp,
        );
  Future<void> _pendingWrite = Future<void>.value();

  void _refresh(void Function() action) => setState(action);

  void _submit(String answer) {
    final exercise = widget.lesson.exercises[_session.state.index];
    final incorrectBefore = _session.state.incorrectAttempts;
    _refresh(() => _session.submit(answer));
    final grade = _session.state.grade!;
    if (widget.feedbackSoundsEnabled) {
      final service = widget.feedbackAudioService;
      if (service != null) {
        unawaited(
          service.play(
            grade.isCorrect
                ? AnswerFeedbackSound.success
                : AnswerFeedbackSound.failure,
          ),
        );
      }
    }
    final repository = widget.repository;
    if (repository != null) {
      _enqueue(() async {
        await repository.recordAttempt(
          lessonId: widget.lesson.id,
          exerciseId: exercise.id,
          submittedAnswer: answer,
          correct: grade.isCorrect,
          incorrectBefore: incorrectBefore,
          occurredAt: DateTime.now().toUtc(),
        );
        await _saveProgress();
      });
    }
  }

  void _enqueue(Future<void> Function() operation) {
    _pendingWrite = _pendingWrite.then((_) => operation());
    unawaited(_pendingWrite);
  }

  Future<void> _saveProgress() async {
    if (widget.isReview) return;
    final state = _session.state;
    final completedProgress = _completedProgress;
    await widget.repository?.saveLessonProgress(
      LessonProgress(
        lessonId: widget.lesson.id,
        exerciseIndex: state.index,
        xp: (completedProgress?.xp ?? 0) + state.xp,
        completedAt: state.isComplete
            ? DateTime.now().toUtc()
            : completedProgress?.completedAt,
      ),
    );
  }

  void _continue() {
    _refresh(_session.continueAfterCorrect);
    _enqueue(_saveProgress);
  }

  @override
  Widget build(BuildContext context) {
    final state = _session.state;
    if (state.isComplete) {
      return _Completion(
        lesson: widget.lesson,
        xp: state.xp,
        isReview: widget.isReview,
      );
    }
    final exercise = widget.lesson.exercises[state.index];
    return Column(
      children: [
        LessonHeader(
          progress:
              (state.index + ((state.grade?.isCorrect ?? false) ? 1 : 0)) /
              widget.lesson.exercises.length,
          xp: state.xp,
        ),
        Expanded(
          child: _ExerciseView(
            key: ValueKey('${exercise.id}-${state.grade == null}'),
            exercise: exercise,
            grade: state.grade,
            submittedAnswer: state.submittedAnswer,
            onSubmit: _submit,
            onRetry: () => _refresh(_session.retry),
            onContinue: _continue,
          ),
        ),
      ],
    );
  }
}

class _LessonPayload {
  const new(this.lesson, this.progress, {required this.isReview});

  final Lesson lesson;
  final LessonProgress? progress;
  final bool isReview;
}

class _ExerciseView extends StatefulWidget {
  const new({
    required this.exercise,
    required this.grade,
    required this.submittedAnswer,
    required this.onSubmit,
    required this.onRetry,
    required this.onContinue,
    super.key,
  });

  final Exercise exercise;
  final GradeResult? grade;
  final String? submittedAnswer;
  final ValueChanged<String> onSubmit;
  final VoidCallback onRetry;
  final VoidCallback onContinue;

  @override
  State<_ExerciseView> createState() => _ExerciseViewState();
}

class _ExerciseViewState extends State<_ExerciseView> {
  ExerciseAnswer _answer = ExerciseAnswer.empty;

  bool get _hasFeedback => widget.grade != null;
  bool get _isCorrect => widget.grade?.isCorrect ?? false;

  void _onAnswerChanged(ExerciseAnswer answer) =>
      setState(() => _answer = answer);

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Expanded(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          children: [
            LanguageDirectionHeader(
              dimension: widget.exercise.masteryDimension,
            ),
            const SizedBox(height: 14),
            Text(
              _instruction,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 14),
            _prompt(),
            const SizedBox(height: 28),
            _input(),
          ],
        ),
      ),
      if (_hasFeedback)
        AnswerFeedback(
          correct: _isCorrect,
          submitted: widget.submittedAnswer ?? '',
          correction: widget.exercise.acceptedAnswers.first,
          croatianCorrection:
              widget.exercise.type != ExerciseType.matching &&
                  widget.exercise.masteryDimension !=
                      MasteryDimension.croatianToGerman
              ? widget.exercise.acceptedAnswers.first
              : null,
          explanation: widget.exercise.explanation,
        ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _buttonAction,
            child: Text(_buttonLabel),
          ),
        ),
      ),
    ],
  );

  String get _instruction => switch (widget.exercise.type) {
    ExerciseType.matching => 'Was gehört zusammen?',
    ExerciseType.translation => 'Schreibe die Übersetzung',
    ExerciseType.fillBlank => 'Fülle die Lücke',
    ExerciseType.sentence => 'Ordne den Satz',
  };

  String get _buttonLabel {
    if (_isCorrect) return 'Weiter';
    if (_hasFeedback) return 'Noch einmal';
    return 'Prüfen';
  }

  VoidCallback? get _buttonAction {
    if (_isCorrect) return widget.onContinue;
    if (_hasFeedback) return widget.onRetry;
    return _answer.canSubmit ? () => widget.onSubmit(_answer.value) : null;
  }

  Widget _input() => switch (widget.exercise.type) {
    ExerciseType.matching => MatchingInput(
      exercise: widget.exercise,
      enabled: !_hasFeedback,
      onChanged: _onAnswerChanged,
    ),
    ExerciseType.sentence => SentenceInput(
      exercise: widget.exercise,
      enabled: !_hasFeedback,
      onChanged: _onAnswerChanged,
    ),
    ExerciseType.translation || ExerciseType.fillBlank => TextAnswerInput(
      exercise: widget.exercise,
      enabled: !_hasFeedback,
      onChanged: _onAnswerChanged,
      onSubmitted: widget.onSubmit,
    ),
  };

  Widget _prompt() {
    final croatianSource =
        widget.exercise.masteryDimension == MasteryDimension.croatianToGerman
        ? widget.exercise.prompt.replaceFirst('Übersetze:', '').trim()
        : null;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(widget.exercise.prompt)),
        if (croatianSource != null) SpeechButton(text: croatianSource),
      ],
    );
  }
}

class _Completion extends StatelessWidget {
  const new({required this.lesson, required this.xp, required this.isReview});

  final Lesson lesson;
  final int xp;
  final bool isReview;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.workspace_premium_rounded,
            size: 84,
            color: context.palette.crown,
          ),
          const SizedBox(height: 16),
          Text(
            'Lektion geschafft!',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 8),
          Text('${lesson.title} · $xp XP'),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => context.go(isReview ? '/review' : '/path'),
            child: Text(isReview ? 'Zur Wiederholung' : 'Zum Lernweg'),
          ),
        ],
      ),
    ),
  );
}

class _LoadFailure extends StatelessWidget {
  const new({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_outline_rounded, size: 48),
        const Text('Die Lektion konnte nicht geladen werden.'),
        TextButton(onPressed: onClose, child: const Text('Zurück')),
      ],
    ),
  );
}
