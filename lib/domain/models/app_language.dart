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
