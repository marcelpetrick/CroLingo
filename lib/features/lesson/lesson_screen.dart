import 'package:crolingo/core/theme/app_colors.dart';
import 'package:crolingo/data/course/asset_course_repository.dart';
import 'package:crolingo/domain/course/course.dart';
import 'package:crolingo/domain/learning/answer_grader.dart';
import 'package:crolingo/domain/learning/lesson_session.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Interactive player for one bundled lesson.
class LessonScreen extends StatefulWidget {
  /// Creates a lesson player for a stable lesson ID.
  const LessonScreen({required this.lessonId, this.lesson, super.key});

  /// Lesson to load.
  final String lessonId;

  /// Optional preloaded lesson for deterministic hosts and tests.
  final Future<Lesson>? lesson;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  late final Future<Lesson> _lesson = widget.lesson ?? _loadLesson();

  Future<Lesson> _loadLesson() async {
    final course = await AssetCourseRepository().load();
    return course.units
        .expand((unit) => unit.lessons)
        .firstWhere((lesson) => lesson.id == widget.lessonId);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: FutureBuilder<Lesson>(
        future: _lesson,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _LoadFailure(onClose: () => context.pop());
          }
          final lesson = snapshot.data;
          if (lesson == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return _LessonPlayer(lesson: lesson);
        },
      ),
    ),
  );
}

class _LessonPlayer extends StatefulWidget {
  const _LessonPlayer({required this.lesson});

  final Lesson lesson;

  @override
  State<_LessonPlayer> createState() => _LessonPlayerState();
}

class _LessonPlayerState extends State<_LessonPlayer> {
  late final LessonSession _session = LessonSession(widget.lesson);

  void _refresh(void Function() action) => setState(action);

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
            onSubmit: (answer) => _refresh(() => _session.submit(answer)),
            onRetry: () => _refresh(_session.retry),
            onContinue: () => _refresh(_session.continueAfterCorrect),
          ),
        ),
      ],
    );
  }
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
            Text(
              _instruction,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 14),
            Text(widget.exercise.prompt),
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
      decoration: const InputDecoration(
        labelText: 'Deine Antwort',
        border: OutlineInputBorder(),
      ),
    ),
  };

  Widget _matchingInput() {
    final choices = widget.exercise.pairs.map((pair) => pair.german).toList();
    return Column(
      children: [
        for (final pair in widget.exercise.pairs)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: DropdownButtonFormField<String>(
              initialValue: _matching[pair.croatian],
              decoration: InputDecoration(
                labelText: pair.croatian,
                border: const OutlineInputBorder(),
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

class _Feedback extends StatelessWidget {
  const _Feedback({
    required this.correct,
    required this.submitted,
    required this.correction,
    required this.explanation,
  });

  final bool correct;
  final String submitted;
  final String correction;
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
          Text('Lösung: $correction'),
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
