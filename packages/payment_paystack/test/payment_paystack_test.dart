import 'package:flutter_test/flutter_test.dart';
import 'package:payment_core/payment_core.dart';
import 'package:payment_paystack/payment_paystack.dart';
import 'package:payment_webview_core/payment_webview_core.dart';

PaystackRequest _request({WebViewCheckoutOutcome? Function(Uri uri)? onReturn}) {
  return PaystackRequest(
    checkoutUrl: 'https://checkout.paystack.com/abc123',
    onReturn:
        onReturn ??
        (uri) => uri.toString().startsWith('https://app.example.com/return')
            ? WebViewCheckoutOutcome.pending
            : null,
    transactionReference: 'txn_ref_123',
  );
}

void main() {
  group('PaystackRequest', () {
    test('gatewayType is paystack and fields round-trip', () {
      final request = _request();

      expect(request.gatewayType, PaymentGatewayType.paystack);
      expect(request.checkoutUrl, 'https://checkout.paystack.com/abc123');
      expect(request.transactionReference, 'txn_ref_123');
      expect(
        request.onReturn(Uri.parse('https://app.example.com/return')),
        WebViewCheckoutOutcome.pending,
      );
      expect(request.onReturn(Uri.parse('https://evil.com/return')), isNull);
    });

    test('deprecated returnUrlPrefix: reference/trxref always yields pending', () {
      // ignore: deprecated_member_use
      final request = PaystackRequest(
        checkoutUrl: 'https://checkout.paystack.com/abc123',
        returnUrlPrefix: 'https://app.example.com/return',
        transactionReference: 'txn_ref_123',
      );

      expect(
        request.onReturn(Uri.parse('https://app.example.com/return?reference=ref_1')),
        WebViewCheckoutOutcome.pending,
      );
      expect(
        request.onReturn(Uri.parse('https://app.example.com/return?trxref=ref_2')),
        WebViewCheckoutOutcome.pending,
      );
      expect(
        request.onReturn(Uri.parse('https://app.example.com/return?status=cancel')),
        WebViewCheckoutOutcome.cancelled,
      );
    });
  });

  group('PaystackGatewayPlugin', () {
    test('type is paystack', () {
      expect(PaystackGatewayPlugin().type, PaymentGatewayType.paystack);
    });
  });
}
