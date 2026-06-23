import 'package:aeronet_app_flutter/data/services/api_client.dart';
import 'package:aeronet_app_flutter/data/models/technician_model.dart';
import 'package:aeronet_app_flutter/core/utils/helpers.dart';

class TechnicianRepository {
  TechnicianRepository._();
  static final TechnicianRepository instance = TechnicianRepository._();

  Future<List<TechnicianModel>> getTechnicians() async {
    // In backend endpoint can be GET /technician or /technicians. 
    // The instructions say: GET /technician. Let's make sure it matches.
    final response = await ApiClient.instance.get('/technician');
    final list = asList(response);
    return list.map((e) => TechnicianModel.fromJson(asMap(e))).toList();
  }

  Future<TechnicianModel> createTechnician(Map<String, dynamic> data) async {
    final response = await ApiClient.instance.post('/technician', data);
    return TechnicianModel.fromJson(asMap(response));
  }

  Future<TechnicianModel> updateTechnician(String id, Map<String, dynamic> data) async {
    final response = await ApiClient.instance.patch('/technician/$id', data);
    return TechnicianModel.fromJson(asMap(response));
  }

  Future<void> deleteTechnician(String id) async {
    await ApiClient.instance.delete('/technician/$id');
  }
}
