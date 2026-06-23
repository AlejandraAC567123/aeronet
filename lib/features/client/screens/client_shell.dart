import 'package:flutter/material.dart';
import 'package:aeronet_app_flutter/core/utils/app_state_provider.dart';
import 'package:aeronet_app_flutter/features/client/providers/client_provider.dart';
import 'package:aeronet_app_flutter/features/client/screens/dashboard_screen.dart';
import 'package:aeronet_app_flutter/features/client/screens/services_screen.dart';
import 'package:aeronet_app_flutter/features/client/screens/tickets_client_screen.dart';
import 'package:aeronet_app_flutter/features/client/screens/invoices_client_screen.dart';
import 'package:aeronet_app_flutter/features/client/screens/profile_screen.dart';

class ClientShell extends StatefulWidget {
  const ClientShell({super.key});

  @override
  State<ClientShell> createState() => _ClientShellState();
}

class _ClientShellState extends State<ClientShell> {
  int _currentIndex = 0;
  late final ClientProvider _clientProvider;

  final List<Widget> _pages = const [
    DashboardScreen(),
    ServicesScreen(),
    TicketsClientScreen(),
    InvoicesClientScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _clientProvider = ClientProvider();
    // Load initial data
    _clientProvider.loadDashboard();
    _clientProvider.loadLocalDrafts();
  }

  @override
  void dispose() {
    _clientProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateProvider<ClientProvider>(
      notifier: _clientProvider,
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
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Inicio',
            ),
            NavigationDestination(
              icon: Icon(Icons.wifi_tethering),
              selectedIcon: Icon(Icons.wifi_tethering),
              label: 'Servicios',
            ),
            NavigationDestination(
              icon: Icon(Icons.confirmation_number_outlined),
              selectedIcon: Icon(Icons.confirmation_number),
              label: 'Tickets',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long),
              label: 'Deudas',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
