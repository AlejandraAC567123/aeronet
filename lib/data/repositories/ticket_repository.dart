import 'package:aeronet_app_flutter/data/services/api_client.dart';
import 'package:aeronet_app_flutter/data/models/ticket_model.dart';
import 'package:aeronet_app_flutter/core/utils/helpers.dart';

class TicketRepository {
  TicketRepository._();
  static final TicketRepository instance = TicketRepository._();

  // Backend API Operations
  Future<List<TicketModel>> getTickets() async {
    final response = await ApiClient.instance.get('/tickets');
    final list = asList(response);
    return list.map((e) => TicketModel.fromJson(asMap(e))).toList();
  }

  Future<List<TicketModel>> getMyTickets() async {
    final response = await ApiClient.instance.get('/tickets/my-tickets');
    final list = asList(response);
    return list.map((e) => TicketModel.fromJson(asMap(e))).toList();
  }

  Future<List<TicketModel>> getAssignedToMe() async {
    final response = await ApiClient.instance.get('/tickets/assigned/me');
    final list = asList(response);
    return list.map((e) => TicketModel.fromJson(asMap(e))).toList();
  }

  Future<TicketModel> createTicket(Map<String, dynamic> data) async {
    final response = await ApiClient.instance.post('/tickets', data);
    return TicketModel.fromJson(asMap(response));
  }

  Future<TicketModel> updateTicket(String id, Map<String, dynamic> data) async {
    final response = await ApiClient.instance.patch('/tickets/$id', data);
    return TicketModel.fromJson(asMap(response));
  }

  Future<void> deleteTicket(String id) async {
    await ApiClient.instance.delete('/tickets/$id');
  }
}
