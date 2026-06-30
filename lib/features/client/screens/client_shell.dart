import 'package:flutter/material.dart';
import 'package:aeronet_app_flutter/core/utils/app_state_provider.dart';
import 'package:aeronet_app_flutter/features/client/providers/client_provider.dart';
import 'package:aeronet_app_flutter/features/client/screens/dashboard_screen.dart';
import 'package:aeronet_app_flutter/features/client/screens/services_screen.dart';
import 'package:aeronet_app_flutter/features/client/screens/tickets_client_screen.dart';
import 'package:aeronet_app_flutter/features/client/screens/invoices_client_screen.dart';
import 'package:aeronet_app_flutter/features/client/screens/profile_screen.dart';

import 'dart:ui'; // Para ImageFilter

class ClientShell extends StatefulWidget {
  const ClientShell({super.key});

  @override
  State<ClientShell> createState() => _ClientShellState();
}

class _ClientShellState extends State<ClientShell> {
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
      child: ListenableBuilder(
        listenable: _clientProvider,
        builder: (context, _) {
          final tabIndex = _clientProvider.currentTabIndex;
          return Scaffold(
            extendBody: true, // Permite que el cuerpo se dibuje detrás de la barra inferior para el efecto blur
            body: _pages[tabIndex],
            bottomNavigationBar: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF10131F), // Color translúcido de fondo
                    border: Border(
                      top: BorderSide(color: Color(0xFF2B3150), width: 1.0),
                    ),
                  ),
                  child: SafeArea(
                    bottom: true,
                    child: NavigationBar(
                      selectedIndex: tabIndex,
                      onDestinationSelected: (index) {
                        _clientProvider.setTabIndex(index);
                      },
                      backgroundColor: Colors.transparent, // Transparente para ver el blur del contenedor
                      elevation: 0,
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
            ),
          ),
        ),
      );
    },
  ),
);
  }
}
