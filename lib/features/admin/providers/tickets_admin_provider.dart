import 'package:flutter/material.dart';
import 'package:aeronet_app_flutter/data/models/ticket_model.dart';
import 'package:aeronet_app_flutter/data/repositories/ticket_repository.dart';

class TicketsAdminProvider extends ChangeNotifier {
  List<TicketModel> _tickets = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<TicketModel> get tickets => _tickets;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadTickets() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _tickets = await TicketRepository.instance.getTickets();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTicketStatus(String id, String status, {String? resolutionNotes}) async {
    _isLoading = true;
    notifyListeners();
    try {
      await TicketRepository.instance.updateTicket(id, {
        'status': status,
        if (resolutionNotes != null && resolutionNotes.trim().isNotEmpty)
          'resolution_notes': resolutionNotes.trim(),
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
