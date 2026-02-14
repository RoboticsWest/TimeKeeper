import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Creates an animated infinite list which scrolls forever horizontally.
///
/// Uses a paint-only Transform.translate approach instead of scrollController.jumpTo()
/// to avoid triggering expensive layout passes every frame.
class AnimatedInfiniteHorizontalList extends HookConsumerWidget {
  final List<Widget> children;
  final double childWidth;
  final int scrollSpeedMs;

  const AnimatedInfiniteHorizontalList({
    super.key,
    required this.children,
    required this.childWidth,
    this.scrollSpeedMs = 2000,
  });

  double _getChildrenTotalWidth() {
    return children.length * childWidth;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;

        if (children.isNotEmpty && availableWidth < _getChildrenTotalWidth()) {
          return _InfiniteScrolling(
            items: children,
            childWidth: childWidth,
            scrollSpeedMs: scrollSpeedMs,
          );
        } else {
          // Static normal list — fits on screen
          return ScrollConfiguration(
            behavior: ScrollConfiguration.of(
              context,
            ).copyWith(scrollbars: false),
            child: CustomScrollView(
              scrollDirection: Axis.horizontal,
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return RepaintBoundary(
                      child: children.elementAtOrNull(index),
                    );
                  }, childCount: children.length),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

class _InfiniteScrolling extends HookWidget {
  final List<Widget> items;
  final double childWidth;
  final int scrollSpeedMs;

  const _InfiniteScrolling({
    required this.items,
    required this.childWidth,
    required this.scrollSpeedMs,
  });

  @override
  Widget build(BuildContext context) {
    final totalWidth = items.length * childWidth;
    final duration = Duration(
      milliseconds: (items.isEmpty ? 1 : items.length) * scrollSpeedMs,
    );
    final animationController = useAnimationController(duration: duration);

    useEffect(() {
      Future.delayed(const Duration(seconds: 2), () {
        if (context.mounted) {
          animationController.repeat();
        }
      });
      return null;
    }, [items.length]);

    final row = RepaintBoundary(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final item in items) SizedBox(width: childWidth, child: item),
          for (final item in items) SizedBox(width: childWidth, child: item),
        ],
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          child: ClipRect(
            child: OverflowBox(
              maxWidth: totalWidth * 2,
              alignment: Alignment.centerLeft,
              child: AnimatedBuilder(
                animation: animationController,
                builder: (context, child) {
                  final offset = animationController.value * totalWidth;
                  return Transform.translate(
                    offset: Offset(-offset, 0),
                    child: child,
                  );
                },
                child: row,
              ),
            ),
          ),
        );
      },
    );
  }
}
