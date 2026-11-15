import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/app_style.dart';

/// Concept of the vocabulary tab: pick one of several dictionaries.
/// The list is a placeholder; real dictionaries will come from a repository.
class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  static const _dictionaries = ['A1', 'A2', 'B1', 'B2'];

  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
            child: Text(
              strings.dictionaries,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          for (var i = 0; i < _dictionaries.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: AppPalette.of(context).card,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: i == _selected
                        ? AppColors.accentBlue
                        : colors.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 4,
                  ),
                  title: Text(_dictionaries[i]),
                  trailing: Icon(
                    i == _selected
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    color: i == _selected
                        ? AppColors.accentBlue
                        : colors.onSurfaceVariant,
                  ),
                  onTap: () => setState(() => _selected = i),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
