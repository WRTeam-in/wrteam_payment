import 'package:flutter/material.dart';

import 'webview_checkout_page.dart';

/// Launches the checkout WebView and resolves with the terminal redirect
/// [Uri] once it navigates to one of `returnUrlPrefixes`, or null if the
/// user backs out without completing the flow.
class WebViewCheckoutLauncher {
  const WebViewCheckoutLauncher._();

  static Future<Uri?> open(
    BuildContext context, {
    required String checkoutUrl,
    required List<String> returnUrlPrefixes,
    String title = 'Complete Payment',
  }) {
    return Navigator.of(context, rootNavigator: true).push<Uri>(
      MaterialPageRoute(
        builder: (_) => WebViewCheckoutPage(
          checkoutUrl: checkoutUrl,
          returnUrlPrefixes: returnUrlPrefixes,
          title: title,
        ),
      ),
    );
  }
}
