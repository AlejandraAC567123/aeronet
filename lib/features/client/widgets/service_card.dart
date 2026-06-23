import 'package:flutter/material.dart';
import 'package:aeronet_app_flutter/data/models/service_model.dart';
import 'package:aeronet_app_flutter/shared/widgets/glass_container.dart';
import 'package:aeronet_app_flutter/shared/extensions/string_extensions.dart';

class ServiceCard extends StatelessWidget {
  const ServiceCard({super.key, required this.service});

  final ServiceModel service;

  @override
  Widget build(BuildContext context) {
    final plan = service.plan;
    final hasCoordinates = service.latitude != null && service.longitude != null;

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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2DD4BF).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    service.status.cleanStatus(),
                    style: const TextStyle(
                      color: Color(0xFF2DD4BF),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (plan != null) ...[
              Row(
                children: [
                  const Icon(Icons.arrow_downward, size: 16, color: Color(0xFF2DD4BF)),
                  const SizedBox(width: 4),
                  Text('${plan.downloadSpeed} Mbps Bajada', style: const TextStyle(color: Colors.white70)),
                  const SizedBox(width: 16),
                  const Icon(Icons.arrow_upward, size: 16, color: Color(0xFF2DD4BF)),
                  const SizedBox(width: 4),
                  Text('${plan.uploadSpeed} Mbps Subida', style: const TextStyle(color: Colors.white70)),
                ],
              ),
              const SizedBox(height: 12),
            ],
            const Divider(color: Colors.white10),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.home_outlined, size: 20, color: Color(0xFF2DD4BF)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.address,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                      if (service.reference != null && service.reference!.isNotEmpty)
                        Text(
                          'Ref: ${service.reference}',
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (hasCoordinates) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.pin_drop_outlined, size: 18, color: Colors.white38),
                  const SizedBox(width: 8),
                  Text(
                    'GPS: ${service.latitude!.toStringAsFixed(5)}, ${service.longitude!.toStringAsFixed(5)}',
                    style: const TextStyle(color: Colors.white54, fontSize: 12, fontFamily: 'monospace'),
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
