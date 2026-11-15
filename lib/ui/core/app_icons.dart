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
  static const bookOpen = IconData(0xe0e6, fontFamily: _font);
  static const cards = IconData(0xe0f8, fontFamily: _font);
  static const caretDown = IconData(0xe136, fontFamily: _font);
  static const caretRight = IconData(0xe13a, fontFamily: _font);
  static const chartLineUp = IconData(0xe156, fontFamily: _font);
  static const check = IconData(0xe182, fontFamily: _font);
  static const checkCircle = IconData(0xe184, fontFamily: _font);
  static const circle = IconData(0xe18a, fontFamily: _font);
  static const clockCounterClockwise = IconData(0xe1a0, fontFamily: _font);
  static const deviceMobile = IconData(0xe1e0, fontFamily: _font);
  static const eye = IconData(0xe220, fontFamily: _font);
  static const info = IconData(0xe2ce, fontFamily: _font);
  static const listChecks = IconData(0xeadc, fontFamily: _font);
  static const magnifyingGlass = IconData(0xe30c, fontFamily: _font);
  static const moon = IconData(0xe330, fontFamily: _font);
  static const pencilSimple = IconData(0xe3b4, fontFamily: _font);
  static const play = IconData(0xe3d0, fontFamily: _font);
  static const plusCircle = IconData(0xe3d6, fontFamily: _font);
  static const slidersHorizontal = IconData(0xe434, fontFamily: _font);
  static const speakerHigh = IconData(0xe44a, fontFamily: _font);
  static const squaresFour = IconData(0xe464, fontFamily: _font);
  static const sun = IconData(0xe472, fontFamily: _font);
  static const translate = IconData(0xe4a2, fontFamily: _font);
  static const x = IconData(0xe4f6, fontFamily: _font);
  static const xCircle = IconData(0xe4f8, fontFamily: _font);
}
