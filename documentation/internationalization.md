# Internationalization

JetX provides simple and powerful internationalization (i18n) support. Add multiple languages to your app with minimal setup and clean syntax.

---

## Table of Contents

- [Quick Start](#quick-start)
- [Advanced Features](#advanced-features)
- [Dynamic Locale Switching](#dynamic-locale-switching)
- [Best Practices](#best-practices)
- [Complete Example](#complete-example)

---

## Quick Start

### 1. Define Translations

Create a translations class that extends `Translations`:

```dart
class Messages extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': {
      'hello': 'Hello',
      'welcome': 'Welcome to JetX',
      'goodbye': 'Goodbye',
    },
    'es_ES': {
      'hello': 'Hola',
      'welcome': 'Bienvenido a JetX',
      'goodbye': 'Adiós',
    },
    'fr_FR': {
      'hello': 'Bonjour',
      'welcome': 'Bienvenue à JetX',
      'goodbye': 'Au revoir',
    },
  };
}
```

### 2. Configure App

Add translations to your `JetMaterialApp`:

```dart
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return JetMaterialApp(
      translations: Messages(), // Add translations
      locale: Locale('en', 'US'), // Default locale
      fallbackLocale: Locale('en', 'US'), // Fallback locale
      home: HomeScreen(),
    );
  }
}
```

### 3. Use in UI

Use the `.tr` extension to translate text:

```dart
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('welcome'.tr)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('hello'.tr),
            SizedBox(height: 20),
            Text('welcome'.tr),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => print('goodbye'.tr),
              child: Text('goodbye'.tr),
            ),
          ],
        ),
      ),
    );
  }
}
```

**That's it!** Your app now supports multiple languages.

---

## Advanced Features

### Parameters

Pass parameters to translations:

```dart
class Messages extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': {
      'welcome_user': 'Welcome, @name!',
      'item_count': 'You have @count items',
      'user_profile': 'Profile of @name (@email)',
    },
    'es_ES': {
      'welcome_user': '¡Bienvenido, @name!',
      'item_count': 'Tienes @count elementos',
      'user_profile': 'Perfil de @name (@email)',
    },
  };
}

// Usage
Text('welcome_user'.trParams({'name': 'John'}));
Text('item_count'.trParams({'count': '5'}));
Text('user_profile'.trParams({'name': 'John', 'email': 'john@example.com'}));
```

### Pluralization

Handle singular and plural forms:

```dart
class Messages extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': {
      'item': 'item',
      'items': 'items',
      'no_items': 'No items',
    },
    'es_ES': {
      'item': 'elemento',
      'items': 'elementos',
      'no_items': 'Sin elementos',
    },
  };
}

// Usage
Text('item'.trPlural('items', count));
// When count = 0: "No items"
// When count = 1: "1 item"
// When count = 5: "5 items"
```

### Fallback Locales

Set up fallback locales for missing translations:

```dart
JetMaterialApp(
  translations: Messages(),
  locale: Locale('de', 'DE'), // German locale
  fallbackLocale: Locale('en', 'US'), // Fallback to English
  home: HomeScreen(),
)
```

If a German translation is missing, it will fall back to English.

### Nested Keys

Organize translations with nested keys:

```dart
class Messages extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': {
      'auth': {
        'login': 'Login',
        'logout': 'Logout',
        'register': 'Register',
        'forgot_password': 'Forgot Password',
      },
      'navigation': {
        'home': 'Home',
        'profile': 'Profile',
        'settings': 'Settings',
      },
    },
    'es_ES': {
      'auth': {
        'login': 'Iniciar Sesión',
        'logout': 'Cerrar Sesión',
        'register': 'Registrarse',
        'forgot_password': 'Olvidé mi Contraseña',
      },
      'navigation': {
        'home': 'Inicio',
        'profile': 'Perfil',
        'settings': 'Configuración',
      },
    },
  };
}

// Usage
Text('auth.login'.tr);
Text('navigation.home'.tr);
```

---

## Dynamic Locale Switching

### Change Locale Programmatically

```dart
// Change to Spanish
Jet.updateLocale(Locale('es', 'ES'));

// Change to French
Jet.updateLocale(Locale('fr', 'FR'));

// Change to English
Jet.updateLocale(Locale('en', 'US'));
```

### Locale Controller

Create a controller to manage locale state:

```dart
class LocaleController extends JetxController {
  final currentLocale = Locale('en', 'US').obs;
  
  final supportedLocales = [
    Locale('en', 'US'),
    Locale('es', 'ES'),
    Locale('fr', 'FR'),
    Locale('de', 'DE'),
  ];
  
  @override
  void onInit() {
    super.onInit();
    _loadSavedLocale();
  }
  
  void _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString('locale');
    if (savedLocale != null) {
      final locale = Locale(savedLocale.split('_')[0], savedLocale.split('_')[1]);
      changeLocale(locale);
    }
  }
  
  void changeLocale(Locale locale) async {
    currentLocale.value = locale;
    Jet.updateLocale(locale);
    
    // Save preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', '${locale.languageCode}_${locale.countryCode}');
  }
  
  String get currentLanguageName {
    switch (currentLocale.value.languageCode) {
      case 'en': return 'English';
      case 'es': return 'Español';
      case 'fr': return 'Français';
      case 'de': return 'Deutsch';
      default: return 'English';
    }
  }
}
```

### Locale Selection UI

```dart
class LocaleSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Jet.put(LocaleController());
    
    return Obx(() => DropdownButton<Locale>(
      value: controller.currentLocale.value,
      items: controller.supportedLocales.map((locale) {
        return DropdownMenuItem<Locale>(
          value: locale,
          child: Text(_getLanguageName(locale)),
        );
      }).toList(),
      onChanged: (locale) {
        if (locale != null) {
          controller.changeLocale(locale);
        }
      },
    ));
  }
  
  String _getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'en': return 'English';
      case 'es': return 'Español';
      case 'fr': return 'Français';
      case 'de': return 'Deutsch';
      default: return locale.languageCode;
    }
  }
}
```

### System Locale Detection

```dart
class LocaleController extends JetxController {
  @override
  void onInit() {
    super.onInit();
    _detectSystemLocale();
  }
  
  void _detectSystemLocale() async {
    final systemLocale = Platform.localeName;
    final locale = Locale(systemLocale.split('_')[0], systemLocale.split('_')[1]);
    
    // Check if we support this locale
    if (supportedLocales.contains(locale)) {
      changeLocale(locale);
    } else {
      // Fall back to English
      changeLocale(Locale('en', 'US'));
    }
  }
}
```

---

## Best Practices

### File Organization

Organize translations in separate files:

```dart
// lib/translations/messages_en.dart
class MessagesEn extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': {
      'hello': 'Hello',
      'welcome': 'Welcome',
      // ... more translations
    },
  };
}

// lib/translations/messages_es.dart
class MessagesEs extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'es_ES': {
      'hello': 'Hola',
      'welcome': 'Bienvenido',
      // ... more translations
    },
  };
}

// lib/translations/messages.dart
class Messages extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    ...MessagesEn().keys,
    ...MessagesEs().keys,
  };
}
```

### Key Naming Conventions

Use consistent naming conventions:

```dart
// Good: Clear, hierarchical naming
'auth.login.title': 'Login',
'auth.login.email': 'Email',
'auth.login.password': 'Password',
'auth.login.button': 'Sign In',

// Good: Descriptive names
'welcome_message': 'Welcome to our app',
'error_network': 'Network connection error',
'success_saved': 'Data saved successfully',

// Avoid: Unclear names
'msg1': 'Hello',
'text': 'Welcome',
'btn': 'Click me',
```

### Performance Tips

1. **Lazy Loading**: Load translations only when needed
2. **Caching**: Cache frequently used translations
3. **Minimal Keys**: Only include translations you actually use
4. **Fallback Strategy**: Always provide fallback locales

```dart
class OptimizedMessages extends Translations {
  static final _cache = <String, Map<String, String>>{};
  
  @override
  Map<String, Map<String, String>> get keys {
    if (_cache.isEmpty) {
      _cache.addAll(_loadTranslations());
    }
    return _cache;
  }
  
  Map<String, Map<String, String>> _loadTranslations() {
    // Load translations from files or API
    return {
      'en_US': _loadEnglishTranslations(),
      'es_ES': _loadSpanishTranslations(),
    };
  }
}
```

---

## Complete Example

### Multi-Language App

```dart
// lib/translations/messages.dart
class Messages extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': {
      'app_title': 'JetX Demo',
      'welcome': 'Welcome to JetX',
      'change_language': 'Change Language',
      'current_language': 'Current Language: @lang',
      'hello_user': 'Hello, @name!',
      'item_count': 'You have @count items',
      'settings': 'Settings',
      'profile': 'Profile',
      'logout': 'Logout',
    },
    'es_ES': {
      'app_title': 'Demo de JetX',
      'welcome': 'Bienvenido a JetX',
      'change_language': 'Cambiar Idioma',
      'current_language': 'Idioma Actual: @lang',
      'hello_user': '¡Hola, @name!',
      'item_count': 'Tienes @count elementos',
      'settings': 'Configuración',
      'profile': 'Perfil',
      'logout': 'Cerrar Sesión',
    },
    'fr_FR': {
      'app_title': 'Démo JetX',
      'welcome': 'Bienvenue à JetX',
      'change_language': 'Changer de Langue',
      'current_language': 'Langue Actuelle: @lang',
      'hello_user': 'Bonjour, @name!',
      'item_count': 'Vous avez @count éléments',
      'settings': 'Paramètres',
      'profile': 'Profil',
      'logout': 'Déconnexion',
    },
  };
}

// lib/controllers/locale_controller.dart
class LocaleController extends JetxController {
  final currentLocale = Locale('en', 'US').obs;
  final userName = 'John'.obs;
  final itemCount = 5.obs;
  
  final supportedLocales = [
    Locale('en', 'US'),
    Locale('es', 'ES'),
    Locale('fr', 'FR'),
  ];
  
  @override
  void onInit() {
    super.onInit();
    _loadSavedLocale();
  }
  
  void _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString('locale');
    if (savedLocale != null) {
      final locale = Locale(savedLocale.split('_')[0], savedLocale.split('_')[1]);
      changeLocale(locale);
    }
  }
  
  void changeLocale(Locale locale) async {
    currentLocale.value = locale;
    Jet.updateLocale(locale);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', '${locale.languageCode}_${locale.countryCode}');
  }
  
  String get currentLanguageName {
    switch (currentLocale.value.languageCode) {
      case 'en': return 'English';
      case 'es': return 'Español';
      case 'fr': return 'Français';
      default: return 'English';
    }
  }
}

// lib/main.dart
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return JetMaterialApp(
      title: 'JetX Demo',
      translations: Messages(),
      locale: Locale('en', 'US'),
      fallbackLocale: Locale('en', 'US'),
      home: HomeScreen(),
    );
  }
}

// lib/screens/home_screen.dart
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localeController = Jet.put(LocaleController());
    
    return Scaffold(
      appBar: AppBar(
        title: Text('app_title'.tr),
        actions: [
          PopupMenuButton<Locale>(
            onSelected: localeController.changeLocale,
            itemBuilder: (context) => localeController.supportedLocales.map((locale) {
              return PopupMenuItem<Locale>(
                value: locale,
                child: Text(_getLanguageName(locale)),
              );
            }).toList(),
            child: Obx(() => Text(localeController.currentLanguageName)),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'welcome'.tr,
              style: Theme.of(context).textTheme.headline4,
            ),
            SizedBox(height: 20),
            
            Obx(() => Text(
              'hello_user'.trParams({'name': localeController.userName.value}),
              style: Theme.of(context).textTheme.headline6,
            )),
            
            SizedBox(height: 20),
            
            Obx(() => Text(
              'item_count'.trParams({'count': localeController.itemCount.value.toString()}),
              style: Theme.of(context).textTheme.bodyLarge,
            )),
            
            SizedBox(height: 20),
            
            Text(
              'current_language'.trParams({'lang': localeController.currentLanguageName}),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            
            SizedBox(height: 40),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Jet.toNamed('/settings'),
                    child: Text('settings'.tr),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Jet.toNamed('/profile'),
                    child: Text('profile'.tr),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  String _getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'en': return 'English';
      case 'es': return 'Español';
      case 'fr': return 'Français';
      default: return locale.languageCode;
    }
  }
}
```

---

## Learn More

- **[State Management](./state_management.md)** - Reactive state management
- **[UI Features](./ui_features.md)** - Theming, dialogs, and more
- **[Quick Reference](./quick_reference.md)** - Fast lookup for all features
- **[Route Management](./route_management.md)** - Navigation without context

---

**Ready to make your app multilingual?** [Get started with JetX →](../README.md#quick-start)
