import 'package:material_ui/material_ui.dart';

class CardsTopBar extends StatelessWidget {
  const CardsTopBar({
    super.key,
    required this.progress,
    required this.onClose,
    required this.onUndo,
  });

  final double progress;
  final VoidCallback onClose;
  final VoidCallback? onUndo; // null = disabled

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton.filledTonal(
          onPressed: onClose,
          tooltip: 'Закрыть',
          icon: const Icon(Icons.close),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _ProgressBar(progress: progress),
          ),
        ),
        IconButton.filledTonal(
          onPressed: onUndo,
          tooltip: 'Назад',
          icon: const Icon(Icons.arrow_back),
        ),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 8,
        child: ColoredBox(
          color: colors.surfaceContainerHighest,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress),
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value.clamp(0.0, 1.0).toDouble(),
              child: ColoredBox(color: colors.onSurface),
            ),
          ),
        ),
      ),
    );
  }
}