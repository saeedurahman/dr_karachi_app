class CheckoutRequestModel {
  final String deliveryMethod; // 'delivery' or 'pickup'
  final String? deliveryAddress;
  final String? notes;
  final String paymentMethod; // 'cod'
  final bool marketingOptIn;

  CheckoutRequestModel({
    this.deliveryMethod = 'delivery',
    this.deliveryAddress,
    this.notes,
    this.paymentMethod = 'cod',
    this.marketingOptIn = false,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'delivery_method': deliveryMethod,
      'payment_method': paymentMethod,
      'marketing_opt_in': marketingOptIn,
    };
    if (deliveryAddress != null && deliveryAddress!.trim().isNotEmpty) {
      map['delivery_address'] = deliveryAddress!.trim();
    }
    if (notes != null && notes!.trim().isNotEmpty) {
      map['notes'] = notes!.trim();
    }
    return map;
  }
}

class OrderResponseModel {
  final String id;
  final String status;
  final String paymentMethod;
  final double subtotal;
  final double discountAmount;
  final double platformFee;
  final double deliveryCharges;
  final double grandTotal;
  final String? deliveryAddress;
  final String? createdAt;

  OrderResponseModel({
    required this.id,
    required this.status,
    required this.paymentMethod,
    required this.subtotal,
    required this.discountAmount,
    required this.platformFee,
    required this.deliveryCharges,
    required this.grandTotal,
    this.deliveryAddress,
    this.createdAt,
  });

  factory OrderResponseModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    return OrderResponseModel(
      id: json['id'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      paymentMethod: json['payment_method'] as String? ?? 'cod',
      subtotal: parseDouble(json['subtotal']),
      discountAmount: parseDouble(json['discount_amount']),
      platformFee: parseDouble(json['platform_fee']),
      deliveryCharges: parseDouble(json['delivery_charges']),
      grandTotal: parseDouble(json['grand_total']),
      deliveryAddress: json['delivery_address'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }
}
