import 'package:flutter_test/flutter_test.dart';
import 'package:wrteam_payment/wrteam_payment.dart';

void main() {
  test('re-exports payment_core public API', () {
    expect(PaymentGatewayType.stripe.id, 'stripe');

    final result = PaymentResult.success(transactionId: 'txn_1');
    expect(result.isSuccess, isTrue);

    expect(PaymentRegistry.registeredPlugins, isEmpty);
  });
}
