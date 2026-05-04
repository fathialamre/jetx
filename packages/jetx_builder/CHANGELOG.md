## 0.1.0-dev.1

- Initial release.
- `@JetRoute(path: ...)` annotation handler.
- Emits a `_$<ClassName>` mixin per annotated class with a `location`
  getter built on `Jet.buildUrl`.
- Path `:name` segments matched by field name; non-path fields become
  query params; missing path-param fields fail the build with
  `InvalidGenerationSourceError`.
