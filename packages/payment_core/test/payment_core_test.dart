import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:payment_core/payment_core.dart';

class _FakeRequest extends PaymentRequest {
  @override
  PaymentGatewayType get gatewayType => PaymentGatewayType.custom;
}

class _FakePlugin extends PaymentGatewayPlugin<_FakeRequest> {
  _FakePlugin({this.shouldThrow = false});

  final bool shouldThrow;

  @override
  PaymentGatewayType get type => PaymentGatewayType.custom;

  @override
  String get displayName => 'Fake Gateway';

  @override
  String get iconAsset => 'assets/fake.png';

  @override
  Future<PaymentResult> processPayment(BuildContext context, _FakeRequest request) async {
    if (shouldThrow) {
      throw Exception('boom');
    }
    return PaymentResult.success(transactionId: 'txn_123');
  }
}

void main() {
  tearDown(PaymentRegistry.clear);

  group('PaymentRegistry', () {
    test('registers and looks up a plugin by type', () {
      final plugin = _FakePlugin();

      PaymentRegistry.register(plugin);

      expect(PaymentRegistry.getPlugin(PaymentGatewayType.custom), same(plugin));
      expect(PaymentRegistry.registeredPlugins, contains(plugin));
    });

    test('unregisters a plugin by type', () {
      PaymentRegistry.register(_FakePlugin());

      PaymentRegistry.unregister(PaymentGatewayType.custom);

      expect(PaymentRegistry.getPlugin(PaymentGatewayType.custom), isNull);
    });

    test('clears all registered plugins', () {
      PaymentRegistry.register(_FakePlugin());

      PaymentRegistry.clear();

      expect(PaymentRegistry.registeredPlugins, isEmpty);
    });
  });

  group('PaymentOrchestrator', () {
    testWidgets('routes a successful payment to the registered plugin', (tester) async {
      PaymentRegistry.register(_FakePlugin());
      late PaymentResult result;

      await tester.pumpWidget(
        Builder(
          builder: (context) {
            PaymentOrchestrator.pay(context, _FakeRequest()).then((r) => result = r);
            return const SizedBox.shrink();
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(result.isSuccess, isTrue);
      expect(result.transactionId, 'txn_123');
    });

    testWidgets('returns PLUGIN_NOT_FOUND when no plugin is registered', (tester) async {
      late PaymentResult result;

      await tester.pumpWidget(
        Builder(
          builder: (context) {
            PaymentOrchestrator.pay(context, _FakeRequest()).then((r) => result = r);
            return const SizedBox.shrink();
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(result.isFailed, isTrue);
      expect(result.errorCode, 'PLUGIN_NOT_FOUND');
    });

    testWidgets('catches exceptions from a plugin and returns UNHANDLED_EXCEPTION', (tester) async {
      PaymentRegistry.register(_FakePlugin(shouldThrow: true));
      late PaymentResult result;

      await tester.pumpWidget(
        Builder(
          builder: (context) {
            PaymentOrchestrator.pay(context, _FakeRequest()).then((r) => result = r);
            return const SizedBox.shrink();
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(result.isFailed, isTrue);
      expect(result.errorCode, 'UNHANDLED_EXCEPTION');
    });
  });
}
