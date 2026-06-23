class TicketModel {
  final String id;
  final String type; // ticket or work_order
  final String subject;
  final String description;
  final String category;
  final String priority;
  final String status;
  final String createdAt;
  final String? customerId;
  final String? technicianId;

  TicketModel({
    required this.id,
    required this.type,
    required this.subject,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    required this.createdAt,
    this.customerId,
    this.technicianId,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: '${json['id'] ?? ''}',
      type: '${json['type'] ?? 'ticket'}',
      subject: '${json['subject'] ?? ''}',
      description: '${json['description'] ?? ''}',
      category: '${json['category'] ?? 'RECLAMO'}',
      priority: '${json['priority'] ?? 'medium'}',
      status: '${json['status'] ?? 'open'}',
      createdAt: '${json['created_at'] ?? json['createdAt'] ?? ''}',
      customerId: json['customer_id']?.toString() ?? json['customer']?['id']?.toString(),
      technicianId: json['technician_id']?.toString() ?? json['technician']?['id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'subject': subject,
      'description': description,
      'category': category,
      'priority': priority,
      'status': status,
      'created_at': createdAt,
      'customer_id': customerId,
      'technician_id': technicianId,
    };
  }
}
