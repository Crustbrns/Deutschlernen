import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/app_style.dart';
import 'package:deutschlernen/ui/core/widgets/choice_sheet.dart';

Future<void> showAddOwnWordSheet({
  required BuildContext context,
  required Future<void> Function(String german, String translation) onSave,
}) {
  final strings = AppStrings.of(context);
  return showSheet(
    context: context,
    title: strings.addWord,
    builder: (_) => _OwnWordForm(onSave: onSave),
  );
}

class _OwnWordForm extends StatefulWidget {
  const _OwnWordForm({required this.onSave});

  final Future<void> Function(String german, String translation) onSave;

  @override
  State<_OwnWordForm> createState() => _OwnWordFormState();
}

class _OwnWordFormState extends State<_OwnWordForm> {
  final _formKey = GlobalKey<FormState>();
  final _germanController = TextEditingController();
  final _translationController = TextEditingController();
  final _translationFocus = FocusNode();
  bool _saving = false;

  @override
  void dispose() {
    _germanController.dispose();
    _translationController.dispose();
    _translationFocus.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      await widget.onSave(
        _germanController.text.trim(),
        _translationController.text.trim(),
      );
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final palette = AppPalette.of(context);
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    );

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _germanController,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _translationFocus.requestFocus(),
            validator: (value) =>
                value?.trim().isEmpty ?? true ? strings.fieldRequired : null,
            decoration: InputDecoration(
              labelText: strings.germanWord,
              filled: true,
              fillColor: palette.card,
              isDense: true,
              border: border,
              enabledBorder: border,
              focusedBorder: border,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _translationController,
            focusNode: _translationFocus,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _save(),
            validator: (value) =>
                value?.trim().isEmpty ?? true ? strings.fieldRequired : null,
            decoration: InputDecoration(
              labelText: strings.translation,
              filled: true,
              fillColor: palette.card,
              isDense: true,
              border: border,
              enabledBorder: border,
              focusedBorder: border,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _saving ? null : _save,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(strings.addWord),
          ),
        ],
      ),
    );
  }
}
