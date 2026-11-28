import 'package:payment_core/payment_core.dart';

import 'webview_checkout_outcome.dart';
import 'webview_legacy_on_return.dart';
import 'webview_return_url_matcher.dart';

/// Builds a legacy `isReturnUrl` callback for the common case of a single
/// registered return URL (optionally with suffix paths for
/// success/cancel/etc.): matches any [Uri] with the same scheme and host as
/// [prefix], and whose path starts with [prefix]'s path.
bool Function(Uri uri) returnUrlPrefixMatcher(String prefix) {
  final prefixUri = Uri.parse(prefix);
  return (uri) =>
      uri.scheme == prefixUri.scheme &&
      uri.host == prefixUri.host &&
      uri.path.startsWith(prefixUri.path);
}

/// Base request for gateways that redirect to a hosted checkout page rather
/// than embedding a native SDK. [checkoutUrl] must be produced by the host
/// app's backend calling the gateway's "initialize transaction" API (which
/// needs a secret key and must never run on the client).
abstract class WebViewCheckoutRequest extends PaymentRequest {
  WebViewCheckoutRequest({
    required this.checkoutUrl,
    WebViewCheckoutOutcome? Function(Uri uri)? onReturn,
    @Deprecated('Use onReturn instead. Will be removed in a future release.')
    bool Function(Uri uri)? isReturnUrl,
    @Deprecated('Use onReturn instead. Will be removed in a future release.')
    String? returnUrlPrefix,
    required this.transactionReference,
    @Deprecated('Use onReturn instead. Will be removed in a future release.')
    WebViewOutcomeMatcher matcher = const WebViewReturnUrlMatcher(),
    this.title = 'Complete Payment',
  }) : assert(
         onReturn != null || isReturnUrl != null || returnUrlPrefix != null,
         'Provide onReturn (isReturnUrl/returnUrlPrefix/matcher are deprecated and will be removed).',
       ),
       onReturn =
           onReturn ?? legacyOnReturn(isReturnUrl ?? returnUrlPrefixMatcher(returnUrlPrefix!), matcher);

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
