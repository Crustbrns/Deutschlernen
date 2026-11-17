import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/ui/core/app_style.dart';

/// A scrolling tab of the shell (Learn, Progress, Settings): its title,
/// then [children], with the shared side and bottom gutters.
class TabPage extends StatelessWidget {
  const TabPage({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          AppSizes.bottomPadding(context),
        ),
        children: [TabTitle(title), ...children],
      ),
    );
  }
}

/// Title at the top of a tab: 8 inside the 16 screen gutter, condensed
/// (at the default spacing the letters drift apart).
class TabTitle extends StatelessWidget {
  const TabTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
      child: Text(
        text,
        style: Theme.of(context).textTheme.headlineSmall
            ?.copyWith(letterSpacing: -0.5),
      ),
    );
  }
}
