import 'payment_status.dart';

class PaymentResult {
  final PaymentStatus status;
  final String? transactionId;
  final String? message;
  final String? errorCode;
  final Map<String, dynamic>? rawResponse;

  const PaymentResult({
    required this.status,
    this.transactionId,
    this.message,
    this.errorCode,
    this.rawResponse,
  });

  factory PaymentResult.success({
    required String transactionId,
    String? message,
    Map<String, dynamic>? rawResponse,
  }) {
    return PaymentResult(
      status: PaymentStatus.success,
      transactionId: transactionId,
      message: message,
      rawResponse: rawResponse,
    );
  }

  factory PaymentResult.cancelled({String? message}) {
    return PaymentResult(
      status: PaymentStatus.cancelled,
      message: message ?? 'Payment was cancelled by the user.',
    );
  }

  factory PaymentResult.failed({
    required String message,
    String? errorCode,
    Map<String, dynamic>? rawResponse,
  }) {
    return PaymentResult(
      status: PaymentStatus.failed,
      message: message,
      errorCode: errorCode,
      rawResponse: rawResponse,
    );
  }

  factory PaymentResult.pending({
    String? transactionId,
    String? message,
  }) {
    return PaymentResult(
      status: PaymentStatus.pending,
      transactionId: transactionId,
      message: message ?? 'Payment is pending verification.',
    );
  }

  bool get isSuccess => status == PaymentStatus.success;
  bool get isCancelled => status == PaymentStatus.cancelled;
  bool get isFailed => status == PaymentStatus.failed;
  bool get isPending => status == PaymentStatus.pending;
}
