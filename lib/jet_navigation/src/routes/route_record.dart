import 'package:flutter/foundation.dart';

/// Public, immutable snapshot of a single entry on the navigation stack.
///
/// Distinct from [RouteDecoder] which is the internal representation used by
/// [JetDelegate] (it carries a [PageSettings], parameter mutators, completer
/// hooks, and other implementation details). [RouteRecord] is the contract
/// exposed to consumers via `Jet.history` and `Jet.routeChanges`.
///
/// Equality is value-based: two records are equal when their [name],
/// [arguments], and [parameters] all compare equal (parameters use
/// [mapEquals]).
@immutable
class RouteRecord {
  final String name;
  final Object? arguments;
  final Map<String, String> parameters;

  const RouteRecord({
    required this.name,
    this.arguments,
    this.parameters = const {},
  });

  RouteRecord copyWith({
    String? name,
    Object? arguments,
    Map<String, String>? parameters,
  }) =>
      RouteRecord(
        name: name ?? this.name,
        arguments: arguments ?? this.arguments,
        parameters: parameters ?? this.parameters,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RouteRecord &&
        other.name == name &&
        other.arguments == arguments &&
        mapEquals(other.parameters, parameters);
  }

  @override
  int get hashCode => Object.hash(
        name,
        arguments,
        Object.hashAllUnordered(
          parameters.entries.map((e) => Object.hash(e.key, e.value)),
        ),
      );

  @override
  String toString() =>
      'RouteRecord(name: $name, arguments: $arguments, parameters: $parameters)';
}
