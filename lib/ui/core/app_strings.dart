import 'package:material_ui/material_ui.dart';

class AppStrings {
  const AppStrings(this._values, {this.languageCode = 'en'});

  final Map<String, String> _values;

  /// Interface language; picks the plural forms in [wordCount].
  final String languageCode;

  // A missing key shows its own name, so gaps are easy to spot.
  String _get(String key) => _values[key] ?? key;

  String get newWord => _get('newWord');
  String get showTranslation => _get('showTranslation');
  String get plural => _get('plural');
  String get known => _get('known');
  String get learn => _get('learn');
  String get close => _get('close');
  String get back => _get('back');
  String get menu => _get('menu');
  String get language => _get('language');
  String get interfaceLanguage => _get('interfaceLanguage');
  String get wordsLanguage => _get('wordsLanguage');
  String get settingsAppearance => _get('settingsAppearance');
  String get settingsLanguages => _get('settingsLanguages');
  String get settingsVoice => _get('settingsVoice');
  String get settingsNotifications => _get('settingsNotifications');
  String get theme => _get('theme');
  String get themeDark => _get('themeDark');
  String get themeLight => _get('themeLight');
  String get showTranscription => _get('showTranscription');
  String get showTranscriptionHint => _get('showTranscriptionHint');
  String get reminders => _get('reminders');
  String get remindersHint => _get('remindersHint');
  String get autoSpeak => _get('autoSpeak');
  String get autoSpeakHint => _get('autoSpeakHint');
  String get speechRate => _get('speechRate');
  String get speechRateHint => _get('speechRateHint');
  String get speedSlow => _get('speedSlow');
  String get speedFast => _get('speedFast');
  String get goodWork => _get('goodWork');
  String get restart => _get('restart');
  String get tabMain => _get('tabMain');
  String get tabVocabulary => _get('tabVocabulary');
  String get tabStatistics => _get('tabStatistics');
  String get tabSettings => _get('tabSettings');
  String get startLearning => _get('startLearning');
  String get learnNewWords => _get('learnNewWords');
  String get repeatWords => _get('repeatWords');
  String get soonLabel => _get('soonLabel'); // short, for a row's trailing
  String get chooseLevels => _get('chooseLevels');
  String get comingSoon => _get('comingSoon');
  String get modeShow => _get('modeShow');
  String get modeWrite => _get('modeWrite');
  String get modeChoice => _get('modeChoice');
  String get checkAnswer => _get('checkAnswer');
  String get answerHint => _get('answerHint');
  String get correct => _get('correct');
  String get wrongAnswer => _get('wrongAnswer');
  String get searchHint => _get('searchHint');
  String get nothingFound => _get('nothingFound');
  String get noWordsYet => _get('noWordsYet');

  /// "1 слово", "2 слова", "5 слов" / "1 word", "5 words".
  /// JSON keys: wordCountOne, wordCountFew, wordCountMany, wordCountOther,
  /// with {n} for the number. A language uses only the forms it has;
  /// a missing form falls back to wordCountOther.
  String wordCount(int n) => _plural('wordCount', n);

  /// "Искали 3 раза" / "Looked up 3 times": shown on a searched word's card.
  String lookupCount(int n) => _plural('lookupCount', n);

  /// "Выбрано 3 категории": the learn menu's categories row.
  String levelsSelected(int n) => _plural('levelsSelected', n);

  /// Template `<base><Form>` for n with {n} replaced; falls back to Other.
  String _plural(String base, int n) {
    final form = _pluralForm(n);
    final template = _values['$base$form'] ?? _get('${base}Other');
    return template.replaceAll('{n}', '$n');
  }

  /// Simplified CLDR plural rules for integers.
  String _pluralForm(int n) {
    switch (languageCode) {
      case 'ru' || 'uk':
        // 1, 21, 31 → One; 2–4, 22–24 → Few; 0, 5–20, 25–30 → Many.
        // 11–14 are Many: they end in 1–4 but are "teens".
        final mod10 = n % 10, mod100 = n % 100;
        if (mod10 == 1 && mod100 != 11) return 'One';
        if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
          return 'Few';
        }
        return 'Many';
      case 'zh':
        return 'Other'; // no plural forms
      default: // en, es: 1 → One, everything else → Other
        return n == 1 ? 'One' : 'Other';
    }
  }

  /// Texts for the current language: `AppStrings.of(context).known`.
  static AppStrings of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStringsScope>();
    assert(scope != null, 'No AppStringsScope found above this widget');
    return scope!.strings;
  }
}

class AppStringsScope extends InheritedWidget {
  const AppStringsScope({
    super.key,
    required this.strings,
    required super.child,
  });

  final AppStrings strings;

  @override
  bool updateShouldNotify(AppStringsScope oldWidget) =>
      strings != oldWidget.strings;
}
