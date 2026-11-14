import 'package:flutter/foundation.dart';
import 'package:deutschlernen/data/repositories/word_repository.dart';
import 'package:deutschlernen/data/services/sound_service.dart';
import 'package:deutschlernen/data/services/speech_service.dart';
import 'package:deutschlernen/domain/models/card_decision.dart';
import 'package:deutschlernen/domain/models/word.dart';

class CardsViewModel extends ChangeNotifier {
  CardsViewModel({
    required WordRepository wordRepository,
    required SoundService soundService,
    required SpeechService speechService,
  })  : _wordRepository = wordRepository,
        _soundService = soundService,
        _speechService = speechService;

  final WordRepository _wordRepository;
  final SoundService _soundService;
  final SpeechService _speechService;

  List<Word> _words = [];
  final List<CardDecision> _history = [];
  CardDecision? _lastUndone;
  bool _isLoading = true;
  bool _isSwiping = false;

  List<Word> get words => _words;
  bool get isLoading => _isLoading;

  /// Index of the current card = number of decisions made so far.
  int get index => _history.length;
  bool get isFinished => !_isLoading && index >= _words.length;
  bool get canUndo => _history.isNotEmpty;
  double get progress => _words.isEmpty ? 0 : index / _words.length;

  /// Set after an undo, so the UI can fly the card back in from the right side.
  CardDecision? get lastUndone => _lastUndone;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    _words = await _wordRepository.getWords();
    _history.clear();
    _lastUndone = null;

    _isLoading = false;
    notifyListeners();
  }

  /// The card has been released and starts flying off screen.
  void onSwipeStarted() {
    _isSwiping = true;
    _soundService.playSwipe();
  }

  /// The card has left the screen.
  void onCardSwiped(CardDecision decision) {
    _history.add(decision);
    _lastUndone = null;
    _isSwiping = false;
    notifyListeners();
  }

  void undo() {
    if (!canUndo || _isSwiping) return;
    _lastUndone = _history.removeLast();
    _soundService.playSwipe();
    notifyListeners();
  }

  void restart() {
    _history.clear();
    _lastUndone = null;
    notifyListeners();
  }

  void speak(String text) => _speechService.speak(text);
}