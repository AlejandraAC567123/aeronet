class TechnicianModel {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String specialty;
  final String status;

  TechnicianModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.specialty,
    required this.status,
  });

  factory TechnicianModel.fromJson(Map<String, dynamic> json) {
    return TechnicianModel(
      id: '${json['id'] ?? ''}',
      fullName: '${json['full_name'] ?? ''}',
      email: '${json['email'] ?? ''}',
      phone: '${json['phone'] ?? ''}',
      specialty: '${json['specialty'] ?? ''}',
      status: '${json['status'] ?? 'active'}',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'specialty': specialty,
      'status': status,
    };
  }
}
