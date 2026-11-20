import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/data/repositories/history_repository.dart';
import 'package:deutschlernen/data/repositories/lookup_repository.dart';
import 'package:deutschlernen/data/repositories/own_words_repository.dart';
import 'package:deutschlernen/data/repositories/progress_repository.dart';
import 'package:deutschlernen/data/services/review_scheduler.dart';
import 'package:deutschlernen/data/repositories/settings_repository.dart';
import 'package:deutschlernen/data/repositories/word_repository.dart';
import 'package:deutschlernen/data/services/notification_service.dart';
import 'package:deutschlernen/data/services/device_languages_service.dart';
import 'package:deutschlernen/data/services/speech_service.dart';
import 'package:deutschlernen/data/repositories/language_repository.dart';
import 'package:deutschlernen/data/services/asset_service.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/app_style.dart';
import 'package:deutschlernen/ui/core/view_models/language_view_model.dart';
import 'package:deutschlernen/ui/core/view_models/learning_view_model.dart';
import 'package:deutschlernen/ui/core/view_models/reminders_coordinator.dart';
import 'package:deutschlernen/ui/core/widgets/muted_banner.dart';
import 'package:deutschlernen/ui/home/widgets/home_shell.dart';
import 'package:deutschlernen/ui/settings/view_models/settings_view_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _assetService = AssetService();
  final _speechService = SpeechService();
  final _notificationService = NotificationService();
  final _settingsRepository = SettingsRepository();
  late final _settingsViewModel = SettingsViewModel(
    settingsRepository: _settingsRepository,
    speechService: _speechService,
    notificationService: _notificationService,
  );
  late final _languageViewModel = LanguageViewModel(
    languageRepository: LanguageRepository(assetService: _assetService),
    settingsRepository: _settingsRepository,
    deviceLanguages: DeviceLanguagesService(),
  );
  late final _learningViewModel = LearningViewModel(
    wordRepository: WordRepository(assetService: _assetService),
    settingsRepository: _settingsRepository,
    lookupRepository: LookupRepository(),
    ownWordsRepository: OwnWordsRepository(),
    progressRepository: ProgressRepository(),
    historyRepository: HistoryRepository(),
    reviewScheduler: ReviewScheduler(),
    speechService: _speechService,
    settingsViewModel: _settingsViewModel,
    languageViewModel: _languageViewModel,
  );
  late final _reminders = RemindersCoordinator(
    notifications: _notificationService,
    learning: _learningViewModel,
    settings: _settingsViewModel,
    languages: _languageViewModel,
  );

  /// The progress is final while the app is in the background, so that is
  /// when the reminders are planned.
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onHide: _reminders.reschedule);
    _load();
  }

  // Words are loaded in the translation language, so languages go first.
  Future<void> _load() async {
    await Future.wait([_settingsViewModel.load(), _languageViewModel.load()]);
    await _learningViewModel.load();
    await _reminders.start();
    await _reminders.reschedule();
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _reminders.dispose();
    _learningViewModel.dispose();
    _languageViewModel.dispose();
    _settingsViewModel.dispose();
    _speechService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _settingsViewModel,
      builder: (context, _) => MaterialApp(
        title: 'Deutsch lernen',
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: _settingsViewModel.themeMode,
        // Above the navigator: pushed routes, sheets, dialogs and hero
        // flights all read the strings without wrapping themselves again.
        builder: (context, navigator) => MediaQuery.withClampedTextScaling(
          // The iOS text size is followed up to ×1.3: beyond that the fixed
          // height controls (tabs, buttons, the week strip) clip their text.
          maxScaleFactor: 1.3,
          child: ListenableBuilder(
            listenable: _languageViewModel,
            builder: (context, _) => AppStringsScope(
              strings: _languageViewModel.strings,
              child: MutedBanner(
                mutedTaps: _speechService.mutedTaps,
                child: navigator!,
              ),
            ),
          ),
        ),
        home: HomeShell(
          viewModel: _learningViewModel,
          languageViewModel: _languageViewModel,
          settingsViewModel: _settingsViewModel,
          reminderOpened: _reminders.opened,
          onReminderHandled: _reminders.handled,
        ),
      ),
    );
  }
}
