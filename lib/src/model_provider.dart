import 'package:flutter/material.dart';
import 'package:flutter_mvu/src/model_controller.dart';
import 'package:flutter_mvu/src/state_view.dart';

class ModelProvider<T> extends StatelessWidget {
  final ModelController<T> modelControler;
  final StateView<T> stateView;

  const ModelProvider({
    super.key,
    required this.modelControler,
    required this.stateView,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      stream: modelControler.stream,
      initialData: modelControler.model,
      builder: (context, snapshot) {
        final state = snapshot.data;
        if (state == null) {
          return stateView.nullStateView(context, modelControler.triggerEvent);
        }
        return stateView.view(context, state, modelControler.triggerEvent);
      },
    );
  }
}
