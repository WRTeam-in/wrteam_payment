import 'package:payment_core/payment_core.dart';

class RazorpayRequest extends PaymentRequest {
  RazorpayRequest({
    required this.razorpayKey,
    required this.amount,
    required this.currency,
    required this.orderId,
    this.name = 'Razorpay',
    this.description,
  });

  /// Razorpay API key for the host app's account.
  final String razorpayKey;

  /// Amount in the smallest currency unit (e.g. paise for INR).
  final int amount;

  /// ISO currency code, e.g. 'INR'.
  final String currency;

  /// Order id created by the host app's backend.
  final String orderId;

  /// Business name shown in the Razorpay checkout.
  final String name;

  /// Optional payment description shown in the checkout.
  final String? description;

  @override
  PaymentGatewayType get gatewayType => PaymentGatewayType.razorpay;
}
