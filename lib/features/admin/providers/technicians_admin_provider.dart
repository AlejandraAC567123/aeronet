import 'package:flutter/material.dart';
import 'package:aeronet_app_flutter/data/models/technician_model.dart';
import 'package:aeronet_app_flutter/data/repositories/technician_repository.dart';

class TechniciansAdminProvider extends ChangeNotifier {
  List<TechnicianModel> _technicians = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<TechnicianModel> get technicians => _technicians;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadTechnicians() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _technicians = await TechnicianRepository.instance.getTechnicians();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createTechnician(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      await TechnicianRepository.instance.createTechnician(data);
      _technicians = await TechnicianRepository.instance.getTechnicians();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTechnician(String id, Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      await TechnicianRepository.instance.updateTechnician(id, data);
      _technicians = await TechnicianRepository.instance.getTechnicians();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteTechnician(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await TechnicianRepository.instance.deleteTechnician(id);
      _technicians = await TechnicianRepository.instance.getTechnicians();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
