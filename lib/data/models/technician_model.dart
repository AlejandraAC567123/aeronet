class TechnicianModel {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String documentNumber;
  final String specialization;
  final String status;

  TechnicianModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.documentNumber,
    required this.specialization,
    required this.status,
  });

  factory TechnicianModel.fromJson(Map<String, dynamic> json) {
    return TechnicianModel(
      id: '${json['id'] ?? ''}',
      fullName: '${json['full_name'] ?? ''}',
      email: '${json['email'] ?? ''}',
      phone: '${json['phone'] ?? ''}',
      documentNumber: '${json['document_number'] ?? ''}',
      specialization: '${json['specialization'] ?? json['specialty'] ?? ''}',
      status: '${json['status'] ?? 'active'}',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'document_number': documentNumber,
      'specialization': specialization,
      'status': status,
    };
  }
}