import 'package:payment_core/payment_core.dart';
import 'package:payment_webview_core/payment_webview_core.dart';

class PayPalRequest extends WebViewCheckoutRequest {
  PayPalRequest({
    required super.checkoutUrl,
    WebViewCheckoutOutcome? Function(Uri uri)? onReturn,
    @Deprecated('Use onReturn instead. Will be removed in a future release.')
    String? returnUrl,
    @Deprecated('Use onReturn instead. Will be removed in a future release.')
    String successPath = '/success',
    @Deprecated('Use onReturn instead. Will be removed in a future release.')
    String cancelPath = '/cancel',
    required super.transactionReference,
    super.title,
  }) : assert(
         onReturn != null || returnUrl != null,
         'Provide onReturn (returnUrl/successPath/cancelPath are deprecated and will be removed).',
       ),
       super(onReturn: onReturn ?? _legacyOnReturn(returnUrl!, successPath, cancelPath));

  static WebViewCheckoutOutcome? Function(Uri uri) _legacyOnReturn(
    String returnUrl,
    String successPath,
    String cancelPath,
  ) {
    final isReturnUrl = returnUrlPrefixMatcher(returnUrl);
    final isCancel = returnUrlPrefixMatcher('$returnUrl$cancelPath');
    final isSuccess = returnUrlPrefixMatcher('$returnUrl$successPath');
    return (uri) {
      if (!isReturnUrl(uri)) return null;
      if (isCancel(uri)) return WebViewCheckoutOutcome.cancelled;
      if (isSuccess(uri)) return WebViewCheckoutOutcome.pending;
      return WebViewCheckoutOutcome.failed;
    };
  }

  @override
  PaymentGatewayType get gatewayType => PaymentGatewayType.paypal;
}
