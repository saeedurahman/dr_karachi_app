class AppointmentModel {
  final String id;
  final String doctorName;
  final String specialization;
  final String branchName;
  final String appointmentTime;
  final String status;
  final String? room;
  final String? doctorImageUrl;

  AppointmentModel({
    required this.id,
    required this.doctorName,
    required this.specialization,
    required this.branchName,
    required this.appointmentTime,
    required this.status,
    this.room,
    this.doctorImageUrl,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] as String,
      doctorName: json['doctor_name'] as String? ?? 'Consultant Doctor',
      specialization: json['specialization'] as String? ?? 'General Physician',
      branchName: json['branch_name'] as String? ?? 'Karachi Campus',
      appointmentTime: json['appointment_time'] as String? ?? 'Today',
      status: json['status'] as String? ?? 'confirmed',
      room: json['room'] as String?,
      doctorImageUrl: json['doctor_image_url'] as String?,
    );
  }
}
