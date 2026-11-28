import 'package:payment_core/payment_core.dart';
import 'package:payment_webview_core/payment_webview_core.dart';

class PayTabsRequest extends WebViewCheckoutRequest {
  PayTabsRequest({
    required super.checkoutUrl,
    required super.onReturn,
    required super.transactionReference,
    super.title,
  });

  @override
  PaymentGatewayType get gatewayType => PaymentGatewayType.paytabs;
}
