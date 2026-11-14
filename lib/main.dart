import 'package:deutschlernen/data/repositories/word_rep.dart';
import 'package:deutschlernen/ui/cards/view_models/cards_view_model.dart';
import 'package:deutschlernen/ui/cards/widgets/cards_screen.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  runApp(const MyApp());
}

final viewModel = CardsViewModel(wordRepository: WordRepository())..load();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My First App',
      theme: ThemeData(colorSchemeSeed: Colors.blue),
      home: CardsScreen(viewModel: viewModel),
    );
  }
}