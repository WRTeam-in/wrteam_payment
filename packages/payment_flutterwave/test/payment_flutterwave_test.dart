import 'package:flutter_test/flutter_test.dart';
import 'package:payment_core/payment_core.dart';
import 'package:payment_flutterwave/payment_flutterwave.dart';
import 'package:payment_webview_core/payment_webview_core.dart';

FlutterwaveRequest _request({WebViewCheckoutOutcome? Function(Uri uri)? onReturn}) {
  return FlutterwaveRequest(
    checkoutUrl: 'https://checkout.flutterwave.com/abc123',
    onReturn:
        onReturn ??
        (uri) => uri.toString().startsWith('https://app.example.com/return')
            ? WebViewCheckoutOutcome.pending
            : null,
    transactionReference: 'txn_ref_123',
  );
}

void main() {
  group('FlutterwaveRequest', () {
    test('gatewayType is flutterwave and fields round-trip', () {
      final request = _request();

      expect(request.gatewayType, PaymentGatewayType.flutterwave);
      expect(request.checkoutUrl, 'https://checkout.flutterwave.com/abc123');
      expect(request.transactionReference, 'txn_ref_123');
      expect(
        request.onReturn(Uri.parse('https://app.example.com/return')),
        WebViewCheckoutOutcome.pending,
      );
      expect(request.onReturn(Uri.parse('https://evil.com/return')), isNull);
    });

    test(
      'deprecated returnUrlPrefix: status=cancelled trusted directly, else transaction id yields pending',
      () {
        // ignore: deprecated_member_use
        final request = FlutterwaveRequest(
          checkoutUrl: 'https://checkout.flutterwave.com/abc123',
          returnUrlPrefix: 'https://app.example.com/return',
          transactionReference: 'txn_ref_123',
        );

        expect(
          request.onReturn(
            Uri.parse('https://app.example.com/return?status=cancelled&tx_ref=ref_1'),
          ),
          WebViewCheckoutOutcome.cancelled,
        );
        expect(
          request.onReturn(
            Uri.parse(
              'https://app.example.com/return?status=successful&transaction_id=id_1',
            ),
          ),
          WebViewCheckoutOutcome.pending,
        );
        expect(
          request.onReturn(Uri.parse('https://app.example.com/return?foo=fail')),
          WebViewCheckoutOutcome.failed,
        );
      },
    );
  });

  group('FlutterwaveGatewayPlugin', () {
    test('type is flutterwave', () {
      expect(FlutterwaveGatewayPlugin().type, PaymentGatewayType.flutterwave);
    });
  });
}
