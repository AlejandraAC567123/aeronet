import 'package:flutter/material.dart';
import 'package:aeronet_app_flutter/core/utils/app_state_provider.dart';
import 'package:aeronet_app_flutter/features/admin/providers/admin_provider.dart';
import 'package:aeronet_app_flutter/shared/widgets/app_page.dart';
import 'package:aeronet_app_flutter/shared/widgets/loading_widget.dart';
import 'package:aeronet_app_flutter/shared/widgets/error_state.dart';
import 'package:aeronet_app_flutter/shared/widgets/empty_state.dart';
import 'package:aeronet_app_flutter/shared/widgets/glass_container.dart';
import 'package:aeronet_app_flutter/core/utils/helpers.dart';

class PaymentsAdminScreen extends StatelessWidget {
  const PaymentsAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adminProvider = AppStateProvider.of<AdminProvider>(context);

    return AppPage(
      title: 'Historial de Pagos',
      subtitle: 'Pagos registrados en el sistema',
      actions: [
        IconButton(
          tooltip: 'Actualizar',
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () => adminProvider.loadPayments(),
        ),
      ],
      child: RefreshIndicator(
        onRefresh: () => adminProvider.loadPayments(),
        child: ListenableBuilder(
          listenable: adminProvider,
          builder: (context, _) {
            if (adminProvider.isLoading && adminProvider.payments.isEmpty) {
              return const LoadingWidget(message: 'Cargando pagos...');
            }

            if (adminProvider.errorMessage != null) {
              return ErrorState(
                error: adminProvider.errorMessage!,
                onRetry: () => adminProvider.loadPayments(),
              );
            }

            if (adminProvider.payments.isEmpty) {
              return const EmptyState(
                text: 'No se registran pagos en el sistema.',
                icon: Icons.payments_outlined,
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: adminProvider.payments.length,
              itemBuilder: (context, index) {
                final payment = adminProvider.payments[index];
                final date = payment.paymentDate ?? payment.createdAt ?? '';
                final displayDate = date.isNotEmpty ? date.split('T')[0] : '--';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                payment.customerName ?? 'Cliente',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Text(
                              money(payment.amountReceived),
                              style: const TextStyle(
                                color: Color(0xFF2DD4BF),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Método: ${payment.displayMethod}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            Text(
                              displayDate,
                              style: const TextStyle(color: Colors.white54, fontSize: 12),
                            ),
                          ],
                        ),
                        if (payment.transactionReference != null && payment.transactionReference!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Ref: ${payment.transactionReference}',
                            style: const TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                        ]
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
