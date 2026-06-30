import 'package:flutter/material.dart';
import 'package:aeronet_app_flutter/data/models/ticket_model.dart';
import 'package:aeronet_app_flutter/data/repositories/ticket_repository.dart';
import 'package:aeronet_app_flutter/data/models/technician_model.dart';
import 'package:aeronet_app_flutter/data/repositories/technician_repository.dart';

class TicketsAdminProvider extends ChangeNotifier {
  List<TicketModel> _tickets = [];
  List<TechnicianModel> _technicians = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<TicketModel> get tickets => _tickets;
  List<TechnicianModel> get technicians => _technicians;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadTickets() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _tickets = await TicketRepository.instance.getTickets();
      _technicians = await TechnicianRepository.instance.getTechnicians();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTicketStatus(String id, String status, {String? resolutionNotes, String? technicianId}) async {
    _isLoading = true;
    notifyListeners();
    try {
      await TicketRepository.instance.updateTicket(id, {
        'status': status,
        if (resolutionNotes != null && resolutionNotes.trim().isNotEmpty)
          'resolution_notes': resolutionNotes.trim(),
        if (technicianId != null && technicianId.isNotEmpty)
          'technician_id': technicianId,
      });
      _tickets = await TicketRepository.instance.getTickets();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
