import 'package:flutter/material.dart';
import 'package:aeronet_app_flutter/core/utils/app_state_provider.dart';
import 'package:aeronet_app_flutter/features/admin/providers/services_admin_provider.dart';
import 'package:aeronet_app_flutter/shared/widgets/app_page.dart';
import 'package:aeronet_app_flutter/shared/widgets/loading_widget.dart';
import 'package:aeronet_app_flutter/shared/widgets/error_state.dart';
import 'package:aeronet_app_flutter/shared/widgets/empty_state.dart';
import 'package:aeronet_app_flutter/shared/widgets/glass_container.dart';
import 'package:aeronet_app_flutter/core/utils/helpers.dart';

class ServicesAdminScreen extends StatefulWidget {
  final Widget? drawer;
  const ServicesAdminScreen({super.key, this.drawer});

  @override
  State<ServicesAdminScreen> createState() => _ServicesAdminScreenState();
}

class _ServicesAdminScreenState extends State<ServicesAdminScreen> {

  late final ServicesAdminProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = ServicesAdminProvider();
    _provider.loadServices();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = _provider;

    return AppStateProvider<ServicesAdminProvider>(
      notifier: _provider,
      child: AppPage(
        drawer: widget.drawer,
      title: 'Servicios y Conexiones',
      subtitle: 'Administración de servicios de clientes',
      actions: [
        IconButton(
          tooltip: 'Actualizar',
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () => adminProvider.loadServices(),
        ),
      ],
      child: RefreshIndicator(
        onRefresh: () => adminProvider.loadServices(),
        child: ListenableBuilder(
          listenable: adminProvider,
          builder: (context, _) {
            if (adminProvider.isLoading && adminProvider.services.isEmpty) {
              return const LoadingWidget(message: 'Cargando servicios...');
            }

            if (adminProvider.errorMessage != null) {
              return ErrorState(
                error: adminProvider.errorMessage!,
                onRetry: () => adminProvider.loadServices(),
              );
            }

            if (adminProvider.services.isEmpty) {
              return const EmptyState(
                text: 'No hay servicios registrados en el sistema.',
                icon: Icons.wifi_tethering,
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: adminProvider.services.length,
              itemBuilder: (context, index) {
                final service = adminProvider.services[index];
                
                Color statusColor;
                switch (service.status.toLowerCase()) {
                  case 'active':
                  case 'activo':
                    statusColor = const Color(0xFF2DD4BF);
                    break;
                  case 'pending':
                  case 'pendiente':
                    statusColor = Colors.orangeAccent;
                    break;
                  case 'suspended':
                  case 'suspendido':
                    statusColor = Colors.redAccent;
                    break;
                  default:
                    statusColor = Colors.grey;
                }

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
                                service.customerName ?? 'Cliente desconocido',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: statusColor.withOpacity(0.3)),
                              ),
                              child: Text(
                                service.status.toUpperCase(),
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (service.plan != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Plan: ${service.plan!.name}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, color: Colors.white54, size: 16),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                service.address,
                                style: const TextStyle(color: Colors.white54),
                              ),
                            ),
                          ],
                        ),
                        if (service.monthlyAmount != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Mensualidad: ${money(service.monthlyAmount)}',
                            style: const TextStyle(
                              color: Color(0xFF2DD4BF),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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