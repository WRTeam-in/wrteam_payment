import 'package:flutter/widgets.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:meta/meta.dart';
import 'package:payment_core/payment_core.dart';

import 'stripe_request.dart';

class StripeGatewayPlugin extends PaymentGatewayPlugin<StripeRequest> {
  @override
  PaymentGatewayType get type => PaymentGatewayType.stripe;

  @override
  @internal
  Future<PaymentResult> processPayment(
    BuildContext context,
    StripeRequest request,
  ) async {
    Stripe.publishableKey = request.publishableKey;
    Stripe.merchantIdentifier = request.merchantIdentifier;

    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: request.clientSecret,
          merchantDisplayName: request.merchantDisplayName,
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      return PaymentResult.success(
        transactionId: paymentIntentIdFrom(request.clientSecret),
      );
    } on StripeException catch (e) {
      final error = e.error;
      if (error.code == FailureCode.Canceled) {
        return PaymentResult.cancelled(message: error.localizedMessage ?? error.message);
      }
      return PaymentResult.failed(
        message: error.localizedMessage ?? error.message ?? 'Stripe payment failed.',
        errorCode: error.stripeErrorCode ?? error.code.name,
        rawResponse: {
          'code': error.code.name,
          'type': error.type,
          'declineCode': error.declineCode,
        },
      );
    }
  }

  /// A PaymentIntent client secret has the form `pi_XXX_secret_YYY`; the
  /// PaymentIntent id is everything before `_secret_`.
  @visibleForTesting
  static String paymentIntentIdFrom(String clientSecret) {
    final index = clientSecret.indexOf('_secret_');
    return index == -1 ? clientSecret : clientSecret.substring(0, index);
  }
}
