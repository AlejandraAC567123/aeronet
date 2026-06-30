class PaymentModel {
  final String id;
  final String? customerId;
  final String? serviceId;
  final double amountReceived;
  final String paymentMethod;
  final String? transactionReference;
  final String? provider;
  final String? paymentDate;
  final String? createdAt;
  final String? customerName;

  PaymentModel({
    required this.id,
    this.customerId,
    this.serviceId,
    required this.amountReceived,
    required this.paymentMethod,
    this.transactionReference,
    this.provider,
    this.paymentDate,
    this.createdAt,
    this.customerName,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    String? custName;
    if (json['customer'] is Map) {
      custName = '${json['customer']['full_name'] ?? ''}';
    }

    return PaymentModel(
      id: '${json['id'] ?? ''}',
      customerId: '${json['customer_id'] ?? json['customerId'] ?? ''}',
      serviceId: '${json['service_id'] ?? json['serviceId'] ?? ''}',
      amountReceived: double.tryParse('${json['amount_received'] ?? json['amountReceived'] ?? '0.0'}') ?? 0.0,
      paymentMethod: '${json['payment_method'] ?? json['paymentMethod'] ?? ''}',
      transactionReference: '${json['transaction_reference'] ?? json['transactionReference'] ?? ''}',
      provider: '${json['provider'] ?? ''}',
      paymentDate: '${json['payment_date'] ?? json['paymentDate'] ?? ''}',
      createdAt: '${json['created_at'] ?? json['createdAt'] ?? ''}',
      customerName: custName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'service_id': serviceId,
      'amount_received': amountReceived,
      'payment_method': paymentMethod,
      'transaction_reference': transactionReference,
      'provider': provider,
      'payment_date': paymentDate,
      'created_at': createdAt,
    };
  }

  String get displayMethod {
    switch (paymentMethod.toUpperCase()) {
      case 'CASH':
        return 'Efectivo';
      case 'TRANSFER':
        return 'Transferencia';
      case 'CARD':
        return 'Tarjeta';
      case 'YAPE':
        return 'Yape';
      default:
        return paymentMethod;
    }
  }
}
