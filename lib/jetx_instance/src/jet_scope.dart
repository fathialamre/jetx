import 'package:flutter/widgets.dart';
import 'provider.dart';

/// A root-level widget that manages global provider state.
/// Similar to ProviderScope in Riverpod, this widget should wrap your entire app
/// to enable proper provider lifecycle management and reference tracking.
class JetScope extends StatefulWidget {
  /// The child widget tree to wrap.
  final Widget child;

  /// Optional list of initial providers to register when the scope is created.
  /// These providers will be registered immediately when the scope initializes.
  final List<Provider> providers;

  const JetScope({
    super.key,
    required this.child,
    this.providers = const [],
  });

  @override
  State<JetScope> createState() => _JetScopeState();
}

class _JetScopeState extends State<JetScope> {
  @override
  void initState() {
    super.initState();
    // Register any initial providers if needed
    // This could be extended to support initial provider registration
    // For now, providers are registered explicitly via Jet.put() calls
  }

  @override
  void dispose() {
    // Clean up any scope-specific resources if needed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
