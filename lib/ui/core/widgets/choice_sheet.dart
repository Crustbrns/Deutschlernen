import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/ui/core/app_icons.dart';
import 'package:deutschlernen/ui/core/app_style.dart';
import 'package:deutschlernen/ui/core/widgets/grouped_card.dart';
import 'package:deutschlernen/ui/core/widgets/menu_row.dart';

/// One option of [showChoiceSheet].
class Choice<T> {
  const Choice(this.value, this.label, {this.subtitle});

  final T value;
  final String label;
  final String? subtitle; // gray line under the label
}

/// Bottom sheet to pick one of [choices], built like the level sheet: title,
/// then one GroupedCard on the screen background. The chosen one is blue
/// with a check; a tap picks and closes. Used for the language and theme.
Future<void> showChoiceSheet<T>({
  required BuildContext context,
  required String title,
  required List<Choice<T>> choices,
  required T current,
  required ValueChanged<T> onSelected,
}) {
  return showSheet(
    context: context,
    title: title,
    builder: (sheetContext) => GroupedCard(
      children: [
        for (final choice in choices)
          ChoiceRow(
            choice: choice,
            isSelected: choice.value == current,
            onTap: () {
              onSelected(choice.value);
              Navigator.of(sheetContext).pop();
            },
          ),
      ],
    ),
  );
}

/// Like [showChoiceSheet], but several can be on: a tap toggles and is
/// applied right away, the sheet stays open. The last one can't be turned
/// off. [rowBuilder] draws a custom row (e.g. a level row with its icon and
/// word count); by default it is a [ChoiceRow].
Future<void> showMultiChoiceSheet<T>({
  required BuildContext context,
  required String title,
  required List<Choice<T>> choices,
  required Set<T> selected,
  required ValueChanged<Set<T>> onChanged,
  Widget Function(Choice<T> choice, bool isSelected, VoidCallback onTap)?
  rowBuilder,
}) {
  final row =
      rowBuilder ??
      (choice, isSelected, onTap) =>
          ChoiceRow(choice: choice, isSelected: isSelected, onTap: onTap);
  // Local copy: the sheet redraws itself on each tap.
  var current = {...selected};
  return showSheet(
    context: context,
    title: title,
    builder: (_) => StatefulBuilder(
      builder: (context, setSheetState) => GroupedCard(
        children: [
          for (final choice in choices)
            row(choice, current.contains(choice.value), () {
              final next = {...current};
              if (!next.remove(choice.value)) next.add(choice.value);
              if (next.isEmpty) return;
              setSheetState(() => current = next);
              onChanged(next);
            }),
        ],
      ),
    ),
  );
}

/// The frame of every picker sheet: drag handle, title, then [builder]'s
/// content on the screen background (so card-colored blocks stand out).
/// [title] null: the content shows its own [SheetTitle] (e.g. one that
/// changes while the sheet is open).
Future<void> showSheet({
  required BuildContext context,
  String? title,
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    // Height follows the content, but never under the status bar.
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppPalette.of(context).background,
    builder: (sheetContext) => SafeArea(
      // Scrolls instead of clipping on short screens.
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null) SheetTitle(title),
              builder(sheetContext),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Title of a sheet, 8 from the left like the tab titles.
class SheetTitle extends StatelessWidget {
  const SheetTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
      child: Text(text, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}

/// Full-width primary button that closes the sheet.
class SheetDoneButton extends StatelessWidget {
  const SheetDoneButton(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () => Navigator.of(context).pop(),
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text(label),
    );
  }
}

/// The chosen one is blue with a check, the others have an empty circle.
class ChoiceRow<T> extends StatelessWidget {
  const ChoiceRow({
    super.key,
    required this.choice,
    required this.isSelected,
    required this.onTap,
  });

  final Choice<T> choice;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MenuRow(
      compact: true,
      title: choice.label,
      subtitle: choice.subtitle,
      titleColor: isSelected ? AppColors.softBlue : null,
      trailing: SelectionMark(isSelected: isSelected),
      onTap: onTap,
    );
  }
}

/// Right end of a pickable row: a blue check when chosen, else an empty
/// circle.
class SelectionMark extends StatelessWidget {
  const SelectionMark({super.key, required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return isSelected
        ? const Icon(AppIcons.checkCircle, color: AppColors.softBlue)
        : Icon(
            AppIcons.circle,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          );
  }
}
