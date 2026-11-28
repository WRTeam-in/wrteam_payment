import 'package:payment_core/payment_core.dart';
import 'package:payment_webview_core/payment_webview_core.dart';

import 'payu_request.dart';

class PayUGatewayPlugin extends WebViewGatewayPlugin<PayURequest> {
  @override
  PaymentGatewayType get type => PaymentGatewayType.payu;
}
