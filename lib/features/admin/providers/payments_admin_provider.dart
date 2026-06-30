import 'package:flutter/material.dart';
import 'package:aeronet_app_flutter/data/models/payment_model.dart';
import 'package:aeronet_app_flutter/data/repositories/payment_repository.dart';

class PaymentsAdminProvider extends ChangeNotifier {
  List<PaymentModel> _payments = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<PaymentModel> get payments => _payments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadPayments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _payments = await PaymentRepository.instance.getPayments();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
