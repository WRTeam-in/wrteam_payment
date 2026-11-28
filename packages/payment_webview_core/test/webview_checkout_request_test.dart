import 'package:flutter_test/flutter_test.dart';
import 'package:payment_core/payment_core.dart';
import 'package:payment_webview_core/payment_webview_core.dart';

class _FakeRequest extends WebViewCheckoutRequest {
  _FakeRequest({
    super.onReturn,
    @Deprecated('test fixture mirrors the deprecated constructor')
    super.isReturnUrl,
    @Deprecated('test fixture mirrors the deprecated constructor')
    super.returnUrlPrefix,
    @Deprecated('test fixture mirrors the deprecated constructor')
    super.matcher,
  }) : super(checkoutUrl: 'https://pay.example.com/checkout', transactionReference: 'ref_1');

  @override
  PaymentGatewayType get gatewayType => PaymentGatewayType.cashfree;
}

void main() {
  group('WebViewCheckoutRequest legacy construction', () {
    test('onReturn takes precedence when given', () {
      // ignore: deprecated_member_use_from_same_package
      final request = _FakeRequest(onReturn: (uri) => WebViewCheckoutOutcome.success);

      expect(
        request.onReturn(Uri.parse('https://anything.example.com')),
        WebViewCheckoutOutcome.success,
      );
    });

    test('deprecated isReturnUrl + matcher still compiles and resolves onReturn', () {
      // ignore: deprecated_member_use_from_same_package
      final request = _FakeRequest(
        isReturnUrl: returnUrlPrefixMatcher('https://app.example.com/return'),
        matcher: const WebViewReturnUrlMatcher(),
      );

      expect(
        request.onReturn(Uri.parse('https://app.example.com/return?status=success')),
        WebViewCheckoutOutcome.success,
      );
      expect(
        request.onReturn(Uri.parse('https://app.example.com/return?ref=abc')),
        WebViewCheckoutOutcome.failed,
      );
      expect(request.onReturn(Uri.parse('https://evil.com/return')), isNull);
    });

    test('deprecated returnUrlPrefix alone still compiles, using the default matcher', () {
      // ignore: deprecated_member_use_from_same_package
      final request = _FakeRequest(returnUrlPrefix: 'https://app.example.com/return');

      expect(
        request.onReturn(Uri.parse('https://app.example.com/return?event=cancel')),
        WebViewCheckoutOutcome.cancelled,
      );
    });
  });
}
