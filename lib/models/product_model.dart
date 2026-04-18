class ProductModel {
  final int id;
  final String name;
  final String? description;
  final double price;
  final int stockQuantity;
  final String? imageUrl;

  const ProductModel({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.stockQuantity,
    this.imageUrl,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id:            json['id'] as int,
        name:          json['name'] as String,
        description:   json['description'] as String?,
        price:         double.parse(json['price'].toString()),
        stockQuantity: json['stock_quantity'] as int,
        imageUrl:      json['image_url'] as String?,
      );

  bool get inStock => stockQuantity > 0;
}
