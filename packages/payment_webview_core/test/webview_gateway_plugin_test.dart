import 'package:flutter_test/flutter_test.dart';
import 'package:payment_webview_core/payment_webview_core.dart';

void main() {
  group('WebViewGatewayPlugin.resultFrom', () {
    test('picks up a known reference query param and keeps the outcome', () {
      final result = WebViewGatewayPlugin.resultFrom(
        Uri.parse('https://app.example.com/return?order_id=ORDER123'),
        WebViewCheckoutOutcome.pending,
        'fallback_ref',
      );

      expect(result.isPending, isTrue);
      expect(result.transactionId, 'ORDER123');
    });

    test('tries reference params in priority order', () {
      final result = WebViewGatewayPlugin.resultFrom(
        Uri.parse('https://app.example.com/return?reference=REF1&trxref=REF2'),
        WebViewCheckoutOutcome.success,
        'fallback_ref',
      );

      expect(result.transactionId, 'REF1');
    });

    test('falls back to the request transactionReference when no known param is present', () {
      final result = WebViewGatewayPlugin.resultFrom(
        Uri.parse('https://app.example.com/return?foo=bar'),
        WebViewCheckoutOutcome.failed,
        'fallback_ref',
      );

      expect(result.isFailed, isTrue);
    });

    test('maps every outcome through WebViewCheckoutOutcomeMapping', () {
      final cancelled = WebViewGatewayPlugin.resultFrom(
        Uri.parse('https://app.example.com/return'),
        WebViewCheckoutOutcome.cancelled,
        'fallback_ref',
      );
      expect(cancelled.isCancelled, isTrue);

      final success = WebViewGatewayPlugin.resultFrom(
        Uri.parse('https://app.example.com/return?token=tok_1'),
        WebViewCheckoutOutcome.success,
        'fallback_ref',
      );
      expect(success.isSuccess, isTrue);
      expect(success.transactionId, 'tok_1');
    });
  });
}
