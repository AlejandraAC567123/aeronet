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
    required String address,
    required String reference,
    double? latitude,
    double? longitude,
  }) async {
    // Call the dedicated direct services installer endpoint
    final response = await ApiClient.instance.post('/services/with-ticket', {
      'plan_id': planId,
      'address': address,
      'reference': reference,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
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
