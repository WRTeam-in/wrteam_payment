import 'package:payment_core/payment_core.dart';
import 'package:payment_webview_core/payment_webview_core.dart';

import 'paystack_request.dart';

class PaystackGatewayPlugin extends WebViewGatewayPlugin<PaystackRequest> {
  @override
  PaymentGatewayType get type => PaymentGatewayType.paystack;
}
