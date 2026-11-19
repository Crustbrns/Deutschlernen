class OwnWord {
  const OwnWord({
    required this.id,
    required this.german,
    required this.translation,
  });

  final String id;
  final String german;
  final String translation;

  Map<String, dynamic> toJson() => {
    'german': german,
    'translation': translation,
  };

  factory OwnWord.fromJson(String id, Map<String, dynamic> json) => OwnWord(
    id: id,
    german: json['german'] as String,
    translation: json['translation'] as String,
  );
}
