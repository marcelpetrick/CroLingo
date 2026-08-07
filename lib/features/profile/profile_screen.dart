import 'package:crolingo/app/providers.dart';
import 'package:crolingo/core/theme/app_colors.dart';
import 'package:crolingo/data/course/asset_course_repository.dart';
import 'package:crolingo/domain/course/course.dart';
import 'package:crolingo/domain/progress/concept_mastery.dart';
import 'package:crolingo/domain/progress/progress_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Complete local learning statistics without accounts or telemetry.
class ProfileScreen extends ConsumerStatefulWidget {
  /// Creates the profile screen.
  const ProfileScreen({this.course, super.key});

  /// Optional deterministic course source for embedded hosts and tests.
  final Future<Course>? course;

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late final Future<_ProfileData> _data = _load();

  Future<_ProfileData> _load() async {
    final repository = ref.read(progressRepositoryProvider);
    final stats = await repository.loadStats();
    final course = await (widget.course ?? AssetCourseRepository().load());
    final attempts = await repository.loadAttemptHistory();
    final learned = ConceptMasteryCalculator.calculate(
      course,
      attempts,
    ).where((concept) => concept.scores.isNotEmpty).length;
    return _ProfileData(stats: stats, learnedConcepts: learned);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<_ProfileData>(
    future: _data,
    builder: (context, snapshot) => CustomScrollView(
      slivers: [
        SliverAppBar.large(
          leading: IconButton(
            tooltip: 'Zurück',
            onPressed: context.pop,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          title: const Text('Profil & Statistik'),
        ),
        if (snapshot.hasError)
          const SliverFillRemaining(
            child: Center(
              child: Text('Statistik konnte nicht geladen werden.'),
            ),
          )
        else if (!snapshot.hasData)
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
            sliver: SliverList.separated(
              itemCount: 7,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) => [
                _Stat(
                  icon: Icons.bolt_rounded,
                  value: '${snapshot.data!.stats.totalXp}',
                  label: 'XP insgesamt',
                ),
                _Stat(
                  icon: Icons.check_circle_outline_rounded,
                  value: '${snapshot.data!.stats.completedLessons}',
                  label: 'Lektionen',
                ),
                _Stat(
                  icon: Icons.menu_book_rounded,
                  value: '${snapshot.data!.learnedConcepts}',
                  label: 'Wörter gelernt',
                ),
                _Stat(
                  icon: Icons.calendar_today_outlined,
                  value: '${snapshot.data!.stats.studyDays}',
                  label: 'Lerntage',
                ),
                _Stat(
                  icon: Icons.local_fire_department_outlined,
                  value: '${snapshot.data!.stats.currentStreak}',
                  label: 'Aktuelle Serie',
                ),
                _Stat(
                  icon: Icons.emoji_events_outlined,
                  value: '${snapshot.data!.stats.longestStreak}',
                  label: 'Längste Serie',
                ),
                _Stat(
                  icon: Icons.flag_outlined,
                  value: _date(snapshot.data!.stats.startedOn),
                  label: 'Gestartet',
                ),
              ][index],
            ),
          ),
      ],
    ),
  );
}

class _ProfileData {
  const _ProfileData({required this.stats, required this.learnedConcepts});

  final LearningStats stats;
  final int learnedConcepts;
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 30),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
          ),
          const SizedBox(width: 8),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    ),
  );
}

String _date(DateTime? value) => value == null
    ? '—'
    : '${value.day.toString().padLeft(2, '0')}.'
          '${value.month.toString().padLeft(2, '0')}.${value.year}';
