import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/ui/core/app_icons.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/app_style.dart';
import 'package:deutschlernen/ui/core/widgets/round_icon_button.dart';

/// Pill-shaped search field, iOS-style. Idle: no outline, full width.
/// Active (focused or holding text): blue outline while focused, and the
/// field shrinks to make room for a round close button on its right.
/// The button clears the text, hides the keyboard and returns the idle look.
class SearchField extends StatefulWidget {
  const SearchField({
    super.key,
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final VoidCallback onChanged;

  @override
  State<SearchField> createState() => SearchFieldStateX();
}

class SearchFieldStateX extends State<SearchField> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Rebuild on focus changes: the outline and the button depend on it.
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  // Also active with text but no focus (e.g. after scrolling the results
  // hid the keyboard), so the text can still be cleared.
  bool get _isActive =>
      _focusNode.hasFocus || widget.controller.text.isNotEmpty;

  void _close() {
    widget.controller.clear();
    _focusNode.unfocus();
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final pill = OutlineInputBorder(
      borderRadius: BorderRadius.circular(100), // fully round ends
      borderSide: BorderSide.none,
    );
    // Quiet grays, so the search doesn't draw attention from the content:
    // the outline is the divider color, hint and close icon a bit more
    // visible to stay readable.
    final colors = Theme.of(context).colorScheme;
    final gray = AppColors.divider(colors);
    final lightGray = AppColors.quietText(colors);

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            onChanged: (_) => widget.onChanged(),
            autocorrect: false,
            enableSuggestions: false,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(color: lightGray),
              prefixIcon: const Icon(AppIcons.magnifyingGlass),
              filled: true,
              fillColor: AppPalette.of(context).card,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: pill,
              enabledBorder: pill,
              focusedBorder: pill.copyWith(borderSide: BorderSide(color: gray)),
            ),
          ),
        ),
        // AnimatedSize: the field shrinks/grows smoothly as the button
        // appears/disappears instead of jumping.
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: _isActive
              ? Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: RoundIconButton(
                    icon: AppIcons.x,
                    tooltip: AppStrings.of(context).close,
                    iconColor: lightGray,
                    onPressed: _close,
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
