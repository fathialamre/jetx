# Parameters vs Arguments in JetX Navigation

## Overview

JetX provides two different ways to pass data during navigation: **Parameters** and **Arguments**. Understanding the difference is crucial for choosing the right approach.

## Quick Comparison

| Feature | Parameters | Arguments |
|---------|-----------|-----------|
| **Type** | `Map<String, String>` | `dynamic` (any type) |
| **Visibility** | Visible in URL | Not visible in URL |
| **Access** | `Jet.parameters` | `Jet.arguments` |
| **Type Safety** | String only | Any type |
| **Use Case** | Query strings, deep links | Complex objects, metadata |
| **Serialization** | Required (to String) | Not required |
| **URL Example** | `/user/42?tab=posts` | `/user/42` |
| **Restoration** | Survives app restart | Lost on restart |

---

## Parameters

### What are Parameters?

Parameters are **query string values** that appear in the URL. They are always strings and become part of the route path.

### Syntax

```dart
Jet.toNamed('/path', parameters: {'key': 'value'});
```

### How Parameters Work

```dart
// Navigate with parameters
const UserPageRoute(userId: 42).pushWithParameters({
  'tab': 'posts',
  'filter': 'recent',
});

// Generated URL: /user/42?tab=posts&filter=recent

// Access in destination
class UserPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tab = Jet.parameters['tab'];        // 'posts'
    final filter = Jet.parameters['filter'];  // 'recent'
    return Scaffold(...);
  }
}
```

### When to Use Parameters

✅ **Use Parameters for:**
1. **Deep linking** - URLs that can be shared or bookmarked
2. **Query filters** - Search terms, sorting, filtering
3. **Tracking** - UTM parameters, campaign IDs
4. **Public data** - Data that should be visible in URL
5. **SEO-friendly** - Web apps that need URL-based routing
6. **State restoration** - Data that survives app restart

### Parameters Examples

#### 1. Search/Filter

```dart
// Navigate to search with filters
const SearchPageRoute().pushWithParameters({
  'query': 'flutter',
  'category': 'mobile',
  'sort': 'recent',
});

// URL: /search?query=flutter&category=mobile&sort=recent

// In SearchPage:
final query = Jet.parameters['query'];      // 'flutter'
final category = Jet.parameters['category']; // 'mobile'
final sort = Jet.parameters['sort'];        // 'recent'
```

#### 2. Deep Linking

```dart
// Handle deep link: myapp://product/123?ref=email&campaign=summer
const ProductPageRoute(productId: 123).pushWithParameters({
  'ref': 'email',
  'campaign': 'summer',
});

// URL: /product/123?ref=email&campaign=summer
// Shareable, bookmarkable, restorable!
```

#### 3. Analytics Tracking

```dart
// Navigate with tracking parameters
const ArticlePageRoute(articleId: 456).pushWithParameters({
  'utm_source': 'newsletter',
  'utm_medium': 'email',
  'utm_campaign': 'weekly_digest',
});

// URL: /article/456?utm_source=newsletter&utm_medium=email&utm_campaign=weekly_digest
```

#### 4. Pagination

```dart
// Navigate with page number
const ListPageRoute().pushWithParameters({
  'page': '1',
  'limit': '20',
});

// URL: /list?page=1&limit=20
```

### Parameters Limitations

❌ **Don't use Parameters for:**
- Complex objects (classes, lists, maps)
- Sensitive data (passwords, tokens)
- Large data (images, files)
- Data that should be hidden from URL

---

## Arguments

### What are Arguments?

Arguments are **metadata objects** passed invisibly during navigation. They can be any Dart type and don't appear in the URL.

### Syntax

```dart
Jet.toNamed('/path', arguments: anyObject);
```

### How Arguments Work

```dart
// Navigate with arguments (complex object)
const UserPageRoute(userId: 42).pushWithArgs({
  'source': 'notification',
  'timestamp': DateTime.now(),
  'user': User(name: 'John', email: 'john@example.com'),
  'options': ['edit', 'delete', 'share'],
});

// URL: /user/42 (clean, no query string)

// Access in destination
class UserPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final args = Jet.arguments as Map?;
    final source = args?['source'];              // 'notification'
    final timestamp = args?['timestamp'];        // DateTime object
    final user = args?['user'] as User;          // User object
    final options = args?['options'] as List;    // List of strings
    return Scaffold(...);
  }
}
```

