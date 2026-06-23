class InvoiceModel {
  final String id;
  final String customerId;
  final double amount;
  final String status;
  final String? dueDate;
  final String? createdAt;
  final String? customerName;

  InvoiceModel({
    required this.id,
    required this.customerId,
    required this.amount,
    required this.status,
    this.dueDate,
    this.createdAt,
    this.customerName,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    // Some endpoints may return 'amount', others 'total'
    final amt = double.tryParse('${json['amount'] ?? json['total'] ?? '0.0'}') ?? 0.0;
    
    // Check if customer info is nested
    String? custName;
    if (json['customer'] is Map) {
      custName = '${json['customer']['full_name'] ?? json['customer']['email'] ?? ''}';
    }

    return InvoiceModel(
      id: '${json['id'] ?? ''}',
      customerId: '${json['customer_id'] ?? json['customerId'] ?? ''}',
      amount: amt,
      status: '${json['status'] ?? 'pending'}',
      dueDate: '${json['due_date'] ?? json['dueDate'] ?? ''}',
      createdAt: '${json['created_at'] ?? json['createdAt'] ?? ''}',
      customerName: custName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'amount': amount,
      'status': status,
      'due_date': dueDate,
      'created_at': createdAt,
    };
  }
}
