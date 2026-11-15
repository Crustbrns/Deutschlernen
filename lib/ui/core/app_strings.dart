import 'package:material_ui/material_ui.dart';

class AppStrings {
  const AppStrings(this._values);

  final Map<String, String> _values;

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
