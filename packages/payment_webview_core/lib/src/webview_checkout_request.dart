import 'package:payment_core/payment_core.dart';

import 'webview_return_url_matcher.dart';

/// Builds an [WebViewCheckoutRequest.isReturnUrl] callback for the common
/// case of a single registered return URL (optionally with suffix paths for
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
    bool Function(Uri uri)? isReturnUrl,
    @Deprecated('Use isReturnUrl instead. Will be removed in a future release.')
    String? returnUrlPrefix,
    required this.transactionReference,
    this.matcher = const WebViewReturnUrlMatcher(),
    this.title = 'Complete Payment',
  }) : assert(
         isReturnUrl != null || returnUrlPrefix != null,
         'Provide isReturnUrl (returnUrlPrefix is deprecated and will be removed).',
       ),
       isReturnUrl = isReturnUrl ?? returnUrlPrefixMatcher(returnUrlPrefix!);

  /// The hosted checkout page to load.
  final String checkoutUrl;

  /// Called for every navigation and URL change in the checkout WebView.
  /// Return true once [uri] is the app's own return URL (success, cancel,
  /// or any other terminal callback) — the WebView closes and hands [uri]
  /// to the plugin's `mapResult`. The gateway/app is responsible for
  /// recognizing its own return URL; [returnUrlPrefixMatcher] covers the
  /// common single-prefix case.
  final bool Function(Uri uri) isReturnUrl;

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
