import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/product_provider.dart';
import '../../services/api_service.dart';
import '../auth/login_screen.dart';
import '../cart/cart_screen.dart';
import '../orders/orders_screen.dart';
import '../products/product_list_screen.dart';
import '../../widgets/stat_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  Map<String, dynamic>? _stats;
  bool _statsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final api = context.read<AuthProvider>().apiService;
    await Future.wait([
      _loadStats(api),
      context.read<ProductProvider>().fetchProducts(api),
      context.read<OrderProvider>().fetchOrders(api),
    ]);
  }

  Future<void> _loadStats(ApiService api) async {
    try {
      final res = await api.getDashboard();
      if (mounted) {
        setState(() {
          _stats       = res['data']['stats'] as Map<String, dynamic>;
          _statsLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _statsLoading = false);
    }
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cart = context.watch<CartProvider>();

    final pages = [
      _HomeTab(stats: _stats, loading: _statsLoading),
      const ProductListScreen(),
      const OrdersScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentIndex == 0
            ? 'Hi, ${auth.user?.name.split(' ').first ?? 'User'} 👋'
            : _currentIndex == 1
                ? 'Products'
                : 'My Orders'),
        actions: [
          if (_currentIndex == 1)
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  ),
                ),
                if (cart.totalItems > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${cart.totalItems}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Dashboard'),
          NavigationDestination(
              icon: Icon(Icons.phone_android_outlined),
              selectedIcon: Icon(Icons.phone_android),
              label: 'Products'),
          NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long),
              label: 'Orders'),
        ],
      ),
    );
  }
}

// ── Home Tab ─────────────────────────────────────────────────
class _HomeTab extends StatelessWidget {
  final Map<String, dynamic>? stats;
  final bool loading;

  const _HomeTab({this.stats, required this.loading});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {},
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Order Summary',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (loading)
              const Center(child: CircularProgressIndicator())
            else
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: [
                  StatCard(
                    label: 'Total Orders',
                    value: '${stats?['total_orders'] ?? 0}',
                    icon: Icons.shopping_bag_outlined,
                    color: AppTheme.primary,
                  ),
                  StatCard(
                    label: 'Completed',
                    value: '${stats?['completed_orders'] ?? 0}',
                    icon: Icons.check_circle_outline,
                    color: Colors.green,
                  ),
                  StatCard(
                    label: 'Pending',
                    value: '${stats?['pending_orders'] ?? 0}',
                    icon: Icons.hourglass_empty,
                    color: Colors.orange,
                  ),
                  StatCard(
                    label: 'Rejected',
                    value: '${stats?['rejected_orders'] ?? 0}',
                    icon: Icons.cancel_outlined,
                    color: AppTheme.error,
                  ),
                ],
              ),
            const SizedBox(height: 24),
            const Text('Recent Orders',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Consumer<OrderProvider>(
              builder: (_, orderProv, __) {
                if (orderProv.loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (orderProv.orders.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('No orders yet.',
                          style: TextStyle(color: Colors.grey)),
                    ),
                  );
                }
                final recent = orderProv.orders.take(3).toList();
                return Column(
                  children: recent.map((o) {
                    Color statusColor;
                    switch (o.status) {
                      case 'completed':
                        statusColor = Colors.green;
                        break;
                      case 'rejected':
                        statusColor = AppTheme.error;
                        break;
                      default:
                        statusColor = Colors.orange;
                    }
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.receipt_long,
                            color: AppTheme.primary),
                        title: Text('Order #${o.id}'),
                        subtitle: Text(
                            '${o.items.length} item(s) · ₱${o.totalAmount.toStringAsFixed(2)}'),
                        trailing: Chip(
                          label: Text(o.status.toUpperCase(),
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.white)),
                          backgroundColor: statusColor,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
