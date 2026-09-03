import 'package:meta/meta.dart';
import 'package:payment_core/payment_core.dart';
import 'package:payment_webview_core/payment_webview_core.dart';

import 'cashfree_request.dart';

class CashfreeGatewayPlugin extends WebViewGatewayPlugin<CashfreeRequest> {
  @override
  PaymentGatewayType get type => PaymentGatewayType.cashfree;

  @override
  PaymentResult mapResult(Uri returnUri, CashfreeRequest request) =>
      resultFrom(returnUri, request);

  /// Cashfree's hosted checkout substitutes `order_id` into `return_url`
  /// (via the `{order_id}` placeholder configured on the order) regardless
  /// of outcome — there's no status in the redirect itself. Reaching the
  /// return URL only proves the checkout flow concluded, not that it
  /// succeeded, so this always returns [PaymentResult.pending] and defers
  /// to Cashfree's Order Status API (or the payment webhook) for the real
  /// outcome.
  @visibleForTesting
  static PaymentResult resultFrom(Uri returnUri, CashfreeRequest request) {
    final orderId = returnUri.queryParameters['order_id'];

    if (orderId != null) {
      return PaymentResult.pending(
        transactionId: orderId,
        message:
            'Cashfree redirected back to the app; verify the final status '
            "with Cashfree's Order Status API before fulfilling the order.",
      );
    }

    final outcome = request.matcher(returnUri);
    if (outcome != null) {
      return outcome.toPaymentResult(transactionId: request.transactionReference);
    }

    return PaymentResult.failed(
      message: 'Cashfree redirected without an order reference.',
      errorCode: 'NO_REFERENCE',
    );
  }
}
