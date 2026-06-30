import 'dart:async';
import 'package:flutter/material.dart';
import 'package:aeronet_app_flutter/core/utils/app_state_provider.dart';
import 'package:aeronet_app_flutter/features/admin/providers/admin_provider.dart';
import 'package:aeronet_app_flutter/shared/widgets/app_page.dart';
import 'package:aeronet_app_flutter/shared/widgets/loading_widget.dart';
import 'package:aeronet_app_flutter/shared/widgets/error_state.dart';
import 'package:aeronet_app_flutter/shared/widgets/empty_state.dart';
import 'package:aeronet_app_flutter/data/models/ticket_model.dart';
import 'package:aeronet_app_flutter/shared/widgets/glass_container.dart';
import 'package:aeronet_app_flutter/shared/extensions/string_extensions.dart';
import 'package:aeronet_app_flutter/core/utils/helpers.dart';
 
class TicketsAdminScreen extends StatefulWidget {
  const TicketsAdminScreen({super.key});
 
  @override
  State<TicketsAdminScreen> createState() => _TicketsAdminScreenState();
}
 
class _TicketsAdminScreenState extends State<TicketsAdminScreen> {
  Timer? _pollingTimer;
  
  // ✅ Constante extraída a nivel de clase para evitar redundancia
  static const List<String> validStatuses = ['open', 'assigned', 'in_progress', 'resolved', 'closed'];
 
  @override
  void initState() {
    super.initState();
    // Setup polling every 30 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        // ✅ CAMBIO: Usar .read() en lugar de .of() para no suscribirse a cambios en el timer
        final provider = AppStateProvider.read<AdminProvider>(context);
        provider.loadTickets();
      }
    });
  }
 
  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
 
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
      case 'closed':
        return const Color(0xFF2DD4BF);
      case 'in_progress':
      case 'assigned':
        return Colors.yellowAccent;
      case 'open':
      default:
        return Colors.cyanAccent;
    }
  }
 
  void _showStatusDialog(BuildContext context, AdminProvider provider, TicketModel ticket) {
    _pollingTimer?.cancel();

    String selectedStatus = validStatuses.contains(ticket.status) ? ticket.status : 'open';
    final notesController = TextEditingController();
 
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text('Actualizar Estado', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (dialogContext, setDialogState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      dropdownColor: const Color(0xFF1E293B),
                      decoration: const InputDecoration(labelText: 'Nuevo estado'),
                      style: const TextStyle(color: Colors.white),
                      items: validStatuses.map((st) {
                        return DropdownMenuItem(value: st, child: Text(st.cleanStatus()));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => selectedStatus = val);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Notas de Resolución (Opcional)',
                        hintText: 'Escribe detalles de la resolución...',
                        hintStyle: TextStyle(color: Colors.white30),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar', style: TextStyle(color: Colors.white60)),
            ),
            FilledButton(
              onPressed: () async {
                try {
                  await provider.updateTicketStatus(
                    ticket.id,
                    selectedStatus,
                    resolutionNotes: notesController.text,
                  );
                  if (ctx.mounted) Navigator.of(ctx).pop();
                } catch (e) {
                  if (ctx.mounted) showMessage(ctx, e.toString());
                }
              },
              child: const Text('Actualizar'),
            ),
          ],
        );
      },
    ).then((_) {
      notesController.dispose();
      if (mounted) {
        _pollingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
          if (mounted) {
            // ✅ CAMBIO: Usar .read() en lugar de .of() para no suscribirse a cambios en el timer
            final provider = AppStateProvider.read<AdminProvider>(context);
            provider.loadTickets();
          }
        });
      }
    });
  }
 
  @override
  Widget build(BuildContext context) {
    final adminProvider = AppStateProvider.read<AdminProvider>(context);
 
    return AppPage(
      title: 'Tickets Soporte',
      subtitle: 'Monitoreo de Averías (Polling 30s)',
      actions: [
        IconButton(
          tooltip: 'Forzar Recarga',
          icon: const Icon(Icons.refresh, color: Color(0xFF2DD4BF)),
          onPressed: () => adminProvider.loadTickets(),
        ),
      ],
      child: RefreshIndicator(
        onRefresh: () => adminProvider.loadTickets(),
        child: ListenableBuilder(
          listenable: adminProvider,
          builder: (context, _) {
            if (adminProvider.isLoading && adminProvider.tickets.isEmpty) {
              return const LoadingWidget(message: 'Cargando todos los tickets...');
            }
 
            if (adminProvider.errorMessage != null) {
              return ErrorState(
                error: adminProvider.errorMessage!,
                onRetry: () => adminProvider.loadTickets(),
              );
            }
 
            if (adminProvider.tickets.isEmpty) {
              return const EmptyState(
                text: 'No hay tickets de soporte reportados.',
                icon: Icons.support_agent_outlined,
              );
            }
 
            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: adminProvider.tickets.length,
              itemBuilder: (context, index) {
                final ticket = adminProvider.tickets[index];
                final statusColor = _getStatusColor(ticket.status);
 
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GlassContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                ticket.subject.isNotEmpty ? ticket.subject : ticket.category.cleanStatus(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            InkWell(
                              onTap: () => _showStatusDialog(context, adminProvider, ticket),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      ticket.status.cleanStatus(),
                                      style: TextStyle(
                                        color: statusColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(Icons.edit_outlined, size: 10, color: statusColor),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                ticket.type.toUpperCase(),
                                style: const TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              ticket.category.cleanStatus(),
                              style: const TextStyle(color: Colors.white60, fontSize: 12),
                            ),
                            const Spacer(),
                            Text(
                              'Prioridad: ${ticket.priority.toUpperCase()}',
                              style: TextStyle(
                                color: ticket.priority.toLowerCase() == 'high'
                                    ? Colors.redAccent
                                    : ticket.priority.toLowerCase() == 'medium'
                                        ? Colors.orangeAccent
                                        : Colors.greenAccent,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Divider(color: Colors.white10, height: 16),
                        Text(
                          ticket.description,
                          style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                        ),
                        if (ticket.createdAt.isNotEmpty) ...
[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              'Creado: ${ticket.createdAt.split('T')[0]}',
                              style: const TextStyle(color: Colors.white30, fontSize: 10),
                            ),
                          ),
                        ],
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