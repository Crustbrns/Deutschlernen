import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';

/// Concept of the main menu: a single entry point into the cards.
class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key, required this.onStartLearning});

  final VoidCallback onStartLearning;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return SafeArea(
      bottom: false,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Deutsch lernen',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onStartLearning,
              icon: const Icon(Icons.play_arrow),
              label: Text(strings.startLearning),
            ),
          ],
        ),
      ),
    );
  }
}
