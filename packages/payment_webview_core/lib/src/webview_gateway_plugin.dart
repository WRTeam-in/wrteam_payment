import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:payment_core/payment_core.dart';

import 'webview_checkout_launcher.dart';
import 'webview_checkout_outcome.dart';
import 'webview_checkout_outcome_mapping.dart';
import 'webview_checkout_request.dart';

/// Query-param names the gateways in this package redirect a reference
/// back under. Checked in this order; the first one present wins.
const _referenceParams = [
  'reference',
  'trxref',
  'order_id',
  'tranRef',
  'TransactionToken',
  'TransID',
  'transaction_id',
  'tx_ref',
  'txnid',
  'mihpayid',
  'token',
];

/// Base [PaymentGatewayPlugin] for redirect/WebView-based gateways. Launches
/// the checkout page, resolves `cancelled` when the user backs out without
/// [WebViewCheckoutRequest.onReturn] ever matching, and otherwise maps the
/// outcome it decided into a [PaymentResult] — attaching a gateway-issued
/// reference from the return URL's query when there is one, falling back
/// to [WebViewCheckoutRequest.transactionReference] otherwise.
abstract class WebViewGatewayPlugin<T extends WebViewCheckoutRequest>
    extends PaymentGatewayPlugin<T> {
  @override
  @internal
  Future<PaymentResult> processPayment(BuildContext context, T request) async {
    final result = await WebViewCheckoutLauncher.open(
      context,
      checkoutUrl: request.checkoutUrl,
      onReturn: request.onReturn,
      title: request.title,
    );

    if (result == null) {
      return PaymentResult.cancelled();
    }

    final (returnUri, outcome) = result;
    return resultFrom(returnUri, outcome, request.transactionReference);
  }

  @visibleForTesting
  static PaymentResult resultFrom(
    Uri returnUri,
    WebViewCheckoutOutcome outcome,
    String transactionReference,
  ) {
    final reference = _referenceFrom(returnUri) ?? transactionReference;
    return outcome.toPaymentResult(transactionId: reference);
  }

  static String? _referenceFrom(Uri uri) {
    for (final param in _referenceParams) {
      final value = uri.queryParameters[param];
      if (value != null) return value;
    }
    return null;
  }
}
