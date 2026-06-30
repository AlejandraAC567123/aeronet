import 'package:flutter/material.dart';
import 'package:aeronet_app_flutter/core/utils/app_state_provider.dart';
import 'package:aeronet_app_flutter/features/admin/screens/customers_screen.dart';
import 'package:aeronet_app_flutter/features/admin/screens/plans_screen.dart';
import 'package:aeronet_app_flutter/features/admin/screens/tickets_admin_screen.dart';
import 'package:aeronet_app_flutter/features/admin/screens/invoices_admin_screen.dart';
import 'package:aeronet_app_flutter/features/admin/screens/technicians_screen.dart';
import 'package:aeronet_app_flutter/features/admin/screens/dashboard_admin_screen.dart';
import 'package:aeronet_app_flutter/features/admin/screens/services_admin_screen.dart';
import 'package:aeronet_app_flutter/features/admin/screens/payments_admin_screen.dart';
import 'package:aeronet_app_flutter/features/client/screens/profile_screen.dart';
import 'package:aeronet_app_flutter/shared/widgets/app_drawer.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _currentIndex = 0;

  Widget _buildDrawer() {
    return AppDrawer(
      role: 'admin',
      currentIndex: _currentIndex,
      onItemSelected: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
    );
  }

  List<Widget> get _pages => [
    DashboardAdminScreen(drawer: _buildDrawer()),
    CustomersScreen(drawer: _buildDrawer()),
    PlansScreen(drawer: _buildDrawer()),
    ServicesAdminScreen(drawer: _buildDrawer()),
    TicketsAdminScreen(drawer: _buildDrawer()),
    InvoicesAdminScreen(drawer: _buildDrawer()),
    PaymentsAdminScreen(drawer: _buildDrawer()),
    TechniciansScreen(drawer: _buildDrawer()),
    ProfileScreen(drawer: _buildDrawer()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
    );
  }
}

