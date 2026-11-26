import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewCheckoutPage extends StatefulWidget {
  const WebViewCheckoutPage({
    super.key,
    required this.checkoutUrl,
    required this.returnUrlPrefix,
    required this.title,
  });

  final String checkoutUrl;
  final String returnUrlPrefix;
  final String title;

  @override
  State<WebViewCheckoutPage> createState() => _WebViewCheckoutPageState();
}

bool _matchesReturnUrl(Uri url, Uri prefix) =>
    url.scheme == prefix.scheme &&
    url.host == prefix.host &&
    url.path.startsWith(prefix.path);

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
            final prefixUri = Uri.parse(widget.returnUrlPrefix);
            if (requestUri != null && _matchesReturnUrl(requestUri, prefixUri)) {
              Navigator.of(context).pop(requestUri);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onUrlChange: (change) {
            final changeUri = Uri.tryParse(change.url ?? '');
            if (changeUri != null && _matchesReturnUrl(changeUri, Uri.parse(widget.returnUrlPrefix))) {
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
