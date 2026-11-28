import 'package:payment_core/payment_core.dart';
import 'package:payment_webview_core/payment_webview_core.dart';

class CashfreeRequest extends WebViewCheckoutRequest {
  CashfreeRequest({
    required super.checkoutUrl,
    required super.onReturn,
    required super.transactionReference,
    super.title,
  });

  @override
  PaymentGatewayType get gatewayType => PaymentGatewayType.cashfree;
}
