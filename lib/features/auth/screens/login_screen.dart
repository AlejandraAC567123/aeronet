import 'package:flutter/material.dart';
import 'package:aeronet_app_flutter/shared/widgets/glass_container.dart';
import 'package:aeronet_app_flutter/features/auth/widgets/login_form.dart';
import 'package:aeronet_app_flutter/core/utils/app_state_provider.dart';
import 'package:aeronet_app_flutter/features/auth/providers/auth_provider.dart';
import 'package:aeronet_app_flutter/core/utils/local_notifier.dart';
import 'package:aeronet_app_flutter/core/utils/helpers.dart';
import 'package:aeronet_app_flutter/core/routes/app_routes.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = AppStateProvider.of<AuthProvider>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0B1120),
              Color(0xFF0F2027),
              Color(0xFF203A43),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: GlassContainer(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF2DD4BF).withOpacity(0.1),
                        ),
                        child: const Icon(
                          Icons.wifi_tethering,
                          size: 64,
                          color: Color(0xFF2DD4BF),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'AeroNet Móvil',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tu Portal de Internet ISP',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 32),
                      LoginForm(
                        isLoading: authProvider.isLoading,
                        onSubmit: (name, email, password, isSignup) async {
                          try {
                            if (isSignup) {
                              await authProvider.signup(name!, email, password);
                              if (context.mounted) {
                                showMessage(context, 'Registro completado. Ahora inicia sesión.');
                              }
                            } else {
                              await authProvider.login(email, password);
                              final user = authProvider.currentUser;
                              
                              if (user != null) {
                                await LocalNotifier.instance.show(
                                  'Inicio de Sesión',
                                  'Bienvenido a AeroNet, has ingresado como ${user.role == "admin" ? "Administrador" : "Cliente"}.',
                                );
                                
                                if (context.mounted) {
                                  final route = user.role == 'admin'
                                      ? AppRoutes.adminShell
                                      : AppRoutes.clientShell;
                                  Navigator.of(context).pushReplacementNamed(route);
                                }
                              }
                            }
                          } catch (e) {
                            if (context.mounted) {
                              showMessage(context, e.toString());
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
