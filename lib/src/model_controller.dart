import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_mvu/src/event.dart';
import 'package:flutter_mvu/src/sink_and_stream.dart';

class ModelController<T> {
  final T _model;
  T get model => _model;

  final _events = EventStream<T>();
  final _outEvents = OutEventStream<T>();
  final _stateStream = BroadcastStream<T>();

  ModelController(this._model) {
    _initEventStreamListener();
    _notifyListeners();
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
    _events.stream.listen((Event<T> event) async {
      event.updateModel(_model, triggerEvent, _triggerOutEvent);
      _notifyListeners();
    });
  }

  void _triggerOutEvent(OutEvent<T> outEvent) {
    assert(() {
      debugPrint("Triggering out-event: ${outEvent.runtimeType}");
      return true;
    }());
    _outEvents.sink.add(outEvent);
  }

  void _notifyListeners() {
    _stateStream.sink.add(_model);
  }

  @mustCallSuper
  void dispose() {
    _stateStream.dispose();
    _events.dispose();
    _outEvents.dispose();
  }
}
