import 'package:payment_webview_core/payment_webview_core.dart';

/// PayPal is the one gateway (of the 5) where the gateway itself picks
/// between two distinct, app-registered URLs based on the real outcome
/// (approve vs cancel) — a structural signal, unlike the others where a
/// single URL is hit regardless of outcome. Matching the literal registered
/// URLs is correct regardless of what words happen to be in their paths,
/// unlike keyword guessing.
class PayPalReturnUrlMatcher implements WebViewOutcomeMatcher {
  const PayPalReturnUrlMatcher({
    required this.successUrlPrefix,
    required this.cancelUrlPrefix,
  });

  final String successUrlPrefix;
  final String cancelUrlPrefix;

  @override
  WebViewCheckoutOutcome? call(Uri uri) {
    final url = uri.toString();
    if (url.startsWith(cancelUrlPrefix)) {
      return WebViewCheckoutOutcome.cancelled;
    }
    if (url.startsWith(successUrlPrefix)) {
      // Approval only — the actual charge still needs a server-side
      // Capture Order call, so this isn't a genuine success yet.
      return WebViewCheckoutOutcome.pending;
    }
    return null;
  }
}
