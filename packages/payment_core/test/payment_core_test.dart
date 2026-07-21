import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:payment_core/payment_core.dart';

/// Demonstrates a host app minting its own gateway type, since
/// PaymentGatewayType is open rather than a closed enum.
const _fakeGatewayType = PaymentGatewayType('fake');

class _FakeRequest extends PaymentRequest {
  @override
  PaymentGatewayType get gatewayType => _fakeGatewayType;
}

class _FakePlugin extends PaymentGatewayPlugin<_FakeRequest> {
  _FakePlugin({this.shouldThrow = false, this.type = _fakeGatewayType});

  final bool shouldThrow;

  @override
  final PaymentGatewayType type;

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

  group('PaymentGatewayType', () {
    test('two instances with the same id are equal and share a hash code', () {
      const a = PaymentGatewayType('bank_transfer');
      const b = PaymentGatewayType('bank_transfer');

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('instances with different ids are not equal', () {
      expect(const PaymentGatewayType('a') == const PaymentGatewayType('b'), isFalse);
    });

    test('a host app can register a gateway PaymentGatewayType has no built-in for', () {
      const bankTransfer = PaymentGatewayType('bank_transfer');
      final defaultPlugin = _FakePlugin();
      final bankTransferPlugin = _FakePlugin(type: bankTransfer);

      // Registering under a distinct, non-built-in id doesn't collide with
      // any other registration, unlike a shared PaymentGatewayType.custom.
      PaymentRegistry.register(defaultPlugin);
      PaymentRegistry.register(bankTransferPlugin);

      expect(PaymentRegistry.getPlugin(_fakeGatewayType), same(defaultPlugin));
      expect(PaymentRegistry.getPlugin(bankTransfer), same(bankTransferPlugin));
    });
  });

  group('PaymentRegistry', () {
    test('registers and looks up a plugin by type', () {
      final plugin = _FakePlugin();

      PaymentRegistry.register(plugin);

      expect(PaymentRegistry.getPlugin(_fakeGatewayType), same(plugin));
      expect(PaymentRegistry.registeredPlugins, contains(plugin));
    });

    test('unregisters a plugin by type', () {
      PaymentRegistry.register(_FakePlugin());

      PaymentRegistry.unregister(_fakeGatewayType);

      expect(PaymentRegistry.getPlugin(_fakeGatewayType), isNull);
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
