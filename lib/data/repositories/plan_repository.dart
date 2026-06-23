import 'package:aeronet_app_flutter/data/services/api_client.dart';
import 'package:aeronet_app_flutter/data/models/plan_model.dart';
import 'package:aeronet_app_flutter/core/utils/helpers.dart';

class PlanRepository {
  PlanRepository._();
  static final PlanRepository instance = PlanRepository._();

  Future<List<PlanModel>> getPlans() async {
    final response = await ApiClient.instance.get('/plans');
    final list = asList(response);
    return list.map((e) => PlanModel.fromJson(asMap(e))).toList();
  }

  Future<PlanModel> createPlan(Map<String, dynamic> data) async {
    final response = await ApiClient.instance.post('/plans', data);
    return PlanModel.fromJson(asMap(response));
  }

  Future<PlanModel> updatePlan(String id, Map<String, dynamic> data) async {
    final response = await ApiClient.instance.patch('/plans/$id', data);
    return PlanModel.fromJson(asMap(response));
  }

  Future<void> deletePlan(String id) async {
    await ApiClient.instance.delete('/plans/$id');
  }
}
