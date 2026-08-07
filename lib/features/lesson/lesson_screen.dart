import 'dart:async';

import 'package:crolingo/core/theme/app_colors.dart';
import 'package:crolingo/core/widgets/speech_button.dart';
import 'package:crolingo/data/course/asset_course_repository.dart';
import 'package:crolingo/domain/audio/feedback_audio_service.dart';
import 'package:crolingo/domain/course/course.dart';
import 'package:crolingo/domain/learning/answer_grader.dart';
import 'package:crolingo/domain/learning/lesson_session.dart';
import 'package:crolingo/domain/progress/progress_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Interactive player for one bundled lesson.
class LessonScreen extends StatefulWidget {
  /// Creates a lesson player for a stable lesson ID.
  const LessonScreen({
    required this.lessonId,
    this.lesson,
    this.repository,
    this.feedbackAudioService,
    this.feedbackSoundsEnabled = true,
    super.key,
  });

  /// Lesson to load.
  final String lessonId;

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
    final allProgress = await widget.repository?.loadLessonProgress();
    final progress = allProgress
        ?.where((item) => item.lessonId == widget.lessonId)
        .firstOrNull;
    return _LessonPayload(lesson, progress);
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
  const _LessonPlayer({
    required this.lesson,
    required this.progress,
    required this.repository,
    required this.feedbackAudioService,
    required this.feedbackSoundsEnabled,
  });

  final Lesson lesson;
  final LessonProgress? progress;
  final ProgressRepository? repository;
  final FeedbackAudioService? feedbackAudioService;
  final bool feedbackSoundsEnabled;

  @override
  State<_LessonPlayer> createState() => _LessonPlayerState();
}

