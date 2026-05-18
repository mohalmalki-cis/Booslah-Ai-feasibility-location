import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class BackgroundWidget extends StatelessWidget {
  final Widget child;

  const BackgroundWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isDark) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0F172A)],
          ),
        ),
        child: child,
      );
    }

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AppConstants.backgroundImage),
          fit: BoxFit.cover,
        ),
      ),
      child: child,
    );
  }
}
