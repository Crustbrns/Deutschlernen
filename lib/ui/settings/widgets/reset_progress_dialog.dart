import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/app_style.dart';
import 'package:deutschlernen/ui/core/widgets/menu_row.dart';

/// Asks before wiping all progress: one stray tap would lose every FSRS
/// interval. True = the user confirmed.
Future<bool> confirmResetAllProgress(BuildContext context) async {
  final strings = AppStrings.of(context);
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
  return confirmed ?? false;
}
