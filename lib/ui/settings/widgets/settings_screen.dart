import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/domain/models/app_language.dart';
import 'package:deutschlernen/domain/models/app_settings.dart';
import 'package:deutschlernen/ui/cards/widgets/language_sheet.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/app_style.dart';
import 'package:deutschlernen/ui/core/widgets/app_switch.dart';
import 'package:deutschlernen/ui/core/widgets/grouped_card.dart';
import 'package:deutschlernen/ui/core/widgets/menu_row.dart';
import 'package:deutschlernen/ui/settings/view_models/settings_view_model.dart';
import 'package:deutschlernen/ui/settings/widgets/theme_switch.dart';

/// Settings tab: title, then one block per category, rows like the Learn
/// menu (split by dividers) but without icons — the user's choice.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.settings,
    required this.languages,
    required this.uiLanguage,
    required this.wordLanguage,
    required this.onUiLanguageSelected,
    required this.onWordLanguageSelected,
    required this.onResetAllProgress,
  });

  final SettingsViewModel settings;
  final List<AppLanguage> languages;
  final AppLanguage uiLanguage;
  final AppLanguage wordLanguage;
  final ValueChanged<AppLanguage> onUiLanguageSelected;
  final ValueChanged<AppLanguage> onWordLanguageSelected;

  /// Makes every word new again (after the user confirms).
  final VoidCallback onResetAllProgress;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

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
            _Category(
              title: strings.settingsAppearance,
              children: [
                MenuRow(
                  compact: true,
                  title: strings.theme,
                  trailing: ThemeSwitch(
                    mode: settings.themeMode,
                    onChanged: settings.setThemeMode,
                  ),
                  // Tapping the row itself flips the theme too.
                  onTap: () => settings.setThemeMode(
                    settings.themeMode == ThemeMode.dark
                        ? ThemeMode.light
                        : ThemeMode.dark,
                  ),
                ),
                _SwitchRow(
                  title: strings.showTranscription,
                  hint: strings.showTranscriptionHint,
                  value: settings.showTranscription,
                  onChanged: settings.setShowTranscription,
                ),
              ],
            ),
            _Category(
              title: strings.settingsLanguages,
              children: [
                _LanguageRow(
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
                _LanguageRow(
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
            _Category(
              title: strings.settingsVoice,
              children: [
                _SwitchRow(
                  title: strings.autoSpeak,
                  hint: strings.autoSpeakHint,
                  value: settings.autoSpeak,
                  onChanged: settings.setAutoSpeak,
                ),
                _SpeedRow(settings: settings),
              ],
            ),
            _Category(
              title: strings.settingsNotifications,
              children: [
                _SwitchRow(
                  title: strings.reminders,
                  hint: strings.remindersHint,
                  value: settings.notificationsEnabled,
                  onChanged: settings.setNotificationsEnabled,
                ),
              ],
            ),
            _Category(
              title: strings.settingsProgress,
              children: [
                // Red: it wipes data and can't be undone.
                MenuRow(
                  compact: true,
                  titleColor: AppColors.decisionRed,
                  title: strings.resetAllProgress,
                  subtitle: strings.resetAllProgressHint,
                  onTap: () => _confirmReset(context, strings),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Asks before wiping: one stray tap would lose all FSRS intervals.
  Future<void> _confirmReset(BuildContext context, AppStrings strings) async {
    final colors = Theme.of(context).colorScheme;
    final buttonText = MenuRow.titleStyle();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppPalette.of(context).card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          strings.resetAllConfirmTitle,
          style: AppListText.title(colors),
        ),
        content: Text(
          strings.resetAllConfirmBody,
          style: MenuRow.hintStyle(context, soft: true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            style: TextButton.styleFrom(foregroundColor: colors.onSurface),
            child: Text(strings.cancel, style: buttonText),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.decisionRed),
            child: Text(strings.resetConfirm, style: buttonText),
          ),
        ],
      ),
    );
    if (confirmed ?? false) onResetAllProgress();
  }
}

/// A gray category name above a GroupedCard with its rows.
class _Category extends StatelessWidget {
  const _Category({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            // 8 = same left edge as the screen title.
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Text(title, style: MenuRow.hintStyle(context, soft: true)),
          ),
          GroupedCard(children: children),
        ],
      ),
    );
  }
}

/// MenuRow with an on/off switch; the whole row toggles it.
class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.title,
    required this.hint,
    required this.value,
    required this.onChanged,
  });
  final String title;
  final String hint;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return MenuRow(
      compact: true,
      title: title,
      subtitle: hint,
      trailing: AppSwitch(value: value, onChanged: onChanged),
      onTap: () => onChanged(!value),
    );
  }
}

/// Opens the language sheet; the current language is the blue value on the
/// right (no chevron: navigation rows don't have one).
class _LanguageRow extends StatelessWidget {
  const _LanguageRow({
    required this.title,
    required this.current,
    required this.onTap,
  });
  final String title;
  final AppLanguage current;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MenuRow(
      compact: true,
      title: title,
      trailing: Text(
        current.label,
        style: MenuRow.hintStyle(context).copyWith(color: AppColors.softBlue),
      ),
      onTap: onTap,
    );
  }
}

/// Speech rate: a MenuRow header with a slider and slow / fast under it.
class _SpeedRow extends StatelessWidget {
  const _SpeedRow({required this.settings});

  final SettingsViewModel settings;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final palette = AppPalette.of(context);
    final hint = MenuRow.hintStyle(context, soft: true).copyWith(fontSize: 13);

    return Column(
      children: [
        // Not tappable itself: the slider below is the control.
        IgnorePointer(
          child: MenuRow(
            compact: true,
            title: strings.speechRate,
            subtitle: strings.speechRateHint,
            onTap: () {}, // keeps the row in its enabled colors
          ),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            activeTrackColor: AppColors.softBlue,
            inactiveTrackColor: palette.subtleButton,
            thumbColor: AppColors.softBlue,
            overlayColor: AppColors.softBlue.withValues(alpha: 0.12),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            // Plain round track: no M3 gap and stop dot around the thumb.
            trackShape: const RoundedRectSliderTrackShape(),
            showValueIndicator: ShowValueIndicator.never,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Slider(
              value: settings.speechRate,
              min: AppSettings.minSpeechRate,
              max: AppSettings.maxSpeechRate,
              onChanged: settings.previewSpeechRate,
              // Released: save it and say a sample word.
              onChangeEnd: settings.commitSpeechRate,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 0, 28, 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(strings.speedSlow, style: hint),
              Text(strings.speedFast, style: hint),
            ],
          ),
        ),
      ],
    );
  }
}
