import 'package:flutter/material.dart';
import 'package:aeronet_app_flutter/core/utils/app_state_provider.dart';
import 'package:aeronet_app_flutter/features/client/providers/client_provider.dart';
import 'package:aeronet_app_flutter/shared/widgets/app_page.dart';
import 'package:aeronet_app_flutter/shared/widgets/loading_widget.dart';
import 'package:aeronet_app_flutter/shared/widgets/error_state.dart';
import 'package:aeronet_app_flutter/features/auth/providers/auth_provider.dart';
import 'package:aeronet_app_flutter/data/models/customer_model.dart';
import 'package:aeronet_app_flutter/data/repositories/customer_repository.dart';
import 'package:aeronet_app_flutter/shared/widgets/signal_indicator.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  CustomerModel? _profile;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    if (!mounted) return;
    try {
      final profile = await CustomerRepository.instance.getMe();
      if (mounted) {
        setState(() {
          _profile = profile;
        });
      }
    } catch (e) {
      debugPrint('Error al obtener perfil en Dashboard: $e');
    }
  }

  Future<void> _refreshAll(ClientProvider clientProvider) async {
    await Future.wait([
      clientProvider.loadDashboard(),
      _fetchProfile(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final clientProvider = AppStateProvider.of<ClientProvider>(context);
    final authProvider = AppStateProvider.of<AuthProvider>(context);
    
    // Fallback name if profile isn't loaded yet or fails
    String displayName = 'AeroNet';
    if (_profile != null && _profile!.fullName.isNotEmpty) {
      displayName = _profile!.fullName.split(' ')[0];
    } else {
      final email = authProvider.currentUser?.email ?? '';
      if (email.isNotEmpty && email.contains('@')) {
        displayName = email.split('@')[0].toUpperCase();
      }
    }

    return AppPage(
      title: '', // Se maneja en el header personalizado
      subtitle: '',
      child: RefreshIndicator(
        onRefresh: () => _refreshAll(clientProvider),
        color: const Color(0xFF4FE6C4),
        backgroundColor: const Color(0xFF1A1E30),
        child: _buildContent(context, clientProvider, displayName),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ClientProvider provider, String displayName) {
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

    // Calcular dias para vencimiento si hay pendientes
    String deudasSubtitle = '$totalDebts emitidas este año';
    Color deudasColor = const Color(0xFF4FE6C4);
    if (pendingDebts > 0) {
      deudasColor = const Color(0xFFFFB454);
      
      // Intentar encontrar el vencimiento más cercano
      final pendingList = provider.myDebts.where((inv) => inv.status.toLowerCase() == 'pending');
      if (pendingList.isNotEmpty) {
        final nearest = pendingList.first;
        if (nearest.dueDate != null && nearest.dueDate!.isNotEmpty) {
          try {
            final due = DateTime.parse(nearest.dueDate!.split('T')[0]);
            final diff = due.difference(DateTime.now()).inDays + 1;
            if (diff > 0) {
              deudasSubtitle = 'Vence en $diff días';
            } else if (diff == 0) {
              deudasSubtitle = 'Vence hoy';
            } else {
              deudasSubtitle = 'Vencido hace ${diff.abs()} días';
              deudasColor = const Color(0xFFFF6B6B);
            }
          } catch (_) {}
        }
      }
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 90), // Aire para bottom navigation bar
      children: [
        // Custom Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bienvenida de nuevo',
                    style: TextStyle(
                      color: Color(0xFF8C92AE),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Plus Jakarta Sans',
                        color: Color(0xFFF2F4FA),
                      ),
                      children: [
                        const TextSpan(text: 'Hola, '),
                        TextSpan(
                          text: displayName,
                          style: const TextStyle(color: Color(0xFF4FE6C4)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // "Servicio activo" status chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF222840),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2B3150), width: 1.0),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SignalIndicator(activeBars: 4, size: 12),
                  SizedBox(width: 8),
                  Text(
                    'Servicio activo',
                    style: TextStyle(
                      color: Color(0xFFF2F4FA),
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),

        // Metrics Horizontal row (4 items)
        Row(
          children: [
            _buildMetricTile(
              label: 'Facturas',
              value: '$totalDebts',
            ),
            const SizedBox(width: 8),
            _buildMetricTile(
              label: 'Pendiente',
              value: '$pendingDebts',
              hasDot: pendingDebts > 0,
            ),
            const SizedBox(width: 8),
            _buildMetricTile(
              label: 'Servicios',
              value: '$activeServices',
            ),
            const SizedBox(width: 8),
            _buildMetricTile(
              label: 'Tickets',
              value: '$totalTickets',
            ),
          ],
        ),
        const SizedBox(height: 32),

        // Recommended Plans header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Planes disponibles',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFFF2F4FA),
              ),
            ),
            if (provider.allPlans.isNotEmpty)
              Text(
                '${provider.allPlans.length} planes',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  color: Color(0xFF8C92AE),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Horizontally scrolling Plans list
        _buildPlansList(context, provider),
        const SizedBox(height: 32),

        // Accesos rápidos header
        const Text(
          'Accesos rápidos',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFFF2F4FA),
          ),
        ),
        const SizedBox(height: 16),

        // Accesos rápidos list
        _buildQuickAccessTile(
          context,
          icon: Icons.receipt_outlined,
          title: 'Ver mis facturas',
          subtitle: '$totalDebts emitidas este año',
          iconColor: const Color(0xFF4FE6C4), // Menta
          onTap: () {
            // Ir a Deudas (index 3 en Shell) usando ClientProvider
            AppStateProvider.read<ClientProvider>(context).setTabIndex(3);
          },
        ),
        _buildQuickAccessTile(
          context,
          icon: Icons.warning_amber_rounded,
          title: 'Pago pendiente',
          subtitle: deudasSubtitle,
          iconColor: deudasColor,
          onTap: () {
            AppStateProvider.read<ClientProvider>(context).setTabIndex(3);
          },
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    bool hasDot = false,
  }) {
    return Expanded(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1E30),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2B3150), width: 1.0),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFF2F4FA),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      color: Color(0xFF8C92AE),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          if (hasDot)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFB454), // Ámbar
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlansList(BuildContext context, ClientProvider provider) {
    if (provider.allPlans.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1E30),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFF2B3150)),
        ),
        child: const Center(
          child: Text(
            'No hay planes disponibles por el momento.',
            style: TextStyle(color: Color(0xFF8C92AE), fontFamily: 'Inter'),
          ),
        ),
      );
    }

    return SizedBox(
      height: 165,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: provider.allPlans.length,
        itemBuilder: (context, index) {
          final plan = provider.allPlans[index];
          // Categorizar plan para mostrar la etiqueta correspondiente
          final isPopular = plan.speedMbps >= 200;
          final category = isPopular ? 'MÁS ELEGIDO' : 'ECONÓMICO';
          final badgeColor = isPopular ? const Color(0xFF4FE6C4) : const Color(0xFF8C92AE);

          return Container(
            width: 175,
            margin: EdgeInsets.only(right: index == provider.allPlans.length - 1 ? 0 : 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1E30),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isPopular ? const Color(0xFF4FE6C4).withOpacity(0.3) : const Color(0xFF2B3150),
                width: isPopular ? 1.5 : 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: badgeColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      plan.name,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF2F4FA),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        SignalIndicator(activeBars: isPopular ? 4 : 2, size: 10),
                        const SizedBox(width: 6),
                        Text(
                          '${plan.speedMbps} Mbps',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: Color(0xFF8C92AE),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFF2F4FA),
                            ),
                            children: [
                              const TextSpan(text: 'S/ '),
                              TextSpan(
                                text: '${plan.price.toInt()}',
                                style: const TextStyle(fontSize: 22),
                              ),
                            ],
                          ),
                        ),
                        const Text(
                          '/mes',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            color: Color(0xFF5C6280),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF222840),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF2B3150)),
                      ),
                      child: const Icon(
                        Icons.arrow_forward,
                        size: 12,
                        color: Color(0xFF8C92AE),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickAccessTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1E30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2B3150), width: 1.0),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF2F4FA),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: Color(0xFF8C92AE),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF5C6280),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
