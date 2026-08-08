import 'package:crolingo/domain/settings/app_theme_variant.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('resolves every stored name', () {
    for (final variant in AppThemeVariant.values) {
      expect(AppThemeVariant.fromStorage(variant.name), variant);
    }
  });

  test('falls back to the default appearance for unusable values', () {
    // A value can be absent on first launch, or left behind by a future
    // release that offered an appearance this build does not know.
    expect(AppThemeVariant.fromStorage(null), AppThemeVariant.adriatic);
    expect(AppThemeVariant.fromStorage(''), AppThemeVariant.adriatic);
    expect(
      AppThemeVariant.fromStorage('sepia-from-a-later-release'),
      AppThemeVariant.adriatic,
    );
  });
}
