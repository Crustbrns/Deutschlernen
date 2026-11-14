import 'package:flutter/foundation.dart';
import 'package:deutschlernen/data/repositories/word_rep.dart';
import 'package:deutschlernen/domain/models/word.dart';

class CardsViewModel extends ChangeNotifier {
  CardsViewModel({required WordRepository wordRepository})
      : _wordRepository = wordRepository;

  final WordRepository _wordRepository;

  List<Word> _words = [];
  bool _isLoading = false;

  List<Word> get words => List.unmodifiable(_words);
  bool get isLoading => _isLoading;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    _words = await _wordRepository.getWords();

    _isLoading = false;
    notifyListeners();
  }
}