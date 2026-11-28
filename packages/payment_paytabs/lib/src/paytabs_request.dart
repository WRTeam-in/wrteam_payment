import 'package:payment_core/payment_core.dart';
import 'package:payment_webview_core/payment_webview_core.dart';

class PayTabsRequest extends WebViewCheckoutRequest {
  PayTabsRequest({
    required super.checkoutUrl,
    WebViewCheckoutOutcome? Function(Uri uri)? onReturn,
    @Deprecated('Use onReturn instead. Will be removed in a future release.')
    bool Function(Uri uri)? isReturnUrl,
    @Deprecated('Use onReturn instead. Will be removed in a future release.')
    String? returnUrlPrefix,
    required super.transactionReference,
    @Deprecated('Use onReturn instead. Will be removed in a future release.')
    WebViewOutcomeMatcher matcher = const WebViewReturnUrlMatcher(),
    super.title,
  }) : assert(
         onReturn != null || isReturnUrl != null || returnUrlPrefix != null,
         'Provide onReturn (isReturnUrl/returnUrlPrefix/matcher are deprecated and will be removed).',
       ),
       super(
         onReturn:
             onReturn ??
             _legacyOnReturn(isReturnUrl ?? returnUrlPrefixMatcher(returnUrlPrefix!), matcher),
       );

  /// PayTabs appends `tranRef` to the return URL regardless of `respStatus`
  /// (which needs mandatory signature verification before being trusted),
  /// so the old deprecated path trusted `tranRef`'s presence as pending
  /// directly rather than relying on the matcher.
  static WebViewCheckoutOutcome? Function(Uri uri) _legacyOnReturn(
    bool Function(Uri uri) isReturnUrl,
    WebViewOutcomeMatcher matcher,
  ) {
    return (uri) {
      if (!isReturnUrl(uri)) return null;
      if (uri.queryParameters['tranRef'] != null) return WebViewCheckoutOutcome.pending;
      return matcher(uri) ?? WebViewCheckoutOutcome.failed;
    };
  }

  @override
  PaymentGatewayType get gatewayType => PaymentGatewayType.paytabs;
}
