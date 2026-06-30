import 'package:flutter/material.dart';
import 'package:aeronet_app_flutter/data/models/customer_model.dart';
import 'package:aeronet_app_flutter/data/repositories/customer_repository.dart';

class CustomersAdminProvider extends ChangeNotifier {
  List<CustomerModel> _customers = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<CustomerModel> get customers => _customers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadCustomers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _customers = await CustomerRepository.instance.getCustomers();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createCustomer(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (data.containsKey('password')) {
        await CustomerRepository.instance.signupClient(data);
      } else {
        await CustomerRepository.instance.createCustomer(data);
      }
      _customers = await CustomerRepository.instance.getCustomers();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCustomer(String id, Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      await CustomerRepository.instance.updateCustomer(id, data);
      _customers = await CustomerRepository.instance.getCustomers();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCustomer(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await CustomerRepository.instance.deleteCustomer(id);
      _customers = await CustomerRepository.instance.getCustomers();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
