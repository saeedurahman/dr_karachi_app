class BranchModel {
  final String id;
  final String name;
  final String city;
  final String address;
  final String phone;
  final String? email;
  final String? googleMapsUrl;
  final String? workingHoursMonSat;
  final String? workingHoursSun;
  final List<String> services;
  final bool isActive;

  BranchModel({
    required this.id,
    required this.name,
    required this.city,
    required this.address,
    required this.phone,
    this.email,
    this.googleMapsUrl,
    this.workingHoursMonSat,
    this.workingHoursSun,
    this.services = const [],
    this.isActive = true,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    String? monSat;
    String? sun;

    String? parseDayValue(dynamic val) {
      if (val == null) return null;
      if (val is String) return val;
      if (val is Map) {
        final open = val['open'];
        final close = val['close'];
        if (open != null && close != null) {
          return '$open - $close';
        }
      }
      return val.toString();
    }

    if (json['working_hours'] is Map) {
      final wh = json['working_hours'] as Map;
      if (wh['mon_sat'] != null) {
        monSat = parseDayValue(wh['mon_sat']);
      } else if (wh['mon'] != null) {
        monSat = parseDayValue(wh['mon']);
      }

      if (wh['sun'] != null) {
        sun = parseDayValue(wh['sun']);
      }
    }


    return BranchModel(
      id: json['id'] as String,
      name: json['name'] as String,
      city: json['city'] as String? ?? 'Karachi',
      address: json['address'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String?,
      googleMapsUrl: json['google_maps_url'] as String?,
      workingHoursMonSat: monSat,
      workingHoursSun: sun,
      services: (json['services'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  /// Real google_maps_url when available, otherwise a directions link built from the address.
  String getDirectionsUrl() {
    if (googleMapsUrl != null && googleMapsUrl!.trim().isNotEmpty) {
      return googleMapsUrl!;
    }
    final query = '$name, $address';
    return 'https://www.google.com/maps/dir/?api=1&destination=${Uri.encodeComponent(query)}';
  }
}

