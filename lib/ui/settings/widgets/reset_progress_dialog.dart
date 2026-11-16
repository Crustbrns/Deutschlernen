import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/app_style.dart';
import 'package:deutschlernen/ui/core/widgets/confirm_dialog.dart';

/// Asks before wiping all progress: one stray tap would lose every FSRS
/// interval. True = the user confirmed.
Future<bool> confirmResetAllProgress(BuildContext context) {
  final strings = AppStrings.of(context);
  return showConfirmDialog(
    context: context,
    title: strings.resetAllConfirmTitle,
    body: strings.resetAllConfirmBody,
    cancelLabel: strings.cancel,
    confirmLabel: strings.resetConfirm,
    confirmColor: AppColors.decisionRed,
  );
}
