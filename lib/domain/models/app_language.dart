class AppLanguage {
  const AppLanguage({
    required this.code,
    required this.label,
    required this.hello,
    required this.uiNote,
    required this.wordsNote,
  });

  factory AppLanguage.fromJson(Map<String, dynamic> json) {
    return AppLanguage(
      code: json['code'] as String,
      label: json['label'] as String,
      hello: json['hello'] as String,
      uiNote: json['uiNote'] as String,
      wordsNote: json['wordsNote'] as String,
    );
  }

  final String code; // ru, en, ...
  final String label; // shown in the language list

  // Preview in the language sheet, written in this language itself (not in
  // the interface language): the user reads how the choice will look.
  final String hello; // "Привет"
  final String uiNote; // "Меню и тексты на русском"
  final String wordsNote; // "Переводы слов на русском"

  @override
  bool operator ==(Object other) => other is AppLanguage && other.code == code;

  @override
  int get hashCode => code.hashCode;
}

/// Splits [languages] into the ones the user has on the device and the rest.
/// [deviceTags] are language tags ("uk-UA", "zh-Hans-CN") in the phone's
/// order; that order is kept, repeats and unknown languages are dropped.
({List<AppLanguage> onDevice, List<AppLanguage> others}) splitByDevice(
  List<AppLanguage> languages,
  List<String> deviceTags,
) {
  final byCode = {for (final l in languages) l.code: l};
  // A set literal is ordered, so the first mention wins.
  final onDevice = <AppLanguage>{};
  for (final tag in deviceTags) {
    final code = tag.split(RegExp('[-_]')).first.toLowerCase();
    final language = byCode[code];
    if (language != null) onDevice.add(language);
  }
  return (
    onDevice: onDevice.toList(),
    others: [
      for (final l in languages)
        if (!onDevice.contains(l)) l,
    ],
  );
}
