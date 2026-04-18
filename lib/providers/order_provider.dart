import 'package:flutter/foundation.dart';

import '../models/order_model.dart';
import '../services/api_service.dart';

class OrderProvider extends ChangeNotifier {
  List<OrderModel> _orders = [];
  OrderModel?      _lastOrder;
  bool    _loading = false;
  String? _error;

  List<OrderModel> get orders    => _orders;
  OrderModel?      get lastOrder => _lastOrder;
  bool    get loading => _loading;
  String? get error   => _error;

  Future<bool> placeOrder(
      ApiService api, List<Map<String, dynamic>> items) async {
    _loading = true;
    _error   = null;
    notifyListeners();

    try {
      final res  = await api.placeOrder(items);
      _lastOrder = OrderModel.fromJson(res['data'] as Map<String, dynamic>);
      _orders.insert(0, _lastOrder!);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'Failed to place order.';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> fetchOrders(ApiService api) async {
    _loading = true;
    _error   = null;
    notifyListeners();

    try {
      final res  = await api.getOrders();
      final list = res['data'] as List<dynamic>;
      _orders    = list
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Failed to load orders.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
