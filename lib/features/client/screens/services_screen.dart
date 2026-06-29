import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:aeronet_app_flutter/core/utils/app_state_provider.dart';
import 'package:aeronet_app_flutter/features/client/providers/client_provider.dart';
import 'package:aeronet_app_flutter/shared/widgets/app_page.dart';
import 'package:aeronet_app_flutter/shared/widgets/loading_widget.dart';
import 'package:aeronet_app_flutter/shared/widgets/error_state.dart';
import 'package:aeronet_app_flutter/shared/widgets/empty_state.dart';
import 'package:aeronet_app_flutter/features/client/widgets/service_card.dart';
import 'package:aeronet_app_flutter/core/utils/helpers.dart';
import 'package:aeronet_app_flutter/data/repositories/customer_repository.dart';
import 'package:aeronet_app_flutter/data/models/customer_model.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final clientProvider = AppStateProvider.of<ClientProvider>(context);

    return AppPage(
      title: 'Mis Servicios',
      subtitle: 'Instalaciones y Conexiones',
      actions: [
        IconButton(
          tooltip: 'Solicitar Instalación',
          icon: const Icon(Icons.add_location_alt_outlined, color: Color(0xFF2DD4BF)),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AppStateProvider<ClientProvider>(
                  notifier: clientProvider,
                  child: const ServiceRequestPage(),
                ),
              ),
            );
          },
        ),
      ],
      child: RefreshIndicator(
        onRefresh: () => clientProvider.loadMyServices(),
        child: _buildList(context, clientProvider),
      ),
    );
  }

  Widget _buildList(BuildContext context, ClientProvider provider) {
    if (provider.isLoading && provider.myServices.isEmpty) {
      return const LoadingWidget(message: 'Cargando servicios...');
    }

    if (provider.errorMessage != null) {
      return ErrorState(
        error: provider.errorMessage!,
        onRetry: () => provider.loadMyServices(),
      );
    }

    if (provider.myServices.isEmpty) {
      return const EmptyState(
        text: 'Aún no tienes servicios instalados. ¡Solicita tu instalación presionando el botón superior!',
        icon: Icons.router_outlined,
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: provider.myServices.length,
      itemBuilder: (context, index) {
        return ServiceCard(service: provider.myServices[index]);
      },
    );
  }
}

// Request Installation Page
class ServiceRequestPage extends StatefulWidget {
  const ServiceRequestPage({super.key});

  @override
  State<ServiceRequestPage> createState() => _ServiceRequestPageState();
}

