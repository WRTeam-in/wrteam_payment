import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import '../models/payment_gateway_type.dart';
import '../models/payment_request.dart';
import '../models/payment_result.dart';

abstract class PaymentGatewayPlugin<T extends PaymentRequest> {
  /// Gateway enum type
  PaymentGatewayType get type;

  /// Human-readable display name
  String get displayName;

  /// Asset path or URL for icon/logo
  String get iconAsset;

  /// Internal payment execution method.
  /// Marked `@internal` so callers execute via `PaymentOrchestrator.pay()`.
  @internal
  Future<PaymentResult> processPayment(BuildContext context, T request);
}
