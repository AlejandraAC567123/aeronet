import 'package:flutter/material.dart';
import 'package:aeronet_app_flutter/core/utils/app_state_provider.dart';
import 'package:aeronet_app_flutter/features/client/providers/client_provider.dart';
import 'package:aeronet_app_flutter/features/client/screens/dashboard_screen.dart';
import 'package:aeronet_app_flutter/features/client/screens/services_screen.dart';
import 'package:aeronet_app_flutter/features/client/screens/tickets_client_screen.dart';
import 'package:aeronet_app_flutter/features/client/screens/invoices_client_screen.dart';
import 'package:aeronet_app_flutter/features/client/screens/profile_screen.dart';
import 'package:aeronet_app_flutter/shared/widgets/app_drawer.dart';

class ClientShell extends StatefulWidget {
  const ClientShell({super.key});

  @override
  State<ClientShell> createState() => _ClientShellState();
}

class _ClientShellState extends State<ClientShell> {
  late final ClientProvider _clientProvider;

  Widget _getPage(int index, Widget drawer) {
    switch (index) {
      case 0: return DashboardScreen(drawer: drawer);
      case 1: return ServicesScreen(drawer: drawer);
      case 2: return TicketsClientScreen(drawer: drawer);
      case 3: return InvoicesClientScreen(drawer: drawer);
      case 4: return ProfileScreen(drawer: drawer);
      default: return DashboardScreen(drawer: drawer);
    }
  }

  @override
  void initState() {
    super.initState();
    _clientProvider = ClientProvider();
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
          
          final drawer = AppDrawer(
            role: 'client',
            currentIndex: tabIndex,
            onItemSelected: (index) {
              _clientProvider.setTabIndex(index);
            },
          );

          return Scaffold(
            body: _getPage(tabIndex, drawer),
          );
        },
      ),
    );
  }
}

