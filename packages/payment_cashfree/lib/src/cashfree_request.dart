import 'package:payment_core/payment_core.dart';
import 'package:payment_webview_core/payment_webview_core.dart';

class CashfreeRequest extends WebViewCheckoutRequest {
  CashfreeRequest({
    required super.checkoutUrl,
    super.isReturnUrl,
    @Deprecated('Use isReturnUrl instead. Will be removed in a future release.')
    super.returnUrlPrefix,
    required super.transactionReference,
    super.matcher,
    super.title,
  });

  @override
  PaymentGatewayType get gatewayType => PaymentGatewayType.cashfree;
}
