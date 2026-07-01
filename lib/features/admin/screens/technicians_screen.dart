import 'package:flutter/material.dart';
import 'package:aeronet_app_flutter/core/utils/app_state_provider.dart';
import 'package:aeronet_app_flutter/features/admin/providers/technicians_admin_provider.dart';
import 'package:aeronet_app_flutter/shared/widgets/app_page.dart';
import 'package:aeronet_app_flutter/shared/widgets/loading_widget.dart';
import 'package:aeronet_app_flutter/shared/widgets/error_state.dart';
import 'package:aeronet_app_flutter/shared/widgets/empty_state.dart';
import 'package:aeronet_app_flutter/shared/widgets/glass_container.dart';
import 'package:aeronet_app_flutter/data/models/technician_model.dart';
import 'package:aeronet_app_flutter/core/utils/helpers.dart';
import 'package:aeronet_app_flutter/shared/extensions/string_extensions.dart';
import 'package:aeronet_app_flutter/core/theme/app_theme.dart';
 
class TechniciansScreen extends StatefulWidget {
  final Widget? drawer;
  const TechniciansScreen({super.key, this.drawer});

  @override
  State<TechniciansScreen> createState() => _TechniciansScreenState();
}

class _TechniciansScreenState extends State<TechniciansScreen> {
 
  // ✅ Constante de especialidades
  static const List<String> validSpecialties = ['FIBRA', 'COBRE', 'WIRELESS', 'MIXTO'];
 
