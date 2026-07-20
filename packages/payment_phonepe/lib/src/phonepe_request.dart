import 'package:payment_core/payment_core.dart';

class PhonePeRequest extends PaymentRequest {
  PhonePeRequest({
    required this.base64Payload,
    required this.merchantId,
    required this.merchantTransactionId,
    required this.environment,
    required this.flowId,
    this.appSchema,
    this.enableLogging = false,
  });

  /// Base64-encoded, checksum-signed request payload built by the host app's
  /// backend per PhonePe's integration docs. Never build this on the client
  /// — it requires the merchant salt key.
  final String base64Payload;

  /// Merchant id provided by PhonePe at onboarding.
  final String merchantId;

  /// The merchantTransactionId used to build [base64Payload]. Returned as
  /// the [PaymentResult.transactionId] on success, and required to confirm
  /// the final status with PhonePe's server-side status-check API — the
  /// SDK's own response isn't a reliable source of truth on its own.
  final String merchantTransactionId;

  /// `'SANDBOX'` or `'PRODUCTION'`.
  final String environment;

  /// Alphanumeric id correlating this app's user journey with PhonePe's SDK
  /// logs (e.g. a user id).
  final String flowId;

  /// iOS custom URL scheme for returning to the app; ignored on Android.
  final String? appSchema;

  final bool enableLogging;

  @override
  PaymentGatewayType get gatewayType => PaymentGatewayType.phonepe;
}
