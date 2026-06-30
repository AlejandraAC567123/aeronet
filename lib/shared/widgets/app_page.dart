import 'package:flutter/material.dart';

class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.actions = const [],
    this.drawer,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final List<Widget> actions;
  final Widget? drawer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: drawer,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w800,
                color: Color(0xFFF2F4FA),
                fontSize: 22,
                letterSpacing: 0.5,
              ),
            ),
            if (subtitle.isNotEmpty)
              Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  color: Color(0xFF8C92AE),
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        actions: actions,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFF10131F), // Fondo principal sólido
        child: SafeArea(child: child),
      ),
    );
  }
}