  void _showFormDialog(BuildContext context, TechniciansAdminProvider provider, [TechnicianModel? technician]) {
    final isEdit = technician != null;
    final nameController = TextEditingController(text: technician?.fullName);
    final emailController = TextEditingController(text: technician?.email);
    final passwordController = TextEditingController();
    final phoneController = TextEditingController(text: technician?.phone);
    final docNumController = TextEditingController(text: technician?.documentNumber);
    String selectedSpecialization = technician != null && technician.specialization.isNotEmpty
        ? technician.specialization
        : 'FIBRA';
    String status = technician?.status ?? 'active';
    final formKey = GlobalKey<FormState>();
 
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppTheme.cardColor,
          title: Text(isEdit ? 'Editar Técnico' : 'Nuevo Técnico', style: const TextStyle(color: AppTheme.textPrimaryColor)),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nombre completo'),
                    style: const TextStyle(color: AppTheme.textPrimaryColor),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Ingresa el nombre' : null,
                  ),
                  const SizedBox(height: 12),
                  if (!isEdit) ...[
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Correo electrónico'),
                      style: const TextStyle(color: AppTheme.textPrimaryColor),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Ingresa el correo' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: passwordController,
                      decoration: const InputDecoration(labelText: 'Contraseña'),
                      style: const TextStyle(color: AppTheme.textPrimaryColor),
                      obscureText: true,
                      validator: (v) => v == null || v.length < 6 ? 'Mínimo 6 caracteres' : null,
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: 'Teléfono'),
                    style: const TextStyle(color: AppTheme.textPrimaryColor),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Ingresa el teléfono' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: docNumController,
                    decoration: const InputDecoration(labelText: 'Nro de documento'),
                    style: const TextStyle(color: AppTheme.textPrimaryColor),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedSpecialization,
                    dropdownColor: AppTheme.cardColor,
                    decoration: const InputDecoration(labelText: 'Especialidad'),
                    style: const TextStyle(color: AppTheme.textPrimaryColor),
                    items: validSpecialties.map((spec) {
                      return DropdownMenuItem(value: spec, child: Text(spec));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        selectedSpecialization = val;
                      }
                    },
                    validator: (v) => v == null || v.isEmpty ? 'Selecciona una especialidad' : null,
                  ),
                  if (isEdit) ...[
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: status,
                      dropdownColor: AppTheme.cardColor,
                      decoration: const InputDecoration(labelText: 'Estado'),
                      items: ['active', 'inactive', 'on_leave'].map((st) {
                        return DropdownMenuItem(value: st, child: Text(st.cleanStatus()));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) status = val;
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar', style: TextStyle(color: AppTheme.textSecondaryColor)),
            ),
            FilledButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final data = {
                    'full_name': nameController.text.trim(),
                    'phone': phoneController.text.trim(),
                    'document_number': docNumController.text.trim(),
                    'specialization': selectedSpecialization,
                    if (!isEdit) ...{
                      'email': emailController.text.trim(),
                      'password': passwordController.text.trim(),
                    },
                    if (isEdit) ...{
                      'status': status,
                    },
                  };
                  try {
                    if (isEdit) {
                      await provider.updateTechnician(technician.id, data);
                    } else {
                      await provider.createTechnician(data);
                    }
                    if (ctx.mounted) Navigator.of(ctx).pop();
                  } catch (e) {
                    showMessage(context, e.toString());
                  }
                }
              },
              child: Text(isEdit ? 'Guardar' : 'Crear'),
            ),
          ],
        );
      },
    );
  }
 
  void _confirmDelete(BuildContext context, TechniciansAdminProvider provider, String id) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppTheme.cardColor,
          title: const Text('Eliminar Técnico', style: TextStyle(color: AppTheme.textPrimaryColor)),
          content: const Text('¿Estás seguro de eliminar este técnico?', style: TextStyle(color: AppTheme.textSecondaryColor)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar', style: TextStyle(color: AppTheme.textSecondaryColor)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppTheme.errorColor),
              onPressed: () async {
                try {
                  await provider.deleteTechnician(id);
                  if (ctx.mounted) Navigator.of(ctx).pop();
                } catch (e) {
                  showMessage(context, e.toString());
                }
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }
 
  late final TechniciansAdminProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = TechniciansAdminProvider();
    _provider.loadTechnicians();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = _provider;
 
    return AppStateProvider<TechniciansAdminProvider>(
      notifier: _provider,
      child: AppPage(
        drawer: widget.drawer,
      title: 'Técnicos',
      subtitle: 'Personal de Campo ISP',
      actions: [
        IconButton(
          tooltip: 'Nuevo Técnico',
          icon: const Icon(Icons.person_add_outlined, color: AppTheme.accentColor),
          onPressed: () => _showFormDialog(context, adminProvider),
        ),
      ],
      child: RefreshIndicator(
        onRefresh: () => adminProvider.loadTechnicians(),
        child: ListenableBuilder(
          listenable: adminProvider,
          builder: (context, _) {
            if (adminProvider.isLoading && adminProvider.technicians.isEmpty) {
              return const LoadingWidget(message: 'Cargando técnicos...');
            }
 
            if (adminProvider.errorMessage != null) {
              return ErrorState(
                error: adminProvider.errorMessage!,
                onRetry: () => adminProvider.loadTechnicians(),
              );
            }
 
            if (adminProvider.technicians.isEmpty) {
              return const EmptyState(
                text: 'No hay técnicos asignados en el sistema.',
                icon: Icons.engineering_outlined,
              );
            }
 
            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: adminProvider.technicians.length,
              itemBuilder: (context, index) {
                final tech = adminProvider.technicians[index];
                
                Color statusColor = AppTheme.accentColor; // Active
                if (tech.status == 'inactive') {
                  statusColor = AppTheme.errorColor;
                } else if (tech.status == 'on_leave') {
                  statusColor = AppTheme.alertColor;
                }
 
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GlassContainer(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.engineering, color: AppTheme.accentColor, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tech.fullName,
                                style: const TextStyle(
                                  color: AppTheme.textPrimaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                tech.email,
                                style: const TextStyle(color: AppTheme.textSecondaryColor, fontSize: 13),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.phone_outlined, size: 14, color: AppTheme.textTertiaryColor),
                                  const SizedBox(width: 4),
                                  Text(tech.phone, style: const TextStyle(color: AppTheme.textSecondaryColor, fontSize: 12)),
                                  const SizedBox(width: 12),
                                  const Icon(Icons.workspace_premium_outlined, size: 14, color: AppTheme.textTertiaryColor),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      tech.specialization,
                                      style: const TextStyle(color: AppTheme.textSecondaryColor, fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  tech.status.cleanStatus(),
                                  style: TextStyle(
                                    color: statusColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, color: AppTheme.textSecondaryColor, size: 20),
                              onPressed: () => _showFormDialog(context, adminProvider, tech),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppTheme.errorColor, size: 20),
                              onPressed: () => _confirmDelete(context, adminProvider, tech.id),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    ));
  }
}