import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/app_style.dart';

class DecisionBar extends StatelessWidget {
  const DecisionBar({
    super.key,
    required this.onLater,
    required this.onRemembered,
  });

  final VoidCallback onLater;
  final VoidCallback onRemembered;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final strings = AppStrings.of(context);
    const textStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.w700);

    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: onLater,
            style: TextButton.styleFrom(
              foregroundColor: colors.onSurface,
              minimumSize: const Size.fromHeight(56),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.arrow_back),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    strings.later,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textStyle,
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(width: 1, height: 32, color: colors.outlineVariant),
        Expanded(
          child: TextButton(
            onPressed: onRemembered,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.accentTeal,
              minimumSize: const Size.fromHeight(56),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    strings.remembered,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textStyle,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.arrow_forward),
              ],
            ),
          ),
        ),
      ],
    );
  }
}