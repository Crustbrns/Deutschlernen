import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/ui/core/app_style.dart';
import 'package:deutschlernen/ui/core/widgets/app_switch.dart';
import 'package:deutschlernen/ui/core/widgets/menu_row.dart';

/// MenuRow with an on/off switch; the whole row toggles it.
class SettingsSwitchRow extends StatelessWidget {
  const SettingsSwitchRow({
    super.key,
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

/// Opens a choice sheet (language, theme); the current choice is the accent
/// value on the right (no chevron: navigation rows don't have one).
class SettingsValueRow extends StatelessWidget {
  const SettingsValueRow({
    super.key,
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
      // Capped, so a long value ("Немецкий по нажатию", ×1.3 text) wraps
      // onto a second line instead of squeezing the title.
      trailing: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.4,
        ),
        child: Text(
          value,
          textAlign: TextAlign.end,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: MenuRow.hintStyle(context)
              .copyWith(color: AppPalette.of(context).accentText),
        ),
      ),
      onTap: onTap,
    );
  }
}
