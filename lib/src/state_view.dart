import 'package:flutter/material.dart';
import 'package:flutter_mvu/src/event.dart';

/// Defines an interface for building state-based widgets.
///
/// Implementations must provide the [view] function to render UI components
/// corresponding to the state of type [T].
abstract class StateView<T> extends StatelessWidget {
  const StateView({super.key});

  /// Builds and returns a widget in response to the state [currentState].
  ///
  /// The [triggerEvent] can be used within the UI to trigger state changes.
  ///
  /// - [context]: The location in the widget tree where the UI is built.
  /// - [currentState]: The current state data which may be null if not set.
  /// - [triggerEvent]: A function that triggers an event of [Event<T>].
  Widget view(
    BuildContext context,
    T currentState,
    Function(Event<T> event) triggerEvent,
  );

  /// Used to build view when currentState is null
  Widget nullStateView(
    BuildContext context,
    Function(Event<T> event) triggerEvent,
  ) {
    return Container();
  }
}