class _ServiceRequestPageState extends State<ServiceRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _documentNumberController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _referenceController = TextEditingController();
  String? _selectedDocumentType = 'DNI';
  String? _selectedPlanId;
  Position? _currentPosition;
  bool _fetchingLocation = false;
  bool _submitting = false;
  bool _loadingProfile = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _documentNumberController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _loadingProfile = true);
    try {
      final CustomerModel profile = await CustomerRepository.instance.getMe();
      setState(() {
        _fullNameController.text = profile.fullName;
        _phoneController.text = profile.phone;
        _documentNumberController.text = profile.documentNumber;
        if (['DNI', 'RUC'].contains(profile.documentType)) {
          _selectedDocumentType = profile.documentType;
        } else {
          _selectedDocumentType = 'DNI';
        }
        _addressController.text = profile.address;
      });
    } catch (_) {
      // Ignore profile loading errors, allow manual entry
    } finally {
      if (mounted) {
        setState(() => _loadingProfile = false);
      }
    }
  }

  Future<void> _getLocation() async {
    setState(() => _fetchingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        if (mounted) showMessage(context, 'Permiso de ubicación denegado.');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      setState(() {
        _currentPosition = position;
      });
      if (mounted) showMessage(context, 'Ubicación GPS agregada con éxito.');
    } catch (e) {
      if (mounted) showMessage(context, 'Error al obtener GPS: $e');
    } finally {
      if (mounted) setState(() => _fetchingLocation = false);
    }
  }

  Future<void> _submit(ClientProvider provider) async {
    if (!_formKey.currentState!.validate() || _selectedPlanId == null || _selectedDocumentType == null) {
      showMessage(context, 'Por favor completa los campos y selecciona un plan.');
      return;
    }

    setState(() => _submitting = true);
    try {
      final selectedPlan = provider.allPlans.firstWhere((p) => p.id == _selectedPlanId);
      await provider.requestInstallation(
        planId: _selectedPlanId!,
        fullName: _fullNameController.text.trim(),
        documentType: _selectedDocumentType!,
        documentNumber: _documentNumberController.text.trim(),
        phone: _phoneController.text.trim(),
        addressText: _addressController.text.trim(),
        latitude: _currentPosition?.latitude,
        longitude: _currentPosition?.longitude,
        ticketSubject: 'Solicitud de Instalación - ${selectedPlan.name}',
        ticketDescription: _referenceController.text.trim().isNotEmpty
            ? 'Instalación de plan ${selectedPlan.name}. Referencia: ${_referenceController.text.trim()}'
            : 'Instalación de plan ${selectedPlan.name}.',
        ticketPriority: 'ALTA',
      );
      if (mounted) {
        Navigator.of(context).pop();
        showMessage(context, '¡Solicitud registrada con éxito!');
      }
    } catch (e) {
      if (mounted) showMessage(context, e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final clientProvider = AppStateProvider.of<ClientProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Nueva Instalación'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F2027),
              Color(0xFF203A43),
              Color(0xFF0B1120),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Formulario de Solicitud',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Elige el plan de internet y dinos dónde deseas instalar el servicio.',
                    style: TextStyle(fontSize: 13, color: Colors.white60),
                  ),
                  const SizedBox(height: 24),

                  if (_loadingProfile) ...[
                    const LinearProgressIndicator(
                      backgroundColor: Colors.white10,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2DD4BF)),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Plan Select dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedPlanId,
                    decoration: const InputDecoration(
                      labelText: 'Plan de Internet',
                      prefixIcon: Icon(Icons.speed_outlined),
                    ),
                    dropdownColor: const Color(0xFF1E293B),
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    items: clientProvider.allPlans.map((plan) {
                      return DropdownMenuItem(
                        value: plan.id,
                        child: Text('${plan.name} - ${money(plan.price)}'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedPlanId = val;
                      });
                    },
                    validator: (val) => val == null ? 'Selecciona un plan' : null,
                  ),
                  const SizedBox(height: 16),

                  // Nombre Completo
                  TextFormField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre Completo',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    style: const TextStyle(color: Colors.white),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Ingresa el nombre completo'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Tipo / Nro Documento
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          value: _selectedDocumentType,
                          decoration: const InputDecoration(
                            labelText: 'Tipo',
                          ),
                          dropdownColor: const Color(0xFF1E293B),
                          style: const TextStyle(color: Colors.white, fontSize: 15),
                          items: const [
                            DropdownMenuItem(value: 'DNI', child: Text('DNI')),
                            DropdownMenuItem(value: 'RUC', child: Text('RUC')),
                          ],
                          onChanged: (val) {
                            setState(() {
                              _selectedDocumentType = val;
                            });
                          },
                          validator: (val) => val == null ? 'Requerido' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _documentNumberController,
                          decoration: const InputDecoration(
                            labelText: 'Nro Documento',
                          ),
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.number,
                          validator: (val) => val == null || val.trim().isEmpty
                              ? 'Ingresa el número'
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Teléfono
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono / Celular',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.phone,
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Ingresa el teléfono'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Address TextField
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Dirección de Instalación',
                      prefixIcon: Icon(Icons.home_outlined),
                    ),
                    style: const TextStyle(color: Colors.white),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Ingresa la dirección completa'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Reference TextField
                  TextFormField(
                    controller: _referenceController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Referencia de la vivienda',
                      prefixIcon: Icon(Icons.notes_outlined),
                    ),
                    style: const TextStyle(color: Colors.white),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Agrega una referencia'
                        : null,
                  ),
                  const SizedBox(height: 20),

                  // Geolocator Action
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _fetchingLocation ? null : _getLocation,
                          icon: _fetchingLocation
                              ? const SizedBox.square(
                                  dimension: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.my_location, size: 16),
                          label: Text(
                            _currentPosition == null
                                ? 'Agregar Coordenadas GPS'
                                : 'Coordenadas Agregadas',
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  if (_currentPosition != null) ...[
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}, Lng: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                        style: const TextStyle(color: Color(0xFF2DD4BF), fontSize: 12, fontFamily: 'monospace'),
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 32),

                  // Submit Button
                  FilledButton.icon(
                    onPressed: _submitting ? null : () => _submit(clientProvider),
                    icon: _submitting
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.send_outlined),
                    label: const Text('Enviar Solicitud'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
