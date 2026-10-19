import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 3D Cube Flip Rotating Carousel with auto-play, touch pause, and animated dots
class AutoRotatingCarousel extends StatefulWidget {
  const AutoRotatingCarousel({
    super.key,
    required this.cards,
    required this.accentColors,
    this.height = 152,
    this.autoPlayInterval = const Duration(seconds: 4),
    this.showDots = true,
    this.dotsSpacing = 12,
    this.onPageChanged,
  }) : assert(
          cards.length == accentColors.length,
          'accentColors length must match cards length',
        );

  final List<Widget> cards;
  final List<Color> accentColors;
  final double height;
  final Duration autoPlayInterval;
  final bool showDots;
  final double dotsSpacing;
  final ValueChanged<int>? onPageChanged;

  @override
  State<AutoRotatingCarousel> createState() => _AutoRotatingCarouselState();
}

class _AutoRotatingCarouselState extends State<AutoRotatingCarousel> {
  late final PageController _pageController;
  Timer? _autoPlayTimer;

  int get _count => widget.cards.length;

  @override
  void initState() {
    super.initState();
    // Infinite loop starting offset
    final start = _count > 0 ? (100000 - (100000 % _count)) : 0;
    _pageController = PageController(initialPage: start, viewportFraction: 1);
    if (_count > 1) _startAutoPlay();
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(widget.autoPlayInterval, (_) {
      if (!_pageController.hasClients) return;
      _pageController.nextPage(
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  void _pauseAutoPlay() => _autoPlayTimer?.cancel();

  void _resumeAutoPlay() {
    if (_count > 1) _startAutoPlay();
  }

  double _currentPageValue() {
    if (_pageController.hasClients &&
        _pageController.position.haveDimensions) {
      return _pageController.page ?? _pageController.initialPage.toDouble();
    }
    return _pageController.initialPage.toDouble();
  }

  void _goToDot(int index) {
    if (_count == 0) return;
    final current = _currentPageValue().round();
    final currentMod = current % _count;
    final target = current + (index - currentMod);
    _pauseAutoPlay();
    _pageController.animateToPage(
      target,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
    _resumeAutoPlay();
  }

  @override
  Widget build(BuildContext context) {
    if (_count == 0) return const SizedBox.shrink();
    if (_count == 1) {
      return SizedBox(height: widget.height, child: widget.cards.first);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: widget.height,
          child: Listener(
            // Touch pause and resume
            onPointerDown: (_) => _pauseAutoPlay(),
            onPointerUp: (_) => _resumeAutoPlay(),
            onPointerCancel: (_) => _resumeAutoPlay(),
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                if (_count > 0) {
                  widget.onPageChanged?.call(index % _count);
                }
              },
              itemBuilder: (context, index) {
                final card = widget.cards[index % _count];
                return AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) => _CubeTransform(
                    index: index,
                    page: _currentPageValue(),
                    child: child!,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: card,
                  ),
                );
              },
            ),
          ),
        ),
        if (widget.showDots) ...[
          SizedBox(height: widget.dotsSpacing),
          // Dots indicators
          AnimatedBuilder(
            animation: _pageController,
            builder: (context, _) {
              final activeIndex = _currentPageValue().round() % _count;
              return Wrap(
                alignment: WrapAlignment.center,
                children: List.generate(_count, (i) {
                  final isActive = i == activeIndex;
                  final dotColor = widget.accentColors[i];
                  return GestureDetector(
                    onTap: () => _goToDot(i),
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOut,
                      margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                      height: 6,
                      width: isActive ? 22 : 6,
                      decoration: BoxDecoration(
                        color: isActive ? dotColor : dotColor.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: dotColor.withValues(alpha: 0.45),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ],
    );
  }
}

/// 3D Cube flip, scale and perspective transform
class _CubeTransform extends StatelessWidget {
  const _CubeTransform({
    required this.index,
    required this.page,
    required this.child,
  });

  final int index;
  final double page;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final delta = (page - index).clamp(-1.0, 1.0);
    final rotationY = delta * (math.pi / 2) * 0.85;
    final alignment = delta >= 0 ? Alignment.centerRight : Alignment.centerLeft;
    final scale = 1.0 - delta.abs() * 0.16;
    final opacity = (1.0 - delta.abs() * 0.6).clamp(0.0, 1.0);

    return Opacity(
      opacity: opacity,
      child: Transform(
        alignment: alignment,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.0018) // 3D Perspective depth
          ..rotateY(rotationY) // Y-axis 3D rotation
          ..scaleByDouble(scale, scale, 1.0, 1.0),
        child: child,
      ),
    );
  }
}
