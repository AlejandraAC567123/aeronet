import 'package:flutter/material.dart';
import 'package:aeronet_app_flutter/core/utils/app_state_provider.dart';
import 'package:aeronet_app_flutter/features/admin/providers/admin_provider.dart';
import 'package:aeronet_app_flutter/shared/widgets/app_page.dart';
import 'package:aeronet_app_flutter/shared/widgets/loading_widget.dart';
import 'package:aeronet_app_flutter/shared/widgets/error_state.dart';
import 'package:aeronet_app_flutter/shared/widgets/empty_state.dart';
import 'package:aeronet_app_flutter/shared/widgets/glass_container.dart';
import 'package:aeronet_app_flutter/data/models/technician_model.dart';
import 'package:aeronet_app_flutter/core/utils/helpers.dart';
import 'package:aeronet_app_flutter/shared/extensions/string_extensions.dart';
 
class TechniciansScreen extends StatelessWidget {
  const TechniciansScreen({super.key});
 
  // ✅ Constante de especialidades
  static const List<String> validSpecialties = ['FIBRA', 'COBRE', 'WIRELESS', 'MIXTO'];
 
  void _showFormDialog(BuildContext context, AdminProvider provider, [TechnicianModel? technician]) {
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
          backgroundColor: const Color(0xFF1E293B),
          title: Text(isEdit ? 'Editar Técnico' : 'Nuevo Técnico', style: const TextStyle(color: Colors.white)),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nombre completo'),
                    style: const TextStyle(color: Colors.white),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Ingresa el nombre' : null,
                  ),
                  const SizedBox(height: 12),
                  if (!isEdit) ...[
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Correo electrónico'),
                      style: const TextStyle(color: Colors.white),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Ingresa el correo' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: passwordController,
                      decoration: const InputDecoration(labelText: 'Contraseña'),
                      style: const TextStyle(color: Colors.white),
                      obscureText: true,
                      validator: (v) => v == null || v.length < 6 ? 'Mínimo 6 caracteres' : null,
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: 'Teléfono'),
                    style: const TextStyle(color: Colors.white),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Ingresa el teléfono' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: docNumController,
                    decoration: const InputDecoration(labelText: 'Nro de documento'),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedSpecialization,
                    dropdownColor: const Color(0xFF1E293B),
                    decoration: const InputDecoration(labelText: 'Especialidad'),
                    style: const TextStyle(color: Colors.white),
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
                      dropdownColor: const Color(0xFF1E293B),
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
              child: const Text('Cancelar', style: TextStyle(color: Colors.white60)),
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
 
  void _confirmDelete(BuildContext context, AdminProvider provider, String id) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text('Eliminar Técnico', style: TextStyle(color: Colors.white)),
          content: const Text('¿Estás seguro de eliminar este técnico?', style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar', style: TextStyle(color: Colors.white60)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
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
 
  @override
  Widget build(BuildContext context) {
    final adminProvider = AppStateProvider.of<AdminProvider>(context);
 
    return AppPage(
      title: 'Técnicos',
      subtitle: 'Personal de Campo ISP',
      actions: [
        IconButton(
          tooltip: 'Nuevo Técnico',
          icon: const Icon(Icons.person_add_outlined, color: Color(0xFF2DD4BF)),
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
                
                Color statusColor = const Color(0xFF2DD4BF); // Active
                if (tech.status == 'inactive') {
                  statusColor = Colors.redAccent;
                } else if (tech.status == 'on_leave') {
                  statusColor = Colors.orangeAccent;
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
                            color: const Color(0xFF2DD4BF).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.engineering, color: Color(0xFF2DD4BF), size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tech.fullName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                tech.email,
                                style: const TextStyle(color: Colors.white60, fontSize: 13),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.phone_outlined, size: 14, color: Colors.white38),
                                  const SizedBox(width: 4),
                                  Text(tech.phone, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                  const SizedBox(width: 12),
                                  const Icon(Icons.workspace_premium_outlined, size: 14, color: Colors.white38),
                                  const SizedBox(width: 4),
                                  Text(tech.specialization, style: const TextStyle(color: Colors.white70, fontSize: 12)),
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
                              icon: const Icon(Icons.edit_outlined, color: Colors.white60, size: 20),
                              onPressed: () => _showFormDialog(context, adminProvider, tech),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
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
    );
  }
}