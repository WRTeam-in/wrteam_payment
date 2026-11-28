import 'package:payment_webview_core/payment_webview_core.dart';

/// PayPal is the one gateway (of the 5) where the gateway itself picks
/// between two distinct, app-registered URLs based on the real outcome
/// (approve vs cancel) — a structural signal, unlike the others where a
/// single URL is hit regardless of outcome. Matching the literal registered
/// URLs is correct regardless of what words happen to be in their paths,
/// unlike keyword guessing.
///
/// Deprecated along with [PayPalRequest]'s `returnUrl`/`successPath`/
/// `cancelPath` constructor — kept only so code built against it keeps
/// compiling; new code should pass `onReturn` directly.
class PayPalReturnUrlMatcher implements WebViewOutcomeMatcher {
  const PayPalReturnUrlMatcher({
    required this.successUrlPrefix,
    required this.cancelUrlPrefix,
  });

  final String successUrlPrefix;
  final String cancelUrlPrefix;

  @override
  WebViewCheckoutOutcome? call(Uri uri) {
    if (_matches(uri, Uri.parse(cancelUrlPrefix))) {
      return WebViewCheckoutOutcome.cancelled;
    }
    if (_matches(uri, Uri.parse(successUrlPrefix))) {
      // Approval only — the actual charge still needs a server-side
      // Capture Order call, so this isn't a genuine success yet.
      return WebViewCheckoutOutcome.pending;
    }
    return null;
  }

  bool _matches(Uri url, Uri prefix) =>
      url.scheme == prefix.scheme &&
      url.host == prefix.host &&
      url.path.startsWith(prefix.path);
}
