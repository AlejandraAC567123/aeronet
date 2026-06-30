import 'package:flutter/material.dart';
import 'package:aeronet_app_flutter/data/models/plan_model.dart';
import 'package:aeronet_app_flutter/data/repositories/plan_repository.dart';

class PlansAdminProvider extends ChangeNotifier {
  List<PlanModel> _plans = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<PlanModel> get plans => _plans;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadPlans() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _plans = await PlanRepository.instance.getPlans();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createPlan(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      await PlanRepository.instance.createPlan(data);
      _plans = await PlanRepository.instance.getPlans();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePlan(String id, Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      await PlanRepository.instance.updatePlan(id, data);
      _plans = await PlanRepository.instance.getPlans();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deletePlan(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await PlanRepository.instance.deletePlan(id);
      _plans = await PlanRepository.instance.getPlans();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
