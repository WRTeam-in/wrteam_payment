import 'package:payment_core/payment_core.dart';

class StripeRequest extends PaymentRequest {
  StripeRequest({
    required this.clientSecret,
    required this.merchantDisplayName,
    required this.publishableKey,
    this.merchantIdentifier,
  });

  /// PaymentIntent client secret created by the host app's backend.
  final String clientSecret;

  /// Business name shown in Stripe's PaymentSheet header.
  final String merchantDisplayName;

  /// Stripe publishable key for the host app's account.
  final String publishableKey;

  /// Required only if the host app wants Apple Pay offered in the sheet.
  final String? merchantIdentifier;

  @override
  PaymentGatewayType get gatewayType => PaymentGatewayType.stripe;
}
