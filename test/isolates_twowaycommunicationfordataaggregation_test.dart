import 'package:isolates_twowaycommunicationfordataaggregation/isolates_twowaycommunicationfordataaggregation.dart';
import 'package:test/test.dart';

void main() {
  test('aggregateDataInIsolate aggregates data correctly', () async {
    var result = await aggregateDataInIsolate([1, 2, 3, 4]);
    expect(result, equals(10));

    // Sending additional data
    var additionalResult = await aggregateDataInIsolate([5, 6]);
    expect(additionalResult, equals(21)); // 10 + 5 + 6

    shutdown();
  });

  test('aggregateDataInIsolate handles empty data', () async {
    var result = await aggregateDataInIsolate([]);
    expect(result, equals(0));

    shutdown();
  });
}