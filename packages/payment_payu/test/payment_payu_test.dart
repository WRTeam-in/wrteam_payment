import 'package:flutter_test/flutter_test.dart';
import 'package:payment_core/payment_core.dart';
import 'package:payment_payu/payment_payu.dart';
import 'package:payment_webview_core/payment_webview_core.dart';

PayURequest _request({WebViewReturnUrlMatcher? matcher}) {
  return PayURequest(
    checkoutUrl: 'https://secure.payu.in/_payment',
    returnUrlPrefix: 'https://app.example.com/return',
    transactionReference: 'txn_ref_123',
    matcher: matcher ?? const WebViewReturnUrlMatcher(),
  );
}

void main() {
  group('PayURequest', () {
    test('gatewayType is payu and fields round-trip', () {
      final request = _request();

      expect(request.gatewayType, PaymentGatewayType.payu);
      expect(request.returnUrlPrefix, 'https://app.example.com/return');
    });
  });

  group('PayUGatewayPlugin', () {
    test('type is payu', () {
      expect(PayUGatewayPlugin().type, PaymentGatewayType.payu);
    });

    group('resultFrom', () {
      test('status=userCancelled is trusted directly as cancelled', () {
        final result = PayUGatewayPlugin.resultFrom(
          Uri.parse('https://app.example.com/return?status=userCancelled&txnid=TXN1'),
          _request(),
        );

        expect(result.isCancelled, isTrue);
      });

      test('status=success still yields pending, not success', () {
        final result = PayUGatewayPlugin.resultFrom(
          Uri.parse(
            'https://app.example.com/return?status=success&txnid=TXN1&mihpayid=MIHPAY1',
          ),
          _request(),
        );

        expect(result.isPending, isTrue);
        expect(result.transactionId, 'TXN1');
      });

      test('status=failure still yields pending, not failed', () {
        final result = PayUGatewayPlugin.resultFrom(
          Uri.parse('https://app.example.com/return?status=failure&txnid=TXN2'),
          _request(),
        );

        expect(result.isPending, isTrue);
      });

      test('falls back to mihpayid when txnid is absent', () {
        final result = PayUGatewayPlugin.resultFrom(
          Uri.parse('https://app.example.com/return?status=success&mihpayid=MIHPAY2'),
          _request(),
        );

        expect(result.isPending, isTrue);
        expect(result.transactionId, 'MIHPAY2');
      });

      test('with no transaction reference, falls back to the matcher', () {
        final result = PayUGatewayPlugin.resultFrom(
          Uri.parse('https://app.example.com/return?event=cancel'),
          _request(),
        );

        expect(result.isCancelled, isTrue);
      });

      test('fails with NO_REFERENCE when nothing can be resolved', () {
        final result = PayUGatewayPlugin.resultFrom(
          Uri.parse('https://app.example.com/return?foo=bar'),
          _request(),
        );

        expect(result.isFailed, isTrue);
        expect(result.errorCode, 'NO_REFERENCE');
      });
    });
  });
}
