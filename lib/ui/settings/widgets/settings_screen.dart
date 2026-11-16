import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/ui/core/app_icons.dart';
import 'package:deutschlernen/domain/models/app_language.dart';
import 'package:deutschlernen/domain/models/app_settings.dart';
import 'package:deutschlernen/ui/cards/widgets/language_sheet.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/app_style.dart';
import 'package:deutschlernen/ui/core/widgets/app_switch.dart';
import 'package:deutschlernen/ui/core/widgets/choice_sheet.dart';
import 'package:deutschlernen/ui/core/widgets/grouped_card.dart';
import 'package:deutschlernen/ui/core/widgets/menu_row.dart';
import 'package:deutschlernen/ui/settings/view_models/settings_view_model.dart';

/// Settings tab: title, then one block per category, rows like the Learn
/// menu (split by dividers) but without icons — the user's choice.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.settings,
    required this.languages,
    required this.uiLanguage,
    required this.wordLanguage,
    required this.uiFollowsSystem,
    required this.wordFollowsSystem,
    required this.systemLanguage,
    required this.onUiLanguageSelected,
    required this.onWordLanguageSelected,
    required this.onResetAllProgress,
  });

  final SettingsViewModel settings;
  final List<AppLanguage> languages;
  final AppLanguage uiLanguage;
  final AppLanguage wordLanguage;
  final bool uiFollowsSystem;
  final bool wordFollowsSystem;

  /// What "same as system" resolves to on this device.
  final AppLanguage systemLanguage;

  /// null = same as the system.
  final ValueChanged<AppLanguage?> onUiLanguageSelected;
  final ValueChanged<AppLanguage?> onWordLanguageSelected;

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
            _Category(
              title: strings.settingsAppearance,
              children: [
                _ValueRow(
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
                _ValueRow(
                  title: strings.interfaceLanguage,
                  value: uiFollowsSystem
                      ? strings.systemLanguage
                      : uiLanguage.label,
                  onTap: () => showLanguageSheet(
                    context: context,
                    title: strings.interfaceLanguage,
                    systemLabel: strings.systemLanguage,
                    systemLanguage: systemLanguage,
                    languages: languages,
                    current: uiFollowsSystem ? null : uiLanguage,
                    onSelected: onUiLanguageSelected,
                  ),
                ),
                _ValueRow(
                  title: strings.wordsLanguage,
                  value: wordFollowsSystem
                      ? strings.systemLanguage
                      : wordLanguage.label,
                  onTap: () => showLanguageSheet(
                    context: context,
                    title: strings.wordsLanguage,
                    systemLabel: strings.systemLanguage,
                    systemLanguage: systemLanguage,
                    languages: languages,
                    current: wordFollowsSystem ? null : wordLanguage,
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
                  // No hint line: the confirm dialog says what happens.
                  trailing: const Icon(
                    AppIcons.arrowCounterClockwise,
                    size: 22,
                    color: AppColors.decisionRed,
                  ),
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

/// Opens a choice sheet (language, theme); the current choice is the blue
/// value on the right (no chevron: navigation rows don't have one).
class _ValueRow extends StatelessWidget {
  const _ValueRow({
    required this.title,
    required this.value,
    required this.onTap,
  });

  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MenuRow(
      compact: true,
      title: title,
      trailing: Text(
        value,
        style: MenuRow.hintStyle(context).copyWith(color: AppColors.softBlue),
      ),
      onTap: onTap,
    );
  }
}

/// Speech rate: a MenuRow header with a slider and slow / fast under it.
class _SpeedRow extends StatefulWidget {
  const _SpeedRow({required this.settings});

  final SettingsViewModel settings;

  @override
  State<_SpeedRow> createState() => _SpeedRowState();
}

class _SpeedRowState extends State<_SpeedRow> {
  /// Value while the finger is on the slider. Kept here, not in the view
  /// model: notifying it on every frame rebuilt the whole MaterialApp (it
  /// listens to settings for the theme), and the drag stuttered.
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    final settings = widget.settings;
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
            trackHeight: 6,
            activeTrackColor: AppColors.softBlue,
            inactiveTrackColor: palette.sliderTrack,
            // No ripple halo: the white pill thumb is enough feedback.
            overlayColor: Colors.transparent,
            thumbShape: const _PillThumbShape(),
            // Plain round track: no M3 gap and stop dot around the thumb.
            trackShape: const RoundedRectSliderTrackShape(),
            showValueIndicator: ShowValueIndicator.never,
            // Track from 16 to 16, level with the row text and dividers
            // (the default inset leaves room for the ripple halo).
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: Slider(
            value: _dragValue ?? settings.speechRate,
            min: AppSettings.minSpeechRate,
            max: AppSettings.maxSpeechRate,
            onChanged: (v) => setState(() => _dragValue = v),
            // Released: save it and say a sample word.
            onChangeEnd: (v) {
              _dragValue = null;
              settings.commitSpeechRate(v);
            },
          ),
        ),
        Padding(
          // Same 16 edges as the track.
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
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

/// White rounded-rectangle slider thumb (wider than tall), with the same soft
/// shadow as the AppSwitch thumb.
class _PillThumbShape extends SliderComponentShape {
  const _PillThumbShape();

  static const _size = Size(30, 20);

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => _size;

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final pill = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: _size.width, height: _size.height),
      Radius.circular(_size.height / 2),
    );
    final canvas = context.canvas;
    canvas.drawRRect(
      pill.shift(const Offset(0, 1)),
      Paint()
        ..color = AppColors.switchThumbShadow
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas.drawRRect(pill, Paint()..color = AppColors.onAccent);
  }
}
