import 'package:flutter/material.dart';
import 'package:aeronet_app_flutter/core/utils/app_state_provider.dart';
import 'package:aeronet_app_flutter/features/admin/providers/plans_admin_provider.dart';
import 'package:aeronet_app_flutter/shared/widgets/app_page.dart';
import 'package:aeronet_app_flutter/shared/widgets/loading_widget.dart';
import 'package:aeronet_app_flutter/shared/widgets/error_state.dart';
import 'package:aeronet_app_flutter/shared/widgets/empty_state.dart';
import 'package:aeronet_app_flutter/features/admin/widgets/plan_card.dart';
import 'package:aeronet_app_flutter/data/models/plan_model.dart';
import 'package:aeronet_app_flutter/core/utils/helpers.dart';
import 'package:aeronet_app_flutter/core/theme/app_theme.dart';

class PlansScreen extends StatefulWidget {
  final Widget? drawer;
  const PlansScreen({super.key, this.drawer});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {

  void _showFormDialog(BuildContext context, PlansAdminProvider provider, [PlanModel? plan]) {
    final isEdit = plan != null;
    final nameController = TextEditingController(text: plan?.name);
    final speedController = TextEditingController(text: plan?.speedMbps.toString());
    final priceController = TextEditingController(text: plan?.price.toString());
    final descController = TextEditingController(text: plan?.description);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppTheme.cardColor,
          title: Text(isEdit ? 'Editar Plan' : 'Nuevo Plan', style: const TextStyle(color: AppTheme.textPrimaryColor)),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nombre del plan'),
                    style: const TextStyle(color: AppTheme.textPrimaryColor),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Ingresa el nombre' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: speedController,
                    decoration: const InputDecoration(labelText: 'Velocidad (Mbps)'),
                    style: const TextStyle(color: AppTheme.textPrimaryColor),
                    keyboardType: TextInputType.number,
                    validator: (v) => int.tryParse(v ?? '') == null ? 'Ingresa un número entero' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: priceController,
                    decoration: const InputDecoration(labelText: 'Precio (S/.)'),
                    style: const TextStyle(color: AppTheme.textPrimaryColor),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) => double.tryParse(v ?? '') == null ? 'Ingresa un precio decimal' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descController,
                    decoration: const InputDecoration(labelText: 'Descripción'),
                    style: const TextStyle(color: AppTheme.textPrimaryColor),
                    maxLines: 2,
                  ),
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
                    'name': nameController.text.trim(),
                    'speed_mbps': int.parse(speedController.text.trim()),
                    'price': double.parse(priceController.text.trim()),
                    'description': descController.text.trim(),
                  };
                  try {
                    if (isEdit) {
                      await provider.updatePlan(plan.id, data);
                    } else {
                      await provider.createPlan(data);
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

  void _confirmDelete(BuildContext context, PlansAdminProvider provider, String id) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppTheme.cardColor,
          title: const Text('Eliminar Plan', style: TextStyle(color: AppTheme.textPrimaryColor)),
          content: const Text('¿Estás seguro de eliminar este plan? Esto podría afectar a los clientes suscritos.', style: TextStyle(color: AppTheme.textSecondaryColor)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar', style: TextStyle(color: AppTheme.textSecondaryColor)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppTheme.errorColor),
              onPressed: () async {
                try {
                  await provider.deletePlan(id);
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

  late final PlansAdminProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = PlansAdminProvider();
    _provider.loadPlans();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = _provider;

    return AppStateProvider<PlansAdminProvider>(
      notifier: _provider,
      child: AppPage(
        drawer: widget.drawer,
      title: 'Planes',
      subtitle: 'Catálogo de Internet ISP',
      actions: [
        IconButton(
          tooltip: 'Nuevo Plan',
          icon: const Icon(Icons.add_circle_outline, color: AppTheme.accentColor),
          onPressed: () => _showFormDialog(context, adminProvider),
        ),
      ],
      child: RefreshIndicator(
        onRefresh: () => adminProvider.loadPlans(),
        child: ListenableBuilder(
          listenable: adminProvider,
          builder: (context, _) {
            if (adminProvider.isLoading && adminProvider.plans.isEmpty) {
              return const LoadingWidget(message: 'Cargando planes...');
            }

            if (adminProvider.errorMessage != null) {
              return ErrorState(
                error: adminProvider.errorMessage!,
                onRetry: () => adminProvider.loadPlans(),
              );
            }

            if (adminProvider.plans.isEmpty) {
              return const EmptyState(
                text: 'No hay planes de internet registrados.',
                icon: Icons.speed_outlined,
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: adminProvider.plans.length,
              itemBuilder: (context, index) {
                final plan = adminProvider.plans[index];
                return PlanCard(
                  plan: plan,
                  onEdit: () => _showFormDialog(context, adminProvider, plan),
                  onDelete: () => _confirmDelete(context, adminProvider, plan.id),
                );
              },
            );
          },
        ),
      ),
    ));
  }
}