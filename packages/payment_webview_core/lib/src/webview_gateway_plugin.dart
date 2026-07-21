import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:payment_core/payment_core.dart';

import 'webview_checkout_launcher.dart';
import 'webview_checkout_request.dart';

/// Base [PaymentGatewayPlugin] for redirect/WebView-based gateways. Handles
/// launching the checkout page and the cancelled case; subclasses only need
/// to interpret the terminal redirect via [mapResult].
abstract class WebViewGatewayPlugin<T extends WebViewCheckoutRequest>
    extends PaymentGatewayPlugin<T> {
  @override
  @internal
  Future<PaymentResult> processPayment(BuildContext context, T request) async {
    final returnUri = await WebViewCheckoutLauncher.open(
      context,
      checkoutUrl: request.checkoutUrl,
      returnUrlPrefixes: request.returnUrlPrefixes,
      title: request.title,
    );

    if (returnUri == null) {
      return PaymentResult.cancelled();
    }

    return mapResult(returnUri, request);
  }

  /// Interprets the terminal redirect [returnUri] into a [PaymentResult].
  /// Implementations should try the gateway's documented query-param
  /// contract first, falling back to `request.matcher` for anything
  /// unanticipated. Keep the actual mapping in a separate
  /// `@visibleForTesting static` function and have this delegate to it, so
  /// it's unit-testable without an override instance.
  PaymentResult mapResult(Uri returnUri, T request);
}
