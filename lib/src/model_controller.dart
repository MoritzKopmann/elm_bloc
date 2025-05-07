import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_mvu/src/event.dart';
import 'package:flutter_mvu/src/sink_and_stream.dart';

class ModelController<T extends Object> {
  final T _model;
  T get model => _model;

  final _events = EventStream<T>();
  final _outEvents = OutEventStream<T>();
  final _stateStream = BroadcastStream<T>();

  ModelController(this._model, {List<Event<T>> initialEvents = const []}) {
    _initEventStreamListener();
    notifyListeners();
    for (Event<T> event in initialEvents) {
      triggerEvent(event);
    }
  }

  Stream<T> get stream => _stateStream.stream;
  Stream<OutEvent<T>> get outEventStream => _outEvents.stream;

  void triggerEvent(Event<T> event) {
    assert(() {
      debugPrint("Triggering event: ${event.runtimeType}");
      return true;
    }());
    _events.sink.add(event);
  }

  void _initEventStreamListener() {
    // Fire off a detached async function
    () async {
      await for (final Event<T> event in _events.stream) {
        event.updateModel(_model, triggerEvent, _triggerOutEvent);
        notifyListeners();
      }
    }();
  }

  void _triggerOutEvent(OutEvent<T> outEvent) {
    assert(() {
      debugPrint("Triggering out-event: ${outEvent.runtimeType}");
      return true;
    }());
    _outEvents.sink.add(outEvent);
  }

  void notifyListeners() {
    _stateStream.sink.add(_model);
  }

  @mustCallSuper
  void dispose() {
    _stateStream.dispose();
    _events.dispose();
    _outEvents.dispose();
  }
}
