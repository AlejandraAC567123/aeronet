import 'package:flutter/material.dart';
import 'package:aeronet_app_flutter/core/utils/app_state_provider.dart';
import 'package:aeronet_app_flutter/features/client/providers/client_provider.dart';
import 'package:aeronet_app_flutter/shared/widgets/app_page.dart';
import 'package:aeronet_app_flutter/shared/widgets/loading_widget.dart';
import 'package:aeronet_app_flutter/shared/widgets/error_state.dart';
import 'package:aeronet_app_flutter/shared/widgets/empty_state.dart';
import 'package:aeronet_app_flutter/features/client/widgets/invoice_card.dart';
import 'package:aeronet_app_flutter/core/utils/helpers.dart';

class InvoicesClientScreen extends StatelessWidget {
  const InvoicesClientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final clientProvider = AppStateProvider.of<ClientProvider>(context);

    return AppPage(
      title: 'Facturación',
      subtitle: 'Mis Recibos y Pagos',
      child: RefreshIndicator(
        onRefresh: () => clientProvider.loadMyDebts(),
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
      padding: const EdgeInsets.all(16),
      itemCount: provider.myDebts.length,
      itemBuilder: (context, index) {
        final invoice = provider.myDebts[index];
        return InvoiceCard(
          invoice: invoice,
          isLoading: provider.isLoading,
          onSimulatePayment: () async {
            try {
              await provider.simulateInvoicePayment(invoice.id);
              if (context.mounted) {
                showMessage(context, 'Pago simulado con éxito.');
              }
            } catch (e) {
              if (context.mounted) {
                showMessage(context, e.toString());
              }
            }
          },
        );
      },
    );
  }
}
