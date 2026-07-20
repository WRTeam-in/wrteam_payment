# Implementation Plan - Melos Setup & Refined `payment_core` Module

This updated plan introduces **`PaymentGatewayType` enum** for type-safe gateway identification and **`Theme.of(context)` integration** for seamless host app styling.

---

## Clean Interaction Flow

```
┌──────────────┐     Select Gateway      ┌───────────────────────────┐
│              ├────────────────────────>│ PaymentMethodSelectorSheet│
│              │<────────────────────────┤ (Returns `PaymentGatewayType?`)
│              │  PaymentGatewayType     └───────────────────────────┘
│              │
│   Host App   │     Make Server Call
│ (Caller UI)  ├────────────────────────> Server API / Backend Intent
│              │<──────────────────────── Returns order credentials
│              │
│              │  Build PaymentRequest
│              │  & Call Orchestrator    ┌───────────────────────────┐
│              ├────────────────────────>│    PaymentOrchestrator    │
│              │<────────────────────────┤   .pay(context, request)  │
└──────────────┘     PaymentResult       └─────────────┬─────────────┘
                                                       │ Calls internal plugin
                                                       ▼
                                         ┌───────────────────────────┐
                                         │   PaymentGatewayPlugin    │
                                         │  (Stripe, Razorpay, etc.) │
                                         └───────────────────────────┘
```

---

## Key Refinements

1. **`PaymentGatewayType` Enum**:
   - Replaces magic string identifiers with a compile-safe enum (`PaymentGatewayType.stripe`, `PaymentGatewayType.razorpay`, etc.).
   - Provides autocomplete, compile-time safety, and clean `switch` statements in host apps.
2. **Host Theme Integration (`Theme.of(context)`)**:
   - `PaymentMethodSelectorSheet` leverages host app `Theme.of(context)` (color scheme, typography, card shapes, bottom sheet background, divider colors).
   - Automatically matches light/dark modes of host apps (eClassify, etc.).
3. **Pure UI Selector Sheet**:
   - Pops/returns `Future<PaymentGatewayType?>` directly to the caller.
4. **Enforced Single Entry Point (`PaymentOrchestrator`)**:
   - Host apps execute payments exclusively via `PaymentOrchestrator.pay(context, request)`.
   - `processPayment(...)` on plugins is marked `@internal`.

---

## Detailed Model & Interface Skeletons

### 1. `PaymentGatewayType` Enum (`packages/payment_core/lib/src/models/payment_gateway_type.dart`)

```dart
enum PaymentGatewayType {
  stripe,
  razorpay,
  phonepe,
  paystack,
  flutterwave,
  paypal,
  dpo,
  bankTransfer,
  custom;

  /// String representation for logging or fallback backend matching
  String get id => name;
}
```

---

### 2. Abstract `PaymentRequest` (`packages/payment_core/lib/src/models/payment_request.dart`)

```dart
import 'payment_gateway_type.dart';

abstract class PaymentRequest {
  /// Target payment gateway type
  PaymentGatewayType get gatewayType;
}
```

---

### 3. `PaymentResult` (`packages/payment_core/lib/src/models/payment_result.dart`)

```dart
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
```

---

### 4. `PaymentGatewayPlugin` (`packages/payment_core/lib/src/contracts/payment_gateway_plugin.dart`)

```dart
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
```

---

### 5. `PaymentRegistry` (`packages/payment_core/lib/src/registry/payment_registry.dart`)

```dart
import '../contracts/payment_gateway_plugin.dart';
import '../models/payment_gateway_type.dart';

class PaymentRegistry {
  static final Map<PaymentGatewayType, PaymentGatewayPlugin> _plugins = {};

  static void register(PaymentGatewayPlugin plugin) {
    _plugins[plugin.type] = plugin;
  }

  static void unregister(PaymentGatewayType type) {
    _plugins.remove(type);
  }

  static PaymentGatewayPlugin? getPlugin(PaymentGatewayType type) {
    return _plugins[type];
  }

  static List<PaymentGatewayPlugin> get registeredPlugins => _plugins.values.toList();

  static void clear() {
    _plugins.clear();
  }
}
```

---

### 6. `PaymentOrchestrator` (`packages/payment_core/lib/src/orchestrator/payment_orchestrator.dart`)

```dart
import 'package:flutter/widgets.dart';
import '../contracts/payment_gateway_plugin.dart';
import '../models/payment_request.dart';
import '../models/payment_result.dart';
import '../registry/payment_registry.dart';

class PaymentOrchestrator {
  PaymentOrchestrator._();

  static Future<PaymentResult> pay(BuildContext context, PaymentRequest request) async {
    final plugin = PaymentRegistry.getPlugin(request.gatewayType);
    if (plugin == null) {
      return PaymentResult.failed(
        message: 'No registered plugin found for gateway "${request.gatewayType.name}".',
        errorCode: 'PLUGIN_NOT_FOUND',
      );
    }

    try {
      return await plugin.processPayment(context, request);
    } catch (e, stackTrace) {
      return PaymentResult.failed(
        message: 'An unexpected error occurred during payment execution: $e',
        errorCode: 'UNHANDLED_EXCEPTION',
        rawResponse: {'error': e.toString(), 'stackTrace': stackTrace.toString()},
      );
    }
  }
}
```

---

