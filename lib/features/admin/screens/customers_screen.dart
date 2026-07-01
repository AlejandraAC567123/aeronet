import 'package:flutter/material.dart';
import 'package:aeronet_app_flutter/core/utils/app_state_provider.dart';
import 'package:aeronet_app_flutter/features/admin/providers/customers_admin_provider.dart';
import 'package:aeronet_app_flutter/shared/widgets/app_page.dart';
import 'package:aeronet_app_flutter/shared/widgets/loading_widget.dart';
import 'package:aeronet_app_flutter/shared/widgets/error_state.dart';
import 'package:aeronet_app_flutter/shared/widgets/empty_state.dart';
import 'package:aeronet_app_flutter/features/admin/widgets/customer_card.dart';
import 'package:aeronet_app_flutter/data/models/customer_model.dart';
import 'package:aeronet_app_flutter/core/utils/helpers.dart';
import 'package:aeronet_app_flutter/core/routes/app_routes.dart';
import 'package:aeronet_app_flutter/features/auth/providers/auth_provider.dart';
import 'package:aeronet_app_flutter/core/theme/app_theme.dart';

class CustomersScreen extends StatefulWidget {
  final Widget? drawer;
  const CustomersScreen({super.key, this.drawer});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {

  void _showFormDialog(BuildContext context, CustomersAdminProvider provider, [CustomerModel? customer]) {
    final isEdit = customer != null;
    final nameController = TextEditingController(text: customer?.fullName);
    final emailController = TextEditingController(text: customer?.email);
    final phoneController = TextEditingController(text: customer?.phone);
    final docNumController = TextEditingController(text: customer?.documentNumber);
    final addressController = TextEditingController(text: customer?.address);
    final cityController = TextEditingController(text: customer?.city);
    final passwordController = TextEditingController();
    String docType = customer?.documentType.isNotEmpty == true ? customer!.documentType : 'DNI';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppTheme.cardColor,
          title: Text(isEdit ? 'Editar Cliente' : 'Nuevo Cliente', style: const TextStyle(color: AppTheme.textPrimaryColor)),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isEdit) ...[
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Nombre completo'),
                      style: const TextStyle(color: AppTheme.textPrimaryColor),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Ingresa el nombre' : null,
                    ),
                    const SizedBox(height: 12),
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
                  ] else ...[
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Nombre completo'),
                      style: const TextStyle(color: AppTheme.textPrimaryColor),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Ingresa el nombre' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: phoneController,
                      decoration: const InputDecoration(labelText: 'Teléfono'),
                      style: const TextStyle(color: AppTheme.textPrimaryColor),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: docType,
                      dropdownColor: AppTheme.cardColor,
                      decoration: const InputDecoration(labelText: 'Tipo de documento'),
                      items: ['DNI', 'RUC', 'PASAPORTE', 'CE'].map((t) {
                        return DropdownMenuItem(value: t, child: Text(t));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) docType = val;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: docNumController,
                      decoration: const InputDecoration(labelText: 'Nro de documento'),
                      style: const TextStyle(color: AppTheme.textPrimaryColor),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Ingresa el nro de documento' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: addressController,
                      decoration: const InputDecoration(labelText: 'Dirección'),
                      style: const TextStyle(color: AppTheme.textPrimaryColor),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: cityController,
                      decoration: const InputDecoration(labelText: 'Ciudad'),
                      style: const TextStyle(color: AppTheme.textPrimaryColor),
                    ),
                  ]
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
                  final data = isEdit
                      ? {
                          'full_name': nameController.text.trim(),
                          'phone': phoneController.text.trim(),
                          'document_type': docType,
                          'document_number': docNumController.text.trim(),
                          'address': addressController.text.trim(),
                          'city': cityController.text.trim(),
                        }
                      : {
                          'full_name': nameController.text.trim(),
                          'email': emailController.text.trim(),
                          'password': passwordController.text.trim(),
                        };
                  try {
                    if (isEdit) {
                      await provider.updateCustomer(customer.id, data);
                    } else {
                      await provider.createCustomer(data);
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

  void _confirmDelete(BuildContext context, CustomersAdminProvider provider, String id) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppTheme.cardColor,
          title: const Text('Eliminar Cliente', style: TextStyle(color: AppTheme.textPrimaryColor)),
          content: const Text('¿Estás seguro de eliminar este cliente? Esta acción no se puede deshacer.', style: TextStyle(color: AppTheme.textSecondaryColor)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar', style: TextStyle(color: AppTheme.textSecondaryColor)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppTheme.errorColor),
              onPressed: () async {
                try {
                  await provider.deleteCustomer(id);
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

  late final CustomersAdminProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = CustomersAdminProvider();
    _provider.loadCustomers();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = _provider;
    final authProvider = AppStateProvider.of<AuthProvider>(context);

    return AppStateProvider<CustomersAdminProvider>(
      notifier: _provider,
      child: AppPage(
        drawer: widget.drawer,
      title: 'Clientes',
      subtitle: 'Control de Usuarios ISP',
      actions: [
        IconButton(
          tooltip: 'Nuevo Cliente',
          icon: const Icon(Icons.person_add_alt_1_outlined, color: AppTheme.accentColor),
          onPressed: () => _showFormDialog(context, adminProvider),
        ),
        IconButton(
          tooltip: 'Cerrar Sesión',
          icon: const Icon(Icons.logout_outlined, color: AppTheme.errorColor),
          onPressed: () async {
            await authProvider.logout();
            if (context.mounted) {
              Navigator.of(context).pushReplacementNamed(AppRoutes.login);
            }
          },
        ),
      ],
      child: RefreshIndicator(
        onRefresh: () => adminProvider.loadCustomers(),
        child: ListenableBuilder(
          listenable: adminProvider,
          builder: (context, _) {
            if (adminProvider.isLoading && adminProvider.customers.isEmpty) {
              return const LoadingWidget(message: 'Cargando clientes...');
            }

            if (adminProvider.errorMessage != null) {
              return ErrorState(
                error: adminProvider.errorMessage!,
                onRetry: () => adminProvider.loadCustomers(),
              );
            }

            if (adminProvider.customers.isEmpty) {
              return const EmptyState(
                text: 'No hay clientes registrados en el sistema.',
                icon: Icons.people_outline,
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: adminProvider.customers.length,
              itemBuilder: (context, index) {
                final customer = adminProvider.customers[index];
                return CustomerCard(
                  customer: customer,
                  onEdit: () => _showFormDialog(context, adminProvider, customer),
                  onDelete: () => _confirmDelete(context, adminProvider, customer.id),
                );
              },
            );
          },
        ),
      ),
    ));
  }
}