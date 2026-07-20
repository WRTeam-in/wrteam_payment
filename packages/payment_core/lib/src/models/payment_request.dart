import 'payment_gateway_type.dart';

abstract class PaymentRequest {
  /// Target payment gateway type
  PaymentGatewayType get gatewayType;
}
