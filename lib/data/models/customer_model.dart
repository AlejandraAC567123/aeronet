class CustomerModel {
  final String id;
  final String fullName;
  final String email;
  final String role;
  final String documentType;
  final String documentNumber;
  final String avatarUrl;
  final String phone;

  CustomerModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.documentType,
    required this.documentNumber,
    required this.avatarUrl,
    required this.phone,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: '${json['id'] ?? ''}',
      fullName: '${json['full_name'] ?? ''}',
      email: '${json['email'] ?? ''}',
      role: '${json['role'] ?? 'client'}',
      documentType: '${json['document_type'] ?? ''}',
      documentNumber: '${json['document_number'] ?? ''}',
      avatarUrl: '${json['avatar_url'] ?? ''}',
      phone: '${json['phone'] ?? ''}',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'role': role,
      'document_type': documentType,
      'document_number': documentNumber,
      'avatar_url': avatarUrl,
      'phone': phone,
    };
  }
}
