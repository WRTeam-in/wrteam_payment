import 'package:flutter_test/flutter_test.dart';
import 'package:payment_core/payment_core.dart';
import 'package:payment_paystack/payment_paystack.dart';
import 'package:payment_webview_core/payment_webview_core.dart';

PaystackRequest _request({WebViewReturnUrlMatcher? matcher}) {
  return PaystackRequest(
    checkoutUrl: 'https://checkout.paystack.com/abc123',
    returnUrlPrefixes: const ['https://app.example.com/return'],
    transactionReference: 'txn_ref_123',
    matcher: matcher ?? const WebViewReturnUrlMatcher(),
  );
}

void main() {
  group('PaystackRequest', () {
    test('gatewayType is paystack and fields round-trip', () {
      final request = _request();

      expect(request.gatewayType, PaymentGatewayType.paystack);
      expect(request.checkoutUrl, 'https://checkout.paystack.com/abc123');
      expect(request.returnUrlPrefixes, ['https://app.example.com/return']);
      expect(request.transactionReference, 'txn_ref_123');
    });
  });

  group('PaystackGatewayPlugin', () {
    test('type is paystack', () {
      expect(PaystackGatewayPlugin().type, PaymentGatewayType.paystack);
    });

    test('displayName defaults to Paystack and can be overridden', () {
      expect(PaystackGatewayPlugin().displayName, 'Paystack');
      expect(PaystackGatewayPlugin(displayName: 'Cards').displayName, 'Cards');
    });

    test('iconAsset defaults to null and can be overridden', () {
      expect(PaystackGatewayPlugin().iconAsset, isNull);
      expect(
        PaystackGatewayPlugin(iconAsset: 'assets/paystack.png').iconAsset,
        'assets/paystack.png',
      );
    });

    group('resultFrom', () {
      test('a reference query param always yields pending, regardless of outcome', () {
        final result = PaystackGatewayPlugin.resultFrom(
          Uri.parse('https://app.example.com/return?reference=ref_1'),
          _request(),
        );

        expect(result.isPending, isTrue);
        expect(result.transactionId, 'ref_1');
      });

      test('falls back to trxref when reference is absent', () {
        final result = PaystackGatewayPlugin.resultFrom(
          Uri.parse('https://app.example.com/return?trxref=ref_2'),
          _request(),
        );

        expect(result.isPending, isTrue);
        expect(result.transactionId, 'ref_2');
      });

      test('with neither param, falls back to the default keyword classifier', () {
        final result = PaystackGatewayPlugin.resultFrom(
          Uri.parse('https://app.example.com/return?status=cancel'),
          _request(),
        );

        expect(result.isCancelled, isTrue);
      });

      test('with neither param, falls back to a caller-supplied matcher', () {
        final result = PaystackGatewayPlugin.resultFrom(
          Uri.parse('https://app.example.com/return?r=ok'),
          _request(matcher: const WebViewReturnUrlMatcher(successPatterns: ['r=ok'])),
        );

        expect(result.isSuccess, isTrue);
        expect(result.transactionId, 'txn_ref_123');
      });

      test('fails with NO_REFERENCE when nothing can be resolved', () {
        final result = PaystackGatewayPlugin.resultFrom(
          Uri.parse('https://app.example.com/return?r=unknown'),
          _request(),
        );

        expect(result.isFailed, isTrue);
        expect(result.errorCode, 'NO_REFERENCE');
      });
    });
  });
}
