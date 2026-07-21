import 'package:flutter/widgets.dart';
import '../models/payment_request.dart';
import '../models/payment_result.dart';
import '../registry/payment_registry.dart';

class PaymentOrchestrator {
  PaymentOrchestrator._();

  static Future<PaymentResult> pay(BuildContext context, PaymentRequest request) async {
    final plugin = PaymentRegistry.getPlugin(request.gatewayType);
    if (plugin == null) {
      return PaymentResult.failed(
        message: 'No registered plugin found for gateway "${request.gatewayType.id}".',
        errorCode: 'PLUGIN_NOT_FOUND',
      );
    }

    try {
      return await plugin.processPayment(context, request);
    } catch (e, stackTrace) {
      return PaymentResult.failed(
        message: 'An unexpected error occurred during payment execution: $e',
        errorCode: 'UNHANDLED_EXCEPTION',
        rawResponse: {'error': e.toString(), 'stackTrace': stackTrace.toString()},
      );
    }
  }
}
