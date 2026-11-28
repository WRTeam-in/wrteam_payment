import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'webview_checkout_request.dart' show returnUrlPrefixMatcher;

class WebViewCheckoutPage extends StatefulWidget {
  WebViewCheckoutPage({
    super.key,
    required this.checkoutUrl,
    bool Function(Uri uri)? isReturnUrl,
    @Deprecated('Use isReturnUrl instead. Will be removed in a future release.')
    String? returnUrlPrefix,
    required this.title,
  }) : assert(
         isReturnUrl != null || returnUrlPrefix != null,
         'Provide isReturnUrl (returnUrlPrefix is deprecated and will be removed).',
       ),
       isReturnUrl = isReturnUrl ?? returnUrlPrefixMatcher(returnUrlPrefix!);

  final String checkoutUrl;
  final bool Function(Uri uri) isReturnUrl;
  final String title;

  @override
  State<WebViewCheckoutPage> createState() => _WebViewCheckoutPageState();
}

class _WebViewCheckoutPageState extends State<WebViewCheckoutPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            log(request.url);
            final requestUri = Uri.tryParse(request.url);
            if (requestUri != null && widget.isReturnUrl(requestUri)) {
              Navigator.of(context).pop(requestUri);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onUrlChange: (change) {
            final changeUri = Uri.tryParse(change.url ?? '');
            if (changeUri != null && widget.isReturnUrl(changeUri)) {
              Navigator.of(context).pop(changeUri);
            }
          },
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading) const LinearProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
