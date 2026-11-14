import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/ui/cards/view_models/cards_view_model.dart';

class CardsScreen extends StatelessWidget {
  const CardsScreen({super.key, required this.viewModel});

  final CardsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vokabeln')),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            children: [
              for (final word in viewModel.words)
                ListTile(
                  title: Text(word.german),
                  subtitle: Text(word.english),
                ),
            ],
          );
        },
      ),
    );
  }
}