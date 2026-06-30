import 'package:flutter/material.dart';

class SignalIndicator extends StatelessWidget {
  const SignalIndicator({
    super.key,
    this.activeBars = 4,
    this.size = 18,
    this.activeColor = const Color(0xFF4FE6C4),
    this.inactiveColor = const Color(0xFF5C6280),
  });

  final int activeBars;
  final double size;
  final Color activeColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(4, (index) {
        final isActive = index < activeBars;
        // Altura creciente proporcional al tamaño base
        final height = size * (0.3 + 0.23 * index);
        final width = size * 0.22;
        
        return Container(
          width: width,
          height: height,
          margin: EdgeInsets.only(left: size * 0.08),
          decoration: BoxDecoration(
            color: isActive ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(width / 2),
          ),
        );
      }),
    );
  }
}
