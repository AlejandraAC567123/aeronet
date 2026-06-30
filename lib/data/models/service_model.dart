import 'package:aeronet_app_flutter/data/models/plan_model.dart';

class ServiceModel {
  final String id;
  final String address;
  final String status;
  final PlanModel? plan;
  final String? reference;
  final double? latitude;
  final double? longitude;
  final String? customerId;
  final String? customerName;
  final double? monthlyAmount;
  final int? billingDay;

  ServiceModel({
    required this.id,
    required this.address,
    required this.status,
    this.plan,
    this.reference,
    this.latitude,
    this.longitude,
    this.customerId,
    this.customerName,
    this.monthlyAmount,
    this.billingDay,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    PlanModel? parsedPlan;
    if (json['plan'] is Map<String, dynamic>) {
      parsedPlan = PlanModel.fromJson(json['plan']);
    } else if (json['plan'] is Map) {
      parsedPlan = PlanModel.fromJson(json['plan'].map((k, v) => MapEntry('$k', v)));
    }
    
    return ServiceModel(
      id: '${json['id'] ?? ''}',
      address: '${json['address'] ?? json['installation_address'] ?? ''}',
      status: '${json['status'] ?? 'activo'}',
      plan: parsedPlan,
      reference: '${json['reference'] ?? ''}',
      latitude: double.tryParse('${json['latitude'] ?? json['lat'] ?? ''}'),
      longitude: double.tryParse('${json['longitude'] ?? json['lng'] ?? ''}'),
      customerId: '${json['customer_id'] ?? json['customerId'] ?? ''}',
      customerName: json['customer'] is Map ? '${json['customer']['full_name'] ?? ''}' : null,
      monthlyAmount: double.tryParse('${json['monthly_amount'] ?? ''}'),
      billingDay: int.tryParse('${json['billing_day'] ?? ''}'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'address': address,
      'status': status,
      if (plan != null) 'plan': plan!.toJson(),
      'reference': reference,
      'latitude': latitude,
      'longitude': longitude,
      'customer_id': customerId,
      'customer_name': customerName,
      'monthly_amount': monthlyAmount,
      'billing_day': billingDay,
    };
  }
}