class _LessonPlayerState extends State<_LessonPlayer> {
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
    final state = _session.state;
    await widget.repository?.saveLessonProgress(
      LessonProgress(
        lessonId: widget.lesson.id,
        exerciseIndex: state.index,
        xp: state.xp,
        completedAt: state.isComplete ? DateTime.now().toUtc() : null,
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
      return _Completion(lesson: widget.lesson, xp: state.xp);
    }
    final exercise = widget.lesson.exercises[state.index];
    return Column(
      children: [
        _LessonHeader(
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
  const _LessonPayload(this.lesson, this.progress);

  final Lesson lesson;
  final LessonProgress? progress;
}

class _LessonHeader extends StatelessWidget {
  const _LessonHeader({required this.progress, required this.xp});

  final double progress;
  final int xp;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(8, 10, 18, 8),
    child: Row(
      children: [
        IconButton(
          tooltip: 'Lektion schließen',
          onPressed: () => context.pop(),
          icon: const Icon(Icons.close_rounded),
        ),
        Expanded(
          child: Semantics(
            label: '${(progress * 100).round()} Prozent abgeschlossen',
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Icon(Icons.bolt_rounded, color: AppColors.crown),
        Text('$xp XP', style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    ),
  );
}

class _ExerciseView extends StatefulWidget {
  const _ExerciseView({
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
  final _controller = TextEditingController();
  final _matching = <String, String>{};
  final _selectedTiles = <String>[];

  bool get _hasFeedback => widget.grade != null;
  bool get _isCorrect => widget.grade?.isCorrect ?? false;

  String get _answer {
    switch (widget.exercise.type) {
      case ExerciseType.matching:
        final complete = widget.exercise.pairs.every(
          (pair) => _matching[pair.croatian] == pair.german,
        );
        return complete ? 'vollständig' : 'nicht vollständig';
      case ExerciseType.sentence:
        return _selectedTiles.join(' ');
      case ExerciseType.translation:
      case ExerciseType.fillBlank:
        return _controller.text;
    }
  }

  bool get _canSubmit => switch (widget.exercise.type) {
    ExerciseType.matching => _matching.length == widget.exercise.pairs.length,
    ExerciseType.sentence => _selectedTiles.isNotEmpty,
    ExerciseType.translation ||
    ExerciseType.fillBlank => _controller.text.trim().isNotEmpty,
  };

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Expanded(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          children: [
            _LanguageDirectionHeader(
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
        _Feedback(
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
    return _canSubmit ? () => widget.onSubmit(_answer) : null;
  }

  Widget _input() => switch (widget.exercise.type) {
    ExerciseType.matching => _matchingInput(),
    ExerciseType.sentence => _sentenceInput(),
    ExerciseType.translation || ExerciseType.fillBlank => TextField(
      key: const Key('answerField'),
      controller: _controller,
      enabled: !_hasFeedback,
      autocorrect: false,
      enableSuggestions: false,
      textCapitalization: TextCapitalization.sentences,
      onChanged: (_) => setState(() {}),
      onSubmitted: _canSubmit && !_hasFeedback ? widget.onSubmit : null,
      decoration: InputDecoration(
        labelText:
            widget.exercise.masteryDimension ==
                MasteryDimension.croatianToGerman
            ? 'Deine Antwort auf Deutsch'
            : 'Deine Antwort auf Kroatisch',
        border: const OutlineInputBorder(),
      ),
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

  Widget _matchingInput() {
    final choices = widget.exercise.pairs.map((pair) => pair.german).toList();
    return Column(
      children: [
        for (final pair in widget.exercise.pairs)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        pair.croatian,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    SpeechButton(text: pair.croatian),
                  ],
                ),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _matching[pair.croatian],
                  decoration: const InputDecoration(
                    labelText: 'Deutsche Bedeutung',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (final choice in choices.reversed)
                      DropdownMenuItem(value: choice, child: Text(choice)),
                  ],
                  onChanged: _hasFeedback
                      ? null
                      : (value) => setState(() {
                          if (value != null) _matching[pair.croatian] = value;
                        }),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _sentenceInput() {
    final remaining = widget.exercise.tiles.where(
      (tile) => !_selectedTiles.contains(tile),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 72),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Wrap(
            spacing: 8,
            children: [
              for (final tile in _selectedTiles)
                ActionChip(
                  label: Text(tile),
                  onPressed: _hasFeedback
                      ? null
                      : () => setState(() => _selectedTiles.remove(tile)),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          children: [
            for (final tile in remaining)
              ActionChip(
                label: Text(tile),
                onPressed: _hasFeedback
                    ? null
                    : () => setState(() => _selectedTiles.add(tile)),
              ),
          ],
        ),
      ],
    );
  }
}

class _LanguageDirectionHeader extends StatelessWidget {
  const _LanguageDirectionHeader({required this.dimension});

  final MasteryDimension dimension;

  @override
  Widget build(BuildContext context) {
    final (visible, accessible) = switch (dimension) {
      MasteryDimension.recognition => (
        '🇭🇷 Hrvatski ↔ 🇩🇪 Deutsch',
        'Kroatisch und Deutsch zuordnen',
      ),
      MasteryDimension.croatianToGerman => (
        '🇭🇷 Hrvatski → 🇩🇪 Deutsch',
        'Von Kroatisch nach Deutsch',
      ),
      MasteryDimension.germanToCroatian ||
      MasteryDimension.sentenceProduction ||
      MasteryDimension.grammarApplication => (
        '🇩🇪 Deutsch → 🇭🇷 Hrvatski',
        'Von Deutsch nach Kroatisch',
      ),
    };
    return Semantics(
      label: accessible,
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.selectedSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Center(
            child: Text(
              visible,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ),
    );
  }
}

class _Feedback extends StatelessWidget {
  const _Feedback({
    required this.correct,
    required this.submitted,
    required this.correction,
    required this.croatianCorrection,
    required this.explanation,
  });

  final bool correct;
  final String submitted;
  final String correction;
  final String? croatianCorrection;
  final String explanation;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Container(
      width: double.infinity,
      color: correct ? const Color(0xFFE6F6ED) : const Color(0xFFFCEAEC),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                correct ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: correct ? AppColors.success : AppColors.error,
              ),
              const SizedBox(width: 8),
              Text(
                correct ? 'Richtig!' : 'Noch nicht richtig',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          if (!correct) Text('Deine Antwort: $submitted'),
          Row(
            children: [
              Expanded(child: Text('Lösung: $correction')),
              if (croatianCorrection != null)
                SpeechButton(text: croatianCorrection!),
            ],
          ),
          Text(explanation),
        ],
      ),
    ),
  );
}

class _Completion extends StatelessWidget {
  const _Completion({required this.lesson, required this.xp});

  final Lesson lesson;
  final int xp;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.workspace_premium_rounded,
            size: 84,
            color: AppColors.crown,
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
            onPressed: () => context.go('/path'),
            child: const Text('Zum Lernweg'),
          ),
        ],
      ),
    ),
  );
}

class _LoadFailure extends StatelessWidget {
  const _LoadFailure({required this.onClose});

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
