# Contributing

## Need a payment gateway that isn't here?

Pick whichever is easiest for you:

1. **Open a GitHub issue** requesting it — describe the gateway and which
   product needs it.
2. **Reach out directly** — Slack or email
   ([wrteam.ishittanna@gmail.com](mailto:wrteam.ishittanna@gmail.com)).
3. **Add it yourself** — see below. Once your PR is filed, feel free to
   also ping directly so it doesn't sit unnoticed.

## Adding a new gateway package

Every gateway is its own package under `packages/`, following the same
shape regardless of whether it wraps a native SDK or a hosted checkout
page. Look at an existing package before starting — don't design from
scratch:

- **Native SDK gateway** (e.g. a gateway with its own Flutter plugin):
  follow `packages/payment_stripe` or `packages/payment_razorpay`.
- **Redirect / hosted checkout page gateway** (the merchant's backend gets
  a checkout URL from the gateway's API, the app loads it in a WebView,
  the gateway redirects back when done): follow `packages/payment_paystack`
  and depend on `packages/payment_webview_core` rather than reimplementing
  the WebView flow. Check the gateway's actual redirect contract (does it
  give you a status in the query string, or only a reference you must
  verify server-side?) before deciding how `mapResult` should behave —
  don't assume a `success` status in a client-side redirect is trustworthy
  without checking the gateway's own docs.

### Steps

1. Clone the repo (forking is disabled — branch directly in this repo) and
   create a branch off `master`:
   - `feature/<payment-gateway>` for a new gateway, e.g. `feature/adyen`.
   - `bugfix/<bug>` for a fix, e.g. `bugfix/paystack-missing-reference`.

   Then create `packages/payment_<gateway>/` with its own `pubspec.yaml`
   (`publish_to: 'none'`, `resolution: workspace`, a path dependency on
   `payment_core` and, if redirect-based, `payment_webview_core`),
   `analysis_options.yaml` (`include: package:flutter_lints/flutter.yaml`),
   `lib/`, and `test/`.
2. Add the new package to the `workspace:` list in the root `pubspec.yaml`
   and to `melos.yaml` if it isn't already covered by the glob.
3. Implement `<Gateway>Request extends PaymentRequest` (or
   `WebViewCheckoutRequest` for redirect gateways) and
   `<Gateway>GatewayPlugin extends PaymentGatewayPlugin<T>` (or
   `WebViewGatewayPlugin<T>`).
   - Never build gateway credentials/checksums that require a secret key
     on the client. The request should carry whatever the host app's
     backend already produced (a client secret, a checkout URL, a signed
     payload); this package never talks to a gateway's secret-key API
     directly.
   - No `displayName`/`iconAsset` on the plugin — the package doesn't own
     any UI. Don't reintroduce it.
   - Keep response-mapping logic (redirect query params, SDK callback
     payloads) in a small `@visibleForTesting static` pure function the
     plugin delegates to, so it's unit-testable without touching a real
     SDK or WebView platform channel.
4. Write tests covering the request model and the response-mapping
   function. `melos test` and `melos analyze` must both be clean across the
   whole workspace — zero analyzer issues, not just "no errors."
5. Add the package to `wrteam_payment`'s dependencies and
   `lib/wrteam_payment.dart` exports if it should be included in the
   umbrella (it should be, unless there's a specific reason not to).
6. Update `README.md`'s package table.
7. Commit to your `feature/<payment-gateway>` or `bugfix/<bug>` branch and
   open a PR against `master`.

### Verification before opening a PR

This is a [Melos](https://melos.invertase.dev) workspace. Activate it once
(`dart pub global activate melos`), then from the repo root:

```
flutter pub get
melos analyze   # analyzes every package, must report "No issues found"
melos test      # runs flutter test in every package with a test/ directory
```

Both run across the whole workspace in one shot — no need to `cd` into
each package. If you'd rather check a single package while iterating, plain
`flutter analyze` / `flutter test` from inside that package's directory
still works.

## Pull requests

PRs are reviewed strictly — this is deliberate, to catch misuse (secrets
handled client-side, unverified "success" states, scope creep into UI,
etc.) before it ships. A PR needs approval from a maintainer or team lead
before merging. If your PR is sitting without a review, contact us
directly (Slack or email) rather than waiting indefinitely.
