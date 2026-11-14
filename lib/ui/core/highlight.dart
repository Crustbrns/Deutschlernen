import 'package:material_ui/material_ui.dart';

/// Splits [text] so the first occurrence of [target] gets [style].
List<TextSpan> highlightSpans(String text, String target, TextStyle style) {
  if (target.isEmpty) return [TextSpan(text: text)];

  final start = text.toLowerCase().indexOf(target.toLowerCase());
  if (start < 0) return [TextSpan(text: text)];

  final end = start + target.length;
  return [
    TextSpan(text: text.substring(0, start)),
    TextSpan(text: text.substring(start, end), style: style),
    TextSpan(text: text.substring(end)),
  ];
}