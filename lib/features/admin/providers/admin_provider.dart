import 'package:flutter/material.dart';
import 'package:aeronet_app_flutter/data/models/customer_model.dart';
import 'package:aeronet_app_flutter/data/models/plan_model.dart';
import 'package:aeronet_app_flutter/data/models/ticket_model.dart';
import 'package:aeronet_app_flutter/data/models/invoice_model.dart';
import 'package:aeronet_app_flutter/data/models/technician_model.dart';
import 'package:aeronet_app_flutter/data/repositories/customer_repository.dart';
import 'package:aeronet_app_flutter/data/repositories/plan_repository.dart';
import 'package:aeronet_app_flutter/data/repositories/ticket_repository.dart';
import 'package:aeronet_app_flutter/data/repositories/invoice_repository.dart';
import 'package:aeronet_app_flutter/data/repositories/technician_repository.dart';
import 'package:aeronet_app_flutter/data/models/payment_model.dart';
import 'package:aeronet_app_flutter/data/models/service_model.dart';
import 'package:aeronet_app_flutter/data/repositories/payment_repository.dart';
import 'package:aeronet_app_flutter/data/repositories/service_repository.dart';

class AdminProvider extends ChangeNotifier {
  List<CustomerModel> _customers = [];
  List<PlanModel> _plans = [];
  List<TicketModel> _tickets = [];
  List<InvoiceModel> _invoices = [];
  List<TechnicianModel> _technicians = [];
  List<PaymentModel> _payments = [];
  List<ServiceModel> _services = [];

  bool _isLoading = false;
  String? _errorMessage;

  List<CustomerModel> get customers => _customers;
  List<PlanModel> get plans => _plans;
  List<TicketModel> get tickets => _tickets;
  List<InvoiceModel> get invoices => _invoices;
  List<TechnicianModel> get technicians => _technicians;
  List<PaymentModel> get payments => _payments;
  List<ServiceModel> get services => _services;

  // Computed properties for Dashboard
  int get totalCustomers => _customers.length;
  
  int get totalActiveServices {
    return _services.where((s) => s.status.toLowerCase() == 'active' || s.status.toLowerCase() == 'activo').length;
  }
  
  int get totalPendingTickets {
    return _tickets.where((t) => t.status.toLowerCase() == 'open' || t.status.toLowerCase() == 'in_progress').length;
  }
  
  double get totalOutstandingAmount {
    return _invoices.where((i) => i.status.toLowerCase() == 'pending').fold(0.0, (sum, i) => sum + i.amount);
  }
  
  List<PaymentModel> get recentPayments {
    final list = List<PaymentModel>.from(_payments);
    list.sort((a, b) {
      final dateA = a.createdAt ?? a.paymentDate ?? '';
      final dateB = b.createdAt ?? b.paymentDate ?? '';
      return dateB.compareTo(dateA); // descending
    });
    return list.take(5).toList();
  }
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadAllAdminData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await Future.wait([
        _fetchCustomers(),
        _fetchPlans(),
        _fetchTickets(),
        _fetchInvoices(),
        _fetchTechnicians(),
        _fetchPayments(),
        _fetchServices(),
      ]);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCustomers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _fetchCustomers();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPlans() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _fetchPlans();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTickets() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _fetchTickets();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadInvoices() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _fetchInvoices();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTechnicians() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _fetchTechnicians();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPayments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _fetchPayments();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadServices() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _fetchServices();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch helpers
  Future<void> _fetchCustomers() async {
    _customers = await CustomerRepository.instance.getCustomers();
  }

  Future<void> _fetchPlans() async {
    _plans = await PlanRepository.instance.getPlans();
  }

  Future<void> _fetchTickets() async {
    _tickets = await TicketRepository.instance.getTickets();
  }

  Future<void> _fetchInvoices() async {
    _invoices = await InvoiceRepository.instance.getInvoices();
  }

  Future<void> _fetchTechnicians() async {
    _technicians = await TechnicianRepository.instance.getTechnicians();
  }

  Future<void> _fetchPayments() async {
    _payments = await PaymentRepository.instance.getPayments();
  }

  Future<void> _fetchServices() async {
    _services = await ServiceRepository.instance.getServices();
  }

  // Customers actions
  Future<void> createCustomer(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (data.containsKey('password')) {
        // Con contraseña → /auth/signup-client (crea usuario + perfil)
        await CustomerRepository.instance.signupClient(data);
      } else {
        // Sin contraseña → /customers (solo perfil)
        await CustomerRepository.instance.createCustomer(data);
      }
      await _fetchCustomers();
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
      await _fetchCustomers();
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
      await _fetchCustomers();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Plans actions
  Future<void> createPlan(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      await PlanRepository.instance.createPlan(data);
      await _fetchPlans();
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
      await _fetchPlans();
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
      await _fetchPlans();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Ticket status update
  Future<void> updateTicketStatus(String id, String status, {String? resolutionNotes}) async {
    try {
      await TicketRepository.instance.updateTicket(id, {
        'status': status,
        if (resolutionNotes != null && resolutionNotes.trim().isNotEmpty)
          'resolution_notes': resolutionNotes.trim(),
      });
      await _fetchTickets();
    } catch (_) {}
  }

  // Technicians actions
  Future<void> createTechnician(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      await TechnicianRepository.instance.createTechnician(data);
      await _fetchTechnicians();
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
      await _fetchTechnicians();
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
      await _fetchTechnicians();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}