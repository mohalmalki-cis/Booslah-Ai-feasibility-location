import 'package:flutter/material.dart';

/// ويدجت أنيميشن ظهور الكروت — الأسبوع الثامن
/// يُنزلق العنصر من الأسفل أو اليمين مع Fade
///
/// مثال:
///   FadeSlideWidget(
///     delay: Duration(milliseconds: 200),
///     child: MyCard(),
///   )

class FadeSlideWidget extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset beginOffset;

  const FadeSlideWidget({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 450),
    this.beginOffset = const Offset(0, 0.12), // من الأسفل قليلاً
  });

  @override
  State<FadeSlideWidget> createState() => _FadeSlideWidgetState();
}

class _FadeSlideWidgetState extends State<FadeSlideWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _offset = Tween<Offset>(
      begin: widget.beginOffset,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    // ابدأ بعد الـ delay
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _offset,
        child: widget.child,
      ),
    );
  }
}

/// ويدجت يُكرر الأنيميشن على قائمة من العناصر بتأخير متدرج
class StaggeredList extends StatelessWidget {
  final List<Widget> children;
  final Duration itemDelay;
  final Duration itemDuration;

  const StaggeredList({
    super.key,
    required this.children,
    this.itemDelay = const Duration(milliseconds: 80),
    this.itemDuration = const Duration(milliseconds: 400),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(children.length, (i) {
        return FadeSlideWidget(
          delay: itemDelay * i,
          duration: itemDuration,
          child: children[i],
        );
      }),
    );
  }
}
