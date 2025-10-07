import 'package:flutter/material.dart';

import '../rx_flutter/rx_obx_widget.dart';
import 'jet_controllers.dart';
import 'jet_state.dart';

class MixinBuilder<T extends JetController> extends StatelessWidget {
  @required
  final Widget Function(T) builder;
  final bool global;
  final String? id;
  final bool autoRemove;
  final void Function(BindElement<T> state)? initState,
      dispose,
      didChangeDependencies;
  final void Function(Binder<T> oldWidget, BindElement<T> state)?
      didUpdateWidget;
  final T? init;

  const MixinBuilder({
    super.key,
    this.init,
    this.global = true,
    required this.builder,
    this.autoRemove = true,
    this.initState,
    this.dispose,
    this.id,
    this.didChangeDependencies,
    this.didUpdateWidget,
  });

  @override
  Widget build(BuildContext context) {
    return JetBuilder<T>(
        init: init,
        global: global,
        autoRemove: autoRemove,
        initState: initState,
        dispose: dispose,
        id: id,
        didChangeDependencies: didChangeDependencies,
        didUpdateWidget: didUpdateWidget,
        builder: (controller) => Obx(() => builder.call(controller)));
  }
}
