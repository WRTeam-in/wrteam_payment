import 'package:flutter_test/flutter_test.dart';
import 'package:payment_core/payment_core.dart';
import 'package:payment_payu/payment_payu.dart';
import 'package:payment_webview_core/payment_webview_core.dart';

PayURequest _request({WebViewCheckoutOutcome? Function(Uri uri)? onReturn}) {
  return PayURequest(
    checkoutUrl: 'https://secure.payu.in/_payment',
    onReturn:
        onReturn ??
        (uri) => uri.toString().startsWith('https://app.example.com/return')
            ? WebViewCheckoutOutcome.pending
            : null,
    transactionReference: 'txn_ref_123',
  );
}

void main() {
  group('PayURequest', () {
    test('gatewayType is payu and fields round-trip', () {
      final request = _request();

      expect(request.gatewayType, PaymentGatewayType.payu);
      expect(request.checkoutUrl, 'https://secure.payu.in/_payment');
      expect(request.transactionReference, 'txn_ref_123');
      expect(
        request.onReturn(Uri.parse('https://app.example.com/return')),
        WebViewCheckoutOutcome.pending,
      );
      expect(request.onReturn(Uri.parse('https://evil.com/return')), isNull);
    });

    test(
      'deprecated returnUrlPrefix: status=userCancelled trusted directly, else transaction id yields pending',
      () {
        // ignore: deprecated_member_use
        final request = PayURequest(
          checkoutUrl: 'https://secure.payu.in/_payment',
          returnUrlPrefix: 'https://app.example.com/return',
          transactionReference: 'txn_ref_123',
        );

        expect(
          request.onReturn(
            Uri.parse('https://app.example.com/return?status=userCancelled&txnid=TXN1'),
          ),
          WebViewCheckoutOutcome.cancelled,
        );
        expect(
          request.onReturn(
            Uri.parse('https://app.example.com/return?status=failure&txnid=TXN2'),
          ),
          WebViewCheckoutOutcome.pending,
        );
        expect(
          request.onReturn(Uri.parse('https://app.example.com/return?event=cancel')),
          WebViewCheckoutOutcome.cancelled,
        );
      },
    );
  });

  group('PayUGatewayPlugin', () {
    test('type is payu', () {
      expect(PayUGatewayPlugin().type, PaymentGatewayType.payu);
    });
  });
}
