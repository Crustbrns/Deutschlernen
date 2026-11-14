import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/domain/models/example_sentence.dart';
import 'package:deutschlernen/ui/core/app_style.dart';
import 'package:deutschlernen/ui/core/highlight.dart';

class ExampleTile extends StatefulWidget {
  const ExampleTile({
    super.key,
    required this.example,
    required this.initiallyExpanded,
    required this.onSpeak,
  });

  final ExampleSentence example;
  final bool initiallyExpanded;
  final ValueChanged<String> onSpeak;

  @override
  State<ExampleTile> createState() => _ExampleTileState();
}

class _ExampleTileState extends State<ExampleTile> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final base = TextStyle(fontSize: 17, height: 1.35, color: colors.onSurface);
    final bold = base.copyWith(fontWeight: FontWeight.w700);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.outlineVariant)),
      ),
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 14, 12, 0),
              child: Icon(
                _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        style: base,
                        children: markedSpans(widget.example.german, bold),
                      ),
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      alignment: Alignment.topLeft,
                      child: _expanded
                          ? Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text.rich(
                                TextSpan(
                                  style: base,
                                  children:
                                      markedSpans(widget.example.translation, bold),
                                ),
                              ),
                            )
                          : const SizedBox(width: double.infinity),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              onPressed: () =>
                  widget.onSpeak(stripMarkup(widget.example.german)),
              icon: const Icon(Icons.play_arrow_outlined),
              color: AppColors.accentBlue,
            ),
          ],
        ),
      ),
    );
  }
}