import 'package:flutter_test/flutter_test.dart';
import 'package:payment_core/payment_core.dart';
import 'package:payment_flutterwave/payment_flutterwave.dart';
import 'package:payment_webview_core/payment_webview_core.dart';

FlutterwaveRequest _request({WebViewReturnUrlMatcher? matcher}) {
  return FlutterwaveRequest(
    checkoutUrl: 'https://checkout.flutterwave.com/abc123',
    returnUrlPrefix: 'https://app.example.com/return',
    transactionReference: 'txn_ref_123',
    matcher: matcher ?? const WebViewReturnUrlMatcher(),
  );
}

void main() {
  group('FlutterwaveRequest', () {
    test('gatewayType is flutterwave and fields round-trip', () {
      final request = _request();

      expect(request.gatewayType, PaymentGatewayType.flutterwave);
      expect(request.returnUrlPrefix, 'https://app.example.com/return');
      expect(request.transactionReference, 'txn_ref_123');
    });
  });

  group('FlutterwaveGatewayPlugin', () {
    test('type is flutterwave', () {
      expect(FlutterwaveGatewayPlugin().type, PaymentGatewayType.flutterwave);
    });

    test('displayName defaults to Flutterwave and can be overridden', () {
      expect(FlutterwaveGatewayPlugin().displayName, 'Flutterwave');
      expect(FlutterwaveGatewayPlugin(displayName: 'Cards').displayName, 'Cards');
    });

    test('iconAsset defaults to null and can be overridden', () {
      expect(FlutterwaveGatewayPlugin().iconAsset, isNull);
      expect(
        FlutterwaveGatewayPlugin(iconAsset: 'assets/flutterwave.png').iconAsset,
        'assets/flutterwave.png',
      );
    });

    group('resultFrom', () {
      test('status=cancelled is trusted directly as cancelled', () {
        final result = FlutterwaveGatewayPlugin.resultFrom(
          Uri.parse('https://app.example.com/return?status=cancelled&tx_ref=ref_1'),
          _request(),
        );

        expect(result.isCancelled, isTrue);
      });

      test('status=successful still yields pending, not success', () {
        final result = FlutterwaveGatewayPlugin.resultFrom(
          Uri.parse(
            'https://app.example.com/return?status=successful&transaction_id=id_1&tx_ref=ref_1',
          ),
          _request(),
        );

        expect(result.isPending, isTrue);
        expect(result.transactionId, 'id_1');
      });

      test('falls back to tx_ref when transaction_id is absent', () {
        final result = FlutterwaveGatewayPlugin.resultFrom(
          Uri.parse('https://app.example.com/return?status=successful&tx_ref=ref_2'),
          _request(),
        );

        expect(result.isPending, isTrue);
        expect(result.transactionId, 'ref_2');
      });

      test('with nothing usable, falls back to the matcher', () {
        final result = FlutterwaveGatewayPlugin.resultFrom(
          Uri.parse('https://app.example.com/return?foo=fail'),
          _request(),
        );

        expect(result.isFailed, isTrue);
      });

      test('fails with NO_REFERENCE when nothing can be resolved', () {
        final result = FlutterwaveGatewayPlugin.resultFrom(
          Uri.parse('https://app.example.com/return?foo=bar'),
          _request(),
        );

        expect(result.isFailed, isTrue);
        expect(result.errorCode, 'NO_REFERENCE');
      });
    });
  });
}
