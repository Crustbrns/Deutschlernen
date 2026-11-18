import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/domain/models/word_status.dart';

class AppStrings {
  const AppStrings(this._values, {this.languageCode = 'en'});

  final Map<String, String> _values;

  /// Interface language; picks the plural forms in [wordCount].
  final String languageCode;

  // A missing key shows its own name, so gaps are easy to spot.
  String _get(String key) => _values[key] ?? key;

  String get known => _get('known');
  String get learn => _get('learn');
  String get close => _get('close');
  String get back => _get('back');
  String get interfaceLanguage => _get('interfaceLanguage');
  String get wordsLanguage => _get('wordsLanguage');
  String get systemLanguage => _get('systemLanguage');
  String get settingsAppearance => _get('settingsAppearance');
  String get settingsLanguages => _get('settingsLanguages');
  String get settingsVoice => _get('settingsVoice');
  String get settingsNotifications => _get('settingsNotifications');
  String get theme => _get('theme');
  String get themeDark => _get('themeDark');
  String get themeLight => _get('themeLight');
  String get themeSystem => _get('themeSystem');
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
  String get finish => _get('finish');
  String get settingsProgress => _get('settingsProgress');
  String get resetAllProgress => _get('resetAllProgress');
  String get resetAllConfirmTitle => _get('resetAllConfirmTitle');
  String get resetAllConfirmBody => _get('resetAllConfirmBody');
  String get resetConfirm => _get('resetConfirm');
  String get cancel => _get('cancel');
  String get resetProgress => _get('resetProgress');
  String get forgot => _get('forgot');
  String get remembered => _get('remembered');
  String get tabLearn => _get('tabLearn');
  String get tabCategories => _get('tabCategories');
  String get tabProgress => _get('tabProgress');
  String get tabSettings => _get('tabSettings');
  String get learnNewWords => _get('learnNewWords');
  String get repeatWords => _get('repeatWords');
  String get chooseLevels => _get('chooseLevels');
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
  String get statsPeriodWeek => _get('statsPeriodWeek');
  String get statsPeriodMonth => _get('statsPeriodMonth');
  String get statsPeriodQuarter => _get('statsPeriodQuarter');
  String get statsPeriodAll => _get('statsPeriodAll');
  String get statusKnown => _get('statusKnown');
  String get statsLearning => _get('statsLearning');
  String get statsReview => _get('statsReview');
  String get statsLearned => _get('statsLearned');
  String get statsEmpty => _get('statsEmpty');

  /// Short date, "16 ноя" / "16 Nov" / "11月 16日": the order comes from
  /// `dateShort` ({d}, {m}), the month from `monthsShort` (12, comma-separated).
  /// The space lets a narrow label break into day and month.
  String dateShort(DateTime date) =>
      _get('dateShort')
          .replaceAll('{d}', '${date.day}')
          .replaceAll('{m}', monthShort(date));

  /// Short month name, "ноя" / "Nov" / "11月".
  String monthShort(DateTime date) {
    final months = _get('monthsShort').split(',');
    return months.length == 12 ? months[date.month - 1] : '${date.month}';
  }

  /// Monday first; stored comma-separated in one key ("Пн,Вт,…").
  List<String> get weekdaysShort => _get('weekdaysShort').split(',');
  List<String> get weekdaysLong => _get('weekdaysLong').split(',');

  // Reminders (settings and the notifications themselves).
  String get done => _get('done');
  String get reminderKinds => _get('reminderKinds');
  String get reminderSchedule => _get('reminderSchedule');
  String get reminderKindReview => _get('reminderKindReview');
  String get reminderKindReviewHint => _get('reminderKindReviewHint');
  String get reminderKindLearn => _get('reminderKindLearn');
  String get reminderKindLearnHint => _get('reminderKindLearnHint');
  String get reminderDays => _get('reminderDays');
  String get reminderEveryDay => _get('reminderEveryDay');
  String get reminderWeekdays => _get('reminderWeekdays');
  String get reminderWeekend => _get('reminderWeekend');
  String get reminderFrequency => _get('reminderFrequency');
  String get reminderTime => _get('reminderTime');

  /// "Время 2": one of several reminder times.
  String reminderTimeN(int n) => _get('reminderTimeN').replaceAll('{n}', '$n');

  /// "2 раза" / "Twice": how many reminders a day.
  String reminderTimesPerDay(int n) => _plural('reminderTimesPerDay', n);
  String get reminderReviewTitle => _get('reminderReviewTitle');

  /// "12 слов ждут повторения".
  String reminderReviewBody(int n) => _plural('reminderReviewBody', n);
  String get reminderLearnTitle => _get('reminderLearnTitle');
  String get reminderLearnBody => _get('reminderLearnBody');
  String get notificationsDeniedTitle => _get('notificationsDeniedTitle');
  String get notificationsDeniedBody => _get('notificationsDeniedBody');
  String get openSettings => _get('openSettings');

  /// "1 слово", "2 слова", "5 слов" / "1 word", "5 words".
  /// JSON keys: wordCountOne, wordCountFew, wordCountMany, wordCountOther,
  /// with {n} for the number. A language uses only the forms it has;
  /// a missing form falls back to wordCountOther.
  String wordCount(int n) => _plural('wordCount', n);

  /// "Искали 3 раза" / "Looked up 3 times": shown on a searched word's card.
  String lookupCount(int n) => _plural('lookupCount', n);

  /// "Выучено сегодня: 3 из 10".
  String learnedToday(int n, int goal) =>
      _get('learnedToday')
          .replaceAll('{n}', '$n')
          .replaceAll('{goal}', '$goal');

  /// "Выбрано 3 категории": the learn menu's categories row.
  String levelsSelected(int n) => _plural('levelsSelected', n);

  /// Caption of a word in the lists and the opened card's header:
  /// "Новое слово", "Уже знаю", "Учится" (chosen, never reviewed), or just
  /// when it comes back: "Повтор через 8 мин" / "Повторить сейчас".
  String wordState(WordState state, DateTime now) {
    switch (state.status) {
      case WordStatus.newWord:
        return _get('statusNew');
      case WordStatus.known:
        return _get('statusKnown');
      case WordStatus.learning:
        return _get('statusLearning');
      case WordStatus.review || WordStatus.learned:
        final wait = state.due?.difference(now);
        return _capitalize(
          (wait == null || wait <= Duration.zero)
              ? _get('reviewNow')
              : reviewIn(wait),
        );
    }
  }

  /// "повтор через 5 мин / 3 ч / 4 дн. / 2 мес." Rounded up, so it never
  /// says "0 min" for a word that isn't due yet.
  String reviewIn(Duration wait) {
    final minutes = (wait.inSeconds / 60).ceil();
    if (minutes < 60) return _plural('reviewInMinutes', minutes);
    final hours = (minutes / 60).ceil();
    if (hours < 24) return _plural('reviewInHours', hours);
    final days = (hours / 24).ceil();
    if (days < 30) return _plural('reviewInDays', days);
    return _plural('reviewInMonths', (days / 30).round());
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

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
