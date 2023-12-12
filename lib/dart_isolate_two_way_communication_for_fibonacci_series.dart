/// Support for doing something awesome.
///
/// More dartdocs go here.
library;

export 'src/dart_isolate_two_way_communication_for_fibonacci_series_base.dart';

/*
Practice Question 1: Two-Way Communication for Fibonacci Series
Task:
Modify a function generateFibonacciInIsolate to compute the Fibonacci 
series up to a given number in a separate isolate using two-way communication. 
The main isolate can send multiple numbers to the spawned isolate and 
receive the Fibonacci series for each number as a list.
 */

import 'dart:async';
import 'dart:isolate';

class FibonacciIsolate {
  Isolate? worker;
  ReceivePort receivedFromWorker = ReceivePort();
  SendPort? sendToWorker;
  Stream? streamFromWorker;

  FibonacciIsolate() {
    streamFromWorker = receivedFromWorker.asBroadcastStream();
  }

  Future<dynamic> sendAndReceive(int input) async {
    final completer = Completer<List<int>>();

    worker ??=
        await Isolate.spawn(fibonacciIsolateO, receivedFromWorker.sendPort);
    (sendToWorker != null)
        ? sendToWorker?.send(input)
        : print(
            'Send port to worker has not been initialized! This must be the first run.');

    late StreamSubscription? sendAndReceive;
    sendAndReceive = streamFromWorker?.listen((event) async {
      print('Message from worker: $event');
      if (event is SendPort) {
        sendToWorker = event;
        sendToWorker?.send(input);
      }

      if (event is List<int>) {
        completer.complete(event);
        sendAndReceive?.cancel();
      }
    });
    return completer.future;
  }

  Future<void> shutdown() async {
    receivedFromWorker.close();
    worker?.kill();
    worker = null;
  }
}

Future<dynamic> fibonacciIsolateO(SendPort sendToMain) async {
  final receievedFromMain = ReceivePort();
  sendToMain.send(receievedFromMain.sendPort);

  receievedFromMain.listen((message) {
    print('Message from worker: $message');

    if (message is int) {
      final processed = generateFibonacci(message);
      sendToMain.send(processed);
    }
  });
}

List<int> generateFibonacci(int n) {
  List<int> fibonacciSeries = [];
  int a = 0, b = 1;

  for (int i = 0; i < n; i++) {
    fibonacciSeries.add(a);
    int next = a + b;
    a = b;
    b = next;
  }

  return fibonacciSeries;
}

setupFibonacciIsolate() async {
  return FibonacciIsolate();
}
