import 'package:flutter/material.dart';
import 'package:aeronet_app_flutter/data/models/invoice_model.dart';
import 'package:aeronet_app_flutter/data/models/service_model.dart';
import 'package:aeronet_app_flutter/data/repositories/invoice_repository.dart';
import 'package:aeronet_app_flutter/data/repositories/service_repository.dart';

class InvoicesAdminProvider extends ChangeNotifier {
  List<InvoiceModel> _invoices = [];
  List<ServiceModel> _services = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<InvoiceModel> get invoices => _invoices;
  List<ServiceModel> get services => _services;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadInvoices() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        InvoiceRepository.instance.getInvoices(),
        ServiceRepository.instance.getServices(),
      ]);
      _invoices = results[0] as List<InvoiceModel>;
      _services = results[1] as List<ServiceModel>;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createInvoice(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      await InvoiceRepository.instance.createInvoice(data);
      _invoices = await InvoiceRepository.instance.getInvoices();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateInvoice(String id, Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      await InvoiceRepository.instance.updateInvoice(id, data);
      _invoices = await InvoiceRepository.instance.getInvoices();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteInvoice(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await InvoiceRepository.instance.deleteInvoice(id);
      _invoices = await InvoiceRepository.instance.getInvoices();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> generateMonthlyInvoices(String period) async {
    _isLoading = true;
    notifyListeners();
    try {
      await InvoiceRepository.instance.generateMonthlyInvoices(period);
      _invoices = await InvoiceRepository.instance.getInvoices();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> forceBilling() async {
    _isLoading = true;
    notifyListeners();
    try {
      await InvoiceRepository.instance.forceBilling();
      _invoices = await InvoiceRepository.instance.getInvoices();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendWhatsappReminder(String id) async {
    try {
      await InvoiceRepository.instance.sendWhatsappReminder(id);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> simulatePayment(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await InvoiceRepository.instance.simulatePayment(id);
      _invoices = await InvoiceRepository.instance.getInvoices();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
