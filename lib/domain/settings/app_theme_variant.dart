/// Selectable CroLingo appearance.
///
/// The stored name is a durable settings value. Never rename an entry after it
/// has shipped; add a new one instead.
enum AppThemeVariant {
  /// Original Adriatic blue appearance.
  adriatic,

  /// Neon violet night appearance.
  neonViolet,

  /// Deep black appearance.
  midnight,

  /// Soft mint appearance.
  mint,

  /// Maximum-contrast appearance for low vision.
  highContrast;

  /// Resolves a stored name, falling back to [adriatic] for unknown values.
  static AppThemeVariant fromStorage(String? name) {
    for (final variant in values) {
      if (variant.name == name) return variant;
    }
    return adriatic;
  }
}
