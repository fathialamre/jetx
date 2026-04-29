import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../../jet_core/jet_core.dart';
import '../../../jet_instance/src/extension_instance.dart';
import '../../../jet_instance/src/lifecycle.dart';
import '../simple/list_notifier.dart';

typedef JetXControllerBuilder<T extends JetLifeCycleMixin> = Widget Function(
    T controller);

class JetX<T extends JetLifeCycleMixin> extends StatefulWidget {
  final JetXControllerBuilder<T> builder;
  final bool global;
  final bool autoRemove;
  final bool assignId;
  final void Function(JetXState<T> state)? initState,
      dispose,
      didChangeDependencies;
  final void Function(JetX oldWidget, JetXState<T> state)? didUpdateWidget;
  final T? init;
  final String? tag;

  const JetX({
    super.key,
    this.tag,
    required this.builder,
    this.global = true,
    this.autoRemove = true,
    this.initState,
    this.assignId = false,
    //  this.stream,
    this.dispose,
    this.didChangeDependencies,
    this.didUpdateWidget,
    this.init,
    // this.streamController
  });

  @override
  StatefulElement createElement() => StatefulElement(this);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        DiagnosticsProperty<T>('controller', init),
      )
      ..add(DiagnosticsProperty<String>('tag', tag))
      ..add(
          ObjectFlagProperty<JetXControllerBuilder<T>>.has('builder', builder));
  }

  @override
  JetXState<T> createState() => JetXState<T>();
}

class JetXState<T extends JetLifeCycleMixin> extends State<JetX<T>> {
  T? controller;
  bool? _isCreator = false;

  @override
  void initState() {
    // var isPrepared = Jet.isPrepared<T>(tag: widget.tag);
    final isRegistered = Jet.isRegistered<T>(tag: widget.tag);

    if (widget.global) {
      if (isRegistered) {
        _isCreator = Jet.isPrepared<T>(tag: widget.tag);
        controller = Jet.find<T>(tag: widget.tag);
      } else {
        controller = widget.init;
        _isCreator = true;
        Jet.put<T>(controller!, tag: widget.tag);
      }
    } else {
      controller = widget.init;
      _isCreator = true;
      controller?.onStart();
    }
    widget.initState?.call(this);
    if (widget.global && Jet.smartManagement == SmartManagement.onlyBuilder) {
      controller?.onStart();
    }

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.didChangeDependencies != null) {
      widget.didChangeDependencies!(this);
    }
  }

  @override
  void didUpdateWidget(JetX oldWidget) {
    super.didUpdateWidget(oldWidget as JetX<T>);
    widget.didUpdateWidget?.call(oldWidget, this);
  }

  @override
  void dispose() {
    if (widget.dispose != null) widget.dispose!(this);
    if (_isCreator! || widget.assignId) {
      if (widget.autoRemove && Jet.isRegistered<T>(tag: widget.tag)) {
        Jet.delete<T>(tag: widget.tag);
      }
    }

    for (final disposer in disposers) {
      disposer();
    }

    disposers.clear();

    controller = null;
    _isCreator = null;
    super.dispose();
  }

  void _update() {
    if (mounted) {
      setState(() {});
    }
  }

  final disposers = <Disposer>[];

  @override
  Widget build(BuildContext context) => Notifier.instance.append(
      NotifyData(disposers: disposers, updater: _update),
      () => widget.builder(controller!));

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<T>('controller', controller));
  }
}
