import 'package:meta/meta.dart';
import 'package:payment_core/payment_core.dart';
import 'package:payment_webview_core/payment_webview_core.dart';

import 'paytabs_request.dart';

class PayTabsGatewayPlugin extends WebViewGatewayPlugin<PayTabsRequest> {
  PayTabsGatewayPlugin({
    this.displayName = 'PayTabs',
    this.iconAsset,
  });

  @override
  final String displayName;

  /// No icon is bundled with this package: PayTabs's brand assets are
  /// subject to PayTabs's own brand guidelines, so it isn't ours to
  /// redistribute. Leave null to fall back to a generic payment icon in
  /// [PaymentMethodSelectorSheet], or supply your own asset/URL.
  @override
  final String? iconAsset;

  @override
  PaymentGatewayType get type => PaymentGatewayType.paytabs;

  @override
  PaymentResult mapResult(Uri returnUri, PayTabsRequest request) =>
      resultFrom(returnUri, request);

  /// PayTabs appends `tranRef`, `respStatus`, `respMessage`, `cartId` and a
  /// `signature` to the return URL. `respStatus` (e.g. `A` for Authorised)
  /// comes straight from PayTabs's own auth response, which is exactly the
  /// value their docs say must go through mandatory signature verification
  /// before being trusted — so this never infers success/failure from it,
  /// only pending, deferring to a signature-verified backend check.
  @visibleForTesting
  static PaymentResult resultFrom(Uri returnUri, PayTabsRequest request) {
    final params = returnUri.queryParameters;
    final tranRef = params['tranRef'];

    if (tranRef != null) {
      return PaymentResult.pending(
        transactionId: tranRef,
        message:
            'PayTabs redirected back to the app; verify the signed response '
            "server-side before fulfilling the order.",
      );
    }

    final outcome = request.matcher(returnUri);
    if (outcome != null) {
      return outcome.toPaymentResult(transactionId: request.transactionReference);
    }

    return PaymentResult.failed(
      message: 'PayTabs redirected without a transaction reference.',
      errorCode: 'NO_REFERENCE',
    );
  }
}
