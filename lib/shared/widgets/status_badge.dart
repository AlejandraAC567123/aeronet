import 'package:flutter/material.dart';
import 'package:aeronet_app_flutter/core/theme/app_theme.dart';

enum StatusType {
  active,   // Turquoise: active, completed, paid
  pending,  // Amber: pending, in progress, assigned
  error,    // Coral: overdue, error
  neutral   // Gray: open, review, default
}

class StatusBadge extends StatelessWidget {
  final String label;
  final StatusType type;

  const StatusBadge({
    super.key,
    required this.label,
    this.type = StatusType.neutral,
  });

  Color _getColor() {
    switch (type) {
      case StatusType.active:
        return AppTheme.accentColor; // Turquoise
      case StatusType.pending:
        return AppTheme.alertColor;  // Amber
      case StatusType.error:
        return AppTheme.errorColor;  // Coral
      case StatusType.neutral:
        return AppTheme.textSecondaryColor; // Gray
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(50), // Full rounded pill
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
