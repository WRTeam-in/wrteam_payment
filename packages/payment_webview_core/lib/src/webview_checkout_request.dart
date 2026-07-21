import 'package:payment_core/payment_core.dart';

import 'webview_return_url_matcher.dart';

/// Base request for gateways that redirect to a hosted checkout page rather
/// than embedding a native SDK. [checkoutUrl] must be produced by the host
/// app's backend calling the gateway's "initialize transaction" API (which
/// needs a secret key and must never run on the client).
abstract class WebViewCheckoutRequest extends PaymentRequest {
  WebViewCheckoutRequest({
    required this.checkoutUrl,
    required this.returnUrlPrefixes,
    required this.transactionReference,
    this.matcher = const WebViewReturnUrlMatcher(),
    this.title = 'Complete Payment',
  }) : assert(returnUrlPrefixes.isNotEmpty, 'returnUrlPrefixes must not be empty');

  /// The hosted checkout page to load.
  final String checkoutUrl;

  /// The app's own registered callback URL prefix(es). Only redirects
  /// starting with one of these are treated as terminal — everything else
  /// keeps loading. Most gateways only register one; some (e.g. PayPal, with
  /// distinct approve/cancel URLs) need more than one.
  final List<String> returnUrlPrefixes;

  /// The transaction/order reference the backend generated when building
  /// [checkoutUrl]. Returned as [PaymentResult.transactionId] and needed to
  /// confirm the final status with the gateway's server-side verify API.
  final String transactionReference;

  /// Fallback matcher used only when the gateway's own redirect contract
  /// (documented query params) doesn't resolve an outcome.
  final WebViewReturnUrlMatcher matcher;

  /// App bar title shown while the checkout page is loading.
  final String title;
}
