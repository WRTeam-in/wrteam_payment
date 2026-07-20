import '../contracts/payment_gateway_plugin.dart';
import '../models/payment_gateway_type.dart';

class PaymentRegistry {
  static final Map<PaymentGatewayType, PaymentGatewayPlugin> _plugins = {};

  static void register(PaymentGatewayPlugin plugin) {
    _plugins[plugin.type] = plugin;
  }

  static void unregister(PaymentGatewayType type) {
    _plugins.remove(type);
  }

  static PaymentGatewayPlugin? getPlugin(PaymentGatewayType type) {
    return _plugins[type];
  }

  static List<PaymentGatewayPlugin> get registeredPlugins => _plugins.values.toList();

  static void clear() {
    _plugins.clear();
  }
}
