import 'package:crolingo/core/motion/app_motion.dart';
import 'package:crolingo/core/theme/app_theme.dart';
import 'package:crolingo/domain/settings/app_theme_variant.dart';
import 'package:crolingo/features/lesson/widgets/answer_feedback.dart';
import 'package:crolingo/features/lesson/widgets/lesson_celebration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Runs an interactive, data-free preview of CroLingo's motion language.
void main() => runApp(const ProviderScope(child: _PreviewApp()));

class _PreviewApp extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.themeFor(AppThemeVariant.adriatic),
    home: const _MotionPreview(),
  );
}

class _MotionPreview extends StatefulWidget {
  const new();

  @override
  State<_MotionPreview> createState() => _MotionPreviewState();
}

class _MotionPreviewState extends State<_MotionPreview> {
  bool _celebrating = false;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 412),
          child: AnimatedSwitcher(
            duration: AppMotion.responsive(context, AppMotion.standard),
            child: _celebrating
                ? LessonCelebration(
                    key: const ValueKey('celebration'),
                    lessonTitle: 'Begrüßen & Vorstellen',
                    xp: 48,
                    actionLabel: 'Noch einmal ansehen',
                    onContinue: () => setState(() => _celebrating = false),
                  )
                : ListView(
                    key: const ValueKey('feedback'),
                    padding: const EdgeInsets.all(20),
                    children: [
                      MotionEntrance(
                        child: Text(
                          'CroLingo Motion Preview',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const MotionEntrance(
                        delay: Duration(milliseconds: 45),
                        child: Text(
                          'Kurze Bewegungen bestätigen Handlungen, ohne den '
                          'Lernfluss aufzuhalten.',
                        ),
                      ),
                      const SizedBox(height: 24),
                      const AnswerFeedback(
                        correct: true,
                        submitted: 'Dobar dan!',
                        correction: 'Dobar dan!',
                        croatianCorrection: null,
                        explanation: 'Dobar steht vor dan.',
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () => setState(() => _celebrating = true),
                        icon: const Icon(Icons.celebration_rounded),
                        label: const Text('Sieg-Animation zeigen'),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    ),
  );
}
