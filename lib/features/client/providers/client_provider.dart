import 'package:flutter/material.dart';
import 'package:aeronet_app_flutter/data/models/invoice_model.dart';
import 'package:aeronet_app_flutter/data/models/service_model.dart';
import 'package:aeronet_app_flutter/data/models/ticket_model.dart';
import 'package:aeronet_app_flutter/data/models/plan_model.dart';
import 'package:aeronet_app_flutter/data/repositories/invoice_repository.dart';
import 'package:aeronet_app_flutter/data/repositories/service_repository.dart';
import 'package:aeronet_app_flutter/data/repositories/ticket_repository.dart';
import 'package:aeronet_app_flutter/data/repositories/plan_repository.dart';
import 'package:aeronet_app_flutter/core/utils/local_notifier.dart';

class ClientProvider extends ChangeNotifier {
  List<InvoiceModel> _myDebts = [];
  List<ServiceModel> _myServices = [];
  List<TicketModel> _myTickets = [];
  List<PlanModel> _allPlans = [];
  
  bool _isLoading = false;
  String? _errorMessage;
  int _currentTabIndex = 0; // Control de navegación programática

  List<InvoiceModel> get myDebts => _myDebts;
  List<ServiceModel> get myServices => _myServices;
  List<TicketModel> get myTickets => _myTickets;
  List<PlanModel> get allPlans => _allPlans;
  int get currentTabIndex => _currentTabIndex;

  void setTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadDashboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await Future.wait([
        _fetchDebts(),
        _fetchServices(),
        _fetchTickets(),
        _fetchPlans(),
      ]);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMyDebts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _fetchDebts();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMyServices() async {
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

  Future<void> loadMyTickets() async {
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

  // Repository fetch helpers
  Future<void> _fetchDebts() async {
    _myDebts = await InvoiceRepository.instance.getMyDebts();
  }

  Future<void> _fetchServices() async {
    _myServices = await ServiceRepository.instance.getMyServices();
  }

  Future<void> _fetchTickets() async {
    _myTickets = await TicketRepository.instance.getMyTickets();
  }

  Future<void> _fetchPlans() async {
    _allPlans = await PlanRepository.instance.getPlans();
  }

  // Simulate Invoice Payment
  Future<void> simulateInvoicePayment(String invoiceId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await InvoiceRepository.instance.simulatePayment(invoiceId);
      await LocalNotifier.instance.show(
        'Pago Exitoso',
        '¡Tu pago de la factura ha sido procesado y aprobado!',
      );
      await _fetchDebts();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Request Installation
  Future<void> requestInstallation({
    required String planId,
    required String fullName,
    required String documentType,
    required String documentNumber,
    required String phone,
    required String addressText,
    double? latitude,
    double? longitude,
    String? ticketSubject,
    String? ticketDescription,
    String? ticketPriority,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await ServiceRepository.instance.requestInstallation(
        planId: planId,
        fullName: fullName,
        documentType: documentType,
        documentNumber: documentNumber,
        phone: phone,
        addressText: addressText,
        latitude: latitude,
        longitude: longitude,
        ticketSubject: ticketSubject,
        ticketDescription: ticketDescription,
        ticketPriority: ticketPriority,
      );
      await LocalNotifier.instance.show(
        'Solicitud de Instalación',
        'Tu pedido de instalación en $addressText ha sido recibido.',
      );
      await _fetchServices();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create Ticket
  Future<void> createSupportTicket({
    required String subject,
    required String description,
    required String category,
    required String priority,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await TicketRepository.instance.createTicket({
        'type': 'ticket',
        'subject': subject,
        'description': description,
        'category': category,
        'priority': priority,
      });
      await LocalNotifier.instance.show(
        'Ticket Enviado',
        'Hemos recibido tu ticket: $subject. Un asesor lo revisará pronto.',
      );
      await _fetchTickets();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Draft Actions removed
}
