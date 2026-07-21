import 'package:meta/meta.dart';
import 'package:payment_core/payment_core.dart';
import 'package:payment_webview_core/payment_webview_core.dart';

import 'paystack_request.dart';

class PaystackGatewayPlugin extends WebViewGatewayPlugin<PaystackRequest> {
  PaystackGatewayPlugin({
    this.displayName = 'Paystack',
    this.iconAsset,
  });

  @override
  final String displayName;

  /// No icon is bundled with this package: Paystack's brand assets are
  /// subject to Paystack's own brand guidelines, so it isn't ours to
  /// redistribute. Leave null to fall back to a generic payment icon in
  /// [PaymentMethodSelectorSheet], or supply your own asset/URL.
  @override
  final String? iconAsset;

  @override
  PaymentGatewayType get type => PaymentGatewayType.paystack;

  @override
  PaymentResult mapResult(Uri returnUri, PaystackRequest request) =>
      resultFrom(returnUri, request);

  /// Paystack appends `reference` (and historically `trxref`, same value)
  /// to the callback URL regardless of whether the payment actually
  /// succeeded — there's no status in the redirect itself. Reaching the
  /// callback only proves the checkout flow concluded, not that it
  /// succeeded, so this always returns [PaymentResult.pending] and defers
  /// to Paystack's Verify Transaction API for the real outcome.
  @visibleForTesting
  static PaymentResult resultFrom(Uri returnUri, PaystackRequest request) {
    final reference =
        returnUri.queryParameters['reference'] ?? returnUri.queryParameters['trxref'];

    if (reference != null) {
      return PaymentResult.pending(
        transactionId: reference,
        message:
            "Paystack redirected back to the app; verify the final status "
            "with Paystack's Verify Transaction API before fulfilling the order.",
      );
    }

    final outcome = request.matcher(returnUri);
    if (outcome != null) {
      return outcome.toPaymentResult(transactionId: request.transactionReference);
    }

    return PaymentResult.failed(
      message: 'Paystack redirected without a transaction reference.',
      errorCode: 'NO_REFERENCE',
    );
  }
}
