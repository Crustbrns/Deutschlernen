class AppLanguage {
  const AppLanguage({
    required this.code,
    required this.label,
    required this.country,
  });

  factory AppLanguage.fromJson(Map<String, dynamic> json) {
    return AppLanguage(
      code: json['code'] as String,
      label: json['label'] as String,
      country: json['country'] as String,
    );
  }

  final String code; // ru, en, ...
  final String label; // shown in the language list
  final String country; // two-letter country code, used for the flag

  /// Flag emoji built from the country code ("RU" -> 🇷🇺).
  String get flag => String.fromCharCodes(
        country.toUpperCase().codeUnits.map((unit) => 0x1F1E6 + unit - 0x41),
      );

  @override
  bool operator ==(Object other) => other is AppLanguage && other.code == code;

  @override
  int get hashCode => code.hashCode;
}