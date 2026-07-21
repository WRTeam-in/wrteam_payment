import 'webview_checkout_outcome.dart';

/// Classifies a terminal redirect URL (already confirmed to be within the
/// caller's own `returnUrlPrefix`) into a [WebViewCheckoutOutcome]. Returns
/// null if the URL doesn't match anything recognizable. Implement this
/// directly for anything more precise than keyword matching — e.g. matching
/// against known, literal registered URLs rather than guessing from words
/// in the path.
abstract class WebViewOutcomeMatcher {
  WebViewCheckoutOutcome? call(Uri uri);
}

/// Default, override-able keyword-based [WebViewOutcomeMatcher]: looks for
/// common success/cancel/failure words anywhere in the redirect URL. Only
/// meant to be applied to a URL that's already been confirmed to match the
/// caller's own `returnUrlPrefix` — applying it to arbitrary navigation
/// would risk false positives from unrelated third-party URLs. Patterns are
/// overridable via the constructor; a gateway package can also supply its
/// own [WebViewOutcomeMatcher] implementation as
/// [WebViewCheckoutRequest.matcher] if keyword matching doesn't fit its
/// checkout page's redirect URLs.
class WebViewReturnUrlMatcher implements WebViewOutcomeMatcher {
  const WebViewReturnUrlMatcher({
    this.successPatterns = const ['success', 'complete', 'approved'],
    this.cancelPatterns = const ['cancel'],
    this.failurePatterns = const ['fail', 'decline', 'error'],
  });

  final List<String> successPatterns;
  final List<String> cancelPatterns;
  final List<String> failurePatterns;

  @override
  WebViewCheckoutOutcome? call(Uri uri) {
    final haystack = uri.toString().toLowerCase();
    if (failurePatterns.any(haystack.contains)) {
      return WebViewCheckoutOutcome.failed;
    }
    if (cancelPatterns.any(haystack.contains)) {
      return WebViewCheckoutOutcome.cancelled;
    }
    if (successPatterns.any(haystack.contains)) {
      return WebViewCheckoutOutcome.success;
    }
    return null;
  }
}
