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
            if (request.url.startsWith(widget.returnUrlPrefix)) {
              Navigator.of(context).pop(Uri.parse(request.url));
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
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
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const LinearProgressIndicator(),
        ],
      ),
    );
  }
}
