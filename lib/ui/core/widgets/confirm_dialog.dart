import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/ui/core/app_style.dart';
import 'package:deutschlernen/ui/core/widgets/menu_row.dart';

/// App-styled two-button dialog: [title], gray [body], "cancel" in the
/// text color and the action in [confirmColor]. True = the action was
/// chosen; false when cancelled or dismissed.
Future<bool> showConfirmDialog({
  required BuildContext context,
  required String title,
  required String body,
  required String cancelLabel,
  required String confirmLabel,
  required Color confirmColor,
}) async {
  final colors = Theme.of(context).colorScheme;
  final buttonText = MenuRow.titleStyle();

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppPalette.of(context).card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(title, style: AppListText.title(colors)),
      content: Text(body, style: MenuRow.hintStyle(context, soft: true)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          style: TextButton.styleFrom(foregroundColor: colors.onSurface),
          child: Text(cancelLabel, style: buttonText),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: TextButton.styleFrom(foregroundColor: confirmColor),
          child: Text(confirmLabel, style: buttonText),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
