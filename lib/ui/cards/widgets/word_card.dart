import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/domain/models/word.dart';
import 'package:deutschlernen/ui/cards/widgets/example_tile.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/app_style.dart';

class WordCard extends StatefulWidget {
  const WordCard({
    super.key,
    required this.word,
    required this.onSpeak,
    required this.onMenu,
  });

  final Word word;
  final ValueChanged<String> onSpeak;
  final VoidCallback onMenu;

  @override
  State<WordCard> createState() => _WordCardState();
}

class _WordCardState extends State<WordCard> {
  bool _translationVisible = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final strings = AppStrings.of(context);
    final word = widget.word;

    return Material(
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32),
        side: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.4)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 16, 0),
            child: _Header(level: word.level, onMenu: widget.onMenu),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),
                  // FittedBox shrinks long German words instead of overflowing.
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text.rich(
                      TextSpan(
                        style: const TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.w700,
                        ),
                        children: [
                          TextSpan(
                            text: '${word.article} ',
                            style: TextStyle(
                              color: AppColors.forArticle(word.article),
                            ),
                          ),
                          TextSpan(text: word.german),
                        ],
                      ),
                    ),
                  ),
                  if (word.plural != null) ...[
                    // Negative gap: the line boxes of big fonts leave extra
                    // space, so the plural is pulled up a bit.
                    Transform.translate(
                      offset: const Offset(0, -6),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '(die ${word.plural})', // plural is always "die"
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Center(
                    child: _TranscriptionButton(
                      transcription: word.transcription,
                      onPressed: () => widget.onSpeak(word.withArticle),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 72,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _translationVisible
                          ? Center(
                              key: const ValueKey('shown'),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  word.translation,
                                  style: const TextStyle(
                                    fontSize: 42,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            )
                          : Center(
                              key: const ValueKey('hidden'),
                              child: FilledButton.tonal(
                                onPressed: () =>
                                    setState(() => _translationVisible = true),
                                child: Text(strings.showTranslation),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Definition is the first row of the examples block.
                  DefinitionTile(
                    definition: word.definition,
                    translation: word.definitionTranslation,
                  ),
                  for (var i = 0; i < word.examples.length; i++)
                    ExampleTile(
                      key: ValueKey(word.examples[i].german),
                      example: word.examples[i],
                      initiallyExpanded: i == 0,
                      onSpeak: widget.onSpeak,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TranscriptionButton extends StatelessWidget {
  const _TranscriptionButton({
    required this.transcription,
    required this.onPressed,
  });

  final String transcription;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        shape: const StadiumBorder(),
        backgroundColor: colors.surfaceContainer,
        side: BorderSide(color: colors.outlineVariant),
        foregroundColor: colors.onSurface,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        minimumSize: const Size(0, 48),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            transcription,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 16),
          const Icon(Icons.volume_up_outlined, size: 26),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.level, required this.onMenu});

  final String level;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final strings = AppStrings.of(context);

    return Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Text(level, style: const TextStyle(fontSize: 15)),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: colors.outline,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            strings.newWord,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
        IconButton.outlined(
          onPressed: onMenu,
          tooltip: strings.menu,
          icon: const Icon(Icons.more_horiz),
        ),
      ],
    );
  }
}
