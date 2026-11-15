import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/domain/models/app_language.dart';
import 'package:deutschlernen/ui/cards/widgets/language_sheet.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';

/// Concept of the settings tab. For now it only holds the language choice,
/// which used to live behind the "..." button of the card.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.languages,
    required this.current,
    required this.onLanguageSelected,
  });

  final List<AppLanguage> languages;
  final AppLanguage current;
  final ValueChanged<AppLanguage> onLanguageSelected;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
            child: Text(
              strings.tabSettings,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          ListTile(
            leading: Text(current.flag, style: const TextStyle(fontSize: 28)),
            title: Text(strings.language),
            subtitle: Text(current.label),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showLanguageSheet(
              context: context,
              strings: strings,
              languages: languages,
              current: current,
              onSelected: onLanguageSelected,
            ),
          ),
        ],
      ),
    );
  }
}
