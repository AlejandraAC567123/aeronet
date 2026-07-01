import 'package:flutter/material.dart';
import 'package:aeronet_app_flutter/data/models/service_model.dart';
import 'package:aeronet_app_flutter/shared/widgets/glass_container.dart';
import 'package:aeronet_app_flutter/shared/extensions/string_extensions.dart';
import 'package:aeronet_app_flutter/shared/widgets/signal_indicator.dart';
import 'package:aeronet_app_flutter/shared/widgets/status_badge.dart';
import 'package:aeronet_app_flutter/shared/widgets/icon_container.dart';
import 'package:aeronet_app_flutter/core/theme/app_theme.dart';

class ServiceCard extends StatelessWidget {
  const ServiceCard({super.key, required this.service});

  final ServiceModel service;

  @override
  Widget build(BuildContext context) {
    final plan = service.plan;
    final hasCoordinates = service.latitude != null && service.longitude != null;
    final isActivo = service.status.toLowerCase() == 'activo' || service.status.toLowerCase() == 'active';
    
    StatusType statusType;
    switch (service.status.toLowerCase()) {
      case 'activo':
      case 'active':
        statusType = StatusType.active;
        break;
      case 'pending':
      case 'pendiente':
        statusType = StatusType.pending;
        break;
      default:
        statusType = StatusType.neutral;
    }

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
                    plan?.name ?? 'Servicio de Internet',
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                ),
                Row(
                  children: [
                    if (isActivo) ...[
                      const SignalIndicator(activeBars: 4, size: 10),
                      const SizedBox(width: 8),
                    ],
                    StatusBadge(
                      label: service.status.cleanStatus().toUpperCase(),
                      type: statusType,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (plan != null) ...[
              Row(
                children: [
                  const IconContainer(
                    icon: Icons.speed_outlined,
                    color: AppTheme.accentColor,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Velocidad de bajada',
                        style: TextStyle(color: AppTheme.textSecondaryColor, fontSize: 11, fontFamily: 'Inter'),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${plan.speedMbps} Mbps',
                        style: const TextStyle(
                          color: AppTheme.textPrimaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            const Divider(color: AppTheme.borderDividerColor, height: 1.0),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const IconContainer(
                  icon: Icons.home_outlined,
                  color: AppTheme.textSecondaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dirección de instalación',
                        style: TextStyle(color: AppTheme.textSecondaryColor, fontSize: 11, fontFamily: 'Inter'),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        service.address.isEmpty ? 'No registrada' : service.address,
                        style: const TextStyle(
                          color: AppTheme.textPrimaryColor,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Inter',
                          fontSize: 13,
                        ),
                      ),
                      if (service.reference != null && service.reference!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Referencia: ${service.reference}',
                          style: const TextStyle(
                            color: AppTheme.textSecondaryColor,
                            fontSize: 12,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (hasCoordinates) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const SizedBox(width: 42),
                  const Icon(Icons.pin_drop_outlined, size: 14, color: AppTheme.textTertiaryColor),
                  const SizedBox(width: 6),
                  Text(
                    'GPS: ${service.latitude!.toStringAsFixed(5)}, ${service.longitude!.toStringAsFixed(5)}',
                    style: const TextStyle(
                      color: AppTheme.textTertiaryColor,
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
