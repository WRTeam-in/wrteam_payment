import 'package:meta/meta.dart';
import 'package:payment_core/payment_core.dart';
import 'package:payment_webview_core/payment_webview_core.dart';

import 'payu_request.dart';

class PayUGatewayPlugin extends WebViewGatewayPlugin<PayURequest> {
  @override
  PaymentGatewayType get type => PaymentGatewayType.payu;

  @override
  PaymentResult mapResult(Uri returnUri, PayURequest request) =>
      resultFrom(returnUri, request);

  /// PayU appends `status` (`success`/`failure`/`pending`/`userCancelled`),
  /// `txnid`, and `mihpayid` to the return URL, plus a `hash` that's
  /// mandatory to verify server-side per PayU's docs before trusting
  /// anything else in the response. `status=userCancelled` is a safe signal
  /// to trust directly (worst case is an unnecessary no-op) — everything
  /// else with a transaction id present maps to [PaymentResult.pending],
  /// deferring to PayU's Verify Payment API for the confirmed outcome.
  @visibleForTesting
  static PaymentResult resultFrom(Uri returnUri, PayURequest request) {
    final params = returnUri.queryParameters;
    final status = params['status'];
    final id = params['txnid'] ?? params['mihpayid'];

    if (status == 'userCancelled') {
      return PaymentResult.cancelled();
    }

    if (id != null) {
      return PaymentResult.pending(
        transactionId: id,
        message:
            'PayU redirected back to the app; verify the signed response '
            "with PayU's Verify Payment API before fulfilling the order.",
      );
    }

    final outcome = request.matcher(returnUri);
    if (outcome != null) {
      return outcome.toPaymentResult(transactionId: request.transactionReference);
    }

    return PaymentResult.failed(
      message: 'PayU redirected without a transaction reference.',
      errorCode: 'NO_REFERENCE',
    );
  }
}
