import 'package:flutter/material.dart';

import 'webview_checkout_outcome.dart';
import 'webview_checkout_page.dart';

/// Launches the checkout WebView and resolves with the `(uri, outcome)`
/// pair once [onReturn] returns non-null for a navigated URL, or null if
/// the user backs out without completing the flow.
class WebViewCheckoutLauncher {
  const WebViewCheckoutLauncher._();

  static Future<(Uri, WebViewCheckoutOutcome)?> open(
    BuildContext context, {
    required String checkoutUrl,
    required WebViewCheckoutOutcome? Function(Uri uri) onReturn,
    String title = 'Complete Payment',
  }) {
    return Navigator.of(context, rootNavigator: true).push<(Uri, WebViewCheckoutOutcome)>(
      MaterialPageRoute(
        builder: (_) => WebViewCheckoutPage(
          checkoutUrl: checkoutUrl,
          onReturn: onReturn,
          title: title,
        ),
      ),
    );
  }
}
