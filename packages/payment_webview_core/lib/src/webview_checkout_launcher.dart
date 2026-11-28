import 'package:flutter/material.dart';

import 'webview_checkout_page.dart';
import 'webview_checkout_request.dart' show returnUrlPrefixMatcher;

/// Launches the checkout WebView and resolves with the terminal redirect
/// [Uri] once [isReturnUrl] matches it, or null if the user backs out
/// without completing the flow.
class WebViewCheckoutLauncher {
  const WebViewCheckoutLauncher._();

  static Future<Uri?> open(
    BuildContext context, {
    required String checkoutUrl,
    bool Function(Uri uri)? isReturnUrl,
    @Deprecated('Use isReturnUrl instead. Will be removed in a future release.')
    String? returnUrlPrefix,
    String title = 'Complete Payment',
  }) {
    assert(
      isReturnUrl != null || returnUrlPrefix != null,
      'Provide isReturnUrl (returnUrlPrefix is deprecated and will be removed).',
    );
    final resolvedIsReturnUrl = isReturnUrl ?? returnUrlPrefixMatcher(returnUrlPrefix!);
    return Navigator.of(context, rootNavigator: true).push<Uri>(
      MaterialPageRoute(
        builder: (_) => WebViewCheckoutPage(
          checkoutUrl: checkoutUrl,
          isReturnUrl: resolvedIsReturnUrl,
          title: title,
        ),
      ),
    );
  }
}
