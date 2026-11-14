import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/data/repositories/word_repository.dart';
import 'package:deutschlernen/data/services/sound_service.dart';
import 'package:deutschlernen/data/services/speech_service.dart';
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
  final _soundService = SoundService();
  final _speechService = SpeechService();
  late final CardsViewModel _cardsViewModel = CardsViewModel(
    wordRepository: WordRepository(),
    soundService: _soundService,
    speechService: _speechService,
  )..load();

  @override
  void dispose() {
    _cardsViewModel.dispose();
    _soundService.dispose();
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