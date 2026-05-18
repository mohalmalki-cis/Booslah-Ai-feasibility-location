import 'package:flutter/material.dart';

/// انتقالات مخصصة للصفحات — الأسبوع الثامن
/// استخدام: Navigator.push(context, AppPageRoute(builder: (_) => MyScreen()))

// ─── Slide من اليمين (RTL) ────────────────────────────────────────────────
class AppPageRoute<T> extends PageRouteBuilder<T> {
  final WidgetBuilder builder;

  AppPageRoute({required this.builder})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Slide من اليمين
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;

            final tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            final fadeTween = Tween<double>(begin: 0.0, end: 1.0).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: FadeTransition(
                opacity: animation.drive(fadeTween),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 350),
          reverseTransitionDuration: const Duration(milliseconds: 300),
        );
}

// ─── Fade + Scale (للنوافذ المنبثقة والداشبورد) ──────────────────────────
class FadeScalePageRoute<T> extends PageRouteBuilder<T> {
  final WidgetBuilder builder;

  FadeScalePageRoute({required this.builder})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final fadeTween = Tween<double>(begin: 0.0, end: 1.0).chain(
              CurveTween(curve: Curves.easeOut),
            );

            final scaleTween = Tween<double>(begin: 0.92, end: 1.0).chain(
              CurveTween(curve: Curves.easeOutCubic),
            );

            return FadeTransition(
              opacity: animation.drive(fadeTween),
              child: ScaleTransition(
                scale: animation.drive(scaleTween),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
          reverseTransitionDuration: const Duration(milliseconds: 300),
        );
}
