import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:aeronet_app_flutter/data/models/invoice_model.dart';
import 'package:aeronet_app_flutter/shared/widgets/glass_container.dart';
import 'package:aeronet_app_flutter/core/utils/helpers.dart';
import 'package:aeronet_app_flutter/data/services/documents_service.dart';
import 'package:aeronet_app_flutter/shared/extensions/string_extensions.dart';
import 'package:aeronet_app_flutter/shared/widgets/status_badge.dart';
import 'package:aeronet_app_flutter/core/theme/app_theme.dart';

class AdminInvoiceCard extends StatefulWidget {
  final InvoiceModel invoice;

  const AdminInvoiceCard({super.key, required this.invoice});

  @override
  State<AdminInvoiceCard> createState() => _AdminInvoiceCardState();
}

class _AdminInvoiceCardState extends State<AdminInvoiceCard> {
  bool _loadingDocuments = false;
  List<Map<String, dynamic>> _documents = [];
  bool _documentsLoaded = false;

  bool get _isPaidOrInvoiced =>
      widget.invoice.status.toLowerCase() == 'paid' ||
      widget.invoice.status.toLowerCase() == 'approved' ||
      widget.invoice.status.toLowerCase() == 'invoiced';

  Future<void> _loadDocuments() async {
    if (!mounted) return;
    setState(() => _loadingDocuments = true);
    try {
      final docs = await DocumentsService.instance
          .getInvoiceDocuments(widget.invoice.id);
      if (mounted) {
        setState(() {
          _documents = docs;
          _documentsLoaded = true;
        });
      }
    } catch (e) {
      debugPrint('Error cargando comprobantes: $e');
    } finally {
      if (mounted) {
        setState(() => _loadingDocuments = false);
      }
    }
  }

  Future<void> _downloadPdf(String pdfUrl) async {
    if (pdfUrl.isEmpty) return;
    try {
      final uri = Uri.parse(pdfUrl);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        if (mounted) {
          showMessage(context, 'No se pudo abrir el comprobante, intenta de nuevo');
        }
      }
    } catch (e) {
      if (mounted) {
        showMessage(context, 'No se pudo abrir el comprobante, intenta de nuevo');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final invoice = widget.invoice;
    final isPaid = _isPaidOrInvoiced;
    final isOverdue = invoice.status.toLowerCase() == 'overdue';
    StatusType statusType;
    if (isPaid) {
      statusType = StatusType.active;
    } else if (isOverdue) {
      statusType = StatusType.error;
    } else {
      statusType = StatusType.pending;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Factura #${shortId(invoice.id)}',
                  style: const TextStyle(
                    color: AppTheme.textPrimaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                StatusBadge(
                  label: invoice.status.cleanStatus().toUpperCase(),
                  type: statusType,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Cliente', style: TextStyle(color: AppTheme.textSecondaryColor, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(
                      invoice.customerName ?? invoice.customerId,
                      style: const TextStyle(color: AppTheme.textPrimaryColor, fontWeight: FontWeight.w500, fontSize: 13),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Monto', style: TextStyle(color: AppTheme.textSecondaryColor, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(
                      money(invoice.amount),
                      style: const TextStyle(
                        color: AppTheme.textPrimaryColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            if (isPaid) ...[
              const SizedBox(height: 16),
              const Divider(color: AppTheme.borderDividerColor),
              const SizedBox(height: 8),
              const SizedBox(height: 8),
              if (!_documentsLoaded && !_loadingDocuments)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.accentColor),
                      foregroundColor: AppTheme.accentColor,
                    ),
                    onPressed: _loadDocuments,
                    icon: const Icon(Icons.picture_as_pdf, size: 16),
                    label: const Text('Ver Boleta / Factura'),
                  ),
                )
              else if (_loadingDocuments)
                const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
                    ),
                  ),
                )
              else if (_documents.isNotEmpty)
                ..._documents.where((doc) {
                  final pdfUrl = DocumentsService.instance.getPdfUrl(doc);
                  return pdfUrl.isNotEmpty;
                }).map((doc) {
                  final tipo = DocumentsService.instance.getDocumentType(doc);
                  final pdfUrl = DocumentsService.instance.getPdfUrl(doc);
                  final labelText = tipo.contains('FACTURA') ? 'Descargar factura' : 'Descargar boleta';
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.accentColor.withValues(alpha: 0.2),
                          foregroundColor: AppTheme.accentColor,
                        ),
                        onPressed: () => _downloadPdf(pdfUrl),
                        icon: const Icon(Icons.download, size: 16),
                        label: Text(labelText),
                      ),
                    ),
                  );
                })
              else
                const Center(
                  child: Text('No hay comprobantes disponibles', style: TextStyle(color: AppTheme.textSecondaryColor, fontSize: 12)),
                ),
            ]
          ],
        ),
      ),
    );
  }
}