### When to Use Arguments

✅ **Use Arguments for:**
1. **Complex objects** - Classes, models, custom types
2. **Private data** - Data that shouldn't be in URL
3. **Temporary state** - One-time data for next screen
4. **Large data** - Data too large for URL
5. **Type-rich data** - DateTime, enums, custom classes
6. **Navigation context** - Where user came from, what action triggered navigation

### Arguments Examples

#### 1. Passing Objects

```dart
// Navigate with full object
class User {
  final String name;
  final String email;
  final int age;
  User(this.name, this.email, this.age);
}

const ProfileEditPageRoute().pushWithArgs(
  User('John Doe', 'john@example.com', 30)
);

// In ProfileEditPage:
final user = Jet.arguments as User;
print(user.name);  // 'John Doe'
print(user.email); // 'john@example.com'
```

#### 2. Navigation Context

```dart
// Tell next screen where user came from
const DetailPageRoute(itemId: 123).pushWithArgs({
  'previousScreen': 'search_results',
  'searchQuery': 'flutter widgets',
  'position': 5,
  'shouldRefreshOnBack': true,
});

// In DetailPage:
final args = Jet.arguments as Map;
final from = args['previousScreen']; // 'search_results'
final shouldRefresh = args['shouldRefreshOnBack']; // true
```

#### 3. Action Callbacks

```dart
// Pass callbacks
const ImagePickerPageRoute().pushWithArgs({
  'onImageSelected': (File image) {
    uploadImage(image);
  },
  'maxSize': 5 * 1024 * 1024, // 5MB
  'allowedFormats': ['jpg', 'png'],
});

// In ImagePickerPage:
final args = Jet.arguments as Map;
final onImageSelected = args['onImageSelected'] as Function;
onImageSelected(selectedImage);
```

#### 4. Form Pre-fill Data

```dart
// Navigate to form with existing data
const EditProfilePageRoute().pushWithArgs({
  'currentName': user.name,
  'currentEmail': user.email,
  'currentBio': user.bio,
  'avatarUrl': user.avatarUrl,
  'isVerified': user.isVerified,
});
```

### Arguments Limitations

❌ **Don't use Arguments for:**
- Data that needs to survive app restart
- Data for deep linking
- Shareable state
- Web URL-based routing

---

## Side-by-Side Comparison

### Example: Product Page

#### Using Parameters (Deep Link Friendly)

```dart
// Navigate
const ProductPageRoute(productId: 123).pushWithParameters({
  'ref': 'email',
  'discount': '20',
  'color': 'red',
});

// URL: /product/123?ref=email&discount=20&color=red
// ✅ Shareable
// ✅ Bookmarkable
// ✅ Survives restart
// ✅ SEO friendly

// Access
final productId = int.parse(Jet.parameters['productId']!);
final ref = Jet.parameters['ref'];            // String
final discount = Jet.parameters['discount'];   // String '20' (need to parse)
final color = Jet.parameters['color'];        // String
```

#### Using Arguments (Object-Rich)

```dart
// Navigate
const ProductPageRoute(productId: 123).pushWithArgs({
  'source': NavigationSource.email,  // Enum
  'discount': 0.20,                  // Double
  'selectedColor': Color(0xFFFF0000), // Color object
  'campaign': Campaign(id: 5, name: 'Summer Sale'), // Custom object
  'onAddToCart': (Product p) => cart.add(p),        // Callback
});

// URL: /product/123 (clean)
// ✅ Type-safe
// ✅ Complex objects
// ✅ Private data
// ❌ Not shareable
// ❌ Lost on restart

// Access
final args = Jet.arguments as Map;
final source = args['source'] as NavigationSource;  // Enum
final discount = args['discount'] as double;        // 0.20
final color = args['selectedColor'] as Color;       // Color object
final campaign = args['campaign'] as Campaign;      // Custom object
```

---

## Combined Approach (Recommended)

You can use **both** parameters and arguments together!

```dart
// Navigate with both
Jet.toNamed(
  '/product/123',
  parameters: {
    'ref': 'email',           // For deep linking
    'utm_source': 'newsletter' // For analytics
  },
  arguments: {
    'selectedVariant': productVariant,  // Complex object
    'previousScreen': 'search',         // Context
    'onPurchase': () => showThanks(),   // Callback
  },
);

// Access both
class ProductPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // From URL (parameters)
    final ref = Jet.parameters['ref'];
    final utmSource = Jet.parameters['utm_source'];
    
    // From arguments
    final args = Jet.arguments as Map;
    final variant = args['selectedVariant'];
    final previousScreen = args['previousScreen'];
    
    return Scaffold(...);
  }
}
```

