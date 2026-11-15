import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/data/repositories/settings_repository.dart';
import 'package:deutschlernen/data/repositories/word_repository.dart';
import 'package:deutschlernen/data/services/speech_service.dart';
import 'package:deutschlernen/data/repositories/language_repository.dart';
import 'package:deutschlernen/data/services/asset_service.dart';
import 'package:deutschlernen/ui/cards/view_models/cards_view_model.dart';
import 'package:deutschlernen/ui/core/app_style.dart';
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
  final _settingsRepository = SettingsRepository();
  late final SettingsViewModel _settingsViewModel = SettingsViewModel(
    settingsRepository: _settingsRepository,
    speechService: _speechService,
  )..load();
  late final CardsViewModel _cardsViewModel = CardsViewModel(
    wordRepository: WordRepository(assetService: _assetService),
    languageRepository: LanguageRepository(assetService: _assetService),
    settingsRepository: _settingsRepository,
    speechService: _speechService,
    settingsViewModel: _settingsViewModel,
  )..load();

  @override
  void dispose() {
    _cardsViewModel.dispose();
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
        home: HomeShell(
          viewModel: _cardsViewModel,
          settingsViewModel: _settingsViewModel,
        ),
      ),
    );
  }
}
