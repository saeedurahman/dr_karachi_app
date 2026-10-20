import 'package:flutter/material.dart';

/// Animated count-up text widget matching website StatCountUp.
/// Respects user reduce-motion settings (disableAnimations).
/// Animates smoothly to [target] with comma formatting and optional [suffix].
class StatCountUpText extends StatefulWidget {
  final int target;
  final String suffix;
  final String prefix;
  final Duration duration;
  final TextStyle? style;

  const StatCountUpText({
    super.key,
    required this.target,
    this.suffix = '+',
    this.prefix = '',
    this.duration = const Duration(milliseconds: 1400),
    this.style,
  });

  @override
  State<StatCountUpText> createState() => _StatCountUpTextState();
}

class _StatCountUpTextState extends State<StatCountUpText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = IntTween(begin: 0, end: widget.target).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
      if (reduceMotion) {
        _controller.value = 1.0;
      } else {
        _controller.forward();
      }
    }
  }

  @override
  void didUpdateWidget(StatCountUpText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.target != widget.target) {
      _animation = IntTween(
        begin: _animation.value,
        end: widget.target,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final val = _animation.value;
        return Text(
          '${widget.prefix}${_formatNumber(val)}${widget.suffix}',
          style: widget.style,
        );
      },
    );
  }
}