---

## Type Safety Considerations

### Parameters (String Only)

```dart
// Parameters are always strings - need conversion
final page = int.parse(Jet.parameters['page'] ?? '1');
final isActive = Jet.parameters['active'] == 'true';
final price = double.parse(Jet.parameters['price'] ?? '0.0');

// Watch out for null/missing parameters!
final category = Jet.parameters['category'] ?? 'all';
```

### Arguments (Any Type)

```dart
// Arguments maintain type - cast carefully
final args = Jet.arguments as Map?;
final user = args?['user'] as User?;           // Safe cast
final count = args?['count'] as int? ?? 0;     // With default
final options = args?['options'] as List<String>? ?? [];
```

---

## Best Practices

### 1. Choose Based on Purpose

```dart
// ✅ Good: Parameters for public, shareable data
const SearchPageRoute().pushWithParameters({'q': searchTerm});

// ✅ Good: Arguments for private, complex data
const EditPageRoute().pushWithArgs(userData);
```

### 2. Don't Mix Concerns

```dart
// ❌ Bad: Putting complex objects in parameters
Jet.toNamed('/page', parameters: {'user': user.toString()}); // Don't!

// ✅ Good: Use arguments for objects
Jet.toNamed('/page', arguments: user);
```

### 3. Document Expected Data

```dart
/// EditProfilePage expects arguments:
/// - currentUser: User object
/// - onSave: Function(User) callback
class EditProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final args = Jet.arguments as Map;
    final currentUser = args['currentUser'] as User;
    final onSave = args['onSave'] as Function;
    // ...
  }
}
```

### 4. Handle Missing Data Gracefully

```dart
// Parameters - provide defaults
final page = int.tryParse(Jet.parameters['page'] ?? '1') ?? 1;

// Arguments - check for null
final args = Jet.arguments as Map?;
if (args == null || !args.containsKey('user')) {
  // Handle missing data
  return ErrorPage();
}
```

---

## Common Patterns

### Pattern 1: List Detail Navigation

```dart
// From list, pass both
class ProductList extends StatelessWidget {
  void navigateToDetail(Product product, int index) {
    Jet.toNamed(
      '/product/${product.id}',
      parameters: {
        'ref': 'list',          // Trackable
        'position': '$index',   // Analytics
      },
      arguments: {
        'product': product,     // Full object
        'onUpdate': (p) => updateList(p), // Callback
      },
    );
  }
}
```

### Pattern 2: Form Wizard

```dart
// Step 1 -> Step 2
const FormStep2Route().pushWithArgs({
  'dataFromStep1': step1Data,   // Complex object
  'totalSteps': 3,              // Metadata
  'canGoBack': true,            // Context
});
```

### Pattern 3: Deep Link Handler

```dart
// Handle deep link with parameters only
void handleDeepLink(Uri uri) {
  final productId = uri.pathSegments.last;
  final parameters = Map<String, String>.from(uri.queryParameters);
  
  Jet.toNamed('/product/$productId', parameters: parameters);
  // All data comes from URL - shareable!
}
```

---

## Summary

### Use **Parameters** when:
- ✅ Data should be in URL
- ✅ Need deep linking
- ✅ Want shareable routes
- ✅ Building for web
- ✅ Need state restoration
- ✅ Simple string values

### Use **Arguments** when:
- ✅ Complex objects
- ✅ Private/sensitive data
- ✅ Navigation callbacks
- ✅ Temporary context
- ✅ Type-rich data
- ✅ Large data

### Use **Both** when:
- ✅ Tracking + metadata
- ✅ Public ID + private object
- ✅ Deep link + callbacks
- ✅ Maximum flexibility

---

## NavigableRoute Methods Reference

```dart
// Parameters (query string)
route.pushWithParameters({'key': 'value'});

// Arguments (invisible metadata)
route.pushWithArgs(anyObject);

// Both at once
Jet.toNamed(
  route.path,
  parameters: {'public': 'data'},
  arguments: privateObject,
);
```

The key is: **Parameters are for URLs, Arguments are for objects!** 🎯

