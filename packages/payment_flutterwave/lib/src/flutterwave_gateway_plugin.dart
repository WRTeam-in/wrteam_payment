import 'package:meta/meta.dart';
import 'package:payment_core/payment_core.dart';
import 'package:payment_webview_core/payment_webview_core.dart';

import 'flutterwave_request.dart';

class FlutterwaveGatewayPlugin extends WebViewGatewayPlugin<FlutterwaveRequest> {
  @override
  PaymentGatewayType get type => PaymentGatewayType.flutterwave;

  @override
  PaymentResult mapResult(Uri returnUri, FlutterwaveRequest request) =>
      resultFrom(returnUri, request);

  /// Flutterwave appends `status` (`successful`/`cancelled`), `tx_ref`, and
  /// `transaction_id` to the redirect. `status=cancelled` is a safe signal
  /// to trust directly (worst case is an unnecessary no-op) — but
  /// `successful` is not, since it's the same claim Flutterwave's own docs
  /// say must be re-confirmed via the Verify Transaction API before
  /// fulfilling an order. So anything other than an explicit cancellation
  /// with a transaction id present maps to [PaymentResult.pending].
  @visibleForTesting
  static PaymentResult resultFrom(Uri returnUri, FlutterwaveRequest request) {
    final params = returnUri.queryParameters;
    final status = params['status'];
    final id = params['transaction_id'] ?? params['tx_ref'];

    if (status == 'cancelled') {
      return PaymentResult.cancelled();
    }

    if (id != null) {
      return PaymentResult.pending(
        transactionId: id,
        message:
            'Flutterwave redirected back to the app; verify the final status '
            "with Flutterwave's Verify Transaction API before fulfilling the order.",
      );
    }

    final outcome = request.matcher(returnUri);
    if (outcome != null) {
      return outcome.toPaymentResult(transactionId: request.transactionReference);
    }

    return PaymentResult.failed(
      message: 'Flutterwave redirected without a transaction reference.',
      errorCode: 'NO_REFERENCE',
    );
  }
}
