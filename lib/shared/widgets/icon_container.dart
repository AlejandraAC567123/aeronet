import 'package:flutter/material.dart';

class IconContainer extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final double padding;

  const IconContainer({
    super.key,
    required this.icon,
    required this.color,
    this.size = 20.0,
    this.padding = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10), // Rounded square
      ),
      child: Icon(icon, size: size, color: color),
    );
  }
}
