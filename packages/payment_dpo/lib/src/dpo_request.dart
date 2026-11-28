import 'package:payment_core/payment_core.dart';
import 'package:payment_webview_core/payment_webview_core.dart';

class DpoRequest extends WebViewCheckoutRequest {
  DpoRequest({
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

  /// DPO appends `TransactionToken` (sometimes `TransID`) to the return URL
  /// regardless of outcome, so the old deprecated path trusted either as
  /// pending directly rather than relying on the matcher.
  static WebViewCheckoutOutcome? Function(Uri uri) _legacyOnReturn(
    bool Function(Uri uri) isReturnUrl,
    WebViewOutcomeMatcher matcher,
  ) {
    return (uri) {
      if (!isReturnUrl(uri)) return null;
      final params = uri.queryParameters;
      if (params['TransactionToken'] != null || params['TransID'] != null) {
        return WebViewCheckoutOutcome.pending;
      }
      return matcher(uri) ?? WebViewCheckoutOutcome.failed;
    };
  }

  @override
  PaymentGatewayType get gatewayType => PaymentGatewayType.dpo;
}
