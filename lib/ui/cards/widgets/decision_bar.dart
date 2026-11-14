import 'package:material_ui/material_ui.dart';
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
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back),
                SizedBox(width: 12),
                Flexible(
                  child: Text(
                    'Отложить',
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
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    'Запомнил',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textStyle,
                  ),
                ),
                SizedBox(width: 12),
                Icon(Icons.arrow_forward),
              ],
            ),
          ),
        ),
      ],
    );
  }
}