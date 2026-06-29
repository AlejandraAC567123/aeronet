import 'package:aeronet_app_flutter/data/services/api_client.dart';
import 'package:aeronet_app_flutter/data/models/invoice_model.dart';
import 'package:aeronet_app_flutter/core/utils/helpers.dart';

class InvoiceRepository {
  InvoiceRepository._();
  static final InvoiceRepository instance = InvoiceRepository._();

  Future<List<InvoiceModel>> getInvoices() async {
    final response = await ApiClient.instance.get('/invoices');
    final list = asList(response);
    return list.map((e) => InvoiceModel.fromJson(asMap(e))).toList();
  }

  Future<List<InvoiceModel>> getMyDebts() async {
    final response = await ApiClient.instance.get('/invoices/my-debts');
    final list = asList(response);
    return list.map((e) => InvoiceModel.fromJson(asMap(e))).toList();
  }

  Future<InvoiceModel> updateInvoice(String id, Map<String, dynamic> data) async {
    final response = await ApiClient.instance.patch('/invoices/$id', data);
    return InvoiceModel.fromJson(asMap(response));
  }

  // Generate Mercado Pago Link
  // NOTA: /payments/generate-link no existe aún en el backend.
  // Usamos /payments/simulate como fallback hasta que Alejandro lo implemente.
  Future<Map<String, dynamic>> generatePaymentLink(String invoiceId, String documentType) async {
    final response = await ApiClient.instance.post('/payments/simulate/$invoiceId', {
      'chosenDocumentType': documentType,
    });
    return asMap(response);
  }

  // Simulate Payment
  Future<Map<String, dynamic>> simulatePayment(String invoiceId) async {
    final response = await ApiClient.instance.post('/payments/simulate/$invoiceId', {});
    return asMap(response);
  }
}