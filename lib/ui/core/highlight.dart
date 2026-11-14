import 'package:material_ui/material_ui.dart';

/// Turns "Ich trinke gerne **Tee**." into spans where "Tee" is bold.
List<TextSpan> markedSpans(String text, TextStyle boldStyle) {
  final parts = text.split('**');
  final spans = <TextSpan>[];

  for (var i = 0; i < parts.length; i++) {
    if (parts[i].isEmpty) continue;
    // Odd parts are the ones between the ** markers.
    spans.add(TextSpan(text: parts[i], style: i.isOdd ? boldStyle : null));
  }
  return spans;
}

/// Plain text without markers, e.g. for text-to-speech.
String stripMarkup(String text) => text.replaceAll('**', '');