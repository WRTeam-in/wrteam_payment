import 'webview_checkout_outcome.dart';

/// Classifies a terminal redirect URL (already confirmed to be within the
/// caller's own `returnUrlPrefix`) into a [WebViewCheckoutOutcome] by
/// looking for common success/cancel/failure words anywhere in the URL.
/// Only meant to be applied to a URL that's already been confirmed to match
/// the caller's own `returnUrlPrefix` — applying it to arbitrary navigation
/// would risk false positives from unrelated third-party URLs. Patterns are
/// overridable via the constructor; a gateway package can also supply its
/// own instance as [WebViewCheckoutRequest.matcher] if the defaults don't
/// fit its checkout page's redirect URLs.
class WebViewReturnUrlMatcher {
  const WebViewReturnUrlMatcher({
    this.successPatterns = const ['success', 'complete', 'approved'],
    this.cancelPatterns = const ['cancel'],
    this.failurePatterns = const ['fail', 'decline', 'error'],
  });

  final List<String> successPatterns;
  final List<String> cancelPatterns;
  final List<String> failurePatterns;

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
