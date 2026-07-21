import 'package:payment_core/payment_core.dart';
import 'package:payment_webview_core/payment_webview_core.dart';

class PaystackRequest extends WebViewCheckoutRequest {
  PaystackRequest({
    required super.checkoutUrl,
    required super.returnUrlPrefixes,
    required super.transactionReference,
    super.matcher,
    super.title,
  });

  @override
  PaymentGatewayType get gatewayType => PaymentGatewayType.paystack;
}
