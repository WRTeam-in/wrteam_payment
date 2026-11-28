import 'package:flutter/material.dart';

import 'webview_checkout_outcome.dart';
import 'webview_checkout_page.dart';
import 'webview_checkout_request.dart' show returnUrlPrefixMatcher;
import 'webview_legacy_on_return.dart';
import 'webview_return_url_matcher.dart';

/// Launches the checkout WebView and resolves with the `(uri, outcome)`
/// pair once [onReturn] returns non-null for a navigated URL, or null if
/// the user backs out without completing the flow.
class WebViewCheckoutLauncher {
  const WebViewCheckoutLauncher._();

  static Future<(Uri, WebViewCheckoutOutcome)?> open(
    BuildContext context, {
    required String checkoutUrl,
    WebViewCheckoutOutcome? Function(Uri uri)? onReturn,
    @Deprecated('Use onReturn instead. Will be removed in a future release.')
    bool Function(Uri uri)? isReturnUrl,
    @Deprecated('Use onReturn instead. Will be removed in a future release.')
    String? returnUrlPrefix,
    @Deprecated('Use onReturn instead. Will be removed in a future release.')
    WebViewOutcomeMatcher matcher = const WebViewReturnUrlMatcher(),
    String title = 'Complete Payment',
  }) {
    assert(
      onReturn != null || isReturnUrl != null || returnUrlPrefix != null,
      'Provide onReturn (isReturnUrl/returnUrlPrefix/matcher are deprecated and will be removed).',
    );
    final resolvedOnReturn =
        onReturn ?? legacyOnReturn(isReturnUrl ?? returnUrlPrefixMatcher(returnUrlPrefix!), matcher);
    return Navigator.of(context, rootNavigator: true).push<(Uri, WebViewCheckoutOutcome)>(
      MaterialPageRoute(
        builder: (_) => WebViewCheckoutPage(
          checkoutUrl: checkoutUrl,
          onReturn: resolvedOnReturn,
          title: title,
        ),
      ),
    );
  }
}
