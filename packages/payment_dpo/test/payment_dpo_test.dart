import 'package:flutter_test/flutter_test.dart';
import 'package:payment_core/payment_core.dart';
import 'package:payment_dpo/payment_dpo.dart';
import 'package:payment_webview_core/payment_webview_core.dart';

DpoRequest _request({WebViewCheckoutOutcome? Function(Uri uri)? onReturn}) {
  return DpoRequest(
    checkoutUrl: 'https://secure.3gdirectpay.com/payv3.php?ID=abc123',
    onReturn:
        onReturn ??
        (uri) => uri.toString().startsWith('https://app.example.com/return')
            ? WebViewCheckoutOutcome.pending
            : null,
    transactionReference: 'txn_ref_123',
  );
}

void main() {
  group('DpoRequest', () {
    test('gatewayType is dpo and fields round-trip', () {
      final request = _request();

      expect(request.gatewayType, PaymentGatewayType.dpo);
      expect(request.checkoutUrl, 'https://secure.3gdirectpay.com/payv3.php?ID=abc123');
      expect(request.transactionReference, 'txn_ref_123');
      expect(
        request.onReturn(Uri.parse('https://app.example.com/return')),
        WebViewCheckoutOutcome.pending,
      );
      expect(request.onReturn(Uri.parse('https://evil.com/return')), isNull);
    });
  });

  group('DpoGatewayPlugin', () {
    test('type is dpo', () {
      expect(DpoGatewayPlugin().type, PaymentGatewayType.dpo);
    });
  });
}
