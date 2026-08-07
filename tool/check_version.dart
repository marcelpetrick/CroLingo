import 'dart:io';

final versionPattern = RegExp(
  r'^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)\s*$',
  multiLine: true,
);

typedef AppVersion = ({int major, int minor, int patch, int build});

void main() {
  final staged = _git([
    'diff',
    '--cached',
    '--name-only',
    '--',
    'pubspec.yaml',
  ]).trim().isNotEmpty;
  final currentText = staged
      ? _git(['show', ':pubspec.yaml'])
      : _git(['show', 'HEAD:pubspec.yaml']);
  final previousReference = staged ? 'HEAD:pubspec.yaml' : 'HEAD^:pubspec.yaml';
  final previousText = _git(['show', previousReference]);

  final current = _parse(currentText, 'current pubspec.yaml');
  final previous = _parse(previousText, previousReference);

  if (current.build != previous.build + 1) {
    stderr.writeln(
      'Build number must increase exactly once: '
      '${previous.build} -> ${current.build}.',
    );
    exitCode = 1;
  }

  final currentCore =
      current.major * 1000000000 + current.minor * 1000000 + current.patch;
  final previousCore =
      previous.major * 1000000000 + previous.minor * 1000000 + previous.patch;
  if (currentCore <= previousCore) {
    stderr.writeln('Semantic version must increase in every commit.');
    exitCode = 1;
  }

  if (exitCode == 0) {
    stdout.writeln(
      'Version progression is valid: '
      '${previous.major}.${previous.minor}.${previous.patch}+${previous.build} '
      '-> ${current.major}.${current.minor}.${current.patch}+${current.build}',
    );
  }
}

AppVersion _parse(String text, String source) {
  final match = versionPattern.firstMatch(text);
  if (match == null) {
    stderr.writeln('Missing or invalid version in $source.');
    exit(1);
  }
  return (
    major: int.parse(match.group(1)!),
    minor: int.parse(match.group(2)!),
    patch: int.parse(match.group(3)!),
    build: int.parse(match.group(4)!),
  );
}

String _git(List<String> arguments) {
  final result = Process.runSync('git', arguments);
  if (result.exitCode != 0) {
    stderr.write(result.stderr);
    exit(result.exitCode);
  }
  return result.stdout as String;
}
