import 'package:payment_core/payment_core.dart';
import 'package:payment_webview_core/payment_webview_core.dart';

import 'flutterwave_request.dart';

class FlutterwaveGatewayPlugin extends WebViewGatewayPlugin<FlutterwaveRequest> {
  @override
  PaymentGatewayType get type => PaymentGatewayType.flutterwave;
}
