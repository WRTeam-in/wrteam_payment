import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:payment_core/payment_core.dart';
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';

import 'phonepe_request.dart';

class PhonePeGatewayPlugin extends PaymentGatewayPlugin<PhonePeRequest> {
  @override
  PaymentGatewayType get type => PaymentGatewayType.phonepe;

  @override
  @internal
  Future<PaymentResult> processPayment(
    BuildContext context,
    PhonePeRequest request,
  ) async {
    final initialized = await PhonePePaymentSdk.init(
      request.environment,
      request.merchantId,
      request.flowId,
      request.enableLogging,
    );

    if (!initialized) {
      return PaymentResult.failed(
        message: 'Failed to initialize the PhonePe SDK.',
        errorCode: 'INIT_FAILED',
      );
    }

    final response = await PhonePePaymentSdk.startTransaction(
      request.base64Payload,
      request.appSchema ?? '',
    );

    return resultFrom(response, merchantTransactionId: request.merchantTransactionId);
  }

  /// Maps the PhonePe SDK's `{status, error}` response to a [PaymentResult].
  /// A `SUCCESS` status still needs confirming against PhonePe's server-side
  /// status-check API before fulfilling an order — the SDK response alone
  /// isn't authoritative (e.g. the app can be killed after payment but
  /// before the callback is delivered).
  @visibleForTesting
  static PaymentResult resultFrom(
    Map<dynamic, dynamic>? response, {
    required String merchantTransactionId,
  }) {
    if (response == null) {
      return PaymentResult.failed(
        message: 'No response received from the PhonePe SDK.',
        errorCode: 'NO_RESPONSE',
      );
    }

    final rawResponse = Map<String, dynamic>.from(response);
    final error = rawResponse['error'] as String?;

    switch (rawResponse['status']) {
      case 'SUCCESS':
        return PaymentResult.success(
          transactionId: merchantTransactionId,
          message:
              "Verify the final status with PhonePe's server-side status API "
              'before fulfilling the order.',
          rawResponse: rawResponse,
        );
      case 'INTERRUPTED':
        return PaymentResult.cancelled(
          message: error ?? 'Payment was interrupted.',
        );
      case 'FAILURE':
        return PaymentResult.failed(
          message: error ?? 'PhonePe payment failed.',
          errorCode: 'FAILURE',
          rawResponse: rawResponse,
        );
      default:
        return PaymentResult.failed(
          message: 'Unrecognized PhonePe status: ${rawResponse['status']}',
          errorCode: 'UNKNOWN_STATUS',
          rawResponse: rawResponse,
        );
    }
  }
}
