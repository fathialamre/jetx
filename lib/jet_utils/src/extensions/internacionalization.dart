import 'dart:ui';

import '../../../jet_core/jet_core.dart';

class _IntlHost {
  Locale? locale;

  Locale? fallbackLocale;

  Map<String, Map<String, String>> translations = {};
}

extension FirstWhereExt<T> on List<T> {
  /// The first element satisfying [test], or `null` if there are none.
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

extension LocalesIntl on JetInterface {
  static final _intlHost = _IntlHost();

  Locale? get locale => _intlHost.locale;

  Locale? get fallbackLocale => _intlHost.fallbackLocale;

  set locale(Locale? newLocale) => _intlHost.locale = newLocale;

  set fallbackLocale(Locale? newLocale) => _intlHost.fallbackLocale = newLocale;

  Map<String, Map<String, String>> get translations => _intlHost.translations;

  void addTranslations(Map<String, Map<String, String>> tr) {
    translations.addAll(tr);
  }

  void clearTranslations() {
    translations.clear();
  }

  void appendTranslations(Map<String, Map<String, String>> tr) {
    tr.forEach((key, map) {
      if (translations.containsKey(key)) {
        translations[key]!.addAll(map);
      } else {
        translations[key] = map;
      }
    });
  }
}

/// Resolves the cache-key form (`languageCode_countryCode`) of a [Locale]
/// without re-allocating on every `.tr` call. Strings are interned by Dart, so
/// this is a constant-time concat after the first invocation per locale.
String _localeKey(Locale locale) =>
    '${locale.languageCode}_${locale.countryCode}';

extension Trans on String {
  // Checks whether the language code and country code are present, and
  // whether the key is also present.
  bool get _fullLocaleAndKey {
    final key = _localeKey(Jet.locale!);
    final map = Jet.translations[key];
    return map != null && map.containsKey(this);
  }

  // Checks if there is a callback language in the absence of the specific
  // country, and if it contains that key. We avoid the previous
  // `Map.map(...)` that allocated a new map on every call by walking the
  // existing keys and short-circuiting on first language match.
  Map<String, String>? get _getSimilarLanguageTranslation {
    final lang = Jet.locale!.languageCode.split('_').first;
    for (final entry in Jet.translations.entries) {
      if (entry.key.split('_').first == lang) {
        return entry.value;
      }
    }
    return null;
  }

  String get tr {
    // Returns the key if locale is null.
    if (Jet.locale?.languageCode == null) return this;

    if (_fullLocaleAndKey) {
      return Jet.translations[_localeKey(Jet.locale!)]![this]!;
    }
    final similarTranslation = _getSimilarLanguageTranslation;
    if (similarTranslation != null && similarTranslation.containsKey(this)) {
      return similarTranslation[this]!;
      // If there is no corresponding language or corresponding key, return
      // the key.
    } else if (Jet.fallbackLocale != null) {
      final fallback = Jet.fallbackLocale!;
      final key = _localeKey(fallback);

      final fullMap = Jet.translations[key];
      if (fullMap != null && fullMap.containsKey(this)) {
        return fullMap[this]!;
      }
      final langMap = Jet.translations[fallback.languageCode];
      if (langMap != null && langMap.containsKey(this)) {
        return langMap[this]!;
      }
      Jet.log(
          'Missing translation key "$this" for locale ${_localeKey(Jet.locale!)} (fallback ${_localeKey(fallback)})');
      return this;
    } else {
      Jet.log(
          'Missing translation key "$this" for locale ${_localeKey(Jet.locale!)} (no fallbackLocale set)');
      return this;
    }
  }

  String trArgs([List<String> args = const []]) {
    var key = tr;
    if (args.isNotEmpty) {
      for (final arg in args) {
        key = key.replaceFirst(RegExp(r'%s'), arg.toString());
      }
    }
    return key;
  }

  String trPlural([String? pluralKey, int? i, List<String> args = const []]) {
    return i == 1 ? trArgs(args) : pluralKey!.trArgs(args);
  }

  String trParams([Map<String, String> params = const {}]) {
    var trans = tr;
    if (params.isNotEmpty) {
      params.forEach((key, value) {
        trans = trans.replaceAll('@$key', value);
      });
    }
    return trans;
  }

  String trPluralParams(
      [String? pluralKey, int? i, Map<String, String> params = const {}]) {
    return i == 1 ? trParams(params) : pluralKey!.trParams(params);
  }
}
