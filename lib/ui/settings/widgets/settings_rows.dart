import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/ui/core/app_style.dart';
import 'package:deutschlernen/ui/core/widgets/app_switch.dart';
import 'package:deutschlernen/ui/core/widgets/grouped_card.dart';
import 'package:deutschlernen/ui/core/widgets/menu_row.dart';

/// A gray category name above a GroupedCard with its rows.
class SettingsCategory extends StatelessWidget {
  const SettingsCategory({
    super.key,
    required this.title,
    required this.children,
  });

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
      trailing: Text(
        value,
        style: MenuRow.hintStyle(context)
            .copyWith(color: AppPalette.of(context).accentText),
      ),
      onTap: onTap,
    );
  }
}
