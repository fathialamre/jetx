import 'package:flutter/widgets.dart';

import '../../../instance_manager.dart';
import '../../../utils.dart';
import 'jet_state.dart';
import 'jet_widget_cache.dart';

/// JetView is a great way of quickly access your Controller
/// without having to call `Jet.find<AwesomeController>()` yourself.
///
/// Sample:
/// ```
/// class AwesomeController extends JetxController {
///   final String title = 'My Awesome View';
/// }
///
/// class AwesomeView extends JetView<AwesomeController> {
///   /// if you need you can pass the tag for
///   /// Jet.find<AwesomeController>(tag:"myTag");
///   @override
///   final String tag = "myTag";
///
///   AwesomeView({Key key}):super(key:key);
///
///   @override
///   Widget build(BuildContext context) {
///     return Container(
///       padding: EdgeInsets.all(20),
///       child: Text( controller.title ),
///     );
///   }
/// }
///``
abstract class JetView<T> extends StatelessWidget {
  const JetView({super.key});

  final String? tag = null;

  T get controller => Jet.find<T>(tag: tag)!;

  @override
  Widget build(BuildContext context);
}

/// JetWidget is a great way of quickly access your individual Controller
/// without having to call `Jet.find<AwesomeController>()` yourself.
/// Jet save you controller on cache, so, you can to use Jet.create() safely
/// JetWidget is perfect to multiples instance of a same controller. Each
/// JetWidget will have your own controller, and will be call events as `onInit`
/// and `onClose` when the controller get in/get out on memory.
abstract class JetWidget<S extends JetLifeCycleMixin> extends JetWidgetCache {
  const JetWidget({super.key});

  @protected
  final String? tag = null;

  S get controller => JetWidget._cache[this] as S;

  // static final _cache = <JetWidget, JetLifeCycleBase>{};

  static final _cache = Expando<JetLifeCycleMixin>();

  @protected
  Widget build(BuildContext context);

  @override
  WidgetCache createWidgetCache() => _JetCache<S>();
}

class _JetCache<S extends JetLifeCycleMixin> extends WidgetCache<JetWidget<S>> {
  S? _controller;
  bool _isCreator = false;
  InstanceInfo? info;
  @override
  void onInit() {
    info = Jet.getInstanceInfo<S>(tag: widget!.tag);

    _isCreator = info!.isPrepared && info!.isCreate;

    if (info!.isRegistered) {
      _controller = Jet.find<S>(tag: widget!.tag);
    }

    JetWidget._cache[widget!] = _controller;

    super.onInit();
  }

  @override
  void onClose() {
    if (_isCreator) {
      Jet.asap(() {
        widget!.controller.onDelete();
        Jet.log('"${widget!.controller.runtimeType}" onClose() called');
        Jet.log('"${widget!.controller.runtimeType}" deleted from memory');
        // JetWidget._cache[widget!] = null;
      });
    }
    info = null;
    super.onClose();
  }

  @override
  Widget build(BuildContext context) {
    return Binder(
      init: () => _controller,
      child: widget!.build(context),
    );
  }
}
