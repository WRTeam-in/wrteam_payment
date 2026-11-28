import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'webview_checkout_outcome.dart';

class WebViewCheckoutPage extends StatefulWidget {
  const WebViewCheckoutPage({
    super.key,
    required this.checkoutUrl,
    required this.onReturn,
    required this.title,
  });

  final String checkoutUrl;
  final WebViewCheckoutOutcome? Function(Uri uri) onReturn;
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
            final uri = Uri.tryParse(request.url);
            final outcome = uri == null ? null : widget.onReturn(uri);
            if (uri != null && outcome != null) {
              Navigator.of(context).pop((uri, outcome));
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onUrlChange: (change) {
            final uri = Uri.tryParse(change.url ?? '');
            final outcome = uri == null ? null : widget.onReturn(uri);
            if (uri != null && outcome != null) {
              Navigator.of(context).pop((uri, outcome));
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
