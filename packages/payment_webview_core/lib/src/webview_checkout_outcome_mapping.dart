import 'package:payment_core/payment_core.dart';

import 'webview_checkout_outcome.dart';

extension WebViewCheckoutOutcomeMapping on WebViewCheckoutOutcome {
  /// Converts a keyword-classified outcome into a [PaymentResult].
  /// [transactionId] should be the request's own `transactionReference` —
  /// the redirect URL itself may not carry one.
  PaymentResult toPaymentResult({
    String? transactionId,
    String? message,
    Map<String, dynamic>? rawResponse,
  }) {
    switch (this) {
      case WebViewCheckoutOutcome.success:
        return PaymentResult.success(
          transactionId: transactionId ?? '',
          message: message,
          rawResponse: rawResponse,
        );
      case WebViewCheckoutOutcome.cancelled:
        return PaymentResult.cancelled(message: message);
      case WebViewCheckoutOutcome.failed:
        return PaymentResult.failed(
          message: message ?? 'Payment failed.',
          rawResponse: rawResponse,
        );
      case WebViewCheckoutOutcome.pending:
        return PaymentResult.pending(transactionId: transactionId, message: message);
    }
  }
}
