import 'package:flutter_test/flutter_test.dart';
import 'package:deutschlernen/domain/models/status_counts.dart';

void main() {
  test('mastered: learned plus "already know", not pink or yellow', () {
    const counts = StatusCounts(known: 3, learning: 5, review: 7, learned: 2);
    expect(counts.mastered, 5);
  });
}
