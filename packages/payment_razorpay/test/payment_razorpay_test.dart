import 'package:flutter_test/flutter_test.dart';
import 'package:payment_core/payment_core.dart';
import 'package:payment_razorpay/payment_razorpay.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

void main() {
  group('RazorpayRequest', () {
    test('gatewayType is razorpay and fields round-trip', () {
      final request = RazorpayRequest(
        razorpayKey: 'rzp_test_123',
        amount: 50000,
        currency: 'INR',
        orderId: 'order_abc',
        name: 'Acme Inc',
        description: 'Order #42',
      );

      expect(request.gatewayType, PaymentGatewayType.razorpay);
      expect(request.razorpayKey, 'rzp_test_123');
      expect(request.amount, 50000);
      expect(request.currency, 'INR');
      expect(request.orderId, 'order_abc');
      expect(request.name, 'Acme Inc');
      expect(request.description, 'Order #42');
    });

    test('name defaults to Razorpay and description is optional', () {
      final request = RazorpayRequest(
        razorpayKey: 'rzp_test_123',
        amount: 50000,
        currency: 'INR',
        orderId: 'order_abc',
      );

      expect(request.name, 'Razorpay');
      expect(request.description, isNull);
    });
  });

  group('RazorpayGatewayPlugin', () {
    test('type is razorpay', () {
      expect(RazorpayGatewayPlugin().type, PaymentGatewayType.razorpay);
    });

    group('errorCodeName', () {
      test('maps known Razorpay error codes', () {
        expect(
          RazorpayGatewayPlugin.errorCodeName(Razorpay.NETWORK_ERROR),
          'NETWORK_ERROR',
        );
        expect(
          RazorpayGatewayPlugin.errorCodeName(Razorpay.INVALID_OPTIONS),
          'INVALID_OPTIONS',
        );
        expect(
          RazorpayGatewayPlugin.errorCodeName(Razorpay.PAYMENT_CANCELLED),
          'PAYMENT_CANCELLED',
        );
        expect(
          RazorpayGatewayPlugin.errorCodeName(Razorpay.TLS_ERROR),
          'TLS_ERROR',
        );
        expect(
          RazorpayGatewayPlugin.errorCodeName(Razorpay.INCOMPATIBLE_PLUGIN),
          'INCOMPATIBLE_PLUGIN',
        );
      });

      test('falls back to UNKNOWN_ERROR for unrecognized/null codes', () {
        expect(RazorpayGatewayPlugin.errorCodeName(Razorpay.UNKNOWN_ERROR), 'UNKNOWN_ERROR');
        expect(RazorpayGatewayPlugin.errorCodeName(999), 'UNKNOWN_ERROR');
        expect(RazorpayGatewayPlugin.errorCodeName(null), 'UNKNOWN_ERROR');
      });
    });
  });
}
