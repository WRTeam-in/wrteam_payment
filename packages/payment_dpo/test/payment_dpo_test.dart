import 'package:flutter_test/flutter_test.dart';
import 'package:payment_core/payment_core.dart';
import 'package:payment_dpo/payment_dpo.dart';
import 'package:payment_webview_core/payment_webview_core.dart';

DpoRequest _request({WebViewReturnUrlMatcher? matcher}) {
  return DpoRequest(
    checkoutUrl: 'https://secure.3gdirectpay.com/payv3.php?ID=abc123',
    returnUrlPrefix: 'https://app.example.com/return',
    transactionReference: 'txn_ref_123',
    matcher: matcher ?? const WebViewReturnUrlMatcher(),
  );
}

void main() {
  group('DpoRequest', () {
    test('gatewayType is dpo and fields round-trip', () {
      final request = _request();

      expect(request.gatewayType, PaymentGatewayType.dpo);
      expect(request.returnUrlPrefix, 'https://app.example.com/return');
    });
  });

  group('DpoGatewayPlugin', () {
    test('type is dpo', () {
      expect(DpoGatewayPlugin().type, PaymentGatewayType.dpo);
    });

    test('displayName defaults to DPO and can be overridden', () {
      expect(DpoGatewayPlugin().displayName, 'DPO');
      expect(DpoGatewayPlugin(displayName: 'Cards').displayName, 'Cards');
    });

    test('iconAsset defaults to null and can be overridden', () {
      expect(DpoGatewayPlugin().iconAsset, isNull);
      expect(
        DpoGatewayPlugin(iconAsset: 'assets/dpo.png').iconAsset,
        'assets/dpo.png',
      );
    });

    group('resultFrom', () {
      test('a TransactionToken yields pending', () {
        final result = DpoGatewayPlugin.resultFrom(
          Uri.parse('https://app.example.com/return?TransactionToken=tok_1'),
          _request(),
        );

        expect(result.isPending, isTrue);
        expect(result.transactionId, 'tok_1');
      });

      test('falls back to TransID when TransactionToken is absent', () {
        final result = DpoGatewayPlugin.resultFrom(
          Uri.parse('https://app.example.com/return?TransID=tok_2'),
          _request(),
        );

        expect(result.isPending, isTrue);
        expect(result.transactionId, 'tok_2');
      });

      test('with neither, falls back to the matcher', () {
        final result = DpoGatewayPlugin.resultFrom(
          Uri.parse('https://app.example.com/return?event=cancel'),
          _request(),
        );

        expect(result.isCancelled, isTrue);
      });

      test('fails with NO_REFERENCE when nothing can be resolved', () {
        final result = DpoGatewayPlugin.resultFrom(
          Uri.parse('https://app.example.com/return?foo=bar'),
          _request(),
        );

        expect(result.isFailed, isTrue);
        expect(result.errorCode, 'NO_REFERENCE');
      });
    });
  });
}
