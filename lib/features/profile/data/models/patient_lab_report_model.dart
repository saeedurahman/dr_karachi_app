class PatientLabReportModel {
  final String id;
  final String testName;
  final String testCode;
  final String fileName;
  final String fileType;
  final String? notes;
  final DateTime createdAt;

  PatientLabReportModel({
    required this.id,
    required this.testName,
    required this.testCode,
    required this.fileName,
    required this.fileType,
    this.notes,
    required this.createdAt,
  });

  factory PatientLabReportModel.fromJson(Map<String, dynamic> json) {
    DateTime created = DateTime.now();
    if (json['created_at'] != null) {
      created = DateTime.tryParse(json['created_at'] as String) ?? DateTime.now();
    }

    return PatientLabReportModel(
      id: json['id'] as String? ?? '',
      testName: json['test_name'] as String? ?? 'Diagnostic Pathology Report',
      testCode: json['test_code'] as String? ?? 'LAB-RPT',
      fileName: json['file_name'] as String? ?? 'report.pdf',
      fileType: json['file_type'] as String? ?? 'pdf',
      notes: json['notes'] as String?,
      createdAt: created,
    );
  }
}
