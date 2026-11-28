import 'package:payment_core/payment_core.dart';
import 'package:payment_webview_core/payment_webview_core.dart';

import 'paypal_request.dart';

class PayPalGatewayPlugin extends WebViewGatewayPlugin<PayPalRequest> {
  @override
  PaymentGatewayType get type => PaymentGatewayType.paypal;
}
