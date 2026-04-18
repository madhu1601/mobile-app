class OrderItemModel {
  final int id;
  final int productId;
  final String productName;
  final String? imageUrl;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  const OrderItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    this.imageUrl,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) => OrderItemModel(
        id:          json['id'] as int,
        productId:   json['product_id'] as int,
        productName: json['product_name'] as String,
        imageUrl:    json['image_url'] as String?,
        quantity:    json['quantity'] as int,
        unitPrice:   double.parse(json['unit_price'].toString()),
        subtotal:    double.parse(json['subtotal'].toString()),
      );
}

class OrderModel {
  final int id;
  final int userId;
  final double totalAmount;
  final String status;
  final String? notes;
  final String createdAt;
  final List<OrderItemModel> items;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.totalAmount,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id:          json['id'] as int,
        userId:      json['user_id'] as int,
        totalAmount: double.parse(json['total_amount'].toString()),
        status:      json['status'] as String,
        notes:       json['notes'] as String?,
        createdAt:   json['created_at'] as String,
        items: (json['items'] as List<dynamic>? ?? [])
            .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
