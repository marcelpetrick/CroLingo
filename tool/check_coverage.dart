import 'dart:io';

const minimumCoverage = 95.0;

void main(List<String> arguments) {
  final path = arguments.isEmpty ? 'coverage/lcov.info' : arguments.single;
  final file = File(path);
  if (!file.existsSync()) {
    stderr.writeln('Coverage file not found: $path');
    exitCode = 1;
    return;
  }

  var found = 0;
  var hit = 0;
  var authoredFile = true;
  for (final line in file.readAsLinesSync()) {
    if (line.startsWith('SF:')) {
      final source = line.substring(3);
      authoredFile = !source.endsWith('.g.dart');
    } else if (authoredFile && line.startsWith('LF:')) {
      found += int.parse(line.substring(3));
    } else if (authoredFile && line.startsWith('LH:')) {
      hit += int.parse(line.substring(3));
    }
  }

  if (found == 0) {
    stderr.writeln('Coverage contains no authored Dart lines.');
    exitCode = 1;
    return;
  }

  final percentage = hit * 100 / found;
  stdout.writeln(
    'Line coverage: ${percentage.toStringAsFixed(2)}% ($hit/$found)',
  );
  if (percentage < minimumCoverage) {
    stderr.writeln('Required line coverage: $minimumCoverage%');
    exitCode = 1;
  }
}
