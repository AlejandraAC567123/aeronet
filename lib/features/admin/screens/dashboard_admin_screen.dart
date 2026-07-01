import 'package:flutter/material.dart';
import 'package:aeronet_app_flutter/core/utils/app_state_provider.dart';
import 'package:aeronet_app_flutter/features/admin/providers/dashboard_admin_provider.dart';
import 'package:aeronet_app_flutter/shared/widgets/app_page.dart';
import 'package:aeronet_app_flutter/shared/widgets/loading_widget.dart';
import 'package:aeronet_app_flutter/shared/widgets/error_state.dart';
import 'package:aeronet_app_flutter/shared/widgets/empty_state.dart';
import 'package:aeronet_app_flutter/shared/widgets/glass_container.dart';
import 'package:aeronet_app_flutter/features/admin/widgets/stat_card.dart';
import 'package:aeronet_app_flutter/core/utils/helpers.dart';
import 'package:aeronet_app_flutter/core/theme/app_theme.dart';

class DashboardAdminScreen extends StatefulWidget {
  final Widget? drawer;
  const DashboardAdminScreen({super.key, this.drawer});

  @override
  State<DashboardAdminScreen> createState() => _DashboardAdminScreenState();
}

class _DashboardAdminScreenState extends State<DashboardAdminScreen> {

  late final DashboardAdminProvider _adminProvider;

  @override
  void initState() {
    super.initState();
    _adminProvider = DashboardAdminProvider();
    _adminProvider.loadDashboard();
  }

  @override
  void dispose() {
    _adminProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = _adminProvider;

    return AppStateProvider<DashboardAdminProvider>(
      notifier: _adminProvider,
      child: AppPage(
        drawer: widget.drawer,
      title: 'Panel General',
      subtitle: 'Resumen del sistema',
      child: RefreshIndicator(
        onRefresh: () => adminProvider.loadDashboard(),
        child: ListenableBuilder(
          listenable: adminProvider,
          builder: (context, _) {
            if (adminProvider.isLoading && adminProvider.totalCustomers == 0) {
              return const LoadingWidget(message: 'Cargando datos...');
            }

            if (adminProvider.errorMessage != null) {
              return ErrorState(
                error: adminProvider.errorMessage!,
                onRetry: () => adminProvider.loadDashboard(),
              );
            }

            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Statistics Grid
                        GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: 1.5,
                          children: [
                            StatCard(
                              label: 'Clientes',
                              value: '${adminProvider.totalCustomers}',
                              icon: Icons.people_outline,
                            ),
                            StatCard(
                              label: 'Servicios Activos',
                              value: '${adminProvider.totalActiveServices}',
                              icon: Icons.wifi_tethering,
                              color: AppTheme.accentColor,
                            ),
                            StatCard(
                              label: 'Tickets Pendientes',
                              value: '${adminProvider.totalPendingTickets}',
                              icon: Icons.support_agent_outlined,
                              color: AppTheme.alertColor,
                            ),
                            StatCard(
                              label: 'Por Cobrar',
                              value: money(adminProvider.totalOutstandingAmount),
                              icon: Icons.account_balance_wallet_outlined,
                              color: AppTheme.errorColor,
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'Pagos Recientes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildRecentPayments(adminProvider),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    ));
  }

  Widget _buildRecentPayments(DashboardAdminProvider provider) {
    final payments = provider.recentPayments;

    if (payments.isEmpty) {
      return const EmptyState(
        text: 'Aún no hay pagos registrados.',
        icon: Icons.payments_outlined,
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: payments.length,
      itemBuilder: (context, index) {
        final payment = payments[index];
        final date = payment.paymentDate ?? payment.createdAt ?? '';
        final displayDate = date.isNotEmpty ? date.split('T')[0] : '--';

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassContainer(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment.customerName ?? 'Cliente',
                        style: const TextStyle(
                          color: AppTheme.textPrimaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Método: ${payment.displayMethod}',
                        style: const TextStyle(color: AppTheme.textSecondaryColor),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      money(payment.amountReceived),
                      style: const TextStyle(
                        color: AppTheme.accentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      displayDate,
                      style: const TextStyle(color: AppTheme.textSecondaryColor, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}