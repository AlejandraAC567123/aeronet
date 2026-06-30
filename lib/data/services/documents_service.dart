import 'package:aeronet_app_flutter/data/services/api_client.dart';

class DocumentsService {
  DocumentsService._();
  static final DocumentsService instance = DocumentsService._();

  /// Obtiene los comprobantes (boleta/factura) de una factura
  Future<List<Map<String, dynamic>>> getInvoiceDocuments(String invoiceId) async {
    try {
      final response = await ApiClient.instance.get(
        '/electronic-documents/invoice/$invoiceId',
      );
      
      // Response es lista de documentos
      if (response is List) {
        return List<Map<String, dynamic>>.from(response);
      } else if (response is Map<String, dynamic>) {
        return [response];
      }
      return [];
    } catch (e) {
      throw Exception('Error al obtener comprobantes: $e');
    }
  }

  /// URL del PDF para descargar
  String getPdfUrl(Map<String, dynamic> document) {
    return (document['pdf_url'] ?? document['pdf_link'] ?? '').toString();
  }

  /// Tipo de documento (BOLETA, FACTURA, etc.)
  String getDocumentType(Map<String, dynamic> document) {
    final tipo = document['tipo'] ?? 'COMPROBANTE';
    return tipo.toString().toUpperCase();
  }
}
