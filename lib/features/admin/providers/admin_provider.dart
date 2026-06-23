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

class AdminProvider extends ChangeNotifier {
  List<CustomerModel> _customers = [];
  List<PlanModel> _plans = [];
  List<TicketModel> _tickets = [];
  List<InvoiceModel> _invoices = [];
  List<TechnicianModel> _technicians = [];

  bool _isLoading = false;
  String? _errorMessage;

  List<CustomerModel> get customers => _customers;
  List<PlanModel> get plans => _plans;
  List<TicketModel> get tickets => _tickets;
  List<InvoiceModel> get invoices => _invoices;
  List<TechnicianModel> get technicians => _technicians;
  
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

  // Customers actions
  Future<void> createCustomer(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      await CustomerRepository.instance.createCustomer(data);
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
  Future<void> updateTicketStatus(String id, String status) async {
    try {
      await TicketRepository.instance.updateTicket(id, {'status': status});
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
