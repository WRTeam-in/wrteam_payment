import 'package:flutter/material.dart';
import 'package:payment_core/payment_core.dart';

/// Shows the payment method selector bottom sheet. Not a widget itself —
/// use [show] rather than instantiating the underlying UI directly.
class PaymentMethodSelectorSheet {
  const PaymentMethodSelectorSheet._();

  static Future<PaymentGatewayType?> show(
    BuildContext context, {
    String? title,
  }) {
    return showModalBottomSheet<PaymentGatewayType>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      shape:
          Theme.of(context).bottomSheetTheme.shape ??
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
      builder: (context) =>
          _PaymentMethodSelectorSheetView(title: title ?? 'Select Payment Method'),
    );
  }
}

class _PaymentMethodSelectorSheetView extends StatelessWidget {
  const _PaymentMethodSelectorSheetView({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final plugins = PaymentRegistry.registeredPlugins;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: plugins.length,
                itemBuilder: (context, index) {
                  final plugin = plugins[index];
                  final iconAsset = plugin.iconAsset;
                  return ListTile(
                    leading: iconAsset == null
                        ? Icon(Icons.payment, color: theme.colorScheme.primary)
                        : Image.asset(
                            iconAsset,
                            width: 32,
                            height: 32,
                            errorBuilder: (_, _, _) => Icon(
                              Icons.payment,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                    title: Text(
                      plugin.displayName,
                      style: theme.textTheme.bodyLarge,
                    ),
                    onTap: () {
                      Navigator.of(context).pop(plugin.type);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
