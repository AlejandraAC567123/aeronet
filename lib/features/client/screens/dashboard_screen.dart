import 'package:flutter/material.dart';
import 'package:aeronet_app_flutter/core/utils/app_state_provider.dart';
import 'package:aeronet_app_flutter/features/client/providers/client_provider.dart';
import 'package:aeronet_app_flutter/shared/widgets/app_page.dart';
import 'package:aeronet_app_flutter/shared/widgets/loading_widget.dart';
import 'package:aeronet_app_flutter/shared/widgets/error_state.dart';
import 'package:aeronet_app_flutter/shared/widgets/glass_container.dart';
import 'package:aeronet_app_flutter/core/utils/helpers.dart';
import 'package:aeronet_app_flutter/features/auth/providers/auth_provider.dart';
import 'package:aeronet_app_flutter/data/models/plan_model.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final clientProvider = AppStateProvider.of<ClientProvider>(context);
    final authProvider = AppStateProvider.of<AuthProvider>(context);
    final email = authProvider.currentUser?.email ?? '';

    return AppPage(
      title: 'Inicio',
      subtitle: email,
      child: RefreshIndicator(
        onRefresh: () => clientProvider.loadDashboard(),
        child: _buildContent(context, clientProvider),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ClientProvider provider) {
    if (provider.isLoading && provider.myDebts.isEmpty && provider.myServices.isEmpty) {
      return const LoadingWidget(message: 'Cargando tu información...');
    }

    if (provider.errorMessage != null) {
      return ErrorState(
        error: provider.errorMessage!,
        onRetry: () => provider.loadDashboard(),
      );
    }

    final totalDebts = provider.myDebts.length;
    final pendingDebts = provider.myDebts
        .where((inv) => inv.status.toLowerCase() == 'pending' || inv.status.toLowerCase() == 'overdue')
        .length;
    final activeServices = provider.myServices
        .where((s) => s.status.toLowerCase() == 'activo' || s.status.toLowerCase() == 'active')
        .length;
    final totalTickets = provider.myTickets.length;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        // Metric Panel
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildMetricTile(
              context,
              label: 'Facturas',
              value: '$totalDebts',
              icon: Icons.receipt_long_outlined,
            ),
            _buildMetricTile(
              context,
              label: 'Pendientes',
              value: '$pendingDebts',
              icon: Icons.warning_amber_rounded,
              color: pendingDebts > 0 ? Colors.orangeAccent : const Color(0xFF2DD4BF),
            ),
            _buildMetricTile(
              context,
              label: 'Servicios',
              value: '$activeServices',
              icon: Icons.router_outlined,
            ),
            _buildMetricTile(
              context,
              label: 'Tickets',
              value: '$totalTickets',
              icon: Icons.support_agent_outlined,
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        // Recommended Plans header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Planes Disponibles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (provider.allPlans.isNotEmpty)
              Text(
                '${provider.allPlans.length} planes',
                style: const TextStyle(color: Colors.white60, fontSize: 13),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Plans list
        if (provider.allPlans.isEmpty)
          const GlassContainer(
            padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Center(
              child: Text(
                'No hay planes disponibles por el momento.',
                style: TextStyle(color: Colors.white54),
              ),
            ),
          )
        else
          ...provider.allPlans.map((plan) => _buildPlanTile(context, plan)),
      ],
    );
  }

  Widget _buildMetricTile(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    Color? color,
  }) {
    final themeColor = color ?? const Color(0xFF2DD4BF);
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: themeColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: themeColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanTile(BuildContext context, PlanModel plan) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Subida: ${plan.uploadSpeed} Mbps / Bajada: ${plan.downloadSpeed} Mbps',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white60,
                    ),
                  ),
                  if (plan.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      plan.description,
                      style: const TextStyle(fontSize: 12, color: Colors.white38),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF2DD4BF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                money(plan.price),
                style: const TextStyle(
                  color: Color(0xFF2DD4BF),
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
