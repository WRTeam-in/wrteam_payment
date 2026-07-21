import 'package:payment_core/payment_core.dart';

import 'webview_return_url_matcher.dart';

/// Base request for gateways that redirect to a hosted checkout page rather
/// than embedding a native SDK. [checkoutUrl] must be produced by the host
/// app's backend calling the gateway's "initialize transaction" API (which
/// needs a secret key and must never run on the client).
abstract class WebViewCheckoutRequest extends PaymentRequest {
  WebViewCheckoutRequest({
    required this.checkoutUrl,
    required this.returnUrlPrefix,
    required this.transactionReference,
    this.matcher = const WebViewReturnUrlMatcher(),
    this.title = 'Complete Payment',
  });

  /// The hosted checkout page to load.
  final String checkoutUrl;

  /// The app's own domain/scheme that every one of its callback URLs lives
  /// under (e.g. `https://yourapp.com`, or a custom scheme). Any navigation
  /// starting with this is treated as terminal and handed back — the exact
  /// path (success/cancel/etc.) is for the plugin's `mapResult` to
  /// interpret, not the launcher.
  final String returnUrlPrefix;

  /// The transaction/order reference the backend generated when building
  /// [checkoutUrl]. Returned as [PaymentResult.transactionId] and needed to
  /// confirm the final status with the gateway's server-side verify API.
  final String transactionReference;

  /// Fallback matcher used only when the gateway's own redirect contract
  /// (documented query params) doesn't resolve an outcome. Defaults to
  /// keyword matching; a gateway package can supply its own
  /// [WebViewOutcomeMatcher] implementation instead (e.g. one that matches
  /// literal registered URLs rather than guessing from words in the path).
  final WebViewOutcomeMatcher matcher;

  /// App bar title shown while the checkout page is loading.
  final String title;
}
