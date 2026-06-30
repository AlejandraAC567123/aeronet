import 'package:flutter/material.dart';
import 'package:aeronet_app_flutter/core/utils/app_state_provider.dart';
import 'package:aeronet_app_flutter/features/admin/providers/admin_provider.dart';
import 'package:aeronet_app_flutter/features/admin/screens/customers_screen.dart';
import 'package:aeronet_app_flutter/features/admin/screens/plans_screen.dart';
import 'package:aeronet_app_flutter/features/admin/screens/tickets_admin_screen.dart';
import 'package:aeronet_app_flutter/features/admin/screens/invoices_admin_screen.dart';
import 'package:aeronet_app_flutter/features/admin/screens/technicians_screen.dart';
import 'package:aeronet_app_flutter/features/admin/screens/dashboard_admin_screen.dart';
import 'package:aeronet_app_flutter/features/admin/screens/services_admin_screen.dart';
import 'package:aeronet_app_flutter/features/admin/screens/payments_admin_screen.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _currentIndex = 0;
  late final AdminProvider _adminProvider;

  final List<Widget> _pages = const [
    DashboardAdminScreen(),
    CustomersScreen(),
    PlansScreen(),
    ServicesAdminScreen(),
    TicketsAdminScreen(),
    InvoicesAdminScreen(),
    PaymentsAdminScreen(),
    TechniciansScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _adminProvider = AdminProvider();
    // Fetch all admin data once on startup
    _adminProvider.loadAllAdminData();
  }

  @override
  void dispose() {
    _adminProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateProvider<AdminProvider>(
      notifier: _adminProvider,
      child: Scaffold(
        body: _pages[_currentIndex],
        bottomNavigationBar: Material(
          color: Theme.of(context).colorScheme.surface,
          elevation: 8,
          child: SafeArea(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                child: Row(
                  children: [
                    _buildNavItem(0, Icons.dashboard_outlined, Icons.dashboard, 'Panel'),
                    _buildNavItem(1, Icons.people_outline, Icons.people, 'Clientes'),
                    _buildNavItem(2, Icons.speed_outlined, Icons.speed, 'Planes'),
                    _buildNavItem(3, Icons.wifi_tethering, Icons.wifi_tethering, 'Servicios'),
                    _buildNavItem(4, Icons.support_agent_outlined, Icons.support_agent, 'Tickets'),
                    _buildNavItem(5, Icons.point_of_sale_outlined, Icons.point_of_sale, 'Facturas'),
                    _buildNavItem(6, Icons.payments_outlined, Icons.payments, 'Pagos'),
                    _buildNavItem(7, Icons.engineering_outlined, Icons.engineering, 'Técnicos'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData selectedIcon, String label) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? const Color(0xFF2DD4BF) : Colors.white60;

    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        constraints: const BoxConstraints(minWidth: 80),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isSelected ? selectedIcon : icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
