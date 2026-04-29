import 'package:flutter/widgets.dart';

abstract class JetWidgetCache extends Widget {
  const JetWidgetCache({super.key});

  @override
  JetWidgetCacheElement createElement() => JetWidgetCacheElement(this);

  @protected
  @factory
  WidgetCache createWidgetCache();
}

class JetWidgetCacheElement extends ComponentElement {
  JetWidgetCacheElement(JetWidgetCache widget)
      : cache = widget.createWidgetCache(),
        super(widget) {
    cache._element = this;
    cache._widget = widget;
  }

  @override
  void mount(Element? parent, dynamic newSlot) {
    cache.onInit();
    super.mount(parent, newSlot);
  }

  @override
  Widget build() => cache.build(this);

  final WidgetCache<JetWidgetCache> cache;

  @override
  void activate() {
    super.activate();
    markNeedsBuild();
  }

  @override
  void unmount() {
    super.unmount();
    cache.onClose();
    cache._element = null;
  }
}

@optionalTypeArgs
abstract class WidgetCache<T extends JetWidgetCache> {
  T? get widget => _widget;
  T? _widget;

  BuildContext? get context => _element;

  JetWidgetCacheElement? _element;

  @protected
  @mustCallSuper
  void onInit() {}

  @protected
  @mustCallSuper
  void onClose() {}

  @protected
  Widget build(BuildContext context);
}
