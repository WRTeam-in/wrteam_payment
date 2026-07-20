import 'package:flutter_test/flutter_test.dart';
import 'package:payment_core/payment_core.dart';
import 'package:payment_phonepe/payment_phonepe.dart';

void main() {
  group('PhonePeRequest', () {
    test('gatewayType is phonepe and fields round-trip', () {
      final request = PhonePeRequest(
        base64Payload: 'eyJmb28iOiJiYXIifQ==',
        merchantId: 'MERCHANTUAT',
        merchantTransactionId: 'txn_123',
        environment: 'SANDBOX',
        flowId: 'user_42',
        appSchema: 'myapp://',
        enableLogging: true,
      );

      expect(request.gatewayType, PaymentGatewayType.phonepe);
      expect(request.base64Payload, 'eyJmb28iOiJiYXIifQ==');
      expect(request.merchantId, 'MERCHANTUAT');
      expect(request.merchantTransactionId, 'txn_123');
      expect(request.environment, 'SANDBOX');
      expect(request.flowId, 'user_42');
      expect(request.appSchema, 'myapp://');
      expect(request.enableLogging, isTrue);
    });

    test('appSchema is optional and enableLogging defaults to false', () {
      final request = PhonePeRequest(
        base64Payload: 'eyJmb28iOiJiYXIifQ==',
        merchantId: 'MERCHANTUAT',
        merchantTransactionId: 'txn_123',
        environment: 'PRODUCTION',
        flowId: 'user_42',
      );

      expect(request.appSchema, isNull);
      expect(request.enableLogging, isFalse);
    });
  });

  group('PhonePeGatewayPlugin', () {
    test('type is phonepe', () {
      expect(PhonePeGatewayPlugin().type, PaymentGatewayType.phonepe);
    });

    test('displayName defaults to PhonePe and can be overridden', () {
      expect(PhonePeGatewayPlugin().displayName, 'PhonePe');
      expect(PhonePeGatewayPlugin(displayName: 'UPI').displayName, 'UPI');
    });

    test('iconAsset defaults to null and can be overridden', () {
      expect(PhonePeGatewayPlugin().iconAsset, isNull);
      expect(
        PhonePeGatewayPlugin(iconAsset: 'assets/phonepe.png').iconAsset,
        'assets/phonepe.png',
      );
    });

    group('resultFrom', () {
      test('null response is a failed NO_RESPONSE result', () {
        final result = PhonePeGatewayPlugin.resultFrom(
          null,
          merchantTransactionId: 'txn_123',
        );

        expect(result.isFailed, isTrue);
        expect(result.errorCode, 'NO_RESPONSE');
      });

      test('SUCCESS status maps to a success result carrying the merchant transaction id', () {
        final result = PhonePeGatewayPlugin.resultFrom(
          {'status': 'SUCCESS'},
          merchantTransactionId: 'txn_123',
        );

        expect(result.isSuccess, isTrue);
        expect(result.transactionId, 'txn_123');
        expect(result.rawResponse, {'status': 'SUCCESS'});
      });

      test('INTERRUPTED status maps to a cancelled result', () {
        final result = PhonePeGatewayPlugin.resultFrom(
          {'status': 'INTERRUPTED', 'error': 'User backed out'},
          merchantTransactionId: 'txn_123',
        );

        expect(result.isCancelled, isTrue);
        expect(result.message, 'User backed out');
      });

      test('FAILURE status maps to a failed result', () {
        final result = PhonePeGatewayPlugin.resultFrom(
          {'status': 'FAILURE', 'error': 'Insufficient funds'},
          merchantTransactionId: 'txn_123',
        );

        expect(result.isFailed, isTrue);
        expect(result.errorCode, 'FAILURE');
        expect(result.message, 'Insufficient funds');
      });

      test('unrecognized status maps to a failed UNKNOWN_STATUS result', () {
        final result = PhonePeGatewayPlugin.resultFrom(
          {'status': 'SOMETHING_ELSE'},
          merchantTransactionId: 'txn_123',
        );

        expect(result.isFailed, isTrue);
        expect(result.errorCode, 'UNKNOWN_STATUS');
      });
    });
  });
}
