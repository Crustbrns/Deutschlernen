/// How the card shows the word's explanation (a Settings choice).
enum DefinitionMode {
  /// Only in the translation language, no German (the default).
  translation,

  /// Only the German explanation.
  german,

  /// German; a tap shows the translation under it.
  germanTapForTranslation,
}
