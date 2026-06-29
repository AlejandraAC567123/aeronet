class CustomerModel {
  final String id;
  final String fullName;
  final String email;
  final String role;
  final String documentType;
  final String documentNumber;
  final String avatarUrl;
  final String phone;
  final String address;
  final String city;

  CustomerModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.documentType,
    required this.documentNumber,
    required this.avatarUrl,
    required this.phone,
    required this.address,
    required this.city,
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
      address: '${json['address'] ?? ''}',
      city: '${json['city'] ?? ''}',
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
      'address': address,
      'city': city,
    };
  }
}
