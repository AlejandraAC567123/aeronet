import 'package:flutter/material.dart';
import 'package:aeronet_app_flutter/core/utils/app_state_provider.dart';
import 'package:aeronet_app_flutter/features/admin/providers/invoices_admin_provider.dart';
import 'package:aeronet_app_flutter/shared/widgets/app_page.dart';
import 'package:aeronet_app_flutter/shared/widgets/loading_widget.dart';
import 'package:aeronet_app_flutter/shared/widgets/error_state.dart';
import 'package:aeronet_app_flutter/shared/widgets/empty_state.dart';
import 'package:aeronet_app_flutter/core/utils/helpers.dart';
import 'package:aeronet_app_flutter/shared/extensions/string_extensions.dart';
import 'package:aeronet_app_flutter/features/admin/widgets/admin_invoice_card.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class InvoicesAdminScreen extends StatefulWidget {
  final Widget? drawer;
  const InvoicesAdminScreen({super.key, this.drawer});

  @override
  State<InvoicesAdminScreen> createState() => _InvoicesAdminScreenState();
}

class _InvoicesAdminScreenState extends State<InvoicesAdminScreen> {

  Future<void> _exportInvoicesReport(BuildContext context, InvoicesAdminProvider provider) async {
    try {
      final pdf = pw.Document();

    final totalGeneral = provider.invoices.fold<double>(
      0,
      (sum, invoice) => sum + invoice.amount,
    );

    final generatedAt = DateTime.now();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Reporte de Facturas - AeroNet',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),

            pw.Text(
              'Fecha de generación: '
              '${generatedAt.day.toString().padLeft(2, '0')}/'
              '${generatedAt.month.toString().padLeft(2, '0')}/'
              '${generatedAt.year} '
              '${generatedAt.hour.toString().padLeft(2, '0')}:'
              '${generatedAt.minute.toString().padLeft(2, '0')}',
            ),

            pw.SizedBox(height: 20),

            pw.TableHelper.fromTextArray(
              border: pw.TableBorder.all(
                color: PdfColors.grey400,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.blueGrey800,
              ),
              headerStyle: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
              ),
              headers: const [
                'ID',
                'Estado',
                'Monto',
                'Fecha',
              ],
              data: provider.invoices.map((invoice) {
                String fecha = '-';

                if (invoice.createdAt != null &&
                    invoice.createdAt!.isNotEmpty) {
                  try {
                    final date = DateTime.parse(invoice.createdAt!);

                    fecha =
                        '${date.day.toString().padLeft(2, '0')}/'
                        '${date.month.toString().padLeft(2, '0')}/'
                        '${date.year}';
                  } catch (_) {}
                }

                return [
                  shortId(invoice.id),
                  invoice.status.cleanStatus(),
                  invoice.amount.toStringAsFixed(2),
                  fecha,
                ];
              }).toList(),
            ),

            pw.SizedBox(height: 24),

            pw.Divider(),

            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'TOTAL GENERAL: ${money(totalGeneral)}',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  } catch (e) {
    if (context.mounted) {
      showMessage(
        context,
        'Error al generar el PDF: $e',
      );
    }
  }
}


  late final InvoicesAdminProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = InvoicesAdminProvider();
    _provider.loadInvoices();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = _provider;

    return AppStateProvider<InvoicesAdminProvider>(
      notifier: _provider,
      child: AppPage(
        drawer: widget.drawer,
      title: 'Facturación',
      subtitle: 'Historial de Pagos y Deudas',
      actions: [
        IconButton(
          tooltip: 'Exportar a PDF',
          icon: const Icon(Icons.picture_as_pdf_outlined, color: Color(0xFF2DD4BF)),
          onPressed: () => _exportInvoicesReport(context, adminProvider),
        ),
      ],
      child: RefreshIndicator(
        onRefresh: () => adminProvider.loadInvoices(),
        child: ListenableBuilder(
          listenable: adminProvider,
          builder: (context, _) {
            if (adminProvider.isLoading && adminProvider.invoices.isEmpty) {
              return const LoadingWidget(message: 'Cargando facturas...');
            }

            if (adminProvider.errorMessage != null) {
              return ErrorState(
                error: adminProvider.errorMessage!,
                onRetry: () => adminProvider.loadInvoices(),
              );
            }

            if (adminProvider.invoices.isEmpty) {
              return const EmptyState(
                text: 'No hay facturas registradas en el sistema.',
                icon: Icons.receipt_long_outlined,
              );
            }

              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: adminProvider.invoices.length,
                itemBuilder: (context, index) {
                  final invoice = adminProvider.invoices[index];
                  return AdminInvoiceCard(invoice: invoice);
                },
              );

          },
        ),
      ),
    ));
  }
}