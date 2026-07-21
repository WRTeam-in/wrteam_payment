import 'package:flutter_test/flutter_test.dart';
import 'package:payment_webview_core/payment_webview_core.dart';

void main() {
  group('WebViewReturnUrlMatcher', () {
    const matcher = WebViewReturnUrlMatcher();

    test('matches success keywords', () {
      expect(
        matcher(Uri.parse('https://app.example.com/return?status=success')),
        WebViewCheckoutOutcome.success,
      );
      expect(
        matcher(Uri.parse('https://app.example.com/payment-complete')),
        WebViewCheckoutOutcome.success,
      );
    });

    test('matches cancel keywords', () {
      expect(
        matcher(Uri.parse('https://app.example.com/return?event=cancel')),
        WebViewCheckoutOutcome.cancelled,
      );
    });

    test('matches failure keywords', () {
      expect(
        matcher(Uri.parse('https://app.example.com/return?status=failed')),
        WebViewCheckoutOutcome.failed,
      );
      expect(
        matcher(Uri.parse('https://app.example.com/return?status=declined')),
        WebViewCheckoutOutcome.failed,
      );
    });

    test('failure takes priority when multiple keywords are present', () {
      expect(
        matcher(Uri.parse('https://app.example.com/return?status=success-failed')),
        WebViewCheckoutOutcome.failed,
      );
    });

    test('returns null when nothing matches', () {
      expect(
        matcher(Uri.parse('https://app.example.com/return?ref=abc123')),
        isNull,
      );
    });

    test('patterns are overridable', () {
      const custom = WebViewReturnUrlMatcher(
        successPatterns: ['ok'],
        cancelPatterns: ['abort'],
        failurePatterns: ['nope'],
      );

      expect(
        custom(Uri.parse('https://app.example.com/return?r=ok')),
        WebViewCheckoutOutcome.success,
      );
      expect(
        custom(Uri.parse('https://app.example.com/return?status=success')),
        isNull,
      );
    });
  });
}
