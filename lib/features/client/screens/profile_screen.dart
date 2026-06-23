import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:aeronet_app_flutter/core/utils/app_state_provider.dart';
import 'package:aeronet_app_flutter/features/auth/providers/auth_provider.dart';
import 'package:aeronet_app_flutter/shared/widgets/app_page.dart';
import 'package:aeronet_app_flutter/shared/widgets/loading_widget.dart';
import 'package:aeronet_app_flutter/shared/widgets/glass_container.dart';
import 'package:aeronet_app_flutter/core/utils/helpers.dart';
import 'package:aeronet_app_flutter/core/utils/local_notifier.dart';
import 'package:aeronet_app_flutter/core/routes/app_routes.dart';
import 'package:aeronet_app_flutter/data/repositories/customer_repository.dart';
import 'package:aeronet_app_flutter/data/models/customer_model.dart';
import 'package:aeronet_app_flutter/data/services/storage_service.dart';
import 'package:aeronet_app_flutter/core/constants/app_constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  CustomerModel? _profile;
  bool _loading = true;
  String? _error;
  final _apiUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProfile();
    final fallbackUrl = dotenv.env['API_BASE_URL'] ?? AppConstants.defaultApiUrl;
    _apiUrlController.text = StorageService.instance.getApiBaseUrl(fallbackUrl);
  }

  @override
  void dispose() {
    _apiUrlController.dispose();
    super.dispose();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final profile = await CustomerRepository.instance.getMe();
      setState(() {
        _profile = profile;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _pickAndUploadAvatar(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 75,
        maxWidth: 500,
      );

      if (pickedFile == null) return;

      setState(() => _loading = true);
      final updatedProfile = await CustomerRepository.instance.uploadAvatar(File(pickedFile.path));
      
      setState(() {
        _profile = updatedProfile;
      });

      await LocalNotifier.instance.show(
        'Perfil Actualizado',
        '¡Tu foto de avatar ha sido cargada y actualizada con éxito!',
      );
      
      if (mounted) showMessage(context, 'Avatar actualizado.');
    } catch (e) {
      if (mounted) showMessage(context, 'Error al subir avatar: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveApiUrl() async {
    final url = _apiUrlController.text.trim();
    if (url.isEmpty) return;

    try {
      await StorageService.instance.saveApiBaseUrl(url);
      if (mounted) showMessage(context, 'URL de la API actualizada. Reinicia el flujo para aplicar.');
    } catch (e) {
      if (mounted) showMessage(context, 'Error al guardar la URL.');
    }
  }

  Future<void> _logout(AuthProvider authProvider) async {
    await authProvider.logout();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = AppStateProvider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return AppPage(
      title: 'Mi Perfil',
      subtitle: 'Configuraciones de Usuario',
      child: _loading && _profile == null
          ? const LoadingWidget(message: 'Cargando perfil...')
          : _buildContent(context, authProvider, user),
    );
  }

  Widget _buildContent(BuildContext context, AuthProvider authProvider, dynamic user) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Avatar Header
        Center(
          child: Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: const Color(0xFF1E293B),
                backgroundImage: _profile != null && _profile!.avatarUrl.isNotEmpty
                    ? NetworkImage(_profile!.avatarUrl)
                    : null,
                child: _profile == null || _profile!.avatarUrl.isEmpty
                    ? const Icon(Icons.person, size: 60, color: Colors.white54)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF2DD4BF),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt_outlined, color: Colors.black, size: 20),
                    onPressed: () => _showAvatarPickerOptions(context),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // User Data details
        GlassContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _profile?.fullName ?? 'Usuario AeroNet',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 6),
              Text(
                _profile?.email ?? user?.email ?? '',
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
              if (_profile != null && _profile!.phone.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.phone_outlined, size: 16, color: Color(0xFF2DD4BF)),
                    const SizedBox(width: 8),
                    Text(_profile!.phone, style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ],
              if (_profile != null && _profile!.documentNumber.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.badge_outlined, size: 16, color: Color(0xFF2DD4BF)),
                    const SizedBox(width: 8),
                    Text(
                      '${_profile!.documentType}: ${_profile!.documentNumber}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // API settings input
        GlassContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Parámetros de Desarrollo',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _apiUrlController,
                decoration: InputDecoration(
                  labelText: 'Backend API Base URL',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.save_outlined, color: Color(0xFF2DD4BF)),
                    onPressed: _saveApiUrl,
                  ),
                ),
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Notifications & Sockets details
        GlassContainer(
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.notifications_active_outlined, color: Color(0xFF2DD4BF)),
                title: const Text('Notificaciones Locales', style: TextStyle(color: Colors.white)),
                subtitle: const Text('Gatillar alerta de prueba local', style: TextStyle(color: Colors.white60, fontSize: 12)),
                trailing: IconButton(
                  icon: const Icon(Icons.play_circle_outline, color: Color(0xFF2DD4BF)),
                  onPressed: () async {
                    await LocalNotifier.instance.show(
                      'Notificación de Prueba',
                      'Hola, esto es una prueba exitosa del canal general de AeroNet.',
                    );
                  },
                ),
              ),
              const Divider(color: Colors.white10),
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.hub_outlined, color: Colors.white30),
                title: Text('Servidor de Sockets', style: TextStyle(color: Colors.white30)),
                subtitle: Text('El backend de Render no expone gateway websocket activo.', style: TextStyle(color: Colors.white30, fontSize: 12)),
              ),
            ],
          ),
        ),
        
        if (_error != null) ...[
          const SizedBox(height: 16),
          Text(
            'Error al refrescar datos del backend: $_error',
            style: const TextStyle(color: Colors.redAccent, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],

        const SizedBox(height: 32),

        // Logout
        FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: Colors.redAccent.withOpacity(0.9)),
          onPressed: () => _logout(authProvider),
          icon: const Icon(Icons.logout, color: Colors.white),
          label: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  void _showAvatarPickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: Color(0xFF2DD4BF)),
                title: const Text('Galería', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickAndUploadAvatar(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined, color: Color(0xFF2DD4BF)),
                title: const Text('Cámara', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickAndUploadAvatar(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
