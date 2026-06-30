import 'package:flutter/material.dart';
import 'package:aeronet_app_flutter/data/models/service_model.dart';
import 'package:aeronet_app_flutter/data/models/customer_model.dart';
import 'package:aeronet_app_flutter/data/models/plan_model.dart';
import 'package:aeronet_app_flutter/data/repositories/service_repository.dart';
import 'package:aeronet_app_flutter/data/repositories/customer_repository.dart';
import 'package:aeronet_app_flutter/data/repositories/plan_repository.dart';
import 'package:aeronet_app_flutter/data/services/api_client.dart';

class ServicesAdminProvider extends ChangeNotifier {
  List<ServiceModel> _services = [];
  List<CustomerModel> _customers = [];
  List<PlanModel> _plans = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ServiceModel> get services => _services;
  List<CustomerModel> get customers => _customers;
  List<PlanModel> get plans => _plans;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadServices() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        ServiceRepository.instance.getServices(),
        CustomerRepository.instance.getCustomers(),
        PlanRepository.instance.getPlans(),
      ]);
      _services = results[0] as List<ServiceModel>;
      _customers = results[1] as List<CustomerModel>;
      _plans = results[2] as List<PlanModel>;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createService(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      await ApiClient.instance.post('/services', data);
      _services = await ServiceRepository.instance.getServices();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateService(String id, Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      await ServiceRepository.instance.updateService(id, data);
      _services = await ServiceRepository.instance.getServices();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteService(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await ServiceRepository.instance.deleteService(id);
      _services = await ServiceRepository.instance.getServices();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
