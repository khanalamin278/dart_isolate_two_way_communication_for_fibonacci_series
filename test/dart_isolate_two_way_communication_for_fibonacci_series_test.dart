import 'package:dart_isolate_two_way_communication_for_fibonacci_series/dart_isolate_two_way_communication_for_fibonacci_series.dart';
import 'package:test/test.dart';

void main() {
  test(
      'generateFibonacciInIsolate generates Fibonacci series with two-way communication',
      () async {
    var fibonacciIsolate = await setupFibonacciIsolate();

    expect(await fibonacciIsolate.sendAndReceive(5), equals([0, 1, 1, 2, 3]));
    expect(await fibonacciIsolate.sendAndReceive(7),
        equals([0, 1, 1, 2, 3, 5, 8]));
    expect(await fibonacciIsolate.sendAndReceive(10),
        equals([0, 1, 1, 2, 3, 5, 8, 13, 21, 34]));

    await fibonacciIsolate.shutdown();
  });
}
