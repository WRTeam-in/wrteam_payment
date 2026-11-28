import 'package:payment_core/payment_core.dart';
import 'package:payment_webview_core/payment_webview_core.dart';

class PaystackRequest extends WebViewCheckoutRequest {
  PaystackRequest({
    required super.checkoutUrl,
    super.onReturn,
    @Deprecated('Use onReturn instead. Will be removed in a future release.')
    super.isReturnUrl,
    @Deprecated('Use onReturn instead. Will be removed in a future release.')
    super.returnUrlPrefix,
    required super.transactionReference,
    @Deprecated('Use onReturn instead. Will be removed in a future release.')
    super.matcher,
    super.title,
  });

  @override
  PaymentGatewayType get gatewayType => PaymentGatewayType.paystack;
}
