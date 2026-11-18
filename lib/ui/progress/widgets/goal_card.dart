import 'package:material_ui/material_ui.dart';

/// The word goal on the Progress tab: "12 из 100 слов" with the "Цель"
/// label on the right, and a green bar filled to [known] / [goal].
class GoalCard extends StatelessWidget {
  const GoalCard({super.key, required this.known, required this.goal});

  /// Words known now: green or "already know".
  final int known;

  /// From Settings, 50 or more.
  final int goal;

  @override
  Widget build(BuildContext context) {
    // TODO(you): the card, see the task in the chat.
    return const SizedBox.shrink();
  }
}
