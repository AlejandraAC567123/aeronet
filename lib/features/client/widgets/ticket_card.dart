import 'package:flutter/material.dart';
import 'package:aeronet_app_flutter/data/models/ticket_model.dart';
import 'package:aeronet_app_flutter/shared/widgets/glass_container.dart';
import 'package:aeronet_app_flutter/shared/extensions/string_extensions.dart';

class TicketCard extends StatelessWidget {
  const TicketCard({super.key, required this.ticket});

  final TicketModel ticket;

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.redAccent;
      case 'medium':
        return Colors.orangeAccent;
      case 'low':
      default:
        return Colors.greenAccent;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
      case 'closed':
        return const Color(0xFF2DD4BF); // Teal
      case 'in_progress':
      case 'assigned':
        return Colors.yellowAccent;
      case 'open':
      default:
        return Colors.cyanAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(ticket.status);
    final priorityColor = _getPriorityColor(ticket.priority);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
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
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    ticket.status.cleanStatus(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
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
                    border: Border.all(color: Colors.white24),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    ticket.category.cleanStatus(),
                    style: const TextStyle(color: Colors.white60, fontSize: 11),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: priorityColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  ticket.priority.toLowerCase() == 'high'
                      ? 'Prioridad Alta'
                      : ticket.priority.toLowerCase() == 'medium'
                          ? 'Prioridad Media'
                          : 'Prioridad Baja',
                  style: TextStyle(color: priorityColor, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            if (ticket.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(color: Colors.white10),
              const SizedBox(height: 8),
              Text(
                ticket.description,
                style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (ticket.createdAt.isNotEmpty) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  ticket.createdAt.split('T')[0],
                  style: const TextStyle(color: Colors.white30, fontSize: 10),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
