import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/domain/models/app_language.dart';
import 'package:deutschlernen/ui/cards/widgets/language_sheet.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/widgets/grouped_card.dart';

/// Concept of the settings tab. For now it only holds two language choices:
/// the interface language and the language of the word translations.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.languages,
    required this.uiLanguage,
    required this.wordLanguage,
    required this.onUiLanguageSelected,
    required this.onWordLanguageSelected,
  });

  final List<AppLanguage> languages;
  final AppLanguage uiLanguage;
  final AppLanguage wordLanguage;
  final ValueChanged<AppLanguage> onUiLanguageSelected;
  final ValueChanged<AppLanguage> onWordLanguageSelected;

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
          GroupedCard(
            children: [
              _LanguageTile(
                icon: Icons.phone_android_outlined,
                title: strings.interfaceLanguage,
                current: uiLanguage,
                onTap: () => showLanguageSheet(
                  context: context,
                  title: strings.interfaceLanguage,
                  languages: languages,
                  current: uiLanguage,
                  onSelected: onUiLanguageSelected,
                ),
              ),
              _LanguageTile(
                icon: Icons.translate,
                title: strings.wordsLanguage,
                current: wordLanguage,
                onTap: () => showLanguageSheet(
                  context: context,
                  title: strings.wordsLanguage,
                  languages: languages,
                  current: wordLanguage,
                  onSelected: onWordLanguageSelected,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.icon,
    required this.title,
    required this.current,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final AppLanguage current;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // 16 = divider indent of the GroupedCard.
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text('${current.flag}  ${current.label}'),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
