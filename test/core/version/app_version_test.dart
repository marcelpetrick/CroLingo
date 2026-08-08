import 'dart:io';

import 'package:crolingo/core/version/app_version.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reads the version from the bundled pubspec', () async {
    final version = await AppVersion(
      bundle: _StubBundle('name: crolingo\nversion: 1.2.3+45\n'),
    ).load();

    expect(version, '1.2.3+45');
  });

  test('matches the real pubspec, the single version source', () async {
    final source = File('pubspec.yaml').readAsStringSync();
    final expected = RegExp(
      r'^version:[ \t]*(\S+)',
      multiLine: true,
    ).firstMatch(source)!.group(1);

    final version = await AppVersion(bundle: _StubBundle(source)).load();

    expect(version, expected);
  });

  test('returns null when the pubspec declares no version', () async {
    final version = await AppVersion(
      bundle: _StubBundle('name: crolingo\n'),
    ).load();

    expect(version, isNull);
  });

  test(
    'returns null instead of failing when the asset is unavailable',
    () async {
      final version = await AppVersion(bundle: _BrokenBundle()).load();

      expect(version, isNull);
    },
  );
}

class _StubBundle extends CachingAssetBundle {
  _StubBundle(this.source);

  final String source;

  @override
  Future<ByteData> load(String key) async =>
      ByteData.sublistView(Uint8List.fromList(source.codeUnits));

  @override
  Future<String> loadString(String key, {bool cache = true}) async => source;
}

class _BrokenBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async =>
      throw const FormatException('missing asset');

  @override
  Future<String> loadString(String key, {bool cache = true}) async =>
      throw const FormatException('missing asset');
}
