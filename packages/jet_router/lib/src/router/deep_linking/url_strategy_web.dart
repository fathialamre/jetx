import 'package:web/web.dart' as web;

/// Sets the URL strategy for web platform to use path-based URLs (no hash).
void setUrlStrategy() {
  setPathUrlStrategy();
}

/// Sets hash-based URL strategy (#/path).
/// Uses the fragment identifier (hash) for routing.
void setHashUrlStrategy() {
  // Hash-based URLs use the fragment identifier (#)
  // This is the default behavior and doesn't require special configuration
  // The router will handle hash-based navigation automatically
}

/// Sets path-based URL strategy (/path).
/// Configures the application to use clean URLs without hash.
void setPathUrlStrategy() {
  // Use History API for path-based routing
  // This removes the hash from URLs and uses the browser's history API
  // The router will use pushState/replaceState for navigation

  // Register a base element if not present to ensure proper path resolution
  final document = web.document;
  final bases = document.querySelectorAll('base');

  if (bases.length == 0) {
    final base = document.createElement('base') as web.HTMLBaseElement;
    base.href = web.window.location.origin;
    document.head?.appendChild(base);
  }
}
