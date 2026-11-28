import 'package:flutter_test/flutter_test.dart';
import 'package:payment_cashfree/payment_cashfree.dart';
import 'package:payment_core/payment_core.dart';
import 'package:payment_webview_core/payment_webview_core.dart';

CashfreeRequest _request({WebViewCheckoutOutcome? Function(Uri uri)? onReturn}) {
  return CashfreeRequest(
    checkoutUrl: 'https://payments.cashfree.com/order/#abc123',
    onReturn:
        onReturn ??
        (uri) => uri.toString().startsWith('https://app.example.com/return')
            ? WebViewCheckoutOutcome.pending
            : null,
    transactionReference: 'order_ref_123',
  );
}

void main() {
  group('CashfreeRequest', () {
    test('gatewayType is cashfree and fields round-trip', () {
      final request = _request();

      expect(request.gatewayType, PaymentGatewayType.cashfree);
      expect(request.checkoutUrl, 'https://payments.cashfree.com/order/#abc123');
      expect(request.transactionReference, 'order_ref_123');
      expect(
        request.onReturn(Uri.parse('https://app.example.com/return')),
        WebViewCheckoutOutcome.pending,
      );
      expect(request.onReturn(Uri.parse('https://evil.com/return')), isNull);
    });
  });

  group('CashfreeGatewayPlugin', () {
    test('type is cashfree', () {
      expect(CashfreeGatewayPlugin().type, PaymentGatewayType.cashfree);
    });
  });
}
