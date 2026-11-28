import 'webview_checkout_outcome.dart';
import 'webview_return_url_matcher.dart';

/// Internal only. Bridges the deprecated `isReturnUrl`/`returnUrlPrefix` +
/// `matcher` constructor shape onto the current `onReturn` callback, so
/// code built against it keeps compiling and behaving the same way: once
/// [isReturnUrl] matches, the WebView always closes — [matcher] then
/// classifies the outcome, falling back to [WebViewCheckoutOutcome.failed]
/// when it can't (matching the old per-gateway "unrecognized URL" default).
WebViewCheckoutOutcome? Function(Uri uri) legacyOnReturn(
  bool Function(Uri uri) isReturnUrl,
  WebViewOutcomeMatcher matcher,
) {
  return (uri) => isReturnUrl(uri) ? (matcher(uri) ?? WebViewCheckoutOutcome.failed) : null;
}
