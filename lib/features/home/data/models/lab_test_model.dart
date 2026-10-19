class LabTestModel {
  final String id;
  final String name;
  final String code;
  final String? description;
  final double price;
  final bool homeSamplingAvailable;
  final double homeSamplingFee;
  final int? turnaroundHours;

  LabTestModel({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    required this.price,
    this.homeSamplingAvailable = true,
    this.homeSamplingFee = 0.0,
    this.turnaroundHours,
  });

  factory LabTestModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val, double fallback) {
      if (val == null) return fallback;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? fallback;
      return fallback;
    }

    return LabTestModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      description: json['description'] as String?,
      price: parseDouble(json['price'], 0.0),
      homeSamplingAvailable: json['home_sampling_available'] as bool? ?? true,
      homeSamplingFee: parseDouble(json['home_sampling_fee'], 0.0),
      turnaroundHours: (json['turnaround_hours'] as num?)?.toInt(),
    );
  }
}
