import 'package:flutter/foundation.dart';

import '../models/product_model.dart';
import '../services/api_service.dart';

class ProductProvider extends ChangeNotifier {
  List<ProductModel> _products = [];
  bool    _loading = false;
  String? _error;

  List<ProductModel> get products => _products;
  bool    get loading => _loading;
  String? get error   => _error;

  Future<void> fetchProducts(ApiService api) async {
    _loading = true;
    _error   = null;
    notifyListeners();

    try {
      final res  = await api.getProducts();
      final list = res['data'] as List<dynamic>;
      _products  = list
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Failed to load products.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
