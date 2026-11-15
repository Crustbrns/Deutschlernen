import 'package:material_ui/material_ui.dart';

class GreetingCard extends StatelessWidget {
  const GreetingCard({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Hello, $name!'),
      ),
    );
  }
}
