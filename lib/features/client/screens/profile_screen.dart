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
  final Widget? drawer;
  const ProfileScreen({super.key, this.drawer});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  CustomerModel? _profile;
  bool _loading = true;
  String? _error;
  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  @override
  void dispose() {
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
      drawer: widget.drawer,
      title: 'Mi Perfil',
      subtitle: 'Configuraciones de Usuario',
      child: _loading && _profile == null
          ? const LoadingWidget(message: 'Cargando perfil...')
          : _buildContent(context, authProvider, user),
    );
  }

  Widget _buildContent(BuildContext context, AuthProvider authProvider, dynamic user) {
    return ListView(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100), // Aire inferior para barra inferior extendida
      children: [
        // Avatar Header
        Center(
          child: Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: const Color(0xFF222840), // Superficie secundaria
                backgroundImage: _profile != null && _profile!.avatarUrl.isNotEmpty
                    ? NetworkImage(_profile!.avatarUrl)
                    : null,
                child: _profile == null || _profile!.avatarUrl.isEmpty
                    ? const Icon(Icons.person, size: 60, color: Color(0xFF8C92AE))
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF4FE6C4), // Menta
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt_outlined, color: Color(0xFF10131F), size: 20),
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
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF2F4FA),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _profile?.email ?? user?.email ?? '',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: Color(0xFF8C92AE),
                ),
              ),
              if (_profile != null && _profile!.phone.isNotEmpty) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4FE6C4).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.phone_outlined, size: 16, color: Color(0xFF4FE6C4)),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _profile!.phone,
                      style: const TextStyle(fontFamily: 'Inter', color: Color(0xFFF2F4FA)),
                    ),
                  ],
                ),
              ],
              if (_profile != null && _profile!.documentNumber.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4FE6C4).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.badge_outlined, size: 16, color: Color(0xFF4FE6C4)),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${_profile!.documentType}: ${_profile!.documentNumber}',
                      style: const TextStyle(fontFamily: 'Inter', color: Color(0xFFF2F4FA)),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        
        if (_error != null) ...[
          const SizedBox(height: 16),
          Text(
            'Error al refrescar datos del backend: $_error',
            style: const TextStyle(color: Color(0xFFFF6B6B), fontSize: 12, fontFamily: 'Inter'),
            textAlign: TextAlign.center,
          ),
        ],

        const SizedBox(height: 32),

        // Logout
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFFF6B6B), // Coral
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () => _logout(authProvider),
          icon: const Icon(Icons.logout, color: Colors.white),
          label: const Text(
            'Cerrar Sesión',
            style: TextStyle(fontFamily: 'Inter', color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  void _showAvatarPickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1E30), // Surface background
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: Color(0xFF4FE6C4)),
                title: const Text('Galería', style: TextStyle(fontFamily: 'Inter', color: Color(0xFFF2F4FA))),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickAndUploadAvatar(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined, color: Color(0xFF4FE6C4)),
                title: const Text('Cámara', style: TextStyle(fontFamily: 'Inter', color: Color(0xFFF2F4FA))),
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
