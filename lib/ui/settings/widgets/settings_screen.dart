import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/domain/models/app_language.dart';
import 'package:deutschlernen/ui/core/app_icons.dart';
import 'package:deutschlernen/ui/core/widgets/language_sheet.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/app_style.dart';
import 'package:deutschlernen/ui/core/view_models/language_view_model.dart';
import 'package:deutschlernen/ui/core/widgets/choice_sheet.dart';
import 'package:deutschlernen/ui/core/widgets/menu_row.dart';
import 'package:deutschlernen/ui/settings/view_models/settings_view_model.dart';
import 'package:deutschlernen/ui/settings/widgets/reminders_category.dart';
import 'package:deutschlernen/ui/settings/widgets/reset_progress_dialog.dart';
import 'package:deutschlernen/ui/settings/widgets/settings_rows.dart';
import 'package:deutschlernen/ui/settings/widgets/speed_row.dart';

/// Settings tab: title, then one block per category, rows like the Learn
/// menu (split by dividers) but without icons — the user's choice.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.settings,
    required this.languages,
    required this.onResetAllProgress,
  });

  final SettingsViewModel settings;

  /// Interface and word languages; the language sheets change them.
  final LanguageViewModel languages;

  /// Makes every word new again (after the user confirms).
  final VoidCallback onResetAllProgress;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    // Sheet order: same as system first, like the language sheets.
    final themeLabels = {
      ThemeMode.system: strings.themeSystem,
      ThemeMode.dark: strings.themeDark,
      ThemeMode.light: strings.themeLight,
    };

    return SafeArea(
      bottom: false,
      child: ListenableBuilder(
        listenable: settings,
        builder: (context, _) => ListView(
          // + bottom inset: the last item stays reachable above the blurred bar.
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            24 + MediaQuery.paddingOf(context).bottom,
          ),
          children: [
            // Same title placement as the other tabs.
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
              child: Text(
                strings.tabSettings,
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(letterSpacing: -0.5),
              ),
            ),
            SettingsCategory(
              title: strings.settingsAppearance,
              children: [
                SettingsValueRow(
                  title: strings.theme,
                  value: themeLabels[settings.themeMode]!,
                  onTap: () => showChoiceSheet<ThemeMode>(
                    context: context,
                    title: strings.theme,
                    current: settings.themeMode,
                    onSelected: settings.setThemeMode,
                    choices: [
                      for (final e in themeLabels.entries)
                        Choice(e.key, e.value),
                    ],
                  ),
                ),
                SettingsSwitchRow(
                  title: strings.showTranscription,
                  hint: strings.showTranscriptionHint,
                  value: settings.showTranscription,
                  onChanged: settings.setShowTranscription,
                ),
              ],
            ),
            SettingsCategory(
              title: strings.settingsLanguages,
              children: [
                _languageRow(
                  context,
                  title: strings.interfaceLanguage,
                  current: languages.uiFollowsSystem
                      ? null
                      : languages.uiLanguage,
                  choice: LanguageChoice.interface,
                ),
                _languageRow(
                  context,
                  title: strings.wordsLanguage,
                  current: languages.wordFollowsSystem
                      ? null
                      : languages.wordLanguage,
                  choice: LanguageChoice.words,
                ),
              ],
            ),
            SettingsCategory(
              title: strings.settingsVoice,
              children: [
                SettingsSwitchRow(
                  title: strings.autoSpeak,
                  hint: strings.autoSpeakHint,
                  value: settings.autoSpeak,
                  onChanged: settings.setAutoSpeak,
                ),
                SpeedRow(settings: settings),
              ],
            ),
            RemindersCategory(settings: settings),
            SettingsCategory(
              title: strings.settingsProgress,
              children: [
                // Red: it wipes data and can't be undone.
                MenuRow(
                  compact: true,
                  titleColor: AppColors.decisionRed,
                  title: strings.resetAllProgress,
                  // No hint line: the confirm dialog says what happens.
                  trailing: const Icon(
                    AppIcons.arrowCounterClockwise,
                    size: 22,
                    color: AppColors.decisionRed,
                  ),
                  onTap: () => _confirmReset(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Opens the language sheet; [current] null = same as the system.
  Widget _languageRow(
    BuildContext context, {
    required String title,
    required AppLanguage? current,
    required LanguageChoice choice,
  }) {
    return SettingsValueRow(
      title: title,
      value: current?.label ?? AppStrings.of(context).systemLanguage,
      onTap: () => showLanguageSheet(
        context: context,
        languages: languages,
        choice: choice,
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    if (await confirmResetAllProgress(context)) onResetAllProgress();
  }
}
