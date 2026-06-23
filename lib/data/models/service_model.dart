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

  ServiceModel({
    required this.id,
    required this.address,
    required this.status,
    this.plan,
    this.reference,
    this.latitude,
    this.longitude,
    this.customerId,
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
    };
  }
}
