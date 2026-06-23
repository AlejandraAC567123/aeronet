import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:aeronet_app_flutter/data/models/invoice_model.dart';
import 'package:aeronet_app_flutter/shared/widgets/glass_container.dart';
import 'package:aeronet_app_flutter/core/utils/helpers.dart';
import 'package:aeronet_app_flutter/shared/extensions/string_extensions.dart';
import 'package:aeronet_app_flutter/data/repositories/invoice_repository.dart';

class InvoiceCard extends StatefulWidget {
  const InvoiceCard({
    super.key,
    required this.invoice,
    required this.onSimulatePayment,
    required this.isLoading,
  });

  final InvoiceModel invoice;
  final VoidCallback onSimulatePayment;
  final bool isLoading;

  @override
  State<InvoiceCard> createState() => _InvoiceCardState();
}

class _InvoiceCardState extends State<InvoiceCard> {
  bool _generatingLink = false;

  Future<void> _pay(String documentType) async {
    setState(() => _generatingLink = true);
    try {
      final response = await InvoiceRepository.instance.generatePaymentLink(
        widget.invoice.id,
        documentType,
      );
      final url = '${response['init_point'] ?? response['payment_url'] ?? response['url'] ?? ''}';
      if (url.isNotEmpty) {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (mounted) showMessage(context, 'No se pudo abrir el navegador para la URL.');
        }
      } else {
        if (mounted) showMessage(context, 'El servidor no devolvió un enlace de pago válido.');
      }
    } catch (e) {
      if (mounted) showMessage(context, e.toString());
    } finally {
      if (mounted) setState(() => _generatingLink = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final invoice = widget.invoice;
    final isPaid = invoice.status.toLowerCase() == 'paid' || invoice.status.toLowerCase() == 'approved';
    final isOverdue = invoice.status.toLowerCase() == 'overdue';
    
    Color statusColor = const Color(0xFF2DD4BF); // Teal for paid
    if (!isPaid) {
      statusColor = isOverdue ? Colors.redAccent : Colors.orangeAccent;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    invoice.status.cleanStatus(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                    const Text('Monto Total', style: TextStyle(color: Colors.white60, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(
                      money(invoice.amount),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                if (invoice.dueDate != null && invoice.dueDate!.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Vencimiento', style: TextStyle(color: Colors.white60, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(
                        invoice.dueDate!.split('T')[0],
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
              ],
            ),
            if (!isPaid) ...[
              const SizedBox(height: 16),
              const Divider(color: Colors.white10),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: widget.isLoading || _generatingLink ? null : () => _pay('BOLETA'),
                      icon: const Icon(Icons.receipt_long_outlined, size: 16),
                      label: const Text('Boleta'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: widget.isLoading || _generatingLink ? null : () => _pay('FACTURA'),
                      icon: const Icon(Icons.business_outlined, size: 16),
                      label: const Text('Factura'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: widget.isLoading || _generatingLink ? null : widget.onSimulatePayment,
                  icon: widget.isLoading
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.payment_outlined, size: 16),
                  label: const Text('Simular Pago'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
