import 'package:flutter_test/flutter_test.dart';
import 'package:payment_core/payment_core.dart';
import 'package:payment_stripe/payment_stripe.dart';

void main() {
  group('StripeRequest', () {
    test('gatewayType is stripe and fields round-trip', () {
      final request = StripeRequest(
        clientSecret: 'pi_123_secret_abc',
        merchantDisplayName: 'Acme Inc',
        publishableKey: 'pk_test_123',
        merchantIdentifier: 'merchant.com.acme',
      );

      expect(request.gatewayType, PaymentGatewayType.stripe);
      expect(request.clientSecret, 'pi_123_secret_abc');
      expect(request.merchantDisplayName, 'Acme Inc');
      expect(request.publishableKey, 'pk_test_123');
      expect(request.merchantIdentifier, 'merchant.com.acme');
    });

    test('merchantIdentifier is optional', () {
      final request = StripeRequest(
        clientSecret: 'pi_123_secret_abc',
        merchantDisplayName: 'Acme Inc',
        publishableKey: 'pk_test_123',
      );

      expect(request.merchantIdentifier, isNull);
    });
  });

  group('StripeGatewayPlugin', () {
    test('type is stripe', () {
      expect(StripeGatewayPlugin().type, PaymentGatewayType.stripe);
    });

    test('displayName defaults to Stripe and can be overridden', () {
      expect(StripeGatewayPlugin().displayName, 'Stripe');
      expect(StripeGatewayPlugin(displayName: 'Card').displayName, 'Card');
    });

    test('iconAsset defaults to null and can be overridden', () {
      expect(StripeGatewayPlugin().iconAsset, isNull);
      expect(
        StripeGatewayPlugin(iconAsset: 'assets/stripe.png').iconAsset,
        'assets/stripe.png',
      );
    });

    group('paymentIntentIdFrom', () {
      test('extracts the id preceding _secret_', () {
        expect(
          StripeGatewayPlugin.paymentIntentIdFrom('pi_3P9x_secret_gH7k'),
          'pi_3P9x',
        );
      });

      test('returns the input unchanged if _secret_ is absent', () {
        expect(
          StripeGatewayPlugin.paymentIntentIdFrom('not_a_client_secret'),
          'not_a_client_secret',
        );
      });
    });
  });
}
