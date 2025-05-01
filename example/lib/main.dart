import 'package:flutter/material.dart';
import 'package:flutter_mvu/flutter_mvu.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flutter_mvu Example',
      home: Scaffold(
        appBar: AppBar(title: Text('Auto-managed Counter')),
        body: ModelProvider(
          CounterModel(),
          stateView: CounterView(),
        ),
      ),
    );
  }
}

// 1️⃣ Model
class CounterModel {
  int count = 0;
}

// 2️⃣ Event
class IncrementEvent implements Event<CounterModel> {
  @override
  void updateModel(CounterModel model, trigger, _) {
    model.count++;
  }
}

// 3️⃣ View
class CounterView extends StateView<CounterModel> {
  @override
  Widget view(
    BuildContext context,
    CounterModel state,
    void Function(Event<CounterModel>) triggerEvent,
  ) {
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
