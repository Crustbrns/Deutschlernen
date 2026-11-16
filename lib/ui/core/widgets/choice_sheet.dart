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
          _ChoiceRow(
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
/// off.
Future<void> showMultiChoiceSheet<T>({
  required BuildContext context,
  required String title,
  required List<Choice<T>> choices,
  required Set<T> selected,
  required ValueChanged<Set<T>> onChanged,
}) {
  // Local copy: the sheet redraws itself on each tap.
  var current = {...selected};
  return showSheet(
    context: context,
    title: title,
    builder: (_) => StatefulBuilder(
      builder: (context, setSheetState) => GroupedCard(
        children: [
          for (final choice in choices)
            _ChoiceRow(
              choice: choice,
              isSelected: current.contains(choice.value),
              onTap: () {
                final next = {...current};
                if (!next.remove(choice.value)) next.add(choice.value);
                if (next.isEmpty) return;
                setSheetState(() => current = next);
                onChanged(next);
              },
            ),
        ],
      ),
    ),
  );
}

/// The frame of every picker sheet: drag handle, title, then [builder]'s
/// content on the screen background (so card-colored blocks stand out).
Future<void> showSheet({
  required BuildContext context,
  required String title,
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
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                child: Text(
                  title,
                  style: Theme.of(sheetContext).textTheme.titleLarge,
                ),
              ),
              builder(sheetContext),
            ],
          ),
        ),
      ),
    ),
  );
}

/// The chosen one is blue with a check, the others have an empty circle.
class _ChoiceRow<T> extends StatelessWidget {
  const _ChoiceRow({
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
      trailing: isSelected
          ? const Icon(AppIcons.checkCircle, color: AppColors.softBlue)
          : Icon(
              AppIcons.circle,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      onTap: onTap,
    );
  }
}
