import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderProv = context.watch<OrderProvider>();

    if (orderProv.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (orderProv.orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long_outlined,
                size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No orders yet.',
                style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => orderProv
          .fetchOrders(context.read<AuthProvider>().apiService),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orderProv.orders.length,
        itemBuilder: (ctx, i) {
          final order = orderProv.orders[i];
          return _OrderCard(order: order);
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;

  const _OrderCard({required this.order});

  Color get _statusColor {
    switch (order.status) {
      case 'completed':
        return Colors.green;
      case 'rejected':
        return AppTheme.error;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primary.withOpacity(0.1),
          child: const Icon(Icons.receipt_long, color: AppTheme.primary),
        ),
        title: Text('Order #${order.id}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
            '${order.items.length} item(s) · ₱${order.totalAmount.toStringAsFixed(2)}'),
        trailing: Chip(
          label: Text(order.status.toUpperCase(),
              style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
          backgroundColor: _statusColor,
          padding: EdgeInsets.zero,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                ...order.items.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.phone_android,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(child: Text(item.productName)),
                          Text('×${item.quantity}',
                              style:
                                  const TextStyle(color: Colors.grey)),
                          const SizedBox(width: 8),
                          Text(
                            '₱${item.subtotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    )),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      '₱${order.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                          fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    order.createdAt,
                    style: const TextStyle(
                        fontSize: 11, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
