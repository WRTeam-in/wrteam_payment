import 'package:flutter_test/flutter_test.dart';
import 'package:payment_core/payment_core.dart';
import 'package:payment_paytabs/payment_paytabs.dart';
import 'package:payment_webview_core/payment_webview_core.dart';

PayTabsRequest _request({WebViewCheckoutOutcome? Function(Uri uri)? onReturn}) {
  return PayTabsRequest(
    checkoutUrl: 'https://secure.paytabs.com/payment/page/abc123',
    onReturn:
        onReturn ??
        (uri) => uri.toString().startsWith('https://app.example.com/return')
            ? WebViewCheckoutOutcome.pending
            : null,
    transactionReference: 'txn_ref_123',
  );
}

void main() {
  group('PayTabsRequest', () {
    test('gatewayType is paytabs and fields round-trip', () {
      final request = _request();

      expect(request.gatewayType, PaymentGatewayType.paytabs);
      expect(request.checkoutUrl, 'https://secure.paytabs.com/payment/page/abc123');
      expect(request.transactionReference, 'txn_ref_123');
      expect(
        request.onReturn(Uri.parse('https://app.example.com/return')),
        WebViewCheckoutOutcome.pending,
      );
      expect(request.onReturn(Uri.parse('https://evil.com/return')), isNull);
    });

    test('deprecated returnUrlPrefix: tranRef always yields pending regardless of respStatus', () {
      // ignore: deprecated_member_use
      final request = PayTabsRequest(
        checkoutUrl: 'https://secure.paytabs.com/payment/page/abc123',
        returnUrlPrefix: 'https://app.example.com/return',
        transactionReference: 'txn_ref_123',
      );

      expect(
        request.onReturn(
          Uri.parse('https://app.example.com/return?respStatus=D&tranRef=TST124'),
        ),
        WebViewCheckoutOutcome.pending,
      );
      expect(
        request.onReturn(Uri.parse('https://app.example.com/return?event=cancel')),
        WebViewCheckoutOutcome.cancelled,
      );
    });
  });

  group('PayTabsGatewayPlugin', () {
    test('type is paytabs', () {
      expect(PayTabsGatewayPlugin().type, PaymentGatewayType.paytabs);
    });
  });
}
