import 'package:payment_core/payment_core.dart';
import 'package:payment_webview_core/payment_webview_core.dart';

import 'paypal_return_url_matcher.dart';

class PayPalRequest extends WebViewCheckoutRequest {
  PayPalRequest({
    required super.checkoutUrl,
    required String returnUrl,
    String successPath = '/success',
    String cancelPath = '/cancel',
    required super.transactionReference,
    super.title,
  }) : successUrlPrefix = '$returnUrl$successPath',
       cancelUrlPrefix = '$returnUrl$cancelPath',
       super(
         returnUrlPrefix: returnUrl,
         matcher: PayPalReturnUrlMatcher(
           successUrlPrefix: '$returnUrl$successPath',
           cancelUrlPrefix: '$returnUrl$cancelPath',
         ),
       );

  /// `$returnUrl$successPath` — PayPal redirects here once the buyer
  /// approves the order (approval only; capture still happens server-side
  /// afterwards).
  final String successUrlPrefix;

  /// `$returnUrl$cancelPath` — PayPal redirects here if the buyer backs out
  /// at PayPal's site.
  final String cancelUrlPrefix;

  @override
  PaymentGatewayType get gatewayType => PaymentGatewayType.paypal;
}
