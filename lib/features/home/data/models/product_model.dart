class ProductModel {
  final String id;
  final String name;
  final String sku;
  final String? description;
  final String? categoryId;
  final double originalPrice;
  final double discountPercent;
  final double discountedPrice;
  final String? imageUrl;
  final bool requiresPrescription;
  final int? stockAtBranch;

  ProductModel({
    required this.id,
    required this.name,
    required this.sku,
    this.description,
    this.categoryId,
    required this.originalPrice,
    this.discountPercent = 0.0,
    required this.discountedPrice,
    this.imageUrl,
    this.requiresPrescription = false,
    this.stockAtBranch,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    return ProductModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      sku: json['sku'] as String? ?? '',
      description: json['description'] as String?,
      categoryId: json['category_id'] as String?,
      originalPrice: parseDouble(json['original_price']),
      discountPercent: parseDouble(json['discount_percent']),
      discountedPrice: parseDouble(json['discounted_price']),
      imageUrl: json['image_url'] as String?,
      requiresPrescription: json['requires_prescription'] as bool? ?? false,
      stockAtBranch: (json['stock_at_branch'] as num?)?.toInt(),
    );
  }
}
