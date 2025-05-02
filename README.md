# flutter_mvu 🚀🎉

A minimal Elm-inspired Model-View-Update (MVU) state management library for Flutter. Predictable, testable, and boilerplate-free! 😎✨

---

## 📦 Installation 🔧

1. **Add to `pubspec.yaml`**:
   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     flutter_mvu: ^0.1.0
   ```
2. **Fetch packages**:
   ```bash
   flutter pub get
   ```
3. **Import** into your Dart files:
   ```dart
   import 'package:flutter_mvu/mvu.dart';
   ```

> **Compatibility**: Supports Dart ≥2.17 and Flutter ≥3.0 with full null-safety.

---

## 💡 Concept Overview

At the heart of **MVU** are four simple ideas:

1. **Model**: Your app's state – any plain Dart object holding data; **no base class or mixin required**.
2. **Event**: A message describing _what happened_ (user tap, data fetched, etc.).
3. **Update**: The `updateModel` method inside your `Event<T>` implementation—where you define how the `Model` changes in response to the `Event`.
4. **View**: A Flutter widget that renders the current `Model` and _emits_ `Event<T>` events via the provided `triggerEvent` callback.

Unidirectional flow:
```
User Interaction ➡️ Event ➡️ updateModel ➡️ Model Updated ➡️ View Rebuild ➡️ ...
```

This clear flow ensures that all state changes are predictable, easy to trace, and simple to test. 🛤️🔍

---

## 📝 API Summary 📋

### 🔸 ModelController<T>
Manages your `Model` instance, processes `Event<T>` events, and broadcasts state changes.

- **Constructor**: `ModelController(T initialModel)`
- **Properties**:
  - `T get model` – latest state object
  - `Stream<T> get stream` – broadcast of state snapshots
- **Methods**:
  - `void triggerEvent(Event<T> event)` – enqueue an event
  - `void dispose()` – close streams and free resources


### 🔸 Event<T>
Defines how to update the `Model` when something happens.

```dart
abstract class Event<T> {
  void updateModel(
    T model,
    void Function(Event<T>) triggerEvent,
    void Function(OutEvent<T>) triggerOutEvent,
  );
}
```

- Implement `Event<T>` and override `updateModel`.
- Use `triggerEvent` to chain further events.
- Use `triggerOutEvent` to bubble messages to parent models.


### 🔸 OutEvent<T>
A simple marker to bubble child→parent messages. Your model can be any class; no inheritance needed.

```dart
class ChildDidSomething extends OutEvent<MyChildModel> {
  final String info;
  ChildDidSomething(this.info);
}
```

#### Parent-Child Wiring Example
```dart
class ParentModel { /*…*/ }
class ChildModel  { /*…*/ }

final childCtrl = ModelController(ChildModel());
final parentCtrl = ModelController(ParentModel());

// In parent’s setup logic:
childCtrl.outEventStream.listen((out) {
  parentCtrl.triggerEvent(ChildDidSomething(out.info));
});
```

```dart
class ChildDidSomething extends OutEvent<MyChildModel> {
  final String info;
  ChildDidSomething(this.info);
}
```


### 🔸 StateView<T>
Defines how to render a `Model` and emit `Event<T>` events in response.

```dart
abstract class StateView<T> {
  Widget view(
    BuildContext context,
    T currentState,
    void Function(Event<T>) triggerEvent,
  );
}
```


### 🔸 ModelProvider<T>
A `StatefulWidget` that binds a `ModelController<T>` to a `StateView<T>`.

- **Auto-managed** constructor:
  ```dart
  ModelProvider(
    MyModel(),            // your raw model
    stateView: MyView(),  // your StateView implementation
  )
  ```
  • Creates its own `ModelController` and **auto-disposes** it.

- **Self-managed** constructor:
  ```dart
  ModelProvider.controller(
    myController,        // existing ModelController
    stateView: MyView(),
  )
  ```
  • Uses your controller and **does not dispose** it; you manage lifecycle.

⚠️ **For self-managed controllers, remember to call `controller.dispose()` when you’re done to avoid memory leaks.**

---

## 🚀 Examples

### 1️⃣ Counter Example (Auto-managed)

```dart
// 1️⃣ Define the Model
class CounterModel {
  int count = 0;
}

// 2️⃣ Define an Event
class IncrementEvent implements Event<CounterModel> {
  @override
  void updateModel(CounterModel model, triggerEvent, _) {
    model.count++;
  }
}

// 3️⃣ Define the View
class CounterView extends StateView<CounterModel> {
  @override
  Widget view(BuildContext context, CounterModel state, triggerEvent) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Count: ${state.count}', style: TextStyle(fontSize: 32)),
          ElevatedButton(
            onPressed: () => triggerEvent(IncrementEvent()),
            child: Text('Increment ➕'),
          ),
        ],
      ),
    );
  }
}

// 4️⃣ Wire up in main()
void main() {
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: Text('Auto-managed Counter')),
      body: ModelProvider(
        CounterModel(),
        stateView: CounterView(),
      ),
    ),
  ));
}
```

### 2️⃣ Counter Example (Self-managed)

```dart
// Reuse CounterModel, IncrementEvent, CounterView from above

void main() {
  final counterController = ModelController(CounterModel());

  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: Text('Self-managed Counter')),
      body: ModelProvider.controller(
        counterController,
        stateView: CounterView(),
      ),
    ),
  ));
}

```

### 3️⃣ Async Event Pattern ⏳

```dart
// 1️⃣ Model with loading/error state
class DataModel {
  bool isLoading = false;
  List<String>? items;
  String? error;
}

// 2️⃣ Define result events
class DataLoadedEvent implements Event<DataModel> {
  final List<String> items;
  DataLoadedEvent(this.items);

  @override
  void updateModel(DataModel model, _, __) {
    model.items = items;
    model.isLoading = false;
  }
}

class DataLoadFailedEvent implements Event<DataModel> {
  final String message;
  DataLoadFailedEvent(this.message);

  @override
  void updateModel(DataModel model, _, __) {
    model.error = message;
    model.isLoading = false;
  }
}

// 3️⃣ Async fetch event
class FetchDataEvent implements Event<DataModel> {
  @override
  void updateModel(DataModel model, triggerEvent, _) {
    model.isLoading = true;

    fetchRemoteItems()
      .then((items) => triggerEvent(DataLoadedEvent(items)))
      .catchError((err) => triggerEvent(DataLoadFailedEvent(err.toString())));
  }
}
```

---


## 🧪 Testing 🧪

For unit and widget tests, add the `flutter_mvu_test` package to your dev dependencies:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_mvu_test: ^0.1.0
```

Then import in your test files:

```dart
import 'package:flutter_mvu_test/flutter_mvu_test.dart';
```

Use `TestModelController<T>` to synchronously dispatch events and assert on both model state, `Event<T>` and `OutEvent<T>` emissions. 

See **flutter_mvu_test** [![flutter_mvu_test pub version](https://img.shields.io/pub/v/flutter_mvu_test.svg)](https://pub.dev/packages/flutter_mvu_test)


## 🎓 Tips & Next Steps

- **Dispose wisely**: Auto-managed providers handle it for you; for self-managed, call `dispose()` when appropriate.
- **OutEvents**: Implement to communicate child→parent updates in nested models.
- **Debug logs**: In debug builds, events are printed automatically for easy tracing.

Happy MVU‑ing! 🚀🎨✨
