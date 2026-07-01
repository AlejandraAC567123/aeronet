import 'package:flutter/material.dart';
import 'package:aeronet_app_flutter/core/utils/app_state_provider.dart';
import 'package:aeronet_app_flutter/features/admin/providers/payments_admin_provider.dart';
import 'package:aeronet_app_flutter/shared/widgets/app_page.dart';
import 'package:aeronet_app_flutter/shared/widgets/loading_widget.dart';
import 'package:aeronet_app_flutter/shared/widgets/error_state.dart';
import 'package:aeronet_app_flutter/shared/widgets/empty_state.dart';
import 'package:aeronet_app_flutter/shared/widgets/glass_container.dart';
import 'package:aeronet_app_flutter/core/utils/helpers.dart';
import 'package:aeronet_app_flutter/core/theme/app_theme.dart';

class PaymentsAdminScreen extends StatefulWidget {
  final Widget? drawer;
  const PaymentsAdminScreen({super.key, this.drawer});

  @override
  State<PaymentsAdminScreen> createState() => _PaymentsAdminScreenState();
}

class _PaymentsAdminScreenState extends State<PaymentsAdminScreen> {

  late final PaymentsAdminProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = PaymentsAdminProvider();
    _provider.loadPayments();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = _provider;

    return AppStateProvider<PaymentsAdminProvider>(
      notifier: _provider,
      child: AppPage(
        drawer: widget.drawer,
      title: 'Historial de Pagos',
      subtitle: 'Pagos registrados en el sistema',
      actions: [
        IconButton(
          tooltip: 'Actualizar',
          icon: const Icon(Icons.refresh, color: AppTheme.textPrimaryColor),
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
                                  color: AppTheme.textPrimaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Text(
                              money(payment.amountReceived),
                              style: const TextStyle(
                                color: AppTheme.accentColor,
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
                              style: const TextStyle(color: AppTheme.textSecondaryColor),
                            ),
                            Text(
                              displayDate,
                              style: const TextStyle(color: AppTheme.textSecondaryColor, fontSize: 12),
                            ),
                          ],
                        ),
                        if (payment.transactionReference != null && payment.transactionReference!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Ref: ${payment.transactionReference}',
                            style: const TextStyle(color: AppTheme.textSecondaryColor, fontSize: 12),
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
    ));
  }
}