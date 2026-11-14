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
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(color: colors.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 12, 0),
            child: _Header(level: word.level, onMenu: widget.onMenu),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  // FittedBox shrinks long German words instead of overflowing.
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text.rich(
                      TextSpan(
                        style: const TextStyle(
                          fontFamily: AppFonts.serif,
                          fontSize: 46,
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
                    const SizedBox(height: 8),
                    _PluralLine(label: strings.plural, plural: word.plural!),
                  ],
                  const SizedBox(height: 16),
                  Center(
                    child: OutlinedButton(
                      onPressed: () => widget.onSpeak(word.withArticle),
                      style: OutlinedButton.styleFrom(
                        shape: const StadiumBorder(),
                        side: BorderSide(color: colors.outline),
                        foregroundColor: colors.onSurface,
                        minimumSize: const Size(0, 48),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            word.transcription,
                            style: const TextStyle(
                              fontFamily: AppFonts.serif,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.volume_up_outlined, size: 22),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    word.definition,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppFonts.serif,
                      fontSize: 18,
                      height: 1.4,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
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
                                    fontFamily: AppFonts.serif,
                                    fontSize: 40,
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
                  const SizedBox(height: 20),
                  for (var i = 0; i < word.examples.length; i++)
                    ExampleTile(
                      key: ValueKey(word.examples[i].german),
                      example: word.examples[i],
                      initiallyExpanded: i == 0,
                      onSpeak: widget.onSpeak,
                    ),
                  Divider(height: 1, color: colors.outlineVariant),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PluralLine extends StatelessWidget {
  const _PluralLine({required this.label, required this.plural});

  final String label;
  final String plural;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Text.rich(
      textAlign: TextAlign.center,
      TextSpan(
        style: TextStyle(
          fontFamily: AppFonts.serif,
          fontSize: 20,
          color: colors.onSurfaceVariant,
        ),
        children: [
          TextSpan(text: '$label: '),
          TextSpan(
            text: 'die ',
            style: TextStyle(
              color: AppColors.forArticle('die'),
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(
            text: plural,
            style: TextStyle(
              color: colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
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
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              level,
              style: const TextStyle(
                fontFamily: AppFonts.serif,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: colors.outline,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            strings.newWord,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: AppFonts.serif,
              fontSize: 17,
              fontWeight: FontWeight.w600,
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