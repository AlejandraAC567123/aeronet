import 'package:flutter/material.dart';
import 'package:aeronet_app_flutter/core/utils/app_state_provider.dart';
import 'package:aeronet_app_flutter/features/client/providers/client_provider.dart';
import 'package:aeronet_app_flutter/shared/widgets/app_page.dart';
import 'package:aeronet_app_flutter/shared/widgets/loading_widget.dart';
import 'package:aeronet_app_flutter/shared/widgets/error_state.dart';
import 'package:aeronet_app_flutter/shared/widgets/empty_state.dart';
import 'package:aeronet_app_flutter/features/client/widgets/invoice_card.dart';
import 'package:aeronet_app_flutter/core/utils/helpers.dart';
import 'package:aeronet_app_flutter/data/services/http_service.dart';

class InvoicesClientScreen extends StatefulWidget {
  const InvoicesClientScreen({super.key});

  @override
  State<InvoicesClientScreen> createState() => _InvoicesClientScreenState();
}

class _InvoicesClientScreenState extends State<InvoicesClientScreen> {
  final HttpService _httpService = HttpService.instance;

  Future<void> _generateCheckout(String invoiceId) async {
    try {
      // Loading dialog
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Procesando pago simulado...'),
            ],
          ),
        ),
      );

      // Simular pago
      await _httpService.generateCheckout(invoiceId);

      if (!mounted) return;
      Navigator.of(context).pop(); // Cierra loading

      showMessage(context, '¡Pago simulado procesado exitosamente!');

      // Recargar deudas inmediatamente
      if (mounted) {
        final clientProvider = AppStateProvider.read<ClientProvider>(context);
        await clientProvider.loadMyDebts();
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Cierra loading
      showMessage(context, 'Error: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final clientProvider = AppStateProvider.of<ClientProvider>(context);

    return AppPage(
      title: 'Facturación',
      subtitle: 'Mis Recibos y Pagos',
      child: RefreshIndicator(
        onRefresh: () => clientProvider.loadMyDebts(),
        color: const Color(0xFF4FE6C4),
        backgroundColor: const Color(0xFF1A1E30),
        child: ListenableBuilder(
          listenable: clientProvider,
          builder: (context, _) {
            return _buildContent(context, clientProvider);
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ClientProvider provider) {
    if (provider.isLoading && provider.myDebts.isEmpty) {
      return const LoadingWidget(message: 'Cargando deudas...');
    }

    if (provider.errorMessage != null) {
      return ErrorState(
        error: provider.errorMessage!,
        onRetry: () => provider.loadMyDebts(),
      );
    }

    if (provider.myDebts.isEmpty) {
      return const EmptyState(
        text: 'No tienes recibos ni deudas registradas.',
        icon: Icons.receipt_outlined,
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 90), // Aire inferior para la barra inferior extendida
      itemCount: provider.myDebts.length,
      itemBuilder: (context, index) {
        final invoice = provider.myDebts[index];
        return InvoiceCard(
          invoice: invoice,
          isLoading: provider.isLoading,
          onPayment: () => _generateCheckout(invoice.id),
        );
      },
    );
  }
}