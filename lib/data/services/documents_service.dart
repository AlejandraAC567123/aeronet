import 'package:aeronet_app_flutter/data/services/api_client.dart';

class DocumentsService {
  DocumentsService._();
  static final DocumentsService instance = DocumentsService._();

  /// Obtiene los comprobantes (boleta/factura) de una factura
  Future<List<Map<String, dynamic>>> getInvoiceDocuments(String invoiceId) async {
    try {
      final response = await ApiClient.instance.get(
        '/documentos-electrónicos/factura/$invoiceId',
      );
      
      // Response es lista de documentos
      if (response is List) {
        return List<Map<String, dynamic>>.from(response);
      }
      return [];
    } catch (e) {
      throw Exception('Error al obtener comprobantes: $e');
    }
  }

  /// URL del PDF para descargar
  String getPdfUrl(Map<String, dynamic> document) {
    return document['pdf_url'] ?? '';
  }

  /// Tipo de documento (BOLETA, FACTURA, etc.)
  String getDocumentType(Map<String, dynamic> document) {
    final tipo = document['tipo'] ?? 'COMPROBANTE';
    return tipo.toString().toUpperCase();
  }
}
