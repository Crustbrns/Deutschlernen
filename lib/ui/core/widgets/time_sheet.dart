import 'package:flutter/services.dart' show HapticFeedback;
import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/ui/core/app_style.dart';
import 'package:deutschlernen/ui/core/widgets/choice_sheet.dart';

typedef TimeOfDayValue = ({int hour, int minute});

/// Bottom sheet with iOS-style wheels for hours and minutes (24-hour, as in
/// Germany and Ukraine). The value is applied when the sheet closes, by
/// "Done" or by swiping it down, like iOS settings.
Future<void> showTimeSheet({
  required BuildContext context,
  required String title,
  required String doneLabel,
  required TimeOfDayValue initial,
  required ValueChanged<TimeOfDayValue> onSelected,
}) async {
  var value = initial;
  await showSheet(
    context: context,
    title: title,
    builder: (sheetContext) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TimeWheels(initial: initial, onChanged: (v) => value = v),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () => Navigator.of(sheetContext).pop(),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(doneLabel),
        ),
      ],
    ),
  );
  if (value != initial) onSelected(value);
}

class _TimeWheels extends StatefulWidget {
  const _TimeWheels({required this.initial, required this.onChanged});

  final TimeOfDayValue initial;
  final ValueChanged<TimeOfDayValue> onChanged;

  @override
  State<_TimeWheels> createState() => _TimeWheelsState();
}

class _TimeWheelsState extends State<_TimeWheels> {
  static const _itemExtent = 44.0;
  static const _height = 220.0;

  late var _value = widget.initial;

  void _set({int? hour, int? minute}) {
    final next = (hour: hour ?? _value.hour, minute: minute ?? _value.minute);
    if (next == _value) return;
    HapticFeedback.selectionClick(); // a tick per step, as on iOS
    _value = next;
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final style = TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w500,
      // Digits of equal width, so the numbers don't wobble while scrolling.
      fontFeatures: const [FontFeature.tabularFigures()],
      color: Theme.of(context).colorScheme.onSurface,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: SizedBox(
        height: _height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Band behind the selected row, like the iOS picker.
            Container(
              height: _itemExtent,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: palette.subtleButton,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Wheel(
                  count: 24,
                  initial: _value.hour,
                  style: style,
                  onChanged: (h) => _set(hour: h),
                ),
                Text(':', style: style),
                _Wheel(
                  count: 60,
                  initial: _value.minute,
                  style: style,
                  onChanged: (m) => _set(minute: m),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// One looping wheel of two-digit numbers 0 … [count] − 1.
class _Wheel extends StatefulWidget {
  const _Wheel({
    required this.count,
    required this.initial,
    required this.style,
    required this.onChanged,
  });

  final int count;
  final int initial;
  final TextStyle style;
  final ValueChanged<int> onChanged;

  @override
  State<_Wheel> createState() => _WheelState();
}

class _WheelState extends State<_Wheel> {
  late final _controller = FixedExtentScrollController(
    initialItem: widget.initial,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      child: ListWheelScrollView.useDelegate(
        controller: _controller,
        itemExtent: _TimeWheelsState._itemExtent,
        physics: const FixedExtentScrollPhysics(),
        // Flatter than the default drum, close to the iOS wheel.
        diameterRatio: 1.4,
        overAndUnderCenterOpacity: 0.35,
        // Looping: the index grows past [count], so take it modulo.
        onSelectedItemChanged: (i) => widget.onChanged(i % widget.count),
        childDelegate: ListWheelChildLoopingListDelegate(
          children: [
            for (var i = 0; i < widget.count; i++)
              Center(
                child: Text(i.toString().padLeft(2, '0'), style: widget.style),
              ),
          ],
        ),
      ),
    );
  }
}
