import 'package:flutter_test/flutter_test.dart';
import 'package:payment_core/payment_core.dart';
import 'package:payment_paypal/payment_paypal.dart';
import 'package:payment_webview_core/payment_webview_core.dart';

PayPalRequest _request({WebViewCheckoutOutcome? Function(Uri uri)? onReturn}) {
  return PayPalRequest(
    checkoutUrl: 'https://www.paypal.com/checkoutnow?token=EC-abc123',
    onReturn:
        onReturn ??
        (uri) {
          if (uri.path.endsWith('/cancel')) return WebViewCheckoutOutcome.cancelled;
          if (uri.path.endsWith('/success')) return WebViewCheckoutOutcome.pending;
          return null;
        },
    transactionReference: 'txn_ref_123',
  );
}

void main() {
  group('PayPalRequest', () {
    test('gatewayType is paypal and fields round-trip', () {
      final request = _request();

      expect(request.gatewayType, PaymentGatewayType.paypal);
      expect(
        request.checkoutUrl,
        'https://www.paypal.com/checkoutnow?token=EC-abc123',
      );
      expect(request.transactionReference, 'txn_ref_123');
    });

    test('onReturn distinguishes cancel from success paths', () {
      final request = _request();

      expect(
        request.onReturn(Uri.parse('https://app.example.com/return/cancel?token=EC-abc123')),
        WebViewCheckoutOutcome.cancelled,
      );
      expect(
        request.onReturn(Uri.parse('https://app.example.com/return/success?token=EC-abc123')),
        WebViewCheckoutOutcome.pending,
      );
      expect(request.onReturn(Uri.parse('https://app.example.com/somewhere-else')), isNull);
    });

    test('deprecated returnUrl/successPath/cancelPath still compiles and resolves onReturn', () {
      // ignore: deprecated_member_use
      final request = PayPalRequest(
        checkoutUrl: 'https://www.paypal.com/checkoutnow?token=EC-abc123',
        returnUrl: 'https://app.example.com/return',
        transactionReference: 'txn_ref_123',
      );

      expect(
        request.onReturn(Uri.parse('https://app.example.com/return/cancel?token=EC-abc123')),
        WebViewCheckoutOutcome.cancelled,
      );
      expect(
        request.onReturn(Uri.parse('https://app.example.com/return/success?token=EC-abc123')),
        WebViewCheckoutOutcome.pending,
      );
      expect(
        request.onReturn(Uri.parse('https://app.example.com/return/other')),
        WebViewCheckoutOutcome.failed,
      );
      expect(request.onReturn(Uri.parse('https://evil.com/return')), isNull);
    });
  });

  group('PayPalGatewayPlugin', () {
    test('type is paypal', () {
      expect(PayPalGatewayPlugin().type, PaymentGatewayType.paypal);
    });
  });
}
