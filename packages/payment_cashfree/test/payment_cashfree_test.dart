import 'package:flutter_test/flutter_test.dart';
import 'package:payment_cashfree/payment_cashfree.dart';
import 'package:payment_core/payment_core.dart';
import 'package:payment_webview_core/payment_webview_core.dart';

CashfreeRequest _request({WebViewReturnUrlMatcher? matcher}) {
  return CashfreeRequest(
    checkoutUrl: 'https://payments.cashfree.com/order/#abc123',
    returnUrlPrefix: 'https://app.example.com/return',
    transactionReference: 'order_ref_123',
    matcher: matcher ?? const WebViewReturnUrlMatcher(),
  );
}

void main() {
  group('CashfreeRequest', () {
    test('gatewayType is cashfree and fields round-trip', () {
      final request = _request();

      expect(request.gatewayType, PaymentGatewayType.cashfree);
      expect(request.returnUrlPrefix, 'https://app.example.com/return');
    });
  });

  group('CashfreeGatewayPlugin', () {
    test('type is cashfree', () {
      expect(CashfreeGatewayPlugin().type, PaymentGatewayType.cashfree);
    });

    group('resultFrom', () {
      test('an order_id always yields pending', () {
        final result = CashfreeGatewayPlugin.resultFrom(
          Uri.parse('https://app.example.com/return?order_id=ORDER123'),
          _request(),
        );

        expect(result.isPending, isTrue);
        expect(result.transactionId, 'ORDER123');
      });

      test('with no order_id, falls back to the matcher', () {
        final result = CashfreeGatewayPlugin.resultFrom(
          Uri.parse('https://app.example.com/return?event=cancel'),
          _request(),
        );

        expect(result.isCancelled, isTrue);
      });

      test('fails with NO_REFERENCE when nothing can be resolved', () {
        final result = CashfreeGatewayPlugin.resultFrom(
          Uri.parse('https://app.example.com/return?foo=bar'),
          _request(),
        );

        expect(result.isFailed, isTrue);
        expect(result.errorCode, 'NO_REFERENCE');
      });
    });
  });
}
