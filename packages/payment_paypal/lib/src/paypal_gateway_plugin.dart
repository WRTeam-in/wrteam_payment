import 'package:meta/meta.dart';
import 'package:payment_core/payment_core.dart';
import 'package:payment_webview_core/payment_webview_core.dart';

import 'paypal_request.dart';

class PayPalGatewayPlugin extends WebViewGatewayPlugin<PayPalRequest> {
  @override
  PaymentGatewayType get type => PaymentGatewayType.paypal;

  @override
  PaymentResult mapResult(Uri returnUri, PayPalRequest request) =>
      resultFrom(returnUri, request);

  /// `request.matcher` (a [PayPalReturnUrlMatcher]) already tells cancel
  /// from approval by which literal registered URL PayPal picked — this
  /// just attaches PayPal's order `token` as the transaction id on the
  /// pending (approved-but-not-yet-captured) case.
  @visibleForTesting
  static PaymentResult resultFrom(Uri returnUri, PayPalRequest request) {
    final outcome = request.matcher(returnUri);

    if (outcome == WebViewCheckoutOutcome.cancelled) {
      return PaymentResult.cancelled();
    }

    if (outcome == WebViewCheckoutOutcome.pending) {
      final token = returnUri.queryParameters['token'];
      return PaymentResult.pending(
        transactionId: token ?? request.transactionReference,
        message:
            'The buyer approved the order; capture it and verify the final '
            'status server-side before fulfilling it.',
      );
    }

    return PaymentResult.failed(
      message: 'PayPal redirected to an unrecognized URL.',
      errorCode: 'NO_REFERENCE',
    );
  }
}
