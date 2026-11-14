import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/data/repositories/settings_repository.dart';
import 'package:deutschlernen/data/repositories/word_repository.dart';
import 'package:deutschlernen/data/services/speech_service.dart';
import 'package:deutschlernen/data/repositories/language_repository.dart';
import 'package:deutschlernen/data/services/asset_service.dart';
import 'package:deutschlernen/ui/cards/view_models/cards_view_model.dart';
import 'package:deutschlernen/ui/cards/widgets/cards_screen.dart';
import 'package:deutschlernen/ui/core/app_style.dart';

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
  late final CardsViewModel _cardsViewModel = CardsViewModel(
    wordRepository: WordRepository(assetService: _assetService),
    languageRepository: LanguageRepository(assetService: _assetService),
    settingsRepository: SettingsRepository(),
    speechService: _speechService,
  )..load();

  @override
  void dispose() {
    _cardsViewModel.dispose();
    _speechService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deutsch lernen',
      theme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: AppColors.accentBlue,
        scaffoldBackgroundColor: AppColors.background,
      ),
      home: CardsScreen(viewModel: _cardsViewModel),
    );
  }
}