### 7. Theme-Aware UI Selector Sheet (`packages/payment_core/lib/src/ui/payment_method_selector_sheet.dart`)

```dart
import 'package:flutter/material.dart';
import '../contracts/payment_gateway_plugin.dart';
import '../models/payment_gateway_type.dart';

class PaymentMethodSelectorSheet extends StatelessWidget {
  final List<PaymentGatewayPlugin> plugins;
  final String title;

  const PaymentMethodSelectorSheet({
    super.key,
    required this.plugins,
    this.title = 'Select Payment Method',
  });

  /// Helper static method to show sheet and await selected PaymentGatewayType
  static Future<PaymentGatewayType?> show(
    BuildContext context, {
    required List<PaymentGatewayPlugin> plugins,
    String? title,
  }) {
    return showModalBottomSheet<PaymentGatewayType>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      shape: Theme.of(context).bottomSheetTheme.shape ?? const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => PaymentMethodSelectorSheet(
        plugins: plugins,
        title: title ?? 'Select Payment Method',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: plugins.length,
                itemBuilder: (context, index) {
                  final plugin = plugins[index];
                  return ListTile(
                    leading: Image.asset(
                      plugin.iconAsset,
                      width: 32,
                      height: 32,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.payment,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    title: Text(
                      plugin.displayName,
                      style: theme.textTheme.bodyLarge,
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    onTap: () {
                      Navigator.of(context).pop(plugin.type);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### 8. Example Host App Usage

```dart
// Step 1: Show theme-aware selector sheet -> get selected PaymentGatewayType
final PaymentGatewayType? selectedType = await PaymentMethodSelectorSheet.show(
  context,
  plugins: PaymentRegistry.registeredPlugins,
);

if (selectedType == null) return; // Dismissed

// Step 2: Make server call based on enum & build typed request
switch (selectedType) {
  case PaymentGatewayType.stripe:
    final intent = await api.createStripeIntent();
    final request = StripePaymentRequest(clientSecret: intent['secret']);
    final result = await PaymentOrchestrator.pay(context, request);
    break;

  case PaymentGatewayType.razorpay:
    final order = await api.createRazorpayOrder();
    final request = RazorpayPaymentRequest(orderId: order['id']);
    final result = await PaymentOrchestrator.pay(context, request);
    break;

  default:
    break;
}
```

---

## Proposed File Changes

### Root Workspace Files
- [NEW] [melos.yaml](file:///Users/ishit/Desktop/projects/wrteam_payment/melos.yaml)
- [MODIFY] [pubspec.yaml](file:///Users/ishit/Desktop/projects/wrteam_payment/pubspec.yaml)

### Package: `payment_core`
- [NEW] [packages/payment_core/pubspec.yaml](file:///Users/ishit/Desktop/projects/wrteam_payment/packages/payment_core/pubspec.yaml)
- [NEW] [packages/payment_core/lib/payment_core.dart](file:///Users/ishit/Desktop/projects/wrteam_payment/packages/payment_core/lib/payment_core.dart)
- [NEW] [packages/payment_core/lib/src/models/payment_gateway_type.dart](file:///Users/ishit/Desktop/projects/wrteam_payment/packages/payment_core/lib/src/models/payment_gateway_type.dart)
- [NEW] [packages/payment_core/lib/src/models/payment_status.dart](file:///Users/ishit/Desktop/projects/wrteam_payment/packages/payment_core/lib/src/models/payment_status.dart)
- [NEW] [packages/payment_core/lib/src/models/payment_result.dart](file:///Users/ishit/Desktop/projects/wrteam_payment/packages/payment_core/lib/src/models/payment_result.dart)
- [NEW] [packages/payment_core/lib/src/models/payment_request.dart](file:///Users/ishit/Desktop/projects/wrteam_payment/packages/payment_core/lib/src/models/payment_request.dart)
- [NEW] [packages/payment_core/lib/src/contracts/payment_gateway_plugin.dart](file:///Users/ishit/Desktop/projects/wrteam_payment/packages/payment_core/lib/src/contracts/payment_gateway_plugin.dart)
- [NEW] [packages/payment_core/lib/src/registry/payment_registry.dart](file:///Users/ishit/Desktop/projects/wrteam_payment/packages/payment_core/lib/src/registry/payment_registry.dart)
- [NEW] [packages/payment_core/lib/src/orchestrator/payment_orchestrator.dart](file:///Users/ishit/Desktop/projects/wrteam_payment/packages/payment_core/lib/src/orchestrator/payment_orchestrator.dart)
- [NEW] [packages/payment_core/lib/src/ui/payment_method_selector_sheet.dart](file:///Users/ishit/Desktop/projects/wrteam_payment/packages/payment_core/lib/src/ui/payment_method_selector_sheet.dart)
- [NEW] [packages/payment_core/test/payment_core_test.dart](file:///Users/ishit/Desktop/projects/wrteam_payment/packages/payment_core/test/payment_core_test.dart)

---

## Verification Plan

### Automated Tests
- Unit tests for `PaymentRegistry` (registering, looking up by enum, clearing).
- Unit tests for `PaymentOrchestrator` (successful payment routing, missing plugin error handling, exception safety).
- Run `flutter test` within `packages/payment_core` and `melos bootstrap`.

### Manual Verification
- Code analysis (`flutter analyze`) to ensure zero warnings or errors.
