import 'package:material_ui/material_ui.dart';

class AppStrings {
  const AppStrings(this._values);

  final Map<String, String> _values;

  // A missing key shows its own name, so gaps are easy to spot.
  String _get(String key) => _values[key] ?? key;

  String get newWord => _get('newWord');
  String get showTranslation => _get('showTranslation');
  String get plural => _get('plural');
  String get later => _get('later');
  String get remembered => _get('remembered');
  String get close => _get('close');
  String get back => _get('back');
  String get menu => _get('menu');
  String get language => _get('language');
  String get goodWork => _get('goodWork');
  String get restart => _get('restart');

  /// Texts for the current language: `AppStrings.of(context).later`.
  static AppStrings of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStringsScope>();
    assert(scope != null, 'No AppStringsScope found above this widget');
    return scope!.strings;
  }
}

class AppStringsScope extends InheritedWidget {
  const AppStringsScope({
    super.key,
    required this.strings,
    required super.child,
  });

  final AppStrings strings;

  @override
  bool updateShouldNotify(AppStringsScope oldWidget) =>
      strings != oldWidget.strings;
}