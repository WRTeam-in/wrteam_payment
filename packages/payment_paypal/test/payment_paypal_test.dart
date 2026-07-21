import 'package:flutter_test/flutter_test.dart';
import 'package:payment_core/payment_core.dart';
import 'package:payment_paypal/payment_paypal.dart';
import 'package:payment_webview_core/payment_webview_core.dart';

PayPalRequest _request() {
  return PayPalRequest(
    checkoutUrl: 'https://www.paypal.com/checkoutnow?token=EC-abc123',
    returnUrl: 'https://app.example.com/return',
    transactionReference: 'txn_ref_123',
  );
}

void main() {
  group('PayPalRequest', () {
    test('gatewayType is paypal and returnUrlPrefix is the given returnUrl', () {
      final request = _request();

      expect(request.gatewayType, PaymentGatewayType.paypal);
      expect(request.returnUrlPrefix, 'https://app.example.com/return');
    });

    test('successUrlPrefix/cancelUrlPrefix default to returnUrl + /success, /cancel', () {
      final request = _request();

      expect(request.successUrlPrefix, 'https://app.example.com/return/success');
      expect(request.cancelUrlPrefix, 'https://app.example.com/return/cancel');
    });

    test('successPath/cancelPath are overridable', () {
      final request = PayPalRequest(
        checkoutUrl: 'https://www.paypal.com/checkoutnow?token=EC-abc123',
        returnUrl: 'https://app.example.com/return',
        successPath: '/approved',
        cancelPath: '/declined',
        transactionReference: 'txn_ref_123',
      );

      expect(request.successUrlPrefix, 'https://app.example.com/return/approved');
      expect(request.cancelUrlPrefix, 'https://app.example.com/return/declined');
    });

    test('builds a PayPalReturnUrlMatcher from the success/cancel prefixes', () {
      final request = _request();

      expect(request.matcher, isA<PayPalReturnUrlMatcher>());
    });
  });

  group('PayPalReturnUrlMatcher', () {
    const matcher = PayPalReturnUrlMatcher(
      successUrlPrefix: 'https://app.example.com/return/success',
      cancelUrlPrefix: 'https://app.example.com/return/cancel',
    );

    test('matches the cancel prefix regardless of path wording', () {
      expect(
        matcher(Uri.parse('https://app.example.com/return/cancel?token=EC-abc123')),
        WebViewCheckoutOutcome.cancelled,
      );
    });

    test('matches the success prefix as pending, not success', () {
      expect(
        matcher(Uri.parse('https://app.example.com/return/success?token=EC-abc123')),
        WebViewCheckoutOutcome.pending,
      );
    });

    test('returns null for anything else', () {
      expect(
        matcher(Uri.parse('https://app.example.com/somewhere-else')),
        isNull,
      );
    });
  });

  group('PayPalGatewayPlugin', () {
    test('type is paypal', () {
      expect(PayPalGatewayPlugin().type, PaymentGatewayType.paypal);
    });

    test('displayName defaults to PayPal and can be overridden', () {
      expect(PayPalGatewayPlugin().displayName, 'PayPal');
      expect(PayPalGatewayPlugin(displayName: 'Cards').displayName, 'Cards');
    });

    test('iconAsset defaults to null and can be overridden', () {
      expect(PayPalGatewayPlugin().iconAsset, isNull);
      expect(
        PayPalGatewayPlugin(iconAsset: 'assets/paypal.png').iconAsset,
        'assets/paypal.png',
      );
    });

    group('resultFrom', () {
      test('reaching cancelUrlPrefix is trusted directly as cancelled', () {
        final result = PayPalGatewayPlugin.resultFrom(
          Uri.parse('https://app.example.com/return/cancel?token=EC-abc123'),
          _request(),
        );

        expect(result.isCancelled, isTrue);
      });

      test('reaching successUrlPrefix yields pending, not success', () {
        final result = PayPalGatewayPlugin.resultFrom(
          Uri.parse(
            'https://app.example.com/return/success?token=EC-abc123&PayerID=PAYER1',
          ),
          _request(),
        );

        expect(result.isPending, isTrue);
        expect(result.transactionId, 'EC-abc123');
      });

      test('falls back to transactionReference when token is absent', () {
        final result = PayPalGatewayPlugin.resultFrom(
          Uri.parse('https://app.example.com/return/success'),
          _request(),
        );

        expect(result.isPending, isTrue);
        expect(result.transactionId, 'txn_ref_123');
      });

      test('fails with NO_REFERENCE for an unrecognized URL', () {
        final result = PayPalGatewayPlugin.resultFrom(
          Uri.parse('https://app.example.com/somewhere-else?foo=bar'),
          _request(),
        );

        expect(result.isFailed, isTrue);
        expect(result.errorCode, 'NO_REFERENCE');
      });
    });
  });
}
