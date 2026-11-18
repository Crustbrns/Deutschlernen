import 'package:material_ui/material_ui.dart';

/// The app's only icon set: Phosphor Regular (thin line icons with rounded
/// ends), from the font in assets/fonts/Phosphor.ttf.
///
/// Not the phosphor_flutter package: its icon class extends IconData, which
/// is a final class in current Flutter, so the package no longer compiles.
///
/// To add an icon: find it at phosphoricons.com, take its code point from
/// lib/src/phosphor_icons_regular.dart in github.com/phosphor-icons/flutter
/// (same name, e.g. `bookOpen = ...(0xe0e6, 'Regular')`) and add it below.
/// Names follow Phosphor's, so they are easy to look up.
abstract final class AppIcons {
  static const _font = 'Phosphor';

  static const arrowCounterClockwise = IconData(0xe038, fontFamily: _font);
  static const arrowLeft = IconData(0xe058, fontFamily: _font);
  static const arrowRight = IconData(0xe06c, fontFamily: _font);
  static const arrowUUpLeft = IconData(0xe08a, fontFamily: _font);
  static const checkCircle = IconData(0xe184, fontFamily: _font);
  static const circle = IconData(0xe18a, fontFamily: _font);
  static const clockCounterClockwise = IconData(0xe1a0, fontFamily: _font);
  static const eye = IconData(0xe220, fontFamily: _font);
  static const info = IconData(0xe2ce, fontFamily: _font);
  static const listChecks = IconData(0xeadc, fontFamily: _font);
  static const magnifyingGlass = IconData(0xe30c, fontFamily: _font);
  static const pencilSimple = IconData(0xe3b4, fontFamily: _font);
  static const play = IconData(0xe3d0, fontFamily: _font);
  static const plusCircle = IconData(0xe3d6, fontFamily: _font);
  static const smiley = IconData(0xe436, fontFamily: _font);
  static const smileySad = IconData(0xe43e, fontFamily: _font);
  static const speakerHigh = IconData(0xe44a, fontFamily: _font);
  static const squaresFour = IconData(0xe464, fontFamily: _font);
  static const x = IconData(0xe4f6, fontFamily: _font);
  static const xCircle = IconData(0xe4f8, fontFamily: _font);

  // Phosphor Bold: same code points, thicker strokes. Only where a small
  // icon must still read clearly (the example rows' chevron).
  static const _boldFont = 'PhosphorBold';

  static const caretDownBold = IconData(0xe136, fontFamily: _boldFont);

  // Phosphor Fill (solid), only for the bottom bar tabs and the streak
  // flame. Same code points
  // as in Regular (phosphor_icons_fill.dart in the same repo).
  static const _fillFont = 'PhosphorFill';

  static const fileTextFill = IconData(0xe23a, fontFamily: _fillFont);
  static const fireFill = IconData(0xe242, fontFamily: _fillFont);
  static const gearFill = IconData(0xe270, fontFamily: _fillFont);
  static const houseFill = IconData(0xe2c2, fontFamily: _fillFont);
  static const squaresFourFill = IconData(0xe464, fontFamily: _fillFont);
}
