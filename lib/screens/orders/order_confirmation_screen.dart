import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import 'order_success_screen.dart';

class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart      = context.watch<CartProvider>();
    final orderProv = context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Order Confirmation')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Review Your Order',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  // Items list
                  ...cart.items.map((item) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: item.product.imageUrl != null
                                ? Image.network(
                                    item.product.imageUrl!,
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _imgPlaceholder(),
                                  )
                                : _imgPlaceholder(),
                          ),
                          title: Text(item.product.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600)),
                          subtitle: Text(
                              'Qty: ${item.quantity} × ₱${item.product.price.toStringAsFixed(2)}'),
                          trailing: Text(
                            '₱${item.subtotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary),
                          ),
                        ),
                      )),
                  const Divider(height: 32),
                  // Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Items',
                          style: TextStyle(color: Colors.grey)),
                      Text('${cart.totalItems}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Amount',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(
                        '₱${cart.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary),
                      ),
                    ],
                  ),
                  if (orderProv.error != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: AppTheme.error),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(orderProv.error!,
                                style:
                                    const TextStyle(color: AppTheme.error)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Confirm button
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: orderProv.loading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Confirm Order'),
                    onPressed: () async {
                      final api = context.read<AuthProvider>().apiService;
                      final payload = cart.toOrderPayload();
                      final ok =
                          await orderProv.placeOrder(api, payload);

                      if (!context.mounted) return;
                      if (ok) {
                        cart.clear();
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (_) => OrderSuccessScreen(
                                  order: orderProv.lastOrder!)),
                          (route) => route.isFirst,
                        );
                      }
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _imgPlaceholder() => Container(
        width: 48,
        height: 48,
        color: Colors.grey[200],
        child: const Icon(Icons.phone_android, color: Colors.grey, size: 24),
      );
}
