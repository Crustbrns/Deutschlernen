import 'package:deutschlernen/domain/models/status_counts.dart';
import 'package:deutschlernen/domain/models/word_progress.dart';
import 'package:deutschlernen/domain/models/word_status.dart';

/// The user's progress on every word they have decided on, and the questions
/// the app asks about it. Plain Dart: no Flutter, no storage, easy to test.
class ProgressBook {
  ProgressBook([Map<String, WordProgress>? entries]) : _entries = entries ?? {};

  /// Word id → progress. Words without an entry are new.
  final Map<String, WordProgress> _entries;

  /// Read-only view, for saving.
  Map<String, WordProgress> get entries => Map.unmodifiable(_entries);

  bool get isEmpty => _entries.isEmpty;

  /// Null = the word is new.
  WordProgress? operator [](String wordId) => _entries[wordId];

  /// Sets the word's progress; null makes it new again (used by undo).
  void put(String wordId, WordProgress? progress) {
    if (progress == null) {
      _entries.remove(wordId);
    } else {
      _entries[wordId] = progress;
    }
  }

  /// Returns false if the word was new already.
  bool remove(String wordId) => _entries.remove(wordId) != null;

  void clear() => _entries.clear();

  bool contains(String wordId) => _entries.containsKey(wordId);

  /// Share (0–1) of [wordIds] with progress, i.e. not new; 0 for none.
  double decidedShare(List<String> wordIds) => wordIds.isEmpty
      ? 0
      : wordIds.where(_entries.containsKey).length / wordIds.length;

  WordState stateOf(String wordId, DateTime nowUtc) =>
      WordStatus.of(_entries[wordId], nowUtc);

  /// Words recalled for the first time at or after [since].
  int recalledSince(DateTime since) => _entries.values
      .where((p) => !(p.firstRecalledAt?.isBefore(since) ?? true))
      .length;

  /// Pink words (chosen, never recalled), oldest first. [exists] skips
  /// words no longer in the app.
  List<String> unrecalledIds(bool Function(String wordId) exists) {
    final pink =
        _entries.entries
            .where((e) => e.value.isUnrecalled && exists(e.key))
            .toList()
          // cardId is the creation time in µs, so this is "oldest first".
          ..sort(
            (a, b) => a.value.card!.cardId.compareTo(b.value.card!.cardId),
          );
    return [for (final e in pink) e.key];
  }

  /// Due words, the most overdue first.
  List<String> dueIds(DateTime nowUtc, bool Function(String wordId) exists) {
    final due =
        _entries.entries
            .where((e) => e.value.isDue(nowUtc) && exists(e.key))
            .toList()
          ..sort((a, b) => a.value.card!.due.compareTo(b.value.card!.due));
    return [for (final e in due) e.key];
  }

  /// How many words are in each status right now, for the progress chart.
  StatusCounts counts(DateTime nowUtc) {
    var known = 0, learning = 0, review = 0, learned = 0;
    for (final p in _entries.values) {
      switch (WordStatus.of(p, nowUtc).status) {
        case WordStatus.known:
          known++;
        case WordStatus.learning:
          learning++;
        case WordStatus.review:
          review++;
        case WordStatus.learned:
          learned++;
        case WordStatus.newWord:
          break;
      }
    }
    return StatusCounts(
      known: known,
      learning: learning,
      review: review,
      learned: learned,
    );
  }
}
