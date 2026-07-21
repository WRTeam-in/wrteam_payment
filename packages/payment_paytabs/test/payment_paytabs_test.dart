import 'package:flutter_test/flutter_test.dart';
import 'package:payment_core/payment_core.dart';
import 'package:payment_paytabs/payment_paytabs.dart';
import 'package:payment_webview_core/payment_webview_core.dart';

PayTabsRequest _request({WebViewReturnUrlMatcher? matcher}) {
  return PayTabsRequest(
    checkoutUrl: 'https://secure.paytabs.com/payment/page/abc123',
    returnUrlPrefix: 'https://app.example.com/return',
    transactionReference: 'txn_ref_123',
    matcher: matcher ?? const WebViewReturnUrlMatcher(),
  );
}

void main() {
  group('PayTabsRequest', () {
    test('gatewayType is paytabs and fields round-trip', () {
      final request = _request();

      expect(request.gatewayType, PaymentGatewayType.paytabs);
      expect(request.returnUrlPrefix, 'https://app.example.com/return');
    });
  });

  group('PayTabsGatewayPlugin', () {
    test('type is paytabs', () {
      expect(PayTabsGatewayPlugin().type, PaymentGatewayType.paytabs);
    });

    group('resultFrom', () {
      test('a tranRef always yields pending regardless of respStatus', () {
        final result = PayTabsGatewayPlugin.resultFrom(
          Uri.parse(
            'https://app.example.com/return?respStatus=A&tranRef=TST123&cartId=CART1',
          ),
          _request(),
        );

        expect(result.isPending, isTrue);
        expect(result.transactionId, 'TST123');
      });

      test('a declined respStatus still yields pending, not failed', () {
        final result = PayTabsGatewayPlugin.resultFrom(
          Uri.parse('https://app.example.com/return?respStatus=D&tranRef=TST124'),
          _request(),
        );

        expect(result.isPending, isTrue);
      });

      test('with no tranRef, falls back to the matcher', () {
        final result = PayTabsGatewayPlugin.resultFrom(
          Uri.parse('https://app.example.com/return?event=cancel'),
          _request(),
        );

        expect(result.isCancelled, isTrue);
      });

      test('fails with NO_REFERENCE when nothing can be resolved', () {
        final result = PayTabsGatewayPlugin.resultFrom(
          Uri.parse('https://app.example.com/return?foo=bar'),
          _request(),
        );

        expect(result.isFailed, isTrue);
        expect(result.errorCode, 'NO_REFERENCE');
      });
    });
  });
}
