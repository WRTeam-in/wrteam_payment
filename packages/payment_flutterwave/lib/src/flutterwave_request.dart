import 'package:payment_core/payment_core.dart';
import 'package:payment_webview_core/payment_webview_core.dart';

class FlutterwaveRequest extends WebViewCheckoutRequest {
  FlutterwaveRequest({
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

  /// Flutterwave appends `status` (`successful`/`cancelled`), `tx_ref`, and
  /// `transaction_id` to the redirect. `status=cancelled` was trusted
  /// directly; otherwise a transaction id present was trusted as pending,
  /// falling back to the matcher only when neither is present.
  static WebViewCheckoutOutcome? Function(Uri uri) _legacyOnReturn(
    bool Function(Uri uri) isReturnUrl,
    WebViewOutcomeMatcher matcher,
  ) {
    return (uri) {
      if (!isReturnUrl(uri)) return null;
      final params = uri.queryParameters;
      if (params['status'] == 'cancelled') return WebViewCheckoutOutcome.cancelled;
      if (params['transaction_id'] != null || params['tx_ref'] != null) {
        return WebViewCheckoutOutcome.pending;
      }
      return matcher(uri) ?? WebViewCheckoutOutcome.failed;
    };
  }

  @override
  PaymentGatewayType get gatewayType => PaymentGatewayType.flutterwave;
}
