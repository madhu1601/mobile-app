import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/product_card.dart';
import '../cart/cart_screen.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productProv = context.watch<ProductProvider>();
    final cart        = context.watch<CartProvider>();

    if (productProv.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (productProv.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 8),
            Text(productProv.error!,
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => productProv.fetchProducts(
                  context.read<AuthProvider>().apiService),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (productProv.products.isEmpty) {
      return const Center(child: Text('No products available.'));
    }

    return RefreshIndicator(
      onRefresh: () => productProv
          .fetchProducts(context.read<AuthProvider>().apiService),
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        itemCount: productProv.products.length,
        itemBuilder: (ctx, i) {
          final product = productProv.products[i];
          return ProductCard(
            product: product,
            inCart: cart.contains(product.id),
            onAddToCart: () {
              cart.addItem(product);
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(
                  content: Text('${product.name} added to cart'),
                  duration: const Duration(seconds: 1),
                  action: SnackBarAction(
                    label: 'View Cart',
                    onPressed: () => Navigator.of(ctx).push(
                      MaterialPageRoute(builder: (_) => const CartScreen()),
                    ),
                  ),
                ),
              );
            },
            onRemoveFromCart: () => cart.removeItem(product.id),
          );
        },
      ),
    );
  }
}
