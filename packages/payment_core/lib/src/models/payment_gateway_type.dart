enum PaymentGatewayType {
  stripe,
  razorpay,
  phonepe,
  paystack,
  flutterwave,
  paypal,
  dpo,
  paytabs,
  bankTransfer,
  custom;

  /// String representation for logging or fallback backend matching
  String get id => name;
}
