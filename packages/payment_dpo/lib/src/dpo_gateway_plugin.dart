import 'package:payment_core/payment_core.dart';
import 'package:payment_webview_core/payment_webview_core.dart';

import 'dpo_request.dart';

class DpoGatewayPlugin extends WebViewGatewayPlugin<DpoRequest> {
  @override
  PaymentGatewayType get type => PaymentGatewayType.dpo;
}
