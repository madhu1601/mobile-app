import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // ── Change this to your server URL ──────────────────────────
  static const String baseUrl = 'http://10.0.2.2/ecommerce/backend/public';
  // Use 10.0.2.2 for Android emulator → localhost on host machine
  // Use your actual IP (e.g. http://192.168.1.x/...) for physical device

  String? _token;

  void setToken(String? token) => _token = token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // ── Auth ─────────────────────────────────────────────────────

  Future<Map<String, dynamic>> login(String identifier, String password) async {
    return _post('/api/auth/login', {
      'identifier': identifier,
      'password': password,
    });
  }

  Future<Map<String, dynamic>> register({
    required String name,
    String? email,
    String? mobile,
    required String password,
  }) async {
    return _post('/api/auth/register', {
      'name': name,
      if (email != null && email.isNotEmpty) 'email': email,
      if (mobile != null && mobile.isNotEmpty) 'mobile': mobile,
      'password': password,
    });
  }

  Future<Map<String, dynamic>> logout() async {
    return _post('/api/auth/logout', {});
  }

  // ── Products ─────────────────────────────────────────────────

  Future<Map<String, dynamic>> getProducts() async {
    return _get('/api/products');
  }

  Future<Map<String, dynamic>> getProduct(int id) async {
    return _get('/api/products/$id');
  }

  // ── Orders ───────────────────────────────────────────────────

  Future<Map<String, dynamic>> placeOrder(
      List<Map<String, dynamic>> items, {String? notes}) async {
    return _post('/api/orders', {
      'items': items,
      if (notes != null) 'notes': notes,
    });
  }

  Future<Map<String, dynamic>> getOrders() async {
    return _get('/api/orders');
  }

  Future<Map<String, dynamic>> getOrder(int id) async {
    return _get('/api/orders/$id');
  }

  // ── Dashboard ────────────────────────────────────────────────

  Future<Map<String, dynamic>> getDashboard() async {
    return _get('/api/dashboard');
  }

  // ── HTTP Helpers ─────────────────────────────────────────────

  Future<Map<String, dynamic>> _get(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http.get(uri, headers: _headers);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }
    throw ApiException(
      decoded['message'] as String? ?? 'An error occurred.',
      response.statusCode,
    );
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  const ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}
