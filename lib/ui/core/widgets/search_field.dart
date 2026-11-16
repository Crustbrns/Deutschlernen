import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/ui/core/app_icons.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/app_style.dart';
import 'package:deutschlernen/ui/core/widgets/round_icon_button.dart';

/// Pill-shaped search field, iOS-style. Idle: no outline, full width.
/// Active (focused or holding text): blue outline while focused, and the
/// field shrinks to make room for a round close button on its right.
/// The button clears the text, hides the keyboard and returns the idle look.
///
/// Every search in the app uses this field: [onSearch] fires only once the
/// user stops typing ([pause]), not on every key (project rule). The search
/// key and the close button fire it right away.
class SearchField extends StatefulWidget {
  const SearchField({super.key, required this.hint, required this.onSearch});

  final String hint;

  /// The trimmed query; empty when the search was cleared.
  final ValueChanged<String> onSearch;

  /// How long after the last key the search runs.
  static const pause = Duration(milliseconds: 350);

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;

  /// Last query sent, so the same one isn't sent twice (e.g. submit right
  /// after the pause).
  String _sent = '';

  @override
  void initState() {
    super.initState();
    // Rebuild on focus changes: the outline and the button depend on it.
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // Also active with text but no focus (e.g. after scrolling the results
  // hid the keyboard), so the text can still be cleared.
  bool get _isActive => _focusNode.hasFocus || _controller.text.isNotEmpty;

  void _onChanged(String _) {
    setState(() {}); // the close button depends on the text
    _debounce?.cancel();
    _debounce = Timer(SearchField.pause, _send);
  }

  void _send() {
    _debounce?.cancel();
    final query = _controller.text.trim();
    if (query == _sent) return;
    _sent = query;
    widget.onSearch(query);
  }

  void _close() {
    _controller.clear();
    _focusNode.unfocus();
    _send();
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
            controller: _controller,
            focusNode: _focusNode,
            onChanged: _onChanged,
            onSubmitted: (_) => _send(),
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
