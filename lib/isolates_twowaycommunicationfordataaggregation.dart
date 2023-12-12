/// Support for doing something awesome.
///
/// More dartdocs go here.
library;

import 'dart:async';
import 'dart:isolate';

export 'src/isolates_twowaycommunicationfordataaggregation_base.dart';

/*
Practice Question 3: Two-Way Communication for Data Aggregation

Task:

Implement a function aggregateDataInIsolate that sends a list 
of data points to an isolate for aggregation (e.g., summing up values). 
The isolate should perform the aggregation and send back the result. 
The main isolate can send additional data points for aggregation in real-time.
 */

MainWorker? mainWorker;

class MainWorker{
  final receivedFromWorker = ReceivePort();
  Isolate? childIsolate;
  SendPort? sendToWorker;
  int total = 0;
  late final Stream receivedFromWorkerBroadCast;

  MainWorker(){
    receivedFromWorkerBroadCast = receivedFromWorker.asBroadcastStream();
  }
}

aggregateDataInIsolate(List<int> input) async {
  mainWorker ??= MainWorker();
  final completer = Completer();
  mainWorker?.childIsolate ??= await Isolate.spawn(
    agreggator,
    (mainWorker!).receivedFromWorker.sendPort
  );

  if(mainWorker?.sendToWorker != null){
    mainWorker?.sendToWorker!.send(input);
  }

  StreamSubscription? sub;
  sub = mainWorker?.receivedFromWorkerBroadCast.listen((event) async {
    print("Message received from worker: $event");
    if(event is SendPort){
      print("Sendport received from worker! Setting.");
      mainWorker?.sendToWorker = event;
      mainWorker?.sendToWorker?.send(input);
    }
    if(event is int){
      print("Received processed int from worker: $event");
      mainWorker?.total += event;
      completer.complete(mainWorker?.total);
      sub?.cancel();
    }
  });

  return completer.future;
}

agreggator(SendPort sendToMain) {
  print("Worker isolate spawned!");
  final receivedFromMain = ReceivePort();
  sendToMain.send(receivedFromMain.sendPort);
  receivedFromMain.listen((message) {
    print("Message from main: $message");
    if (message is List) {
      final total = message.fold(0, (previousValue, element) => (previousValue + element) as int);
      sendToMain.send(total);
    }
  });
}

shutdown(){
  mainWorker?.receivedFromWorker.close();
  mainWorker?.childIsolate?.kill();
  mainWorker?.childIsolate = null;
  mainWorker = null;
}