import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/ui/core/app_icons.dart';
import 'package:deutschlernen/domain/models/app_language.dart';
import 'package:deutschlernen/domain/models/app_settings.dart';
import 'package:deutschlernen/ui/cards/widgets/language_sheet.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/app_style.dart';
import 'package:deutschlernen/ui/settings/view_models/settings_view_model.dart';

/// Settings, grouped into categories. Each category is a small titled card.
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
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Text(
                strings.tabSettings,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            _Category(
              title: strings.settingsAppearance,
              children: [
                _ThemeTile(
                  mode: settings.themeMode,
                  onChanged: settings.setThemeMode,
                ),
                SwitchListTile(
                  title: Text(strings.showTranscription),
                  subtitle: Text(strings.showTranscriptionHint),
                  value: settings.showTranscription,
                  onChanged: settings.setShowTranscription,
                ),
              ],
            ),
            _Category(
              title: strings.settingsLanguages,
              children: [
                _LanguageTile(
                  icon: AppIcons.deviceMobile,
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
                  icon: AppIcons.translate,
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
                SwitchListTile(
                  title: Text(strings.autoSpeak),
                  subtitle: Text(strings.autoSpeakHint),
                  value: settings.autoSpeak,
                  onChanged: settings.setAutoSpeak,
                ),
                _SpeedTile(settings: settings),
              ],
            ),
            _Category(
              title: strings.settingsNotifications,
              children: [
                SwitchListTile(
                  title: Text(strings.reminders),
                  subtitle: Text(strings.remindersHint),
                  value: settings.notificationsEnabled,
                  onChanged: settings.setNotificationsEnabled,
                ),
              ],
            ),
            _Category(
              title: strings.settingsProgress,
              children: [
                ListTile(
                  // 16 = divider indent of the GroupedCard.
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  // Red: it wipes data and can't be undone.
                  leading: const Icon(
                    AppIcons.arrowCounterClockwise,
                    color: AppColors.decisionRed,
                  ),
                  title: Text(
                    strings.resetAllProgress,
                    style: const TextStyle(color: AppColors.decisionRed),
                  ),
                  subtitle: Text(strings.resetAllProgressHint),
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.resetAllConfirmTitle),
        content: Text(strings.resetAllConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(strings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.decisionRed,
            ),
            child: Text(strings.resetConfirm),
          ),
        ],
      ),
    );
    if (confirmed ?? false) onResetAllProgress();
  }
}

/// A title above a rounded card that holds the category's rows.
class _Category extends StatelessWidget {
  const _Category({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: 12.5,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w600,
                color: AppPalette.of(context).mutedText,
              ),
            ),
          ),
          Material(
            color: AppPalette.of(context).card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: colors.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  const _ThemeTile({required this.mode, required this.onChanged});

  final ThemeMode mode;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return ListTile(
      title: Text(strings.theme),
      trailing: SegmentedButton<ThemeMode>(
        showSelectedIcon: false,
        selected: {mode},
        onSelectionChanged: (selection) => onChanged(selection.first),
        style: SegmentedButton.styleFrom(visualDensity: VisualDensity.compact),
        segments: [
          ButtonSegment(
            value: ThemeMode.dark,
            icon: const Icon(AppIcons.moon, size: 18),
            label: Text(strings.themeDark),
          ),
          ButtonSegment(
            value: ThemeMode.light,
            icon: const Icon(AppIcons.sun, size: 18),
            label: Text(strings.themeLight),
          ),
        ],
      ),
    );
  }
}

class _SpeedTile extends StatelessWidget {
  const _SpeedTile({required this.settings});

  final SettingsViewModel settings;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final muted = TextStyle(
      fontSize: 13,
      color: AppPalette.of(context).mutedText,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(strings.speechRate, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 2),
          Text(strings.speechRateHint, style: muted),
          Slider(
            value: settings.speechRate,
            min: AppSettings.minSpeechRate,
            max: AppSettings.maxSpeechRate,
            onChanged: settings.previewSpeechRate,
            // Released: save it and say a sample word.
            onChangeEnd: settings.commitSpeechRate,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(strings.speedSlow, style: muted),
                Text(strings.speedFast, style: muted),
              ],
            ),
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
      trailing: const Icon(AppIcons.caretRight),
      onTap: onTap,
    );
  }
}
