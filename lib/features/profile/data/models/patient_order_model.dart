class PatientOrderItemModel {
  final String productName;
  final int quantity;
  final double lineTotal;

  PatientOrderItemModel({
    required this.productName,
    required this.quantity,
    required this.lineTotal,
  });

  factory PatientOrderItemModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    return PatientOrderItemModel(
      productName: json['product_name_snapshot'] as String? ?? 'Prescription Item',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      lineTotal: parseDouble(json['line_total']),
    );
  }
}

class PatientOrderModel {
  final String id;
  final String status;
  final String paymentMethod;
  final double subtotal;
  final double deliveryCharges;
  final double grandTotal;
  final String? deliveryAddress;
  final DateTime createdAt;
  final List<PatientOrderItemModel> items;

  PatientOrderModel({
    required this.id,
    required this.status,
    required this.paymentMethod,
    required this.subtotal,
    required this.deliveryCharges,
    required this.grandTotal,
    this.deliveryAddress,
    required this.createdAt,
    required this.items,
  });

  factory PatientOrderModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    DateTime created = DateTime.now();
    if (json['created_at'] != null) {
      created = DateTime.tryParse(json['created_at'] as String) ?? DateTime.now();
    }

    List<PatientOrderItemModel> parsedItems = [];
    if (json['items'] is List) {
      parsedItems = (json['items'] as List)
          .map((e) => PatientOrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return PatientOrderModel(
      id: json['id'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      paymentMethod: json['payment_method'] as String? ?? 'cod',
      subtotal: parseDouble(json['subtotal']),
      deliveryCharges: parseDouble(json['delivery_charges']),
      grandTotal: parseDouble(json['grand_total']),
      deliveryAddress: json['delivery_address'] as String?,
      createdAt: created,
      items: parsedItems,
    );
  }
}
