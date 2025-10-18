/// A provider that holds a reference to a registered dependency.
/// Similar to Riverpod's Provider, this acts as a key for retrieving instances.
class Provider<T> {
  final String? tag;
  final String _key;

  const Provider._(this._key, this.tag);

  /// Factory constructor to create a provider with a key and optional tag.
  factory Provider.create(String key, {String? tag}) {
    return Provider._(key, tag);
  }

  /// The internal key used to identify this provider in the dependency registry.
  String get key => _key;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Provider<T> && other._key == _key;
  }

  @override
  int get hashCode => _key.hashCode;

  @override
  String toString() => 'Provider<$T>(${tag ?? 'default'})';
}
