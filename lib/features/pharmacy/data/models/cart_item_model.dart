class CartItemModel {
  final String id;
  final String productId;
  final String productName;
  final String? branchId;
  final int quantity;
  final double originalPrice;
  final double discountPercent;
  final double discountedPrice;
  final double lineTotal;
  final int stockAtBranch;
  final String? imageUrl;

  CartItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    this.branchId,
    required this.quantity,
    required this.originalPrice,
    required this.discountPercent,
    required this.discountedPrice,
    required this.lineTotal,
    required this.stockAtBranch,
    this.imageUrl,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    return CartItemModel(
      id: json['id'] as String? ?? '',
      productId: json['product_id'] as String? ?? '',
      productName: json['product_name'] as String? ?? '',
      branchId: json['branch_id'] as String?,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      originalPrice: parseDouble(json['original_price']),
      discountPercent: parseDouble(json['discount_percent']),
      discountedPrice: parseDouble(json['discounted_price']),
      lineTotal: parseDouble(json['line_total']),
      stockAtBranch: (json['stock_at_branch'] as num?)?.toInt() ?? 0,
      imageUrl: json['image_url'] as String?,
    );
  }

  CartItemModel copyWith({
    String? id,
    String? productId,
    String? productName,
    String? branchId,
    int? quantity,
    double? originalPrice,
    double? discountPercent,
    double? discountedPrice,
    double? lineTotal,
    int? stockAtBranch,
    String? imageUrl,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      branchId: branchId ?? this.branchId,
      quantity: quantity ?? this.quantity,
      originalPrice: originalPrice ?? this.originalPrice,
      discountPercent: discountPercent ?? this.discountPercent,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      lineTotal: lineTotal ?? this.lineTotal,
      stockAtBranch: stockAtBranch ?? this.stockAtBranch,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
