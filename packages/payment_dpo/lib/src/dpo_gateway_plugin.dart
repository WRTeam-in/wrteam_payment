import 'package:meta/meta.dart';
import 'package:payment_core/payment_core.dart';
import 'package:payment_webview_core/payment_webview_core.dart';

import 'dpo_request.dart';

class DpoGatewayPlugin extends WebViewGatewayPlugin<DpoRequest> {
  DpoGatewayPlugin({
    this.displayName = 'DPO',
    this.iconAsset,
  });

  @override
  final String displayName;

  /// No icon is bundled with this package: DPO's brand assets are subject
  /// to DPO's own brand guidelines, so it isn't ours to redistribute. Leave
  /// null to fall back to a generic payment icon in
  /// [PaymentMethodSelectorSheet], or supply your own asset/URL.
  @override
  final String? iconAsset;

  @override
  PaymentGatewayType get type => PaymentGatewayType.dpo;

  @override
  PaymentResult mapResult(Uri returnUri, DpoRequest request) =>
      resultFrom(returnUri, request);

  /// DPO appends `TransactionToken` (sometimes `TransID`) to the return
  /// URL. DPO's redirect carries no independent status signal (final status
  /// requires calling DPO's Verify Token API), so any hit maps to
  /// [PaymentResult.pending].
  @visibleForTesting
  static PaymentResult resultFrom(Uri returnUri, DpoRequest request) {
    final params = returnUri.queryParameters;
    final token = params['TransactionToken'] ?? params['TransID'];

    if (token != null) {
      return PaymentResult.pending(
        transactionId: token,
        message:
            'DPO redirected back to the app; verify the final status with '
            "DPO's Verify Token API before fulfilling the order.",
      );
    }

    final outcome = request.matcher(returnUri);
    if (outcome != null) {
      return outcome.toPaymentResult(transactionId: request.transactionReference);
    }

    return PaymentResult.failed(
      message: 'DPO redirected without a transaction token.',
      errorCode: 'NO_REFERENCE',
    );
  }
}
