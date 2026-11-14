import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/ui/core/widgets/greeting_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(child: GreetingCard(name: 'Flutter')),
    );
  }
}