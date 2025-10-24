/// Handles deep links and universal links.
class DeepLinkHandler {
  /// Callback for handling incoming deep links.
  final Future<void> Function(Uri uri)? onDeepLink;

  DeepLinkHandler({this.onDeepLink});

  /// Processes an incoming deep link URI.
  Future<void> handleDeepLink(Uri uri) async {
    if (onDeepLink != null) {
      await onDeepLink!(uri);
    }
  }

  /// Extracts the path from a deep link URI.
  String extractPath(Uri uri) {
    return uri.path;
  }

  /// Extracts query parameters from a deep link URI.
  Map<String, String> extractQueryParameters(Uri uri) {
    return uri.queryParameters;
  }
}
