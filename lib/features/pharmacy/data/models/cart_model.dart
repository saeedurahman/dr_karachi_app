import 'cart_item_model.dart';

class CartModel {
  final String? branchId;
  final List<CartItemModel> items;
  final int itemCount;
  final double subtotal;
  final double discountAmount;
  final double platformFee;
  final double deliveryCharges;
  final double grandTotal;

  CartModel({
    this.branchId,
    required this.items,
    required this.itemCount,
    required this.subtotal,
    required this.discountAmount,
    required this.platformFee,
    required this.deliveryCharges,
    required this.grandTotal,
  });

  factory CartModel.empty() {
    return CartModel(
      branchId: null,
      items: const [],
      itemCount: 0,
      subtotal: 0.0,
      discountAmount: 0.0,
      platformFee: 0.0,
      deliveryCharges: 0.0,
      grandTotal: 0.0,
    );
  }

  factory CartModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    final rawItems = json['items'];
    final List<CartItemModel> items = [];
    if (rawItems is List) {
      items.addAll(
        rawItems.map((e) => CartItemModel.fromJson(e as Map<String, dynamic>)),
      );
    }

    return CartModel(
      branchId: json['branch_id'] as String?,
      items: items,
      itemCount: (json['item_count'] as num?)?.toInt() ?? items.length,
      subtotal: parseDouble(json['subtotal']),
      discountAmount: parseDouble(json['discount_amount']),
      platformFee: parseDouble(json['platform_fee']),
      deliveryCharges: parseDouble(json['delivery_charges']),
      grandTotal: parseDouble(json['grand_total']),
    );
  }

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
}
