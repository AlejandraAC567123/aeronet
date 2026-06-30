import 'package:flutter/material.dart';
import 'package:aeronet_app_flutter/data/models/service_model.dart';
import 'package:aeronet_app_flutter/shared/widgets/glass_container.dart';
import 'package:aeronet_app_flutter/shared/extensions/string_extensions.dart';
import 'package:aeronet_app_flutter/shared/widgets/signal_indicator.dart';

class ServiceCard extends StatelessWidget {
  const ServiceCard({super.key, required this.service});

  final ServiceModel service;

  @override
  Widget build(BuildContext context) {
    final plan = service.plan;
    final hasCoordinates = service.latitude != null && service.longitude != null;
    final isActivo = service.status.toLowerCase() == 'activo' || service.status.toLowerCase() == 'active';
    
    final statusColor = isActivo ? const Color(0xFF4FE6C4) : const Color(0xFFFFB454); // Menta o Ámbar

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
                      color: Color(0xFFF2F4FA),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withOpacity(0.2), width: 1.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isActivo) ...[
                        const SignalIndicator(activeBars: 4, size: 10),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        service.status.cleanStatus().toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (plan != null) ...[
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4FE6C4).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.speed_outlined, size: 18, color: Color(0xFF4FE6C4)),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Velocidad de bajada',
                        style: TextStyle(color: Color(0xFF8C92AE), fontSize: 11, fontFamily: 'Inter'),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${plan.speedMbps} Mbps',
                        style: const TextStyle(
                          color: Color(0xFFF2F4FA),
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
            const Divider(color: Color(0xFF2B3150), height: 1.0),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8C92AE).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.home_outlined, size: 18, color: Color(0xFF8C92AE)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dirección de instalación',
                        style: TextStyle(color: Color(0xFF8C92AE), fontSize: 11, fontFamily: 'Inter'),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        service.address,
                        style: const TextStyle(
                          color: Color(0xFFF2F4FA),
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
                            color: Color(0xFF8C92AE),
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
                  const Icon(Icons.pin_drop_outlined, size: 14, color: Color(0xFF5C6280)),
                  const SizedBox(width: 6),
                  Text(
                    'GPS: ${service.latitude!.toStringAsFixed(5)}, ${service.longitude!.toStringAsFixed(5)}',
                    style: const TextStyle(
                      color: Color(0xFF5C6280),
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
