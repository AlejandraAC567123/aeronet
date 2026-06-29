import 'package:aeronet_app_flutter/data/services/api_client.dart';
import 'package:aeronet_app_flutter/data/models/service_model.dart';
import 'package:aeronet_app_flutter/core/utils/helpers.dart';

class ServiceRepository {
  ServiceRepository._();
  static final ServiceRepository instance = ServiceRepository._();

  Future<List<ServiceModel>> getServices() async {
    final response = await ApiClient.instance.get('/services');
    final list = asList(response);
    return list.map((e) => ServiceModel.fromJson(asMap(e))).toList();
  }

  Future<List<ServiceModel>> getMyServices() async {
    final response = await ApiClient.instance.get('/services/my-services');
    final list = asList(response);
    return list.map((e) => ServiceModel.fromJson(asMap(e))).toList();
  }

  Future<ServiceModel> requestInstallation({
    required String planId,
    required String fullName,
    required String documentType,
    required String documentNumber,
    required String phone,
    required String addressText,
    double? latitude,
    double? longitude,
    String? ticketSubject,
    String? ticketDescription,
    String? ticketPriority,
  }) async {
    // Call the dedicated direct services installer endpoint
    final response = await ApiClient.instance.post('/services/with-ticket', {
      'plan_id': planId,
      'full_name': fullName,
      'document_type': documentType,
      'document_number': documentNumber,
      'phone': phone,
      'address_text': addressText,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'ticket_subject': ticketSubject ?? 'Solicitud de Instalación',
      'ticket_description': ticketDescription ?? 'Solicitud de instalación de plan de internet',
      'ticket_priority': ticketPriority ?? 'ALTA',
    });
    return ServiceModel.fromJson(asMap(response));
  }

  Future<ServiceModel> updateService(String id, Map<String, dynamic> data) async {
    final response = await ApiClient.instance.patch('/services/$id', data);
    return ServiceModel.fromJson(asMap(response));
  }

  Future<void> deleteService(String id) async {
    await ApiClient.instance.delete('/services/$id');
  }
}
