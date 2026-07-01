import 'package:flutter/material.dart';
import 'package:aeronet_app_flutter/core/theme/app_theme.dart';
import 'package:aeronet_app_flutter/features/auth/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.role,
    required this.currentIndex,
    required this.onItemSelected,
  });

  final String role; // 'admin' or 'client'
  final int currentIndex;
  final ValueChanged<int> onItemSelected;

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear token and role
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = role == 'admin' ? _adminItems : _clientItems;

    return Drawer(
      backgroundColor: AppTheme.backgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.rocket_launch,
                      color: AppTheme.accentColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Aeronet',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          'ISP Management',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white10),
            // Menu Items
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isSelected = currentIndex == index;
                  return _DrawerItem(
                    icon: item.icon,
                    label: item.label,
                    isSelected: isSelected,
                    onTap: () {
                      Navigator.pop(context); // Close drawer
                      onItemSelected(index);
                    },
                  );
                },
              ),
            ),
            const Divider(color: Colors.white10),
            // Logout
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _DrawerItem(
                icon: Icons.logout,
                label: 'Cerrar Sesión',
                isSelected: false,
                isDanger: true,
                onTap: () => _logout(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_MenuItem> get _adminItems => const [
    _MenuItem(icon: Icons.dashboard_outlined, label: 'Panel'),
    _MenuItem(icon: Icons.people_outline, label: 'Clientes'),
    _MenuItem(icon: Icons.speed_outlined, label: 'Planes'),
    _MenuItem(icon: Icons.wifi_tethering, label: 'Servicios'),
    _MenuItem(icon: Icons.support_agent_outlined, label: 'Tickets'),
    _MenuItem(icon: Icons.point_of_sale_outlined, label: 'Facturas'),
    _MenuItem(icon: Icons.payments_outlined, label: 'Pagos'),
    _MenuItem(icon: Icons.engineering_outlined, label: 'Técnicos'),
    _MenuItem(icon: Icons.person_outline, label: 'Perfil'),
  ];

  List<_MenuItem> get _clientItems => const [
    _MenuItem(icon: Icons.dashboard_outlined, label: 'Inicio'),
    _MenuItem(icon: Icons.wifi_tethering, label: 'Servicios'),
    _MenuItem(icon: Icons.confirmation_number_outlined, label: 'Tickets'),
    _MenuItem(icon: Icons.receipt_long_outlined, label: 'Deudas'),
    _MenuItem(icon: Icons.person_outline, label: 'Perfil'),
  ];
}

class _MenuItem {
  final IconData icon;
  final String label;

  const _MenuItem({required this.icon, required this.label});
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isDanger = false,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    final color = isDanger 
        ? AppTheme.errorColor 
        : isSelected 
            ? AppTheme.accentColor 
            : AppTheme.textSecondaryColor;
            
    final bgColor = isDanger
        ? Colors.transparent // Changed per design spec for outline danger button
        : isSelected
            ? AppTheme.accentColor.withOpacity(0.1)
            : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        shape: isDanger 
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
                side: BorderSide(color: color.withOpacity(0.5)),
              )
            : null,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
