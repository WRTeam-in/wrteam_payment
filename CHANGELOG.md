## 0.1.0

Initial working monorepo.

- Added `payment_core`: `PaymentGatewayType`, `PaymentRequest`,
  `PaymentResult`, `PaymentGatewayPlugin`, `PaymentRegistry`,
  `PaymentOrchestrator`. Headless — no UI, no `displayName`/`iconAsset`.
  `PaymentGatewayType` is an open class rather than a closed enum, so host
  apps can register gateways this repo doesn't ship.
- Added native-SDK gateway packages: `payment_stripe` (PaymentSheet),
  `payment_razorpay`, `payment_phonepe`.
- Added `payment_webview_core`: a shared WebView checkout launcher and
  `WebViewGatewayPlugin` base for redirect-based gateways.
- Added redirect-based gateway packages built on `payment_webview_core`:
  `payment_paystack`, `payment_flutterwave`, `payment_paytabs`,
  `payment_dpo`, `payment_paypal`.
- Added `wrteam_payment` as a convenience umbrella re-exporting
  `payment_core` and every gateway package.
- Migrated the workspace to Dart pub workspaces + Melos.
