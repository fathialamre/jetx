class RouteConfig {
  final String className;
  final String routeName;
  final String routePath;
  final List<ParamConfig> parameters;
  final List<BindingConfig> bindings;
  final List<String> middlewares;
  final TransitionConfig? transition;
  final bool fullscreenDialog;
  final bool maintainState;
  final bool preventDuplicates;

  RouteConfig({
    required this.className,
    required this.routeName,
    required this.routePath,
    required this.parameters,
    required this.bindings,
    required this.middlewares,
    this.transition,
    required this.fullscreenDialog,
    required this.maintainState,
    required this.preventDuplicates,
  });
}

class ParamConfig {
  final String name;
  final String type;
  final bool isRequired;
  final bool isPath; // true = path param, false = query param
  final bool isArgument; // true = passed as argument (not in URL)
  final Object? defaultValue;

  ParamConfig({
    required this.name,
    required this.type,
    required this.isRequired,
    required this.isPath,
    required this.isArgument,
    this.defaultValue,
  });
}

class DependencyConfig {
  final String typeName;
  final bool lazy;
  final String? tag;
  final bool permanent;
  final bool useFind;
  final String? importPath;

  DependencyConfig({
    required this.typeName,
    this.lazy = true,
    this.tag,
    this.permanent = false,
    this.useFind = true,
    this.importPath,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DependencyConfig &&
          runtimeType == other.runtimeType &&
          typeName == other.typeName &&
          tag == other.tag;

  @override
  int get hashCode => typeName.hashCode ^ (tag?.hashCode ?? 0);
}

class BindingConfig {
  final String controllerType;
  final bool lazy;
  final String? tag;
  final bool permanent;
  final List<DependencyConfig> dependencies; // Changed from List<String>
  final int
      directDependencyCount; // Number of direct constructor params (vs nested)
  final String? importPath; // Import path for this binding type

  BindingConfig({
    required this.controllerType,
    required this.lazy,
    this.tag,
    this.permanent = false,
    this.dependencies = const [],
    this.directDependencyCount = 0,
    this.importPath,
  });
}

class TransitionConfig {
  final String type;
  final int? durationMs;

  TransitionConfig({required this.type, this.durationMs});
}
