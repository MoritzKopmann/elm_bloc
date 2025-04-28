import 'dart:async';
import 'package:flutter_mvu/src/model_controller.dart';
import 'package:flutter_mvu/src/event.dart';

class TestModelController<T extends Object> extends ModelController<T> {
  TestModelController(super.initialModel);

  /// Enqueue [event] and return a Future that completes
  /// with the first new state after the event is applied.
  Future<T> dispatch(Event<T> event) {
    // Wait for the *next* state emission:
    final nextState = stream.skip(1).first;
    triggerEvent(event);
    nextState.whenComplete(() => super.dispose());
    return nextState;
  }
}
