# JetX Annotations

Annotation classes for JetX route code generation.

## Annotations

### @RoutePage

Mark a page class as a route for code generation.

```dart
@RoutePage(
  path: '/user/:id',
  name: 'userRoute',
  transition: 'fadeIn',
  transitionDurationMs: 300,
  fullscreenDialog: false,
  maintainState: true,
  preventDuplicates: true,
)
class UserPage extends StatelessWidget { ... }
```

### @QueryParam

Mark a constructor parameter as a query parameter.

```dart
@QueryParam(name: 'tab', defaultValue: 'home')
final String? tab;
```

### @RouteBinding / @RouteBindings

Bind controllers to routes.

```dart
@RouteBinding(UserController)
class UserPage extends StatelessWidget { ... }

@RouteBindings([UserController, ProfileController])
class UserPage extends StatelessWidget { ... }
```

### @RouteMiddleware / @RouteMiddlewares

Add middleware to routes.

```dart
@RouteMiddleware(AuthMiddleware)
class UserPage extends StatelessWidget { ... }

@RouteMiddlewares([AuthMiddleware, LoggingMiddleware])
class UserPage extends StatelessWidget { ... }
```

## Usage

See the [JetX Generator README](../jetx_generator/README.md) for complete usage instructions.

