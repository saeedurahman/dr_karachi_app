class DoctorSlotModel {
  final DateTime slotDatetime;
  final bool isAvailable;

  DoctorSlotModel({
    required this.slotDatetime,
    required this.isAvailable,
  });

  factory DoctorSlotModel.fromJson(Map<String, dynamic> json) {
    return DoctorSlotModel(
      slotDatetime: DateTime.parse(json['slot_datetime'] as String),
      isAvailable: json['is_available'] as bool? ?? true,
    );
  }

  String get formattedTime {
    final local = slotDatetime.toLocal();
    final hour = local.hour;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final standardHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$standardHour:$minute $period';
  }
}
