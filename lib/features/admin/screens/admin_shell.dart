import 'package:flutter/material.dart';
import 'package:aeronet_app_flutter/core/utils/app_state_provider.dart';
import 'package:aeronet_app_flutter/features/admin/providers/admin_provider.dart';
import 'package:aeronet_app_flutter/features/admin/screens/customers_screen.dart';
import 'package:aeronet_app_flutter/features/admin/screens/plans_screen.dart';
import 'package:aeronet_app_flutter/features/admin/screens/tickets_admin_screen.dart';
import 'package:aeronet_app_flutter/features/admin/screens/invoices_admin_screen.dart';
import 'package:aeronet_app_flutter/features/admin/screens/technicians_screen.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _currentIndex = 0;
  late final AdminProvider _adminProvider;

  final List<Widget> _pages = const [
    CustomersScreen(),
    PlansScreen(),
    TicketsAdminScreen(),
    InvoicesAdminScreen(),
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
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.people_outline),
              selectedIcon: Icon(Icons.people),
              label: 'Clientes',
            ),
            NavigationDestination(
              icon: Icon(Icons.speed_outlined),
              selectedIcon: Icon(Icons.speed),
              label: 'Planes',
            ),
            NavigationDestination(
              icon: Icon(Icons.support_agent_outlined),
              selectedIcon: Icon(Icons.support_agent),
              label: 'Tickets',
            ),
            NavigationDestination(
              icon: Icon(Icons.point_of_sale_outlined),
              selectedIcon: Icon(Icons.point_of_sale),
              label: 'Facturas',
            ),
            NavigationDestination(
              icon: Icon(Icons.engineering_outlined),
              selectedIcon: Icon(Icons.engineering),
              label: 'Técnicos',
            ),
          ],
        ),
      ),
    );
  }
}
