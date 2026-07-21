import 'package:flutter_test/flutter_test.dart';
import 'package:wrteam_payment/wrteam_payment.dart';

void main() {
  test('re-exports payment_core public API', () {
    expect(PaymentGatewayType.stripe.id, 'stripe');

    final result = PaymentResult.success(transactionId: 'txn_1');
    expect(result.isSuccess, isTrue);

    expect(PaymentRegistry.registeredPlugins, isEmpty);
  });

  test('re-exports every gateway package', () {
    expect(StripeGatewayPlugin().type, PaymentGatewayType.stripe);
    expect(RazorpayGatewayPlugin().type, PaymentGatewayType.razorpay);
    expect(PhonePeGatewayPlugin().type, PaymentGatewayType.phonepe);
    expect(PaystackGatewayPlugin().type, PaymentGatewayType.paystack);
    expect(FlutterwaveGatewayPlugin().type, PaymentGatewayType.flutterwave);
    expect(PayTabsGatewayPlugin().type, PaymentGatewayType.paytabs);
    expect(DpoGatewayPlugin().type, PaymentGatewayType.dpo);
    expect(PayPalGatewayPlugin().type, PaymentGatewayType.paypal);
  });

  test('re-exports payment_webview_core', () {
    expect(const WebViewReturnUrlMatcher()(Uri.parse('https://a.com/success')),
        WebViewCheckoutOutcome.success);
  });
}
