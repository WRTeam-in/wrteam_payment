import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:payment_core/payment_core.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'razorpay_request.dart';

class RazorpayGatewayPlugin extends PaymentGatewayPlugin<RazorpayRequest> {
  RazorpayGatewayPlugin({this.displayName = 'Razorpay', this.iconAsset});

  @override
  final String displayName;

  /// No icon is bundled with this package: Razorpay's brand assets are
  /// subject to Razorpay's own brand guidelines, so it isn't ours to
  /// redistribute. Leave null to fall back to a generic payment icon in
  /// [PaymentMethodSelectorSheet], or supply your own asset/URL.
  @override
  final String? iconAsset;

  @override
  PaymentGatewayType get type => PaymentGatewayType.razorpay;

  @override
  @internal
  Future<PaymentResult> processPayment(
    BuildContext context,
    RazorpayRequest request,
  ) async {
    final razorpay = Razorpay();
    final completer = Completer<PaymentResult>();

    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (
      PaymentSuccessResponse response,
    ) {
      completer.complete(
        PaymentResult.success(
          transactionId: response.paymentId ?? request.orderId,
          rawResponse: {
            'orderId': response.orderId,
            'signature': response.signature,
          },
        ),
      );
    });

    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (
      PaymentFailureResponse response,
    ) {
      if (response.code == Razorpay.PAYMENT_CANCELLED) {
        completer.complete(PaymentResult.cancelled(message: response.message));
        return;
      }
      completer.complete(
        PaymentResult.failed(
          message: response.message ?? 'Razorpay payment failed.',
          errorCode: errorCodeName(response.code),
          rawResponse: response.error == null
              ? null
              : Map<String, dynamic>.from(response.error!),
        ),
      );
    });

    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, (
      ExternalWalletResponse response,
    ) {
      completer.complete(
        PaymentResult.pending(
          message:
              'Payment continued via external wallet "${response.walletName}". '
              'Verify the final status with your backend.',
        ),
      );
    });

    razorpay.open({
      'key': request.razorpayKey,
      'amount': request.amount,
      'currency': request.currency,
      'order_id': request.orderId,
      'name': request.name,
      'description': ?request.description,
    });

    try {
      return await completer.future;
    } finally {
      razorpay.clear();
    }
  }

  /// Maps a [Razorpay] payment-failure code constant to a stable error name.
  @visibleForTesting
  static String errorCodeName(int? code) {
    switch (code) {
      case Razorpay.NETWORK_ERROR:
        return 'NETWORK_ERROR';
      case Razorpay.INVALID_OPTIONS:
        return 'INVALID_OPTIONS';
      case Razorpay.PAYMENT_CANCELLED:
        return 'PAYMENT_CANCELLED';
      case Razorpay.TLS_ERROR:
        return 'TLS_ERROR';
      case Razorpay.INCOMPATIBLE_PLUGIN:
        return 'INCOMPATIBLE_PLUGIN';
      default:
        return 'UNKNOWN_ERROR';
    }
  }
}
