/// How the card shows the word's explanation (a Settings choice).
enum DefinitionMode {
  /// Only in the translation language, no German (the default).
  translation,

  /// In the translation language; a tap shows the German one under it.
  translationTapForGerman,

  /// Only the German explanation.
  german,

  /// German; a tap shows the translation under it.
  germanTapForTranslation,
}
