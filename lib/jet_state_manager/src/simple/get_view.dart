import 'package:flutter/widgets.dart';

import '../../../instance_manager.dart';
import '../../../utils.dart';
import 'get_state.dart';
import 'get_widget_cache.dart';

/// JetView is a great way of quickly access your Controller
/// without having to call `Get.find<AwesomeController>()` yourself.
///
/// Sample:
/// ```
/// class AwesomeController extends JetController {
///   final String title = 'My Awesome View';
/// }
///
/// class AwesomeView extends JetView<AwesomeController> {
///   /// if you need you can pass the tag for
///   /// Get.find<AwesomeController>(tag:"myTag");
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

  T get controller => Get.find<T>(tag: tag)!;

  @override
  Widget build(BuildContext context);
}

/// JetWidget is a great way of quickly access your individual Controller
/// without having to call `Get.find<AwesomeController>()` yourself.
/// Get save you controller on cache, so, you can to use Get.create() safely
/// JetWidget is perfect to multiples instance of a same controller. Each
/// JetWidget will have your own controller, and will be call events as `onInit`
/// and `onClose` when the controller get in/get out on memory.
abstract class JetWidget<S extends JetLifeCycleMixin> extends JetWidgetCache {
  const JetWidget({super.key});

  @protected
  final String? tag = null;

  S get controller => JetWidget._cache[this] as S;

  // static final _cache = <JetWidget, GetLifeCycleBase>{};

  static final _cache = Expando<JetLifeCycleMixin>();

  @protected
  Widget build(BuildContext context);

  @override
  WidgetCache createWidgetCache() => _GetCache<S>();
}

class _GetCache<S extends JetLifeCycleMixin> extends WidgetCache<JetWidget<S>> {
  S? _controller;
  bool _isCreator = false;
  InstanceInfo? info;
  @override
  void onInit() {
    info = Get.getInstanceInfo<S>(tag: widget!.tag);

    _isCreator = info!.isPrepared && info!.isCreate;

    if (info!.isRegistered) {
      _controller = Get.find<S>(tag: widget!.tag);
    }

    JetWidget._cache[widget!] = _controller;

    super.onInit();
  }

  @override
  void onClose() {
    if (_isCreator) {
      Get.asap(() {
        widget!.controller.onDelete();
        Get.log('"${widget!.controller.runtimeType}" onClose() called');
        Get.log('"${widget!.controller.runtimeType}" deleted from memory');
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
