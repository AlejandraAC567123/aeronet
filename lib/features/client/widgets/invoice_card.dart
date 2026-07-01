import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:aeronet_app_flutter/data/models/invoice_model.dart';
import 'package:aeronet_app_flutter/shared/widgets/glass_container.dart';
import 'package:aeronet_app_flutter/core/utils/helpers.dart';
import 'package:aeronet_app_flutter/shared/extensions/string_extensions.dart';
import 'package:aeronet_app_flutter/data/services/documents_service.dart';
import 'package:aeronet_app_flutter/shared/widgets/status_badge.dart';
import 'package:aeronet_app_flutter/core/theme/app_theme.dart';

class InvoiceCard extends StatefulWidget {
  const InvoiceCard({
    super.key,
    required this.invoice,
    required this.onPayment,
    required this.isLoading,
  });

  final InvoiceModel invoice;
  final VoidCallback onPayment;
  final bool isLoading;

  @override
  State<InvoiceCard> createState() => _InvoiceCardState();
}

class _InvoiceCardState extends State<InvoiceCard> {
  bool _processingPayment = false;
  bool _loadingDocuments = false;
  List<Map<String, dynamic>> _documents = [];

  @override
  void initState() {
    super.initState();
    // Cargar comprobantes si la factura está en estado pagado/aprobado/facturado
    if (_isPaidOrInvoiced) {
      _loadDocuments();
    }
  }

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
        setState(() => _documents = docs);
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

  StatusType _getStatusType(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'approved':
      case 'invoiced':
        return StatusType.active;
      case 'overdue':
        return StatusType.error;
      default:
        return StatusType.pending;
    }
  }

  @override
  Widget build(BuildContext context) {
    final invoice = widget.invoice;
    final isPending = invoice.status.toLowerCase() == 'pending';
    final isPaid = _isPaidOrInvoiced;
    final isOverdue = invoice.status.toLowerCase() == 'overdue';
    final statusType = _getStatusType(invoice.status);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ENCABEZADO
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Factura #${shortId(invoice.id)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                StatusBadge(
                  label: invoice.status.cleanStatus().toUpperCase(),
                  type: statusType,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // MONTO Y VENCIMIENTO
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Monto Total',
                          style: TextStyle(color: AppTheme.textSecondaryColor, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(
                        money(invoice.amount),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (invoice.dueDate != null && invoice.dueDate!.isNotEmpty)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Vencimiento',
                            style: TextStyle(color: AppTheme.textSecondaryColor, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text(
                          invoice.dueDate!.split('T')[0],
                          style: const TextStyle(
                            color: AppTheme.textPrimaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            // BOTONES
            if (isPending) ...[
              const SizedBox(height: 16),
              const Divider(color: AppTheme.borderDividerColor),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: (widget.isLoading || _processingPayment) ? null : () async {
                    setState(() => _processingPayment = true);
                    try {
                      widget.onPayment();
                    } finally {
                      if (mounted) setState(() => _processingPayment = false);
                    }
                  },
                  icon: _processingPayment || widget.isLoading
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.textPrimaryColor,
                          ),
                        )
                      : const Icon(Icons.payment_outlined, size: 16),
                  label: const Text('Pagar con OpenPay'),
                ),
              ),
            ] else if (isPaid) ...[
              const SizedBox(height: 12),
              Center(
                child: Text(
                  '✓ Pagado',
                  style: const TextStyle(
                    color: AppTheme.accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              
              // Lista de comprobantes
              if (_documents.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(color: AppTheme.borderDividerColor),
                const SizedBox(height: 8),
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
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.accentColor),
                          foregroundColor: AppTheme.accentColor,
                        ),
                        onPressed: () => _downloadPdf(pdfUrl),
                        icon: const Icon(Icons.download, size: 16),
                        label: Text(labelText),
                      ),
                    ),
                  );
                }),
              ] else if (_loadingDocuments) ...[
                const SizedBox(height: 12),
                const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
                    ),
                  ),
                ),
              ],
            ] else if (isOverdue) ...[
              const SizedBox(height: 16),
              const Divider(color: AppTheme.borderDividerColor),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: (widget.isLoading || _processingPayment) ? null : () async {
                    setState(() => _processingPayment = true);
                    try {
                      widget.onPayment();
                    } finally {
                      if (mounted) setState(() => _processingPayment = false);
                    }
                  },
                  icon: _processingPayment || widget.isLoading
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.textPrimaryColor,
                          ),
                        )
                      : const Icon(Icons.payment_outlined, size: 16),
                  label: const Text('Pagar Ahora'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}