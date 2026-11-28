import 'package:payment_core/payment_core.dart';
import 'package:payment_webview_core/payment_webview_core.dart';

import 'paytabs_request.dart';

class PayTabsGatewayPlugin extends WebViewGatewayPlugin<PayTabsRequest> {
  @override
  PaymentGatewayType get type => PaymentGatewayType.paytabs;
}
