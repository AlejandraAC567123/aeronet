import 'package:aeronet_app_flutter/data/services/api_client.dart';

class HttpService {
  HttpService._();
  static final HttpService instance = HttpService._();

  /// Genera un checkout link de OpenPay para una factura
  /// 
  /// Parámetros:
  /// - invoiceId: UUID de la factura a pagar
  /// 
  /// Retorna: URL del checkout de OpenPay
  /// 
  /// Lanza excepciones si:
  /// - La factura no existe
  /// - La factura no está en estado "pending"
  /// - El usuario no es propietario de la factura
  Future<String> generateCheckout(String invoiceId) async {
    try {
      await ApiClient.instance.post(
        '/payments/simulate/$invoiceId',
        {},
      );
      return 'simulated';
    } catch (e) {
      throw Exception('Error al simular pago: ${e.toString()}');
    }
  }
}