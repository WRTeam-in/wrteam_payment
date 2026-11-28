import 'package:payment_core/payment_core.dart';
import 'package:payment_webview_core/payment_webview_core.dart';

import 'cashfree_request.dart';

class CashfreeGatewayPlugin extends WebViewGatewayPlugin<CashfreeRequest> {
  @override
  PaymentGatewayType get type => PaymentGatewayType.cashfree;
}
