import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:aeronet_app_flutter/core/theme/app_theme.dart';
import 'package:aeronet_app_flutter/core/routes/app_routes.dart';
import 'package:aeronet_app_flutter/core/utils/app_state_provider.dart';
import 'package:aeronet_app_flutter/core/utils/local_notifier.dart';
import 'package:aeronet_app_flutter/data/services/storage_service.dart';
import 'package:aeronet_app_flutter/features/auth/providers/auth_provider.dart';
import 'package:aeronet_app_flutter/features/auth/screens/login_screen.dart';
import 'package:aeronet_app_flutter/features/client/screens/client_shell.dart';
import 'package:aeronet_app_flutter/features/admin/screens/admin_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load Dotenv variables (.env file mapping)
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Advertencia: No se pudo cargar el archivo .env, usando configuraciones de respaldo. Detalle: $e");
  }

  // Initialize Core Services
  await StorageService.instance.init();
  await LocalNotifier.instance.init();

  runApp(const AeroNetApp());
}

class AeroNetApp extends StatefulWidget {
  const AeroNetApp({super.key});

  @override
  State<AeroNetApp> createState() => _AeroNetAppState();
}

class _AeroNetAppState extends State<AeroNetApp> {
  late final AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    _authProvider = AuthProvider();
  }

  @override
  void dispose() {
    _authProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateProvider<AuthProvider>(
      notifier: _authProvider,
      child: MaterialApp(
        title: 'AeroNet',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        initialRoute: AppRoutes.bootstrap,
        routes: {
          AppRoutes.bootstrap: (context) => const BootstrapScreen(),
          AppRoutes.login: (context) => const LoginScreen(),
          AppRoutes.clientShell: (context) => const ClientShell(),
          AppRoutes.adminShell: (context) => const AdminShell(),
        },
      ),
    );
  }
}

class BootstrapScreen extends StatefulWidget {
  const BootstrapScreen({super.key});

  @override
  State<BootstrapScreen> createState() => _BootstrapScreenState();
}

class _BootstrapScreenState extends State<BootstrapScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // Add a slight delay for smooth visual transition
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    final authProvider = AppStateProvider.of<AuthProvider>(context);
    authProvider.checkSession();

    if (authProvider.isLoggedIn) {
      final role = authProvider.currentUser?.role ?? 'client';
      if (role == 'admin') {
        Navigator.of(context).pushReplacementNamed(AppRoutes.adminShell);
      } else {
        Navigator.of(context).pushReplacementNamed(AppRoutes.clientShell);
      }
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_tethering,
              size: 72,
              color: Color(0xFF2DD4BF),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2DD4BF)),
            ),
          ],
        ),
      ),
    );
  }
}
