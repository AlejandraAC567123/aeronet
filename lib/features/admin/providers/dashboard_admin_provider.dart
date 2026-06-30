import 'package:flutter/material.dart';
import 'package:aeronet_app_flutter/data/models/customer_model.dart';
import 'package:aeronet_app_flutter/data/models/ticket_model.dart';
import 'package:aeronet_app_flutter/data/models/invoice_model.dart';
import 'package:aeronet_app_flutter/data/models/payment_model.dart';
import 'package:aeronet_app_flutter/data/models/service_model.dart';
import 'package:aeronet_app_flutter/data/repositories/customer_repository.dart';
import 'package:aeronet_app_flutter/data/repositories/ticket_repository.dart';
import 'package:aeronet_app_flutter/data/repositories/invoice_repository.dart';
import 'package:aeronet_app_flutter/data/repositories/payment_repository.dart';
import 'package:aeronet_app_flutter/data/repositories/service_repository.dart';

class DashboardAdminProvider extends ChangeNotifier {
  List<CustomerModel> _customers = [];
  List<TicketModel> _tickets = [];
  List<InvoiceModel> _invoices = [];
  List<PaymentModel> _payments = [];
  List<ServiceModel> _services = [];
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get totalCustomers => _customers.length;
  int get totalActiveServices => _services.where((s) => s.status.toLowerCase() == 'active' || s.status.toLowerCase() == 'activo').length;
  int get totalPendingTickets => _tickets.where((t) => t.status.toLowerCase() == 'open' || t.status.toLowerCase() == 'in_progress').length;
  double get totalOutstandingAmount => _invoices.where((i) => i.status.toLowerCase() == 'pending').fold(0.0, (sum, i) => sum + i.amount);
  
  List<PaymentModel> get recentPayments {
    final list = List<PaymentModel>.from(_payments);
    list.sort((a, b) {
      final dateA = a.createdAt ?? a.paymentDate ?? '';
      final dateB = b.createdAt ?? b.paymentDate ?? '';
      return dateB.compareTo(dateA);
    });
    return list.take(5).toList();
  }

  Future<void> loadDashboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        CustomerRepository.instance.getCustomers(),
        TicketRepository.instance.getTickets(),
        InvoiceRepository.instance.getInvoices(),
        PaymentRepository.instance.getPayments(),
        ServiceRepository.instance.getServices(),
      ]);
      _customers = results[0] as List<CustomerModel>;
      _tickets = results[1] as List<TicketModel>;
      _invoices = results[2] as List<InvoiceModel>;
      _payments = results[3] as List<PaymentModel>;
      _services = results[4] as List<ServiceModel>;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
