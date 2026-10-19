class PatientAppointmentModel {
  final String id;
  final DateTime slotDatetime;
  final String status;
  final String? notes;
  final String? cancellationReason;
  final String doctorName;
  final String doctorSpecialization;
  final double doctorFee;
  final String branchName;
  final String branchCity;
  final String branchAddress;
  final DateTime createdAt;

  PatientAppointmentModel({
    required this.id,
    required this.slotDatetime,
    required this.status,
    this.notes,
    this.cancellationReason,
    required this.doctorName,
    required this.doctorSpecialization,
    required this.doctorFee,
    required this.branchName,
    required this.branchCity,
    required this.branchAddress,
    required this.createdAt,
  });

  factory PatientAppointmentModel.fromJson(Map<String, dynamic> json) {
    // Parse Doctor Summary
    String docName = 'Consultant Doctor';
    String docSpec = 'General Physician';
    double docFee = 0.0;
    if (json['doctor'] is Map<String, dynamic>) {
      final doc = json['doctor'] as Map<String, dynamic>;
      docName = doc['name'] as String? ?? 'Consultant Doctor';
      docSpec = doc['specialization'] as String? ?? 'General Physician';
      final feeRaw = doc['consultation_fee'];
      if (feeRaw is num) {
        docFee = feeRaw.toDouble();
      } else if (feeRaw is String) {
        docFee = double.tryParse(feeRaw) ?? 0.0;
      }
    }

    // Parse Branch Summary
    String brName = 'Main Diagnostic & Clinical Branch';
    String brCity = 'Karachi';
    String brAddr = '';
    if (json['branch'] is Map<String, dynamic>) {
      final br = json['branch'] as Map<String, dynamic>;
      brName = br['name'] as String? ?? 'Karachi Clinic Branch';
      brCity = br['city'] as String? ?? 'Karachi';
      brAddr = br['address'] as String? ?? '';
    }

    DateTime slot = DateTime.now();
    if (json['slot_datetime'] != null) {
      slot = DateTime.tryParse(json['slot_datetime'] as String) ?? DateTime.now();
    }

    DateTime created = DateTime.now();
    if (json['created_at'] != null) {
      created = DateTime.tryParse(json['created_at'] as String) ?? DateTime.now();
    }

    return PatientAppointmentModel(
      id: json['id'] as String? ?? '',
      slotDatetime: slot,
      status: json['status'] as String? ?? 'pending',
      notes: json['notes'] as String?,
      cancellationReason: json['cancellation_reason'] as String?,
      doctorName: docName,
      doctorSpecialization: docSpec,
      doctorFee: docFee,
      branchName: brName,
      branchCity: brCity,
      branchAddress: brAddr,
      createdAt: created,
    );
  }

  bool get canCancel => status == 'pending' || status == 'confirmed';
}
