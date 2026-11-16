class AppLanguage {
  const AppLanguage({required this.code, required this.label});

  factory AppLanguage.fromJson(Map<String, dynamic> json) {
    return AppLanguage(
      code: json['code'] as String,
      label: json['label'] as String,
    );
  }

  final String code; // ru, en, ...
  final String label; // shown in the language list

  @override
  bool operator ==(Object other) => other is AppLanguage && other.code == code;

  @override
  int get hashCode => code.hashCode;
}
