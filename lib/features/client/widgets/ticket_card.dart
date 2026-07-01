import 'package:flutter/material.dart';
import 'package:aeronet_app_flutter/data/models/ticket_model.dart';
import 'package:aeronet_app_flutter/shared/widgets/glass_container.dart';
import 'package:aeronet_app_flutter/shared/extensions/string_extensions.dart';
import 'package:aeronet_app_flutter/shared/widgets/status_badge.dart';
import 'package:aeronet_app_flutter/shared/widgets/icon_container.dart';
import 'package:aeronet_app_flutter/core/theme/app_theme.dart';

class TicketCard extends StatelessWidget {
  const TicketCard({super.key, required this.ticket});

  final TicketModel ticket;

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return AppTheme.errorColor; // Coral (Error/High)
      case 'medium':
        return AppTheme.alertColor; // Ámbar (Alerta/Medium)
      case 'low':
      default:
        return AppTheme.accentColor; // Menta (Positivo/Low)
    }
  }

  StatusType _getStatusType(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
      case 'closed':
        return StatusType.active;
      case 'in_progress':
      case 'assigned':
        return StatusType.pending;
      case 'open':
      default:
        return StatusType.neutral;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'facturacion':
        return Icons.receipt_long_outlined;
      case 'nuevo_servicio':
      case 'traslado':
        return Icons.add_location_alt_outlined;
      case 'reclamo':
      case 'suspension':
        return Icons.report_problem_outlined;
      case 'mejora_plan':
        return Icons.speed_outlined;
      default:
        return Icons.support_agent_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusType = _getStatusType(ticket.status);
    final priorityColor = _getPriorityColor(ticket.priority);
    final categoryIcon = _getCategoryIcon(ticket.category);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icono de categoría translúcido
                IconContainer(
                  icon: categoryIcon,
                  color: priorityColor,
                ),
                const SizedBox(width: 12),
                Expanded(
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
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimaryColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          StatusBadge(
                            label: ticket.status.cleanStatus().toUpperCase(),
                            type: statusType,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppTheme.borderDividerColor),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              ticket.category.cleanStatus(),
                              style: const TextStyle(
                                color: AppTheme.textSecondaryColor,
                                fontSize: 10,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: priorityColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            ticket.priority.toLowerCase() == 'high'
                                ? 'Prioridad Alta'
                                : ticket.priority.toLowerCase() == 'medium'
                                    ? 'Prioridad Media'
                                    : 'Prioridad Baja',
                            style: TextStyle(
                              color: priorityColor,
                              fontSize: 11,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (ticket.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(color: AppTheme.borderDividerColor, height: 1.0),
              const SizedBox(height: 12),
              Text(
                ticket.description,
                style: const TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 13,
                  fontFamily: 'Inter',
                  height: 1.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (ticket.createdAt.isNotEmpty) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  ticket.createdAt.split('T')[0],
                  style: const TextStyle(
                    color: AppTheme.textTertiaryColor,
                    fontSize: 10,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
