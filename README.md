# wrteam_payment

A gateway-agnostic payment monorepo for WRTeam products. One shared
contract (`payment_core`), a plugin per gateway, and no bundled UI — host
apps build their own selection screen and own every gateway's credentials.

This package is **not published to pub.dev**. It's consumed directly by
WRTeam products via a path or git dependency.

## Why it's structured this way

- **`payment_core`** defines the contract every gateway implements:
  `PaymentGatewayType` (an open class, not a closed enum — see below),
  `PaymentRequest`, `PaymentResult`, `PaymentGatewayPlugin`,
  `PaymentRegistry`, and `PaymentOrchestrator`. It has no UI and no
  gateway-specific code.
- **Each gateway is its own package** (`payment_stripe`, `payment_razorpay`,
  `payment_phonepe`, `payment_paystack`, `payment_flutterwave`,
  `payment_paytabs`, `payment_dpo`, `payment_paypal`) depending only on
  `payment_core` (and `payment_webview_core` for the redirect-based ones).
  A host app only pulls in the SDK for a gateway it actually uses.
- **`payment_webview_core`** is shared plumbing for the five gateways that
  work via a hosted checkout page in a WebView (Paystack, Flutterwave,
  PayTabs, DPO, PayPal) rather than a native SDK (Stripe, Razorpay, PhonePe).
- **`wrteam_payment`** is a convenience umbrella that re-exports
  `payment_core` and every gateway package. Depend on it directly if you
  want everything in one import; depend on `payment_core` + specific
  gateway packages instead if you want to keep your app's footprint small
  (Dart tree-shaking removes unused code, but Flutter still bundles the
  native side of every gateway SDK your app depends on — the umbrella isn't
  free).
- **No UI, no `displayName`/`iconAsset`.** The host app owns gateway
  selection UI, labels, and icons entirely — this package only performs
  payment logic (plus the WebView checkout mechanics, which are functional,
  not presentational).

## Basic usage

```dart
import 'package:wrteam_payment/wrteam_payment.dart'; // or a specific gateway package

// Once, e.g. at app startup:
PaymentRegistry.register(StripeGatewayPlugin());
PaymentRegistry.register(RazorpayGatewayPlugin());

// Wherever you initiate a payment:
final result = await PaymentOrchestrator.pay(
  context,
  StripeRequest(
    clientSecret: clientSecretFromYourBackend,
    merchantDisplayName: 'Acme Inc',
    publishableKey: stripePublishableKey,
  ),
);

if (result.isSuccess) {
  // ...
} else if (result.isPending) {
  // Some gateways (Paystack, Flutterwave, PayTabs, DPO, PayPal) can only
  // confirm "the checkout flow completed" client-side — always verify the
  // real outcome against the gateway's server-side status/verify API
  // before fulfilling an order when result.isPending.
}
```

### Adding a gateway PaymentGatewayType has no built-in for

`PaymentGatewayType` is an open class, not a closed `enum`, specifically so
a product can register a gateway we don't ship (bank transfer, an in-house
wallet, anything custom) without needing a change to this repo:

```dart
const bankTransfer = PaymentGatewayType('bank_transfer');

class BankTransferPlugin extends PaymentGatewayPlugin<BankTransferRequest> {
  @override
  PaymentGatewayType get type => bankTransfer;

  @override
  Future<PaymentResult> processPayment(BuildContext context, BankTransferRequest request) {
    // your own flow
  }
}

PaymentRegistry.register(BankTransferPlugin());
```

It goes through the exact same `PaymentOrchestrator.pay()` path as every
built-in gateway.

## Requesting or contributing a new gateway

See [CONTRIBUTING.md](CONTRIBUTING.md).

## Packages

| Package | Depends on | Mechanism |
|---|---|---|
| `payment_core` | — | Contract, registry, orchestrator |
| `payment_webview_core` | `payment_core` | Shared WebView checkout launcher |
| `payment_stripe` | `payment_core` | Native SDK (`flutter_stripe`, PaymentSheet) |
| `payment_razorpay` | `payment_core` | Native SDK (`razorpay_flutter`) |
| `payment_phonepe` | `payment_core` | Native SDK (`phonepe_payment_sdk`) |
| `payment_paystack` | `payment_core`, `payment_webview_core` | WebView redirect |
| `payment_flutterwave` | `payment_core`, `payment_webview_core` | WebView redirect |
| `payment_paytabs` | `payment_core`, `payment_webview_core` | WebView redirect |
| `payment_dpo` | `payment_core`, `payment_webview_core` | WebView redirect |
| `payment_paypal` | `payment_core`, `payment_webview_core` | WebView redirect |
| `wrteam_payment` | all of the above | Umbrella re-export |
