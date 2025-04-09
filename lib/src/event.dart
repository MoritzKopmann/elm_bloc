/// Represents an event that updates a model of type [T].
///
/// Implementers must define [updateModel] to specify how the model is updated.
abstract class Event<T> {
  /// Updates [model] based on the event.
  ///
  /// must be synchronous
  void updateModel(
    T model,
    Function(Event<T> event) triggerEvent,
    Function(OutEvent<T> triggerOutEvent) triggerOutEvent,
  );
}

abstract class OutEvent<T> {}
