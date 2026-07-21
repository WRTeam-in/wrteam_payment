/// Identifies a payment gateway. Open rather than a closed `enum` so host
/// apps can define their own gateways (bank transfer, an in-house wallet,
/// anything we don't ship) without needing an upstream change — just
/// construct `const PaymentGatewayType('my_gateway')` and register a
/// [PaymentGatewayPlugin] for it like any built-in.
class PaymentGatewayType {
  const PaymentGatewayType(this.id);

  /// String identifier, also used for logging or backend matching.
  final String id;

  static const stripe = PaymentGatewayType('stripe');
  static const razorpay = PaymentGatewayType('razorpay');
  static const phonepe = PaymentGatewayType('phonepe');
  static const paystack = PaymentGatewayType('paystack');
  static const flutterwave = PaymentGatewayType('flutterwave');
  static const paypal = PaymentGatewayType('paypal');
  static const dpo = PaymentGatewayType('dpo');
  static const paytabs = PaymentGatewayType('paytabs');

  @override
  bool operator ==(Object other) => other is PaymentGatewayType && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'PaymentGatewayType($id)';
}
