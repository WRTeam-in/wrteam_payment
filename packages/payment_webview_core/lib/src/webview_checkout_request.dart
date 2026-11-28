import 'package:payment_core/payment_core.dart';

import 'webview_checkout_outcome.dart';

/// Base request for gateways that redirect to a hosted checkout page rather
/// than embedding a native SDK. [checkoutUrl] must be produced by the host
/// app's backend calling the gateway's "initialize transaction" API (which
/// needs a secret key and must never run on the client).
abstract class WebViewCheckoutRequest extends PaymentRequest {
  WebViewCheckoutRequest({
    required this.checkoutUrl,
    required this.onReturn,
    required this.transactionReference,
    this.title = 'Complete Payment',
  });

  /// The hosted checkout page to load.
  final String checkoutUrl;

  /// Called for every navigation and URL change in the checkout WebView.
  /// Return null to keep browsing — [uri] isn't the app's return URL (yet).
  /// Return an outcome once it is, to close the WebView with it.
  ///
  /// Typically built from the backend's own return-URL contract, e.g.
  /// matching a failure path as [WebViewCheckoutOutcome.failed], a success
  /// path as [WebViewCheckoutOutcome.success], and any other hit on the
  /// app's return URL as [WebViewCheckoutOutcome.pending] (the final status
  /// still needs a server-side verify call).
  final WebViewCheckoutOutcome? Function(Uri uri) onReturn;

  /// The transaction/order reference the backend generated when building
  /// [checkoutUrl]. Returned as [PaymentResult.transactionId] when the
  /// return URL doesn't carry a gateway-issued reference of its own.
  final String transactionReference;

  /// App bar title shown while the checkout page is loading.
  final String title;
}
