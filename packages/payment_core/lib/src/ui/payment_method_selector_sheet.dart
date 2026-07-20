import 'package:flutter/material.dart';
import '../contracts/payment_gateway_plugin.dart';
import '../models/payment_gateway_type.dart';

class PaymentMethodSelectorSheet extends StatelessWidget {
  final List<PaymentGatewayPlugin> plugins;
  final String title;

  const PaymentMethodSelectorSheet({
    super.key,
    required this.plugins,
    this.title = 'Select Payment Method',
  });

  /// Helper static method to show sheet and await selected PaymentGatewayType
  static Future<PaymentGatewayType?> show(
    BuildContext context, {
    required List<PaymentGatewayPlugin> plugins,
    String? title,
  }) {
    return showModalBottomSheet<PaymentGatewayType>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      shape: Theme.of(context).bottomSheetTheme.shape ??
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
      builder: (context) => PaymentMethodSelectorSheet(
        plugins: plugins,
        title: title ?? 'Select Payment Method',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